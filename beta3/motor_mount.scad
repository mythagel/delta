use <../nema17.scad>
d=17;
w=42;
h=42;


difference() {
	cube([d,w,h]);

	// rod support
	union() {
		// 8mm rod, m6 internal thread
		translate([d/2,0+(4+1),-1]) cylinder(r=4, h=15+1);
		translate([d/2,0+(4+1),-1]) cylinder(r=3, h=42+2);

		translate([d/2,w-(4+1),-1]) cylinder(r=4, h=15+1);
		translate([d/2,w-(4+1),-1]) cylinder(r=3, h=42+2);
	}

	// center bore clearance
	translate([-1,w/2,h/2]) rotate([90,0,90]) cylinder(r=22/2, h=d+2);


	translate([d/2,w/2,h/2]) union() {
		// screw thread holes
		translate([0,-31/2,-31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
		translate([0,31/2,-31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
		translate([0,-31/2,31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
		translate([0,31/2,31/2]) rotate([90,0,90]) cylinder(r=1.5, h=d+2, center=true);
	}

}
$fn=32;
translate([0,w/2,h/2]) rotate([0,90,0]) nema17();

