
module belt_idler() {
	module bearing_mount() {
		difference() {
			rotate([90,0,0]) cylinder(h=7, r=22/2, center=true);
			rotate([90,0,0]) translate([0, 0, -0.5]) cylinder(h=8, r=3.95, center=true);
		}
	}

	h = (7*2) + 6;
	difference() {
		rotate([90,0,0]) cylinder(r=7.5, h=h, center=true);
		translate([0,-(h/2)+(7/2)-0.0001,0]) bearing_mount();
		translate([0,(h/2)-(7/2)+0.0001,0]) bearing_mount();
	}
}

belt_idler();
