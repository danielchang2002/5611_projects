Arm left_arm, right_arm;
Leg leg;
float limb_width = 20;
float limb_radius = 10;
float mike_radius = 100;
float thresh = 5;
float acc_cap = 0.01;
boolean lateral = false;
boolean right = false;
boolean up = false;
float ground;
Vec2 mike_center;
PShape mike;

void setup(){
  // noStroke();
  shapeMode(CENTER);

  mike = loadShape("mike.svg");

  size(1000, 750);
  surface.setTitle("Inverse Kinematics");

  mike_center = new Vec2(width / 2, height / 2);

  float[] lengths = new float[3];
  lengths[0] = 80;
  lengths[1] = 80;
  lengths[2] = 40;
  float[] angles = new float[3];
  left_arm = new Arm(lengths, angles, new Vec2(width / 2 - mike_radius, height / 2));

  angles = new float[3];
  right_arm = new Arm(lengths, angles, new Vec2(width / 2 + mike_radius, height / 2));

  lengths = new float[3];
  lengths[0] = 50;
  lengths[1] = 50;
  lengths[2] = 20;

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

  leg = new Leg(lengths, angles, new Vec2(width / 2 - mike_radius / 3, ground), ground, true);
}

void draw_limb(Limb limb) {
  for (int i = 0; i < limb.angles.length; i++) {
    pushMatrix();
    translate(limb.points[i].x, limb.points[i].y);
    float to_rotate = 0;
    for (int j = 0; j <= i; j++) {
      to_rotate += limb.angles[j];
    }
    rotate(to_rotate);
    if (i == 0) {
      fill(255, 0, 0);
    }
    else {
      fill(206, 247, 90);
    }
    rect(0, -limb_width / 2, limb.lengths[i], limb_width, limb_radius);
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
    leg.switch_roots();
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

void draw() {
  Vec2 center = leg.points[3].plus(leg.points[4]).times(0.5);
  left_arm.points[0] = center.plus(new Vec2(-100, -50));
  right_arm.points[0] = center.plus(new Vec2(100, -50));

  left_arm.fk();
  left_arm.solve();
  right_arm.fk();
  right_arm.solve();

  if (lateral) {
    // check if end effector has reached goal
    if (abs(leg.goal_x - leg.points[leg.points.length - 1].x) < thresh &&
      abs(leg.goal_y - leg.points[leg.points.length - 1].y) < thresh
    ) {
      if (up) {
        leg.goal_x = leg.points[leg.points.length - 1].x + (right ? 25 : -25);
        leg.goal_y = leg.ground;
      }
      else {
        leg.switch_roots();
        // straighten the back half of the leg
        if (leg.points[0].x < leg.points[leg.points.length - 1].x) {
          leg.angles[4] = PI / 2;
        }
        else {
          leg.angles[4] = -PI / 2;
        }
        leg.angles[5] = 0;
        leg.angles[6] = 0;

        leg.goal_x = leg.points[leg.points.length - 1].x + (right ? 25 : -25);
        leg.goal_y = leg.ground - 50;
      }
      up = !up;
    }

  }

  leg.fk();
  leg.solve();
  
  background(250,250,250);
  fill(206, 247, 90);


  // draw leg
  draw_limb(leg);

  // draw mike wazowski body
  pushMatrix();
  shape(mike, 
    0.25 * (left_arm.points[0].x + right_arm.points[0].x + leg.points[3].x + leg.points[4].x),
    0.25 * (left_arm.points[0].y + right_arm.points[0].y + leg.points[3].y + leg.points[4].y),
    mike_radius * 4, mike_radius * 4);
  popMatrix();

  // // draw arms
  draw_limb(left_arm);
  draw_limb(right_arm);

  // draw ground
  strokeWeight(8);
  line(0, ground, width, ground);
  strokeWeight(2);

}