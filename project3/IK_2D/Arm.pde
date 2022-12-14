//-----------------
// Arm class
//-----------------

// Inverse Kinematics Arm 
// Daniel Chang <chan1975@umn.edu>

class Arm extends Limb {
  public Arm(float[] lengths, float[] angles, Vec2 root, float[][] limits) {
    super(lengths, angles, root, limits);
  }

  public void solve() {
    solve(new Vec2(mouseX, mouseY), 0.1, false);
  }

}