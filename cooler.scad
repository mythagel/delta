include <colours.scad>

module cooler_top() {
	
	color(al) difference() {
		cylinder(r=21/2, h=6);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=7);

		translate([6, 0, -0.5]) cylinder(r=2.5, h=7);
		translate([0, 6, -0.5]) cylinder(r=2.5, h=7);

		translate([-6, 0, -0.5]) cylinder(r=2.5, h=5.5);
		translate([0, -6, -0.5]) cylinder(r=2.5, h=5.5);

		difference() {
			rotate_extrude() translate([3.5, 0, 0]) polygon( points=[[0,0],[5,0],[5,5],[0,5]] );
			translate([-8.5, 0, 0]) cube(size = [8.5, 8.5, 5]);
			translate([0, -8.5, 0]) cube(size = [8.5, 8.5, 5]);
			cube(size = [8.5, 8.5, 5]);
		}
	}
}

module cooler_body() {
	height = 30 - 12;
	color(al) difference() {
		cylinder(r=21/2, h=height);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=height+1);

		translate([6, 0, -0.5]) cylinder(r=2.5, h=height+1);
		translate([0, 6, -0.5]) cylinder(r=2.5, h=height+1);
		translate([-6, 0, -0.5]) cylinder(r=2.5, h=height+1);
		translate([0, -6, -0.5]) cylinder(r=2.5, h=height+1);
	}
}

module cooler_base() {
	color(al) difference() {
		cylinder(r=21/2, h=6);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=7);

		translate([6, 0, -0.5]) cylinder(r=2.5, h=5.5);
		translate([0, 6, -0.5]) cylinder(r=2.5, h=5.5);
		translate([-6, 0, -0.5]) cylinder(r=2.5, h=5.5);
		translate([0, -6, -0.5]) cylinder(r=2.5, h=5.5);

		difference() {
			rotate_extrude() translate([3.5, 0, 0]) square(5,5);
			translate([-8.5, 0, -0.5]) cube(size = [8.5, 8.5, 6]);
			translate([0, -8.5, -0.5]) cube(size = [8.5, 8.5, 6]);
		}
	}
}

module cooler() {
	height = 30 - 12;
	union() {
		translate([0, 0, height+5.9]) cooler_top();
		translate([0, 0, 6]) cooler_body();
		translate([0, 0, 6.1]) rotate([180, 0, 0]) cooler_base();
	}
}

cooler();
