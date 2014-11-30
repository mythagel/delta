use <colours.scad>
use <threads.scad>

module rod_support() {
	$fn=32;
	color(al) difference() {
		union() {
			cylinder(r=10/2, h=25);
			cylinder(r=25/2, h=5);
		}
		translate([0,0,-0.1]) cylinder(r=8/2+.001, h=30);

		translate([0, 8.5, -0.1]) metric_thread(5, 0.8, 5.5, internal=true);
		translate([8.5, 0, -0.1]) metric_thread(5, 0.8, 5.5, internal=true);
		translate([-8.5, 0, -0.1]) metric_thread(5, 0.8, 5.5, internal=true);
		translate([0, -8.5, -0.1]) metric_thread(5, 0.8, 5.5, internal=true);
	}
}

rod_support();
