include <gt2_belt.scad>

bearing_radius=10/2;

module carriage(d, w, h) {
	translate([0,-w/2,-h/2]) difference() {
		cube([d,w,h]);

		// rod support
		union() {
			// 8mm rod, m6 internal thread
			translate([d/2,0+(bearing_radius+1),-1]) cylinder(r=bearing_radius, h=h+2);
			translate([d/2,w-(bearing_radius+1),-1]) cylinder(r=bearing_radius, h=h+2);

		}

		// belt guide
		union() {
			translate([d-gt2_belt_width,w/2-(16/2),-1]) cube([gt2_belt_width+1, 2, h+2]);
			translate([d-gt2_belt_width,w/2+(16/2)-2,-1]) cube([gt2_belt_width+1, 2, h+2]);
		
			translate([d-2.5,(w/2)+1,h/2-4]) rotate([0,90,0]) difference() {
				cylinder(r=1.5+2, h=7, center=true);
				cylinder(r=1.5, h=8, center=true);
			}
			translate([d-2.5,(w/2)+1,h/2+4]) rotate([0,90,0]) difference() {
				cylinder(r=1.5+2, h=7, center=true);
				cylinder(r=1.5, h=8, center=true);
			}
		}

	}
}

d=17;
w=42;
h=24;

carriage(d, w, h);