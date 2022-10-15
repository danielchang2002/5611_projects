//PDEs and Integration
//CSCI 5611 Swinging Rope [Exercise]
//Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused, press "space" to unpause

//TODO:
//  1. The rope moves very slowly now, this is because the timestep is 1/20 of realtime
//      a. Make the timestep realtime (20 times faster than the inital code), what happens?
//      b. Call the small 1/20th timestep update, 20 times each frame (in a for loop) -- why is it different?
//  2. When the rope hanging down fully the spacing between the links is not equal, even though they
//     where initalized with an even spacing between each node. What is this?
//      - If this is a bug, fix the corisponding code
//      - If this why is not a bug, explain why this is the expected behavior
//  3. By default, the rope starts vertically. Change initScene() so it starts at an angle. The rope should
//     then swing backc and forth.
//  4. Try changing the mass and the k value. How do they interact wich each other?
//  5. Set the kv value very low, does the rope bounce a lot? What about a high kv (not too high)?
//     Why doesn't the rope stop swinging at high values of kv?
//  6. Add friction/drag so that the rope eventually stops. An easy friction model is a scaled force 
//     in the opposite direction of a nodes current velocity. 

//Challenge:
//  - Set the top of the rope to be wherever the user's mouse is, and allow the user to drag the rope around the scene.
//  - Keep the top of the rope fixed, but allow the user to click and drag one of the balls of the rope to move it around.
//  - Place a medium-sized, static 2D ball in the scene, have the nodes on the rope experience a "bounce" force if they collide with this ball.


//Create Window
String windowTitle = "Swinging Rope";
void setup() {
  size(400, 500, P3D);
  surface.setTitle(windowTitle);
  initScene();
}

//Simulation Parameters
float floor = 500;
Vec2 gravity = new Vec2(0,400);
float radius = 5;
Vec2 stringTop = new Vec2(200,50);
float restLen = 10;
float mass = 1.0; //TRY-IT: How does changing mass affect resting length of the rope?
float k = 200; //TRY-IT: How does changing k affect resting length of the rope?
float kv = 30; //TRY-IT: How big can you make kv?
Vec2 obstaclePosition = new Vec2(100, 300);
float obstacleRadius = 50;
float COR = 0.8;

//Initial positions and velocities of masses
static int maxNodes = 100;
Vec2 pos[] = new Vec2[maxNodes];
Vec2 vel[] = new Vec2[maxNodes];
Vec2 acc[] = new Vec2[maxNodes];

int numNodes = 10;

void initScene(){
  for (int i = 0; i < numNodes; i++){
    pos[i] = new Vec2(0, 0);
    pos[i].x = stringTop.x + i * 10;
    pos[i].y = stringTop.y + 8*i; //Make each node a little lower
    vel[i] = new Vec2(0,0);
  }
}

void update(float dt){

  //Reset accelerations each timestep (momenum only applies to velocity)
  for (int i = 0; i < numNodes; i++){
    acc[i] = new Vec2(0,0);
    acc[i].add(gravity);
  }
  
  //Compute (damped) Hooke's law for each spring
  for (int i = 0; i < numNodes-1; i++){
    Vec2 diff = pos[i+1].minus(pos[i]);
    float stringF = -k*(diff.length() - restLen);
    //println(stringF,diff.length(),restLen);
    
    Vec2 stringDir = diff.normalized();
    float projVbot = dot(vel[i], stringDir);
    float projVtop = dot(vel[i+1], stringDir);
    float dampF = -kv*(projVtop - projVbot);
    
    Vec2 force = stringDir.times(stringF+dampF);
    acc[i].add(force.times(-1.0/mass));
    acc[i+1].add(force.times(1.0/mass));
    
  }

  //Eulerian integration
  for (int i = 1; i < numNodes; i++){
    vel[i].add(acc[i].times(dt));
    pos[i].add(vel[i].times(dt));
  }
  
  // Collision detection and response
  for (int i = 0; i < numNodes; i++){
    if (pos[i].y+radius > floor){
      vel[i].y *= -.9;
      pos[i].y = floor - radius;
    }
  }

  // Collision detection and response (obstacle)
  for (int i = 0; i < numNodes; i++){
    Vec2 dist = pos[i].minus(obstaclePosition);
    if (dist.length() < radius + obstacleRadius + 0.05) {
      Vec2 normal = dist.normalized();
      // bring sphere back to position
      pos[i] = obstaclePosition.plus(normal.times(obstacleRadius + radius)).times(1.01);

      // apply bounce
      Vec2 bounce = normal.times(dot(vel[i], normal));
      vel[i] = vel[i].minus(bounce.times(1 + COR));
    }
  }
  
}

//Draw the scene: one sphere per mass, one line connecting each pair
boolean paused = true;
void draw() {
  background(255,255,255);
  if (!paused) {
    for (int i = 0; i < 40; i++) {
      update(1/(10 * frameRate));
    }
  }
  fill(0,0,0);
  
  for (int i = 0; i < numNodes-1; i++){
    pushMatrix();
    line(pos[i].x,pos[i].y,pos[i+1].x,pos[i+1].y);
    translate(pos[i+1].x,pos[i+1].y);
    sphere(radius);
    popMatrix();
  }

  // draw obstacle
  pushMatrix();
  translate(obstaclePosition.x, obstaclePosition.y);
  sphere(obstacleRadius);
  popMatrix();
  
  if (paused)
    surface.setTitle(windowTitle + " [PAUSED]");
  else
    surface.setTitle(windowTitle + " "+ nf(frameRate,0,2) + "FPS");
}

void keyPressed(){
  if (key == ' ')
    paused = !paused;
}