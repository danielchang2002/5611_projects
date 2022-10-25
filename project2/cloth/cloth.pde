import java.awt.Robot;

// set constants
String WINDOW_TITLE = "Swinging cloth";
Camera camera;
Robot robot;
PImage crosshair;
PImage clothTexture;
PShader nebula;
PImage earth;
PShape sphere;
float texture_w;
float texture_h;

int numUpdatesPerDraw = 40;

int rows = 50;
int cols = 50;
int radius = 10;
float rest_len = 5;
float rip_len = rest_len * 6;
float k_s = 3000; // spring constant
float k_d = 400;
float friction = 0.5;
float startX = 100;
float startY = 200;
float startZ = 0;
float dist_between_nodes = rest_len;
Vec3 obstaclePosition = new Vec3(340, 335, -115);
Vec3 obstacleVelocity = new Vec3(0, 0, 0);
float obstacleRadius = 100;
float obstacleDistFromCamera = 1000;
float COR = 0.0;
float gravity = 300;

Vec3[][] pos = new Vec3[rows][cols];
Vec3[][] vel = new Vec3[rows][cols];
Vec3[][] acc = new Vec3[rows][cols];
boolean[][] ripped_vert;
boolean[][] ripped_hor;

void setup() {
  fullScreen(P3D);
  // size(1792, 1120, P3D);
  surface.setTitle(WINDOW_TITLE);
  noStroke();
  noCursor();
  initScene();
  crosshair = loadImage("crosshair.png");
  clothTexture = loadImage("Big-Goldy-Face.jpg");
  earth = loadImage("earth.jpeg");
  texture_w = clothTexture.width / cols;
  texture_h = clothTexture.height / rows;
  try {
    robot = new Robot();
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  camera = new Camera();

  sphere = createShape(SPHERE, obstacleRadius); 
  sphere.setTexture(earth);

  nebula = loadShader("nebula.glsl");
  nebula.set("resolution", float(width), float(height));
}
void initScene(){

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      pos[i][j] = new Vec3(
        startX + i * dist_between_nodes,
        startY,
        startZ - j * dist_between_nodes
        );
      vel[i][j] = new Vec3(0, 0, 0);
      acc[i][j] = new Vec3(0, 0, 0);
    }
  }
  ripped_vert = new boolean[rows - 1][cols];
  ripped_hor = new boolean[rows][cols - 1];
}

void checkCollision() {
  // collision detection and response
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      float d = obstaclePosition.minus(pos[i][j]).length();

      if (d < obstacleRadius + radius) {
        Vec3 n = pos[i][j].minus(obstaclePosition);
        Vec3 norm = n.normalized();
        Vec3 bounce = norm.times(dot(vel[i][j], norm));
        vel[i][j].subtract(bounce.times(1 + COR));
        pos[i][j] = obstaclePosition.plus(norm.times(obstacleRadius + radius)).times(1.01);
      }
    }
  }
}

void update(float dt) {

  // update obstacle position

  if (mousePressed) {
    obstaclePosition.x = camera.position.x + camera.forwardDir.x * obstacleDistFromCamera;

    // make sure that obstacle doesn't go above xz plane
    obstaclePosition.y = max(
      camera.position.y + camera.forwardDir.y * obstacleDistFromCamera,
      startY + obstacleRadius + radius + 10
    );

    obstaclePosition.z = camera.position.z + camera.forwardDir.z * obstacleDistFromCamera;
  }

  // reset acceleration
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      acc[i][j].x = 0;
      acc[i][j].y = gravity;
      acc[i][j].z = 0;
    }
  }
  
  // apply horizontal force
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols - 1; j++) {
      if (ripped_hor[i][j]) continue;
      Vec3 displacement = pos[i][j + 1].minus(pos[i][j]);
      float distance = displacement.length();
      if (distance > rip_len) {
        ripped_hor[i][j] = true;
      }
      Vec3 displacement_dir = displacement.normalized();
      float v1 = dot(displacement_dir, vel[i][j]);
      float v2 = dot(displacement_dir, vel[i][j + 1]);
      float f = -k_s * (rest_len - distance) - k_d * (v1 - v2);
      acc[i][j].add(displacement_dir.times(f));
      acc[i][j + 1].subtract(displacement_dir.times(f));
    }
  }

  // apply vertical force
  for (int i = 0; i < rows - 1; i++) {
    for (int j = 0; j < cols; j++) {
      if (ripped_vert[i][j]) continue;
      Vec3 displacement = pos[i + 1][j].minus(pos[i][j]);
      float distance = displacement.length();
      if (distance > rip_len) {
        ripped_vert[i][j] = true;
      }
      Vec3 displacement_dir = displacement.normalized();
      float v1 = dot(displacement_dir, vel[i][j]);
      float v2 = dot(displacement_dir, vel[i + 1][j]);
      float f = -k_s * (rest_len - distance) - k_d * (v1 - v2);
      acc[i][j].add(displacement_dir.times(f));
      acc[i + 1][j].subtract(displacement_dir.times(f));
    }
  }

  // fix top
  for (int i = 0; i < cols; i++) {
    acc[0][i].x = 0;
    acc[0][i].y = 0;
    acc[0][i].z = 0;
  }

  // eulerian integration
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      // add "friction"
      acc[i][j].subtract(vel[i][j].times(friction));
      vel[i][j].add(acc[i][j].times(dt));
      pos[i][j].add(vel[i][j].times(dt));
    }
  }
}

boolean paused = true;

void draw() {
  background(255,255,255);

  hint(DISABLE_DEPTH_TEST); //draws on top of whatever is drawn on screen
  camera(); //reset camera to default position, which conveniently lines up with the screen exactly
  // ortho(); //orthographic projection removes any need for the z axis

  nebula.set("time", millis() / 500.0);  
  shader(nebula); 
  rect(0, 0, width, height);
  hint(ENABLE_DEPTH_TEST);

  camera.Update(1.0/(frameRate));

  if (!paused) {
    for (int i = 0; i < numUpdatesPerDraw * 2; i++) {
      update(1.0/(numUpdatesPerDraw * frameRate));
    }
    checkCollision();
  }

  // directionalLight(150, 250, 150, -40, 120, -200);
  directionalLight(255, 255, 255, -100, 120, 0);



  // draw cloth
  for (int i = 0 ; i < rows; i++) {
    for (int j = 0; j < cols; j++) {

      if (i != rows - 1 && j != cols - 1) {

        Vec3 topLeft = pos[i][j];
        Vec3 topRight = pos[i][j + 1];
        Vec3 botLeft = pos[i + 1][j];
        Vec3 botRight = pos[i + 1][j + 1];

        

        float top_left_x = j * texture_w;
        float top_left_y = i * texture_h;


        Vec3 topLeftNormal = getNormal(i, j);
        Vec3 botRightNormal = getNormal(i + 1, j + 1);

        // draw first triangle
        if (!ripped_hor[i][j] && !ripped_vert[i][j + 1]) {
          pushMatrix();
          beginShape();

          texture(clothTexture);

          normal(topLeftNormal.x, topLeftNormal.y, topLeftNormal.z);
          vertex(topLeft.x, topLeft.y, topLeft.z, top_left_x, top_left_y);

          Vec3 topRightNormal = getNormal(i, j + 1);
          normal(topRightNormal.x, topRightNormal.y, topRightNormal.z);
          vertex(topRight.x, topRight.y, topRight.z, top_left_x + texture_w, top_left_y);

          normal(botRightNormal.x, botRightNormal.y, botRightNormal.z);
          vertex(botRight.x, botRight.y, botRight.z, top_left_x + texture_w, top_left_y + texture_h);

          endShape();
          popMatrix();

        }

        // draw second
        if (!ripped_vert[i][j] && !ripped_hor[i + 1][j]) {
          pushMatrix();
          beginShape();

          texture(clothTexture);

          normal(botRightNormal.x, botRightNormal.y, botRightNormal.z);
          vertex(botRight.x, botRight.y, botRight.z, top_left_x + texture_w, top_left_y + texture_h);

          Vec3 botLeftNormal = getNormal(i + 1, j);
          normal(botLeftNormal.x, botLeftNormal.y, botLeftNormal.z);
          vertex(botLeft.x, botLeft.y, botLeft.z, top_left_x, top_left_y + texture_h);

          normal(topLeftNormal.x, topLeftNormal.y, topLeftNormal.z);
          vertex(topLeft.x, topLeft.y, topLeft.z, top_left_x, top_left_y);

          endShape();
          popMatrix();
        }
      }
    }

  }

  fill(255, 0, 0);

  // draw obstacle
  pushMatrix();
  translate(obstaclePosition.x, obstaclePosition.y, obstaclePosition.z);
  shape(sphere);
  popMatrix();

  drawCrossHairs();
  if (paused)
    surface.setTitle(WINDOW_TITLE + " [PAUSED]");
  else
    surface.setTitle(WINDOW_TITLE + " "+ nf(frameRate,0,2) + "FPS");

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

Vec3 getNormal(int i, int j) {
  if (i != 0 && j != 0) {
    return cross(pos[i][j].minus(pos[i - 1][j]), pos[i][j - 1].minus(pos[i][j])).normalized();
  }
  if (i == 0 && j == 0) {
    return cross(pos[i][j].minus(pos[i + 1][j]), pos[i][j + 1].minus(pos[i][j])).normalized();
  }
  if (i == 0) {
    return cross(pos[i + 1][j].minus(pos[i][j]), pos[i][j - 1].minus(pos[i][j])).normalized();
  }
  if (j == 0) {
    return cross(pos[i][j].minus(pos[i - 1][j]), pos[i][j].minus(pos[i][j + 1])).normalized();
  }
  return null;
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