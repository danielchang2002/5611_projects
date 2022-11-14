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

  public Limb(float[] lengths, float[] angles, Vec2 root) {
    this.lengths = lengths;
    this.angles = angles;
    this.points = new Vec2[lengths.length + 1];
    this.points[0] = root;
    this.switch_x = false;
  }

  public void solve(Vec2 goal) {
    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;

    for (int i = points.length - 2; i >= 0; i--) {
      startToGoal = goal.minus(this.points[i]);
      startToEndEffector = this.points[this.points.length - 1].minus(this.points[i]);
      dotProd = dot(startToGoal.normalized(), startToEndEffector.normalized());
      dotProd = clamp(dotProd, -1, 1);
      angleDiff = acos(dotProd);
      if (cross(startToGoal, startToEndEffector) < 0) {
        this.angles[i] += 0.1 * angleDiff;
      }
      else {
        this.angles[i] -= 0.1 * angleDiff;
      }

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

}