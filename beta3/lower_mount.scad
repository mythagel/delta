use <../bearings.scad>
include <gt2_belt.scad>
use <../boxes.scad>

bearing_radius=10/2;

module lower_mount(d, w, h) {
	translate([0,-w/2,-h/2])
	union() {
		difference() {
			cube([d,w,h]);

			// see inside!
			//translate([d-1.5,w/2,h/2]) rotate([0,90,0]) cylinder(h=8, r=40, center=true);

			// axle
			translate([d/2,w/2,h-5]) rotate([0,90,0]) cylinder(h=d+2, r=1, center=true);

			// belt clearance milled by 5/32" bit
			translate([d-(gt2_belt_width/2), w/2, h-(8/2)])
				rotate([0,90,0])
					roundedBox([16, 16, gt2_belt_width+2], 3.96875/2, true);

			// rod support
			translate([d/2,0+(bearing_radius+1),4]) cylinder(r=4, h=h+1);
			translate([d/2,w-(bearing_radius+1),4]) cylinder(r=4, h=h+1);
		}
		
		//idler
		translate([d-(7/2),w/2,h-5]) rotate([0,90,0]) cylinder(h=7, r=10/2, center=true);
	}
}

d=17;
w=42;
h=24;

lower_mount(d, w, h);
