use <threads.scad>

module bearing_block() {
	difference() {
		union() {
			cube([8,40,26/2]);
			translate([0,20,23/2+2]) rotate([0,90,0]) cylinder(r=26/2, h=8);
		}
		translate([-0.5,20,23/2+2]) rotate([0,90,0]) cylinder(r=22/2, h=7.5);

		translate([4,4,-0.5]) cylinder(r=2.5, h=(26/2)+1);
		translate([4,40-4,-0.5]) cylinder(r=2.5, h=(26/2)+1);
	}
}

bearing_block();
