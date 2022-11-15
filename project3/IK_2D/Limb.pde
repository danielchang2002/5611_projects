//-----------------
// Limb class
//-----------------

// Inverse Kinematics Limb 
// Daniel Chang <chan1975@umn.edu>

class Limb {
  float[] lengths;
  float[] angles;
  Vec2[] points;
  boolean switch_x;
  float[][] limits;

  public Limb(float[] lengths, float[] angles, Vec2 root, float[][] limits) {
    this.lengths = lengths;
    this.angles = angles;
    this.points = new Vec2[lengths.length + 1];
    this.points[0] = root;
    this.switch_x = false;
    this.limits = limits;
  }

  public void solve(Vec2 goal, float drag, boolean cap_acc) {
    if (random) {
      solve_random(goal, drag, cap_acc);
      return;
    }

    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;

    for (int i = points.length - 2; i >= 0; i--) {
      startToGoal = goal.minus(this.points[i]);
      startToEndEffector = this.points[this.points.length - 1].minus(this.points[i]);
      dotProd = dot(startToGoal.normalized(), startToEndEffector.normalized());
      dotProd = clamp(dotProd, -1, 1);
      angleDiff = acos(dotProd);
      if (cap_acc && abs(angleDiff) > acc_cap) {
        angleDiff = angleDiff < 0 ? -acc_cap : acc_cap;
      }
      if (cross(startToGoal, startToEndEffector) < 0) {
        this.angles[i] += drag * angleDiff;
      }
      else {
        this.angles[i] -= angleDiff;
      }

      this.angles[i] = clamp(this.angles[i], limits[i][0], limits[i][1]);

      fk();
    }
  }

  public void fk(){
    for (int i = 1; i < points.length; i++) {
      float angle = 0;
      for (int j = 0; j < i; j++) {
        angle += this.angles[j];
      }
      this.points[i] = (new Vec2(cos(angle) * this.lengths[i - 1], sin(angle) * this.lengths[i - 1])).plus(this.points[i - 1]);
    }
  }

  public void solve_random(Vec2 goal, float drag, boolean cap_acc) {
    int NUM_ITERS = 10000;

    float[] best_angles = this.angles;
    float min_dist = this.ee().minus(goal).length();

    for (int i = 0; i < NUM_ITERS; i++) {
      this.angles = new float[this.angles.length];
      for (int j = 0; j < this.angles.length; j++) {
        this.angles[j] = random(-2 * PI, 2 * PI);
        float new_angle = random(-2 * PI, 2 * PI);
        float angleDiff = new_angle - this.angles[j];
        if (abs(angleDiff) > acc_cap) {
          angleDiff = angleDiff < 0 ? -acc_cap : acc_cap;
        }
        this.angles[j] += drag * angleDiff;
        clamp(this.angles[j], limits[j][0], limits[j][1]);
      }
      fk();
      float cur_dist = this.ee().minus(goal).length();
      if (cur_dist < min_dist) {
        best_angles = this.angles;
      };
    }
    this.angles = best_angles;
    fk();
  }

  public Vec2 ee() {
    return this.points[this.points.length - 1];
  }

}