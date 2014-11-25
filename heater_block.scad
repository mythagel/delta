use <ceramic_heater.scad>
use <threads.scad>

module heater_block() {
	difference() {
		cube(size = [21,21,8]);
		rotate([-90, 0, 0]) translate([4, -4, -1])
			ceramic_heater();
		translate([21/2, 21/2, -0.5])
			metric_thread(5, 0.8, 9, internal=true);
		rotate([-90, 0, 0]) translate([15.25, -3.5, -1])
			cylinder(r=2.5/2, h=20);
	}
}

heater_block();