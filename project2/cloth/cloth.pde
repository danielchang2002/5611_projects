// set constants
String WINDOW_TITLE = "Swinging cloth";
int WIDTH = 800;
int HEIGHT = 1000;

void setup() {
  size(800, 1000, P3D);
  surface.setTitle(WINDOW_TITLE);
  initScene();
}

int rows = 10;
int cols = 10;
int radius = 5;
float rest_len = 100;
float k_s = 100; // spring constant
float k_d = 50; // damping constant
float friction = 0.5;
float startX = 100;
float startY = 200;
float startZ = 0;
float xRotation = -PI/5;
float addXRotation = 0;
float yRotation = 0;
float addYRotation = 0;
float cameraTransX = -50;
float cameraTransY = -50;
float cameraTransZ = -50;
float dist_between_nodes = rest_len;
Vec3 obstaclePosition = new Vec3(200, 600, -300);
Vec3 obstacleVelocity = new Vec3(0, 0, 0);
float obstacleRadius = 200;
float COR = 0;
float gravity = 200;
int dragIdx = -1;
boolean dragging = false;
boolean dragCamera = false;
float clickX = -1;
float clickY = -1;

Vec3[][] pos = new Vec3[rows][cols];
Vec3[][] vel = new Vec3[rows][cols];
Vec3[][] acc = new Vec3[rows][cols];

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
}

void update(float dt){
  // update obstacle position
  obstaclePosition.add(obstacleVelocity.times(dt));

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
      Vec3 displacement = pos[i][j + 1].minus(pos[i][j]);
      float distance = displacement.length();
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
      Vec3 displacement = pos[i + 1][j].minus(pos[i][j]);
      float distance = displacement.length();
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

  // drag point
  if (dragging) {
    int row = dragIdx / cols;
    int col = dragIdx % cols;
    pos[row][col].x = mouseX;
    pos[row][col].y = mouseY;
  }
  
}

void print_vel() {
  println();
  println();
  println();
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      print(vel[i][j], "");
    }
    println();
  }
  println();
  println();
  println();
}
boolean paused = true;

void draw() {

  // update rotation angles based on mouse
  if (dragCamera) {
    addXRotation = ((mouseY - clickY) / HEIGHT) * PI;
    addYRotation = ((mouseX - clickX) / WIDTH) * PI;
  }

  // rotate camera
  beginCamera();
  camera();
  translate(cameraTransX, cameraTransY, cameraTransZ);
  rotateX(xRotation + addXRotation);
  rotateY(yRotation + addYRotation);
  endCamera();

  background(255,255,255);
  if (!paused) {
    for (int i = 0; i < 40; i++) {
      update(1/(20 * frameRate));
    }
  }
  // fill(0,0,0);

  // draw cloth
  for (int i = 0 ; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      pushMatrix();

      // draw line from top
      if (i != 0) {
        line(
          pos[i - 1][j].x, pos[i - 1][j].y, pos[i - 1][j].z,
          pos[i][j].x, pos[i][j].y, pos[i][j].z
        );
      }

      // line from left
      if (j != 0) {
        line(
          pos[i][j - 1].x, pos[i][j - 1].y, pos[i][j - 1].z,
          pos[i][j].x, pos[i][j].y, pos[i][j].z
        );
      }

      // draw node
      translate(pos[i][j].x, pos[i][j].y, pos[i][j].z);
      sphere(radius);

      popMatrix();
    }
  }

  // draw obstacle
  pushMatrix();
  translate(obstaclePosition.x, obstaclePosition.y, obstaclePosition.z);
  lights();
  sphere(obstacleRadius);
  popMatrix();

  if (paused)
    surface.setTitle(WINDOW_TITLE + " [PAUSED]");
  else
    surface.setTitle(WINDOW_TITLE + " "+ nf(frameRate,0,2) + "FPS");
}

void keyPressed(){
  if (key == ' ') {
    paused = !paused;
  }
  if (key == 'r') {
    initScene();
  }
  if (key == 'w') {
    obstacleVelocity.z -= 100;
  }
  if (key == 'a') {
    obstacleVelocity.x -= 100;
  }
  if (key == 's') {
    obstacleVelocity.z += 100;
  }
  if (key == 'd') {
    obstacleVelocity.x += 100;
  }
  if (key == 'j') {
    obstacleVelocity.y += 100;
  }
  if (key == 'k') {
    obstacleVelocity.y -= 100;
  }
}

void keyReleased() {
  if (key == 'w') {
    obstacleVelocity.z = 0;
  }
  if (key == 'a') {
    obstacleVelocity.x = 0;
  }
  if (key == 's') {
    obstacleVelocity.z = 0;
  }
  if (key == 'd') {
    obstacleVelocity.x = 0;
  }
  if (key == 'j') {
    obstacleVelocity.y = 0;
  }
  if (key == 'k') {
    obstacleVelocity.y = 0;
  }
  if (key == 'x') {
    cameraTransX += 50;
  }
  if (key == 'y') {
    cameraTransY += 50;
  }
  if (key == 'z') {
    cameraTransZ += 50;
  }
  if (key == 'b') {
    cameraTransX -= 50;
  }
  if (key == 'n') {
    cameraTransY -= 50;
  }
  if (key == 'm') {
    cameraTransZ -= 50;
  }
  println(cameraTransX, cameraTransY, cameraTransZ);
}

void mousePressed() {
  dragCamera = true;
  clickX = mouseX;
  clickY = mouseY;

  // float thresh = 10;
  // for (int i = 0; i < rows; i++) {
  //   for (int j = 0; j < cols; j++) {
  //     if (abs(mouseX - pos[i][j].x) < thresh && abs(mouseY - pos[i][j].y) < thresh) {
  //       dragIdx = i * cols + j;
  //       dragging = true;
  //       break;
  //     }
  //   }
  // }
}

void mouseReleased() {
  dragCamera = false;
  xRotation = xRotation + addXRotation;
  addXRotation = 0;
  yRotation = yRotation + addYRotation;
  addYRotation = 0;
}