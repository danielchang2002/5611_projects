//-----------------
// Leg class
//-----------------

// Inverse Kinematics Leg 
// Daniel Chang <chan1975@umn.edu>

class Leg extends Limb {
  float ground;
  boolean frozen;
  boolean step_right;
  float goal_x;
  float goal_y;
  boolean switched;

  public Leg(float[] lengths, float[] angles, Vec2 root, float ground, boolean frozen, float[][] limits) {
    super(lengths, angles, root, limits);
    super.fk();
    this.ground = ground;
    this.frozen = frozen;
    this.step_right = false;
    this.goal_x = points[points.length - 1].x;
    this.goal_y = ground;
  }

  public void solve() {
    if (frozen) return;
    if (random) {
      solve_random(new Vec2(goal_x, goal_y), 1, true);
      return;
    }
    solve(new Vec2(goal_x, goal_y), 1, true);
  }

    public void solve_random(Vec2 goal, float drag, boolean cap_acc) {

    }

  public void switch_roots() {
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
    for (int i = 1; i < points.length; i++) {
      Vec2 cur_vec = points[i].minus(points[i - 1]);

      // find angle between last_vec and cur_vec
      float dotProd = dot(last_vec.normalized(), cur_vec.normalized());
      dotProd = clamp(dotProd, -1, 1);
      float angleDiff = acos(dotProd); 
      if (cross(last_vec, cur_vec) < 0) {
        new_angles[i - 1] = -angleDiff;
      }
      else {
        new_angles[i - 1] = angleDiff;
      }
      last_vec = cur_vec;
    }
    angles = new_angles;
  }
}

