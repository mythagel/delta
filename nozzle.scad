use <threads.scad>

//nozzle_size

module nozzle() {
	difference() {
		union() {
			cylinder(r1=0.3*1.61, r2=2.5, h=2.501);
			translate([0, 0, 2.5]) metric_thread(5, 0.8, 50-4);
		}

		translate([0, 0, 0.5]) union() {
			translate([0, 0, 1]) cylinder(r=1.5, h=50-2);
			cylinder(r1=0, r2=1.5, h=1);
		}

		cylinder(r=0.3/2, h=3);
	}
}

nozzle();