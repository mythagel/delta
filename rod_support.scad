use <colours.scad>
use <threads.scad>

module rod_support() {
	$fn=32;

	rod_radius = 4;
	r = rod_radius + 10;
	h = 12;
	hole_center = rod_radius + (r-rod_radius)/2;

	color(al) difference() {
		cylinder(r=r, h=h);
		translate([0,0,-0.5]) cylinder(r=rod_radius+.0001, h=h+1);

		translate([0, hole_center, -0.5]) metric_thread(5, 0.8, h+1, internal=true);
		translate([hole_center, 0, -0.5]) metric_thread(5, 0.8, h+1, internal=true);
		translate([-hole_center, 0, -0.5]) metric_thread(5, 0.8, h+1, internal=true);
		translate([0, -hole_center, -0.5]) metric_thread(5, 0.8, h+1, internal=true);

		translate([0, 0, h/2]) rotate([90, 0, 45]) metric_thread(5, 0.8, r, internal=true);
	}

}

rod_support();
