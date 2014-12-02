

module belt_idler() {
	$fn = 32;
	module bearing_mount() {
		difference() {
			rotate([90,0,0]) cylinder(h=7, r=22/2, center=true);
			rotate([90,0,0]) translate([0, 0, -0.5]) cylinder(h=8, r=3.99, center=true);
		}
	}

	h = (7*2) + 6;
	difference() {
		rotate([90,0,0]) cylinder(r=7.5, h=h, center=true);
		translate([0,-(h/2)+(7/2)-0.0001,0]) bearing_mount();
		translate([0,(h/2)-(7/2)+0.0001,0]) bearing_mount();
	}
}

use <bearings.scad>

translate([0,(7+6)/2,0]) rotate([90,0,0]) 608zz();
belt_idler();
translate([0,-(7+6)/2,0]) rotate([90,0,0]) 608zz();
