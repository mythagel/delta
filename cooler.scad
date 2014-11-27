
$fn=32;

module cooler_top() {
	
	difference() {
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
	difference() {
		cylinder(r=21/2, h=height);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=height+1);

		translate([6, 0, -0.5]) cylinder(r=2.5, h=height+1);
		translate([0, 6, -0.5]) cylinder(r=2.5, h=height+1);
		translate([-6, 0, -0.5]) cylinder(r=2.5, h=height+1);
		translate([0, -6, -0.5]) cylinder(r=2.5, h=height+1);
	}
}

module cooler_base() {
	difference() {
		cylinder(r=21/2, h=6);
		translate([0, 0, -0.5]) cylinder(r=2.5, h=7);

		translate([6, 0, -0.5]) cylinder(r=2.5, h=5.5);
		translate([0, 6, -0.5]) cylinder(r=2.5, h=5.5);
		translate([-6, 0, -0.5]) cylinder(r=2.5, h=5.5);
		translate([0, -6, -0.5]) cylinder(r=2.5, h=5.5);

		difference() {
			rotate_extrude() translate([3.5, 0, 0]) polygon( points=[[0,0],[5,0],[5,5],[0,5]] );
			translate([-8.5, 0, 0]) cube(size = [8.5, 8.5, 5]);
			translate([0, -8.5, 0]) cube(size = [8.5, 8.5, 5]);
			//cube(size = [8.5, 8.5, 5]);
		}
	}
}

module cooler() {
	height = 30 - 12;
	union() {
		translate([0, 0, height+6]) cooler_top();
		translate([0, 0, 6]) cooler_body();
		translate([0, 0, 6]) rotate([180, 0, 0]) cooler_base();
	}
}

cooler();
