Arm left_arm, right_arm;
Leg left_leg, right_leg, leg;
float limb_width = 20;
float limb_radius = 10;
float mike_radius = 100;
boolean switch_ = false;
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

  angles = new float[3];
  left_leg = new Leg(lengths, angles, new Vec2(width / 2 - mike_radius / 3, leg_attachment_y), ground, true);

  angles = new float[3];
  right_leg = new Leg(lengths, angles, new Vec2(width / 2 + mike_radius / 3, leg_attachment_y), ground, false);

  lengths = new float[7];
  lengths[0] = 20;
  lengths[1] = 50;
  lengths[2] = 50;
  lengths[3] = 50;
  lengths[4] = 50;
  lengths[5] = 50;
  lengths[6] = 20;
  angles = new float[7];

  angles[0] = -0.58205247;
  angles[1] = -0.35135022;
  angles[2] = 0.16267535;
  angles[3] = 0.57220787;
  angles[4] = 0.8733876;
  angles[5] = 1.10828;
  angles[6] = 0.59998643;

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
  if (key == 'd') {
    left_leg.goal_x += 50;
  }
  if (key == 'f') {
    right_leg.goal_x += 50;
  }
  if (key == 'p') {
    for (Vec2 a : leg.points) {
      println(a);
    }

    for (float a : leg.angles) {
      println(a);
    }
  }
  if (key == 's') {
    leg.switch_();
  }
}

void draw() {

  left_arm.fk();
  left_arm.solve();
  right_arm.fk();
  right_arm.solve();

  left_leg.fk();
  left_leg.solve();
  right_leg.fk();
  right_leg.solve();

  leg.fk();
  leg.solve();
  
  background(250,250,250);
  fill(206, 247, 90);

  // draw mike wazowski body
  // pushMatrix();
  // shape(mike, 
  //   0.25 * (left_arm.points[0].x + right_arm.points[0].x + left_leg.points[0].x + right_leg.points[0].x),
  //   0.25 * (left_arm.points[0].y + right_arm.points[0].y + left_leg.points[0].y + right_leg.points[0].y),
  //   mike_radius * 4, mike_radius * 4);
  // popMatrix();

  // draw legs
  // draw_limb(left_leg);
  // draw_limb(right_leg);
  draw_limb(leg);

  // // draw arms
  // draw_limb(left_arm);
  // draw_limb(right_arm);

  // draw ground
  strokeWeight(8);
  line(0, ground, width, ground);
  strokeWeight(2);

}