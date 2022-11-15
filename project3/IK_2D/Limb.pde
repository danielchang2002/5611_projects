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

  public Vec2 ee() {
    return this.points[this.points.length - 1];
  }

}