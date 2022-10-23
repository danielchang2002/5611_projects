// set constants
String WINDOW_TITLE = "Swinging cloth";
Camera camera;
Robot robot;
import java.awt.Robot;

void setup() {
  fullScreen(P3D);
  surface.setTitle(WINDOW_TITLE);
  noStroke();
  noCursor();
  initScene();
  try {
    robot = new Robot();
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  camera = new Camera();
}

int numUpdatesPerDraw = 20;
int rows = 10;
int cols = 10;
int radius = 5;
float rest_len = 100;
float k_s = 100; // spring constant
float k_d = 80; // damping constant
float friction = 0.5;
float startX = 100;
float startY = 200;
float startZ = 0;
float dist_between_nodes = rest_len;
Vec3 obstaclePosition = new Vec3(200, 600, -300);
Vec3 obstacleVelocity = new Vec3(0, 0, 0);
float obstacleRadius = 200;
float COR = 0.8;
float gravity = 400;

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
}

boolean paused = true;

void draw() {
  camera.Update(1.0/(frameRate));

  background(255,255,255);

  if (!paused) {
    for (int i = 0; i < numUpdatesPerDraw * 2; i++) {
      update(1.0/(numUpdatesPerDraw * frameRate));
    }
  }

  directionalLight(150, 250, 150, -40, 120, -200);



  // draw cloth
  for (int i = 0 ; i < rows; i++) {
    for (int j = 0; j < cols; j++) {

      if (i != rows - 1 && j != cols - 1) {

        Vec3 topLeft = pos[i][j];
        Vec3 topRight = pos[i][j + 1];
        Vec3 botLeft = pos[i + 1][j];
        Vec3 botRight = pos[i + 1][j + 1];

        
        pushMatrix();
        beginShape();
        fill(0, 255, 255 * (abs(pos[i][j].minus(pos[i][j + 1]).length() - rest_len) / (rest_len * 0.5)));

        Vec3 topLeftNormal = getNormal(i, j);
        normal(topLeftNormal.x, topLeftNormal.y, topLeftNormal.z);
        vertex(topLeft.x, topLeft.y, topLeft.z, 0, 0);

        Vec3 topRightNormal = getNormal(i, j + 1);
        normal(topRightNormal.x, topRightNormal.y, topRightNormal.z);
        vertex(topRight.x, topRight.y, topRight.z, rest_len, 0);

        Vec3 botRightNormal = getNormal(i + 1, j + 1);
        normal(botRightNormal.x, botRightNormal.y, botRightNormal.z);
        vertex(botRight.x, botRight.y, botRight.z, rest_len, rest_len);

        Vec3 botLeftNormal = getNormal(i + 1, j);
        normal(botLeftNormal.x, botLeftNormal.y, botLeftNormal.z);
        vertex(botLeft.x, botLeft.y, botLeft.z, 0, rest_len);

        endShape();
        popMatrix();
      }
    }
  }

  fill(255, 0, 0);
  // draw obstacle
  pushMatrix();
  translate(obstaclePosition.x, obstaclePosition.y, obstaclePosition.z);
  sphere(obstacleRadius);
  popMatrix();

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
  // if (key == 'w') {
  //   obstacleVelocity.z -= 100;
  // }
  // if (key == 'a') {
  //   obstacleVelocity.x -= 100;
  // }
  // if (key == 's') {
  //   obstacleVelocity.z += 100;
  // }
  // if (key == 'd') {
  //   obstacleVelocity.x += 100;
  // }
  // if (key == 'j') {
  //   obstacleVelocity.y += 100;
  // }
  // if (key == 'k') {
  //   obstacleVelocity.y -= 100;
  // }
}

void keyReleased() {
  camera.HandleKeyReleased();
  // if (key == 'w') {
  //   obstacleVelocity.z = 0;
  // }
  // if (key == 'a') {
  //   obstacleVelocity.x = 0;
  // }
  // if (key == 's') {
  //   obstacleVelocity.z = 0;
  // }
  // if (key == 'd') {
  //   obstacleVelocity.x = 0;
  // }
  // if (key == 'j') {
  //   obstacleVelocity.y = 0;
  // }
  // if (key == 'k') {
  //   obstacleVelocity.y = 0;
  // }
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

float getTTC(Vec3 vel, Vec3 pos) {
  float a = vel.lengthSqr();
  float b = dot(vel.times(2), pos.minus(obstaclePosition));
  float c = pos.minus(obstaclePosition).lengthSqr() - obstacleRadius * obstacleRadius;
  float disc = sqrt(b * b - 4 * a * c);
  float t1 = (-b + disc) / (2 * a);
  float t2 = (-b - disc) / (2 * a);
  float ans = Float.MAX_VALUE;
  if (t1 > 0) {
    ans = min(ans, t1);
  }
  if (t2 > 0) {
    ans = min(ans, t2);
  }
  return ans;
}