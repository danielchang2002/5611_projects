//-----------------
// Leg class
//-----------------

// Inverse Kinematics Leg 
// Daniel Chang <chan1975@umn.edu>

class Leg extends Limb {
  float ground;
  boolean rooted;
  boolean step_right;
  float goal_x;
  float goal_y;
  boolean switched;

  public Leg(float[] lengths, float[] angles, Vec2 root, float ground, boolean rooted) {
    super(lengths, angles, root);
    this.ground = ground;
    this.rooted = rooted;
    this.step_right = false;
    this.goal_x = points[0].x;
    this.goal_y = ground;
  }

  public void solve() {
    // solve(new Vec2(mouseX, mouseY));
  }

  public void switch_() {
    float[] new_lengths = new float[lengths.length];
    for (int i = 0; i < lengths.length; i++) {
      new_lengths[i] = lengths[lengths.length - 1 - i];
    }
    lengths = new_lengths;

    Vec2[] new_points = new Vec2[points.length];
    for (int i = 0; i < points.length; i++) {
      new_points[i] = points[points.length - 1 - i];
    }
    points = new_points;

    float[] new_angles = new float[angles.length];
    Vec2 last_vec = new Vec2(1, 0);
    if (switched) last_vec = new Vec2(1, 0);
    for (int i = 1; i < points.length; i++) {
      Vec2 cur_vec = points[i].minus(points[i - 1]);
      if (switched) cur_vec = points[i - 1].minus(points[i]);

      // find angle between last_vec and cur_vec
      float dotProd = dot(last_vec.normalized(), cur_vec.normalized());
      dotProd = clamp(dotProd, -1, 1);
      float angleDiff = acos(dotProd); 
      new_angles[i - 1] = angleDiff;
      // new_angles[i - 1] *= -1;
      if (!switched) new_angles[i - 1] *= -1;
      last_vec = cur_vec;
    }

    if (this.switched) {
      new_angles[0] += PI;
    }

    angles = new_angles;
    this.switched = !this.switched;
  }


}

