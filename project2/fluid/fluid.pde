import java.awt.Robot;
PImage crosshair;
Camera camera;
Robot robot;

String WINDOW_TITLE = "Shallow Water";

int cells = 60;

float water_width = 500;
float water_height = 300;
float water_depth = 500;

float dx = water_width / (cells * 1.0);
int numUpdatesPerDraw = 20;
float g = 1;
float damp = 0.1;

float[] h = new float[cells];
float[] hu = new float[cells];

float[] dhdt = new float[cells];
float[] dhudt = new float[cells];
float[] h_mid = new float[cells];
float[] hu_mid = new float[cells];
float[] dhdt_mid = new float[cells];
float[] dhudt_mid = new float[cells];

void setup() {
  size(1792, 1120, P3D);
  // fullScreen(P3D);
  surface.setTitle(WINDOW_TITLE);
  noCursor();
  initScene();
  crosshair = loadImage("crosshair.png");
  try {
    robot = new Robot();
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  camera = new Camera();
}

void initScene() {
  for (int i = 0; i < cells; i++) {
    h[i] = water_height / 2 + sin(i / 10.0) * (water_height / 8);
    hu[i] = 0;
    dhdt[i] = 0;
    dhudt[i] = 0;
    h_mid[i] = 0;
    hu_mid[i] = 0;
    dhdt_mid[i] = 0;
    dhudt_mid[i] = 0;
  }
}

void update(float dt) {
  for (int i = 0; i < cells - 1; i++) {
    h_mid[i] = 0.5 * (h[i] + h[i + 1]);
    hu_mid[i] = 0.5 * (hu[i] + hu[i + 1]);
  }

  for (int i = 0; i < cells - 1; i++) {
    float dhudx_mid = (hu[i + 1] - hu[i]) / dx;
    dhdt_mid[i] = -dhudx_mid;

    float dhu2dx_mid = (pow(hu[i+1], 2) / h[i+1] - pow(hu[i], 2) / h[i]) / dx;
    float dgh2dx_mid = (g * pow(h[i + 1], 2) - pow(h[i], 2)) / dx;
    dhudt_mid[i] = -(dhu2dx_mid + 0.5 * dgh2dx_mid);

  }

  for (int i = 0; i < cells; i++) {
    h_mid[i] += dhdt_mid[i] * dt / 2;
    hu_mid[i] += dhudt_mid[i] * dt / 2;
  }

  for (int i = 1; i < cells - 1; i++) {
    float dhudx = (hu_mid[i] - hu_mid[i - 1])/dx;
    dhdt[i] = -dhudx;

    float dhu2dx = (pow(hu_mid[i], 2) / h_mid[i] - pow(hu_mid[i - 1], 2) / h_mid[i - 1]) / dx;
    float dgh2dx = g * (pow(h_mid[i], 2) - pow(h_mid[i - 1], 2)) / dx;
    dhudt[i] = -(dhu2dx + 0.5 * dgh2dx);
  }

  for (int i = 0; i < cells; i++) {
    h[i] += damp * dhdt[i] * dt;
    hu[i] += damp * dhudt[i] * dt;
  }

  // boundary conditions
  h[0] = h[1];
  h[cells - 1] = h[cells - 2];
  hu[0] = -hu[1];
  hu[cells - 1] = -hu[cells - 2];
}

boolean paused = true;

void draw() {
  camera.Update(1.0/(frameRate));
  background(255,255,255);
  if (!paused) {
    for (int i = 0; i < 100 * numUpdatesPerDraw; i++) {
      update(1.0/(numUpdatesPerDraw * frameRate));
    }
  }

  directionalLight(255, 255, 255, -100, 120, 100);

  pushMatrix();
  noFill();
  stroke(0, 0, 0);
  translate(water_width / 2, water_height / 2, water_depth / 2);
  box(water_width, water_height, water_depth);
  popMatrix();

  // draw water
  fill(0, 0, 255);
  noStroke();
  for (int i = 0; i < cells - 1; i++) {
    float currWaterHeight = h[i];
    float nextWaterHeight = h[i + 1];

    Vec3 one = new Vec3(dx * i, currWaterHeight, water_depth);
    Vec3 two = new Vec3(dx * (i + 1), nextWaterHeight, water_depth);
    Vec3 three = new Vec3(dx * (i + 1), currWaterHeight, 0);

    Vec3 a = two.minus(one);
    Vec3 b = three.minus(two);

    Vec3 n = cross(a, b);

    pushMatrix();
    beginShape();
    normal(n.x, n.y, n.z);
    vertex(dx * i, currWaterHeight, water_depth);
    vertex(dx * (i + 1), nextWaterHeight, water_depth);
    vertex(dx * (i + 1), nextWaterHeight, 0);
    vertex(dx * i, currWaterHeight, 0);
    endShape();
    popMatrix();

    // draw front
    pushMatrix();
    beginShape();
    normal(0, 0, -1);
    vertex(dx * i, currWaterHeight, water_depth);
    vertex(dx * (i + 1), nextWaterHeight, water_depth);
    vertex(dx * (i + 1), water_height, water_depth);
    vertex(dx * i, water_height, water_depth);
    endShape();
    popMatrix();

    // draw back
    pushMatrix();
    beginShape();
    normal(0, 0, 1);
    vertex(dx * i, currWaterHeight, 0);
    vertex(dx * (i + 1), nextWaterHeight, 0);
    vertex(dx * (i + 1), water_height, 0);
    vertex(dx * i, water_height, 0);
    endShape();
    popMatrix();
  }

    // draw left
    pushMatrix();
    beginShape();
    normal(-1, 0, 0);
    vertex(0, h[0], water_depth);
    vertex(0, h[0], 0);
    vertex(0, water_height, 0);
    vertex(0, water_height, water_depth);
    endShape();
    popMatrix();

    // draw right
    pushMatrix();
    beginShape();
    normal(1, 0, 0);
    vertex(dx * (cells - 1), h[cells - 1], water_depth);
    vertex(dx * (cells - 1), h[cells - 1], 0);
    vertex(dx * (cells - 1), water_height, 0);
    vertex(dx * (cells - 1), water_height, water_depth);
    endShape();
    popMatrix();



  if (paused)
    surface.setTitle(WINDOW_TITLE + " [PAUSED]");
  else
    surface.setTitle(WINDOW_TITLE + " "+ nf(frameRate,0,2) + "FPS");

  drawCrossHairs();
}

void keyPressed(){
  camera.HandleKeyPressed();
  if (key == 'p') {
    paused = !paused;
  }
  if (key == 'r') {
    initScene();
  }
}

void keyReleased() {
  camera.HandleKeyReleased();
}

void drawCrossHairs() {

  // draw cross hairs
  hint(DISABLE_DEPTH_TEST); //draws on top of whatever is drawn on screen
  camera(); //reset camera to default position, which conveniently lines up with the screen exactly
  ortho(); //orthographic projection removes any need for the z axis

  beginShape();
  texture(crosshair);
  // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
  float crosshairSize = 25;
  vertex(
    width / 2 - crosshairSize,
    height / 2 - crosshairSize,
    // camera.position.z + camera.forwardDir.z * fromCamera, 
    0, 0
  );
  vertex(
    width / 2 + crosshairSize,
    height / 2 - crosshairSize,
    // camera.position.z + camera.forwardDir.z * fromCamera, 
    crosshair.width, 0
  );
  vertex(
    width / 2 + crosshairSize,
    height / 2 + crosshairSize,
    // camera.position.z + camera.forwardDir.z * fromCamera, 
    crosshair.width, crosshair.height
  );
  vertex(
    width / 2 - crosshairSize,
    height / 2 + crosshairSize,
    // camera.position.z + camera.forwardDir.z * fromCamera, 
    0, crosshair.height
  );
  endShape();
  hint(ENABLE_DEPTH_TEST);



}