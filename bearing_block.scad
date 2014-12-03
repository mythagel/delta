
module bearing_block() {
	difference() {
		union() {
			cube([8,40,26/2]);
			translate([0,20,23/2+2]) rotate([0,90,0]) cylinder(r=26/2, h=8);
		}
		translate([-0.5,20,23/2+2]) rotate([0,90,0]) cylinder(r=22/2, h=7.5);
	}
}

bearing_block();