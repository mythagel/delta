
module effector() {
	r = 25;

	a = [r * cos(0), r * sin(0)];
	b = [r * cos(120), r * sin(120)];
	c = [r * cos(240), r * sin(240)];

	difference() {
		linear_extrude(height=4) polygon([a,b,c]);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=5);
		translate([0, 0, 2]) cylinder(r=21/2, h=2);
	}
}

effector();
