include <gt2_belt.scad>

bearing_radius=10/2;

module motor_mount(d, w, h) {
	translate([0,-w/2,-h/2]) difference() {
		cube([d,w,h]);

			// see inside!
			//translate([d-1.5,w/2,h/2]) rotate([0,90,0]) cylinder(h=10, r=40, center=true);

		// rod support (machined from top)
		union() {
			// 8mm rod, m6 internal thread
			translate([d/2,0+(bearing_radius+1),-1]) cylinder(r=4, h=20+1);
			translate([d/2,w-(bearing_radius+1),-1]) cylinder(r=4, h=20+1);

			// 6mm through holes for M6 tapped rods
			// prefer to not have to drill and tap hardened rods
			//translate([d/2,0+(bearing_radius+1),-1]) cylinder(r=3, h=42+2);
			//translate([d/2,w-(bearing_radius+1),-1]) cylinder(r=3, h=42+2);

			// TODO recessed mounting screws from front or back face.
		}

		// motor flange clearance (machined from back)
		translate([-1,w/2,h/2]) rotate([90,0,90]) cylinder(r=22/2, h=2+1);
		// center bore clearance (machined from front)
		translate([-1,w/2,h/2]) rotate([90,0,90]) cylinder(r=16/2, h=d+2);

		// screw thread holes (machined from front)
		translate([d/2,w/2,h/2]) union() {
			// through hole for threads
			translate([0,-31/2,-31/2]) rotate([90,0,90]) cylinder(r=3/2, h=d+2, center=true);
			translate([0,31/2,-31/2]) rotate([90,0,90]) cylinder(r=3/2, h=d+2, center=true);
			translate([0,-31/2,31/2]) rotate([90,0,90]) cylinder(r=3/2, h=d+2, center=true);
			translate([0,31/2,31/2]) rotate([90,0,90]) cylinder(r=3/2, h=d+2, center=true);

			// screw head clearance
			translate([3,-31/2,-31/2]) rotate([90,0,90]) cylinder(r=5/2, h=d+1, center=true);
			translate([3,31/2,-31/2]) rotate([90,0,90]) cylinder(r=5/2, h=d+1, center=true);
			translate([3,-31/2,31/2]) rotate([90,0,90]) cylinder(r=5/2, h=d+1, center=true);
			translate([3,31/2,31/2]) rotate([90,0,90]) cylinder(r=5/2, h=d+1, center=true);
		}

		// belt guide (machined from front)
		translate([(d/2)+((gt2_belt_width-1)/2),w/2-(16/2),-1]) cube([(gt2_belt_width+1)+1, 16, (h/2)+1]);
	}
}

d=17;
w=42;
h=42;

motor_mount(d, w, h);

