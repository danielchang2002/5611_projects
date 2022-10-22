float phi = 1.738348;
float theta = 3.2188234;
float oldPhi = -1;
float oldTheta = -1;
float rho = 1837;
boolean dragCamera = false;
float clickX = -1;
float clickY = -1;

Vec3 lookLocation = new Vec3(0, 0, 0);
Vec3 cameraLocation = new Vec3(0, 0, 0);

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  rho = max(obstacleRadius * 2, rho + e);
  updateCameraPosition();
}

void mousePressed() {
  dragCamera = true;
  clickX = mouseX;
  clickY = mouseY;
  oldPhi = phi;
  oldTheta = theta;
}

void mouseReleased() {
  dragCamera = false;
}

void updateCameraPosition() {
  float r = rho * sin(phi);
  cameraLocation = lookLocation.plus(new Vec3(
    r * sin(theta), 
    rho * cos(phi), 
    -r * cos(theta)
  ));
}