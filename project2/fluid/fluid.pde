String WINDOW_TITLE = "Shallow Water";

int cells = 40;
float dx = width / (cells * 1.0);
int numUpdatesPerDraw = 100;
float g = 1;
float damp = 0.9;

float[] h = new float[cells];
float[] hu = new float[cells];

float[] dhdt = new float[cells];
float[] dhudt = new float[cells];
float[] h_mid = new float[cells];
float[] hu_mid = new float[cells];
float[] dhdt_mid = new float[cells];
float[] dhudt_mid = new float[cells];


void setup() {
  size(1792, 1120, P2D);
  surface.setTitle(WINDOW_TITLE);
  initScene();
}

void initScene() {
  for (int i = 0; i < cells; i++) {
    h[i] = height / 2 + i * (height / 2) / cells;
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

  for (float test : dhdt) {
    println(test);
  }
  println();

  for (int i = 0; i < cells; i++) {
    h[i] += damp * dhdt[i] * dt;
    hu[i] += damp * dhudt[i] * dt;
  }

  h[0] = h[1];
  h[cells - 1] = h[cells - 2];
  hu[0] = -hu[1];
  hu[cells - 1] = -hu[cells - 2];

  for (float heih : h) {
    println(heih);
  }
  println(count++);
  println();
}

boolean paused = true;

void draw() {
  background(255,255,255);
  if (!paused) {
    for (int i = 0; i < numUpdatesPerDraw; i++) {
      update(1.0/(numUpdatesPerDraw * frameRate));
    }
  }

  // draw water
  fill(0, 0, 255);
  for (int i = 0; i < cells; i++) {
    float waterHeight = h[i];
    rect(i * width / (cells * 1.0), height - waterHeight, width / (cells * 1.0), waterHeight);
  }
}

void keyPressed() {
  if (key == 'p') {
    paused = !paused;
  }
  if (key == 'n') {
    update(1/(frameRate * numUpdatesPerDraw));
  }
}