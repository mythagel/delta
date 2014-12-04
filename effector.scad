
module effector(balls) {
	r = 18;
	a = [r * cos(0), r * sin(0)];
	b = [r * cos(60), r * sin(60)];
	c = [r * cos(120), r * sin(120)];
	d = [r * cos(180), r * sin(180)];
	e = [r * cos(240), r * sin(240)];
	f = [r * cos(300), r * sin(300)];

	difference() {
		linear_extrude(height=4) polygon([a,b,c,d,e,f]);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=5);
		translate([0, 0, 2]) cylinder(r=21/2, h=2);
	}

	r0 = r-4;
	a0 = [r0 * cos(0), r0 * sin(0),5];
	b0 = [r0 * cos(60), r0 * sin(60),5];
	c0 = [r0 * cos(120), r0 * sin(120),5];
	d0 = [r0 * cos(180), r0 * sin(180),5];
	e0 = [r0 * cos(240), r0 * sin(240),5];
	f0 = [r0 * cos(300), r0 * sin(300),5];

	if(balls) {
		translate(a0) sphere(r=2.5);
		translate(b0) sphere(r=2.5);
		translate(c0) sphere(r=2.5);
		translate(d0) sphere(r=2.5);
		translate(e0) sphere(r=2.5);
		translate(f0) sphere(r=2.5);
	}
}

effector(true);
