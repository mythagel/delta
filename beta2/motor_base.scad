use <../nema17.scad>

width = 42.2 + (10*2);

difference() {

	// body
	cube([width, 10, 42.3], center=true);

	// motor space
	translate([0, 8, 0])  cube([42.3, 20, 43], center=true);

// nema17 mounting holes
	for (a = [0:90:359]) {
		translate([0,-1,0]) rotate([90, 90, 0]) rotate([0, 0, a]) translate([15.5, 15.5, 0])
		cylinder(r=2, h=10, center=true, $fn=12);
	}

// rod holes
	translate([(width/2)-5, 0, 0]) cylinder(r=4, h=25);
	translate([5-(width/2), 0, 0]) cylinder(r=4, h=25);

// motor center
	translate([0,-1,0]) rotate([90,0,0]) cylinder(r=11, h=10, center=true);

}

translate([0,-5,0]) rotate([270,0,0]) nema17();

// rods
translate([(width/2)-5, 0, 0]) cylinder(r=4, h=300);
translate([5-(width/2), 0, 0]) cylinder(r=4, h=300);