include <gt2_belt.scad>

module motor_mount(d, w, h) {
	translate([0,-w/2,-h/2]) difference() {
		cube([d,w,h]);

			// see inside!
			//translate([d-1.5,w/2,h/2]) rotate([0,90,0]) cylinder(h=10, r=40, center=true);

		// rod support (machined from top)
		union() {
			// 8mm rod, m6 internal thread
			translate([d/2,0+((15/2)+1),-1]) cylinder(r=4, h=20+1);
			translate([d/2,0+((15/2)+1),-1]) cylinder(r=3, h=42+2);

			translate([d/2,w-((15/2)+1),-1]) cylinder(r=4, h=20+1);
			translate([d/2,w-((15/2)+1),-1]) cylinder(r=3, h=42+2);
		}

		// motor flange clearance (machined from back)
		translate([-1,w/2,h/2]) rotate([90,0,90]) cylinder(r=22/2, h=2+1);
		// center bore clearance (machined from front)
		translate([-1,w/2,h/2]) rotate([90,0,90]) cylinder(r=16/2, h=d+2);

		// screw thread holes (machined from front)
		translate([d/2,w/2,h/2]) union() {
			translate([0,-31/2,-31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
			translate([0,31/2,-31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
			translate([0,-31/2,31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
			translate([0,31/2,31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
		}

		// belt guide (machined from front)
		translate([(d/2)+((gt2_belt_width-1)/2),w/2-(16/2),-1]) cube([(gt2_belt_width+1)+1, 16, (h/2)+1]);
	}
}

d=17;
w=42;
h=42;

motor_mount(d, w, h);

