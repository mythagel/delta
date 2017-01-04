// From Mini Kossel https://github.com/jcrocholl/kossel/blob/master/nema17.scad

module nema17() {
  motor_shaft_diameter = 5;
  motor_shaft_radius = motor_shaft_diameter/2;
  motor_length = 38.8;
  m3_major = 2.85;
  m3_radius = m3_major/2;

  // NEMA 17 stepper motor.
  difference() {
    union() {
      translate([0, 0, -motor_length/2]) intersection() {
        cube([42, 42, motor_length], center=true);
        cylinder(r=25.1, h=motor_length+1, center=true, $fn=60);
      }
      cylinder(r=11, h=4, center=true, $fn=32);
      cylinder(r=2.5, h=40, center=true, $fn=24);
    }
    for (a = [0:90:359]) {
      rotate([0, 0, a]) translate([15.5, 15.5, 0])
        cylinder(r=m3_radius, h=10, center=true, $fn=12);
    }
  }
}

nema17();
