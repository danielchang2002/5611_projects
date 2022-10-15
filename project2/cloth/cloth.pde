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
float rest_len = 80;
float k_s = 2000; // spring constant
float k_d = 0; // damping constant
float gravity = 20;
float startX = 100;
float startY = 200;
float startZ = 0;
float dist_between_nodes = rest_len;
Vec3 obstaclePosition = new Vec3(200, 500, -750);
float obstacleRadius = 100;
float COR = 0.8;

Vec3[][] pos = new Vec3[rows][cols];
Vec3[][] vel = new Vec3[rows][cols];

void initScene(){

  // rotate camera
  beginCamera();
  camera();
  rotateX(-PI/5);
  // rotateY(PI/12);
  endCamera();

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      pos[i][j] = new Vec3(
        startX + i * dist_between_nodes,
        startY,
        startZ - j * 2 * dist_between_nodes
        );
      vel[i][j] = new Vec3(0, 0, 0);
    }
  }
}

void update(float dt){

  // intialize new velocity matrix
  Vec3[][] new_vel = new Vec3[rows][cols];
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      new_vel[i][j] = new Vec3(0, 0, 0);
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
      new_vel[i][j].add(displacement_dir.times(f * dt));
      new_vel[i][j + 1].subtract(displacement_dir.times(f * dt));
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
      new_vel[i][j].add(displacement_dir.times(f * dt));
      new_vel[i + 1][j].subtract(displacement_dir.times(f * dt));
    }
  }

  // apply gravity
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      new_vel[i][j].y += gravity;
    }
  }

  // fix top
  for (int i = 0; i < cols; i++) {
    new_vel[0][i].x = 0;
    new_vel[0][i].y = 0;
    new_vel[0][i].z = 0;
  }


  vel = new_vel;
  update_pos(dt);

  // intialize new velocity matrix
  new_vel = new Vec3[rows][cols];
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      new_vel[i][j] = new Vec3(0, 0, 0);
    }
  }

  // collision detection
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      float d = obstaclePosition.minus(pos[i][j]).length();

      if (d < obstacleRadius + radius) {
        Vec3 n = pos[i][j].minus(obstaclePosition);
        Vec3 norm = n.normalized();
        Vec3 bounce = norm.times(dot(vel[i][j], norm));
        new_vel[i][j].subtract(bounce.times(1 + COR));
        pos[i][j].add(norm.times(10 + obstacleRadius - d));
      }
    }
  }

  vel = new_vel;
  update_pos(dt);
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

void update_pos(float dt) {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      pos[i][j].add(vel[i][j].times(dt));
    }
  }
}

boolean paused = true;
void draw() {
  background(255,255,255);
  if (!paused) {
    for (int i = 0; i < 1000; i++) {
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
  // noStroke();
  lights();
  sphere(obstacleRadius);
  popMatrix();

  if (paused)
    surface.setTitle(WINDOW_TITLE + " [PAUSED]");
  else
    surface.setTitle(WINDOW_TITLE + " "+ nf(frameRate,0,2) + "FPS");
}

void keyPressed(){
  if (key == ' ')
    paused = !paused;
  if (key == 'r')
    initScene();
}