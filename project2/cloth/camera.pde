// Created for CSCI 5611 by Liam Tyler
// Modified by Daniel Chang for minecraft creative mode movement

class Camera
{
  Camera()
  {
    // position      = new PVector( 1522, -307, 928 ); // initial position
    position      = new PVector(641, -135, 293); // initial position
    theta         = 0.719; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = -0.61; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    oldTheta = theta;
    oldPhi = phi;
    moveSpeed     = 500;
    
    // dont need to change these
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1;
    farPlane         = 10000;
  }
  
  void Update(float dt)
  {

    // stop turning once the mouse has stopped moving
    if (mouseX == pmouseX && mouseY == pmouseY) {
      robot.mouseMove(width / 2, height / 2);
      oldTheta = theta;
      oldPhi = phi;
    }
    else {
      theta = oldTheta - ((mouseX - (width / 2.0)) / width) * PI / 3;
      phi = oldPhi - ((mouseY - (height / 2.0)) / height) * PI / 3;
    }


    // theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
    
    // // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    // float maxAngleInRadians = 85 * PI / 180;
    // phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
   
    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( position.x, position.y, position.z,
            position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
            upDir.x, upDir.y, upDir.z );
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyPressed()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 1;
    if ( key == 's' || key == 'S' ) negativeMovement.z = -1;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = -1;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 1;
    if ( key == ' ') negativeMovement.y = -1;
    if ( keyCode == SHIFT) positiveMovement.y = 1;
    
    // if ( keyCode == LEFT )  negativeTurn.x = 1;
    // if ( keyCode == RIGHT ) positiveTurn.x = -0.5;
    // if ( keyCode == UP )    positiveTurn.y = 0.5;
    // if ( keyCode == DOWN )  negativeTurn.y = -1;
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyReleased()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 0;
    if ( key == 's' || key == 'S' ) negativeMovement.z = 0;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = 0;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 0;
    if ( key == ' ') negativeMovement.y = 0;
    if ( keyCode == SHIFT) positiveMovement.y = 0;
    
    // if ( keyCode == LEFT  ) negativeTurn.x = 0;
    // if ( keyCode == RIGHT ) positiveTurn.x = 0;
    // if ( keyCode == UP    ) positiveTurn.y = 0;
    // if ( keyCode == DOWN  ) negativeTurn.y = 0;
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float oldTheta;
  float oldPhi;
  float moveSpeed;
  float turnSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector negativeTurn;
  PVector positiveTurn;
  PVector forwardDir;
};