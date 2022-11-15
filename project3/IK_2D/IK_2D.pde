Arm left_arm, right_arm;
Leg leg;
float test_ang = 0;
float limb_width = 20;
float limb_radius = 10;
float mike_radius = 100;
float thresh = 5;
float step_size = 25;
float acc_cap = 0.01;
boolean lateral = false;
boolean right = false;
boolean up = false;
float ground;
Vec2 mike_center;
Vec2 sully_center;
boolean grabbing = false;
float grab_dist = 50;

PShape mike;
PShape left_foot;
PShape right_foot;
PShape left_foot_red;
PShape right_foot_red;
PShape sully;
PShape hand;
PImage bg;

void setup(){
  // noStroke();
  shapeMode(CENTER);
  sully_center = new Vec2(width - 200, height / 2);

  mike = loadShape("mike.svg");
  left_foot = loadShape("left_foot.svg");
  right_foot = loadShape("right_foot.svg");
  right_foot_red = loadShape("right_foot_red.svg");
  left_foot_red = loadShape("left_foot_red.svg");
  sully = loadShape("sully.svg");
  hand = loadShape("hand_green.svg");
  bg = loadImage("background.jpeg");

  size(1500, 802);
  surface.setTitle("Inverse Kinematics");

  mike_center = new Vec2(width / 2, height / 2);

  float[] lengths = new float[3];
  lengths[0] = 80;
  lengths[1] = 80;
  lengths[2] = 40;
  float[] angles = new float[3];
  float[][] limits = new float[3][2];

  // shoulder
  limits[0][0] = -100000;
  limits[0][1] = 100000;

  // elbow
  limits[1][0] = -3 * PI / 4;
  limits[1][1] = 0;

  // wrist
  limits[2][0] = -PI / 3;
  limits[2][1] = PI / 3;


  left_arm = new Arm(lengths, angles, new Vec2(width / 2 - mike_radius, height / 2), limits);

  angles = new float[3];

  limits = new float[3][2];

  // shoulder
  limits[0][0] = -100000;
  limits[0][1] = 100000;

  // elbow
  limits[1][0] = 0;
  limits[1][1] = 3 * PI / 4;

  // wrist
  limits[2][0] = -PI / 3;
  limits[2][1] = PI / 3;

  right_arm = new Arm(lengths, angles, new Vec2(width / 2 + mike_radius, height / 2), limits);

  lengths = new float[3];
  lengths[0] = 50;
  lengths[1] = 50;
  lengths[2] = 20;

  limits = new float[7][2];
  // ankle
  limits[0][0] = -2 * PI;
  limits[0][1] = 2 * PI;

  // knee
  limits[1][0] = -2 * PI;
  limits[1][1] = 2 * PI;
  // limits[1][0] = -PI / 2;
  // limits[1][1] = 0;

  limits[2][0] = -2 * PI;
  limits[2][1] = 2 * PI;

  limits[3][0] = -2 * PI;
  limits[3][1] = 2 * PI;

  limits[4][0] = -2 * PI;
  limits[4][1] = 2 * PI;

  limits[5][0] = -2 * PI;
  limits[5][1] = 2 * PI;
  // limits[5][0] = -PI / 2;
  // limits[5][1] = 0;

  limits[6][0] = -2 * PI;
  limits[6][1] = 2 * PI;

  float leg_attachment_y = height / 2 + mike_radius * 0.8;
  ground = (leg_attachment_y + lengths[0] + lengths[1] + lengths[2]) - 5;

  lengths = new float[7];
  lengths[0] = 50;
  lengths[1] = 50;
  lengths[2] = 50;
  lengths[3] = 100;
  lengths[4] = 50;
  lengths[5] = 50;
  lengths[6] = 50;
  angles = new float[7];

  angles[0] = -1.4;
  angles[1] = 0.245;
  angles[2] = 0.317;
  angles[3] = 0.812;
  angles[4] = 0.8446;
  angles[5] = 1.06;
  angles[6] = -0.637;

  leg = new Leg(lengths, angles, new Vec2(width / 2 - mike_radius / 3, ground), ground, false, limits);
}

void draw_leg(Limb limb, boolean highlight_root) {
  for (int i = 0; i < limb.angles.length; i++) {
    pushMatrix();
    translate(limb.points[i].x, limb.points[i].y);
    float to_rotate = 0;
    for (int j = 0; j <= i; j++) {
      to_rotate += limb.angles[j];
    }
    rotate(to_rotate);
    if (i == 0 && highlight_root) {
      fill(255, 0, 0);
    }
    else {
      fill(206, 247, 90);
    }
    if (i == 0) {
      // root
      PShape shape;
      if (leg.points[0].x < leg.points[leg.points.length - 1].x) {
        shape = left_foot_red;
        rotate(PI / 2);
        shape(shape, 
          -20,
          -35,
          75, 75);
      }
      else {
        shape = right_foot_red;
        rotate(1.4 * (PI / 2));
        shape(shape, 
          0,
          -30,
          75, 75);
      }
    }
    else if (i == leg.points.length - 2) {
      // end effector
      PShape shape;
      if (leg.points[0].x > leg.points[leg.points.length - 1].x) {
        shape = left_foot;
        rotate(4.7);
        shape(shape, 
          -25,
          10,
          75, 75);
      }
      else {
        shape = right_foot;
        rotate(5);
        shape(shape, 
          30,
          10,
          75, 75);
      }
    }
    else {
      rect(0, -limb_width / 2, limb.lengths[i], limb_width, limb_radius);
    }
    popMatrix();
  }
}

void draw_arm(Limb limb, boolean highlight_root, PShape end) {
  for (int i = 0; i < limb.angles.length; i++) {
    pushMatrix();
    translate(limb.points[i].x, limb.points[i].y);
    float to_rotate = 0;
    for (int j = 0; j <= i; j++) {
      to_rotate += limb.angles[j];
    }
    rotate(to_rotate);
    if (i == 0 && highlight_root) {
      fill(255, 0, 0);
    }
    else {
      fill(206, 247, 90);
    }
    if (end != null && i == limb.angles.length - 1) {
      rotate(PI / 2);
      shape(end, 
        0,
        0,
        150, 150);
    }
    else {
      rect(0, -limb_width / 2, limb.lengths[i], limb_width, limb_radius);
    }
    popMatrix();
  }
}

void keyPressed() {
  if (key == 'r') {
    leg.frozen = !leg.frozen;
  }
  if (key == 'd') {
    right = true;
    lateral = true;
  }
  if (key == 'a') {
    right = false;
    lateral = true;
  }
  if (key == 's') {
    test_ang += 0.1;
  }
  if (key == 'p') {
    for (float a : leg.angles) println(a);
  }
}

void keyReleased() {
  if (key == 'd') {
    lateral = false;
  }
  if (key == 'a') {
    lateral = false;
  }
}

void mousePressed() {
  grabbing = true;
}

void mouseReleased() {
  grabbing = false;
}

void draw() {
  if (grabbing && 
    sully_center.minus(left_arm.ee()).length() < grab_dist
  ) {
    sully_center = left_arm.ee();
  }

  if (grabbing && 
    sully_center.minus(right_arm.ee()).length() < grab_dist
  ) {
    sully_center = right_arm.ee();
  }

  Vec2 center = leg.points[3].plus(leg.points[4]).times(0.5);
  left_arm.points[0] = center.plus(new Vec2(-100, -50));
  right_arm.points[0] = center.plus(new Vec2(100, -50));

  left_arm.fk();
  left_arm.solve();

  right_arm.fk();
  right_arm.solve();

  if (lateral) {

    // leg.angles[5] *= 0.9;
    // leg.angles[6] *= 0.9;

    // check if end effector has reached goal
    if (abs(leg.goal_x - leg.points[leg.points.length - 1].x) < thresh &&
      abs(leg.goal_y - leg.points[leg.points.length - 1].y) < thresh
    ) {
      if (up) {
        leg.goal_x = leg.points[leg.points.length - 1].x + (right ? step_size : -step_size);
        leg.goal_y = leg.ground;
      }
      else {
        leg.switch_roots();

        leg.angles[5] = 0;
        leg.angles[6] = 0;

        // straighten the back half of the leg
        if (leg.points[0].x < leg.points[leg.points.length - 1].x) {
          // leg.angles[4] = (leg.angles[4] + PI / 2) / 2;
          leg.angles[4] = PI / 2;
        }
        else {
          // leg.angles[4] = (leg.angles[4] + -PI / 2) / 2;
          leg.angles[4] = -PI / 2;
        }

        leg.goal_x = leg.points[leg.points.length - 1].x + (right ? step_size : -step_size);
        leg.goal_y = leg.ground - 50;
      }
      up = !up;
    }

  }

  leg.fk();
  leg.solve();
  
  // background(250,250,250);
  background(bg);
  fill(206, 247, 90);


  // draw leg
  draw_leg(leg, true);

  // draw mike wazowski body
  pushMatrix();
  shape(mike, 
    0.25 * (left_arm.points[0].x + right_arm.points[0].x + leg.points[3].x + leg.points[4].x),
    0.25 * (left_arm.points[0].y + right_arm.points[0].y + leg.points[3].y + leg.points[4].y),
    mike_radius * 4, mike_radius * 4);
  popMatrix();

  // draw arms
  draw_arm(left_arm, false, hand);
  draw_arm(right_arm, false, hand);

  // draw sully
  pushMatrix();
  shape(sully, 
    sully_center.x,
    sully_center.y,
    mike_radius * 1.5, mike_radius * 1.5);
  popMatrix();

}