
module motor_mount() {
	difference() {
		cube([20,6,42.3]);
		translate([20,0,0]) rotate([0,-20,0]) cube([20,6,50]);
		rotate([0,90,0]) translate([-5.65,3,-0.5]) cylinder(r=1.5, h=20);
		rotate([0,90,0]) translate([-42.3+5.65,3,-0.5]) cylinder(r=1.5, h=20);

		rotate([0,90,0]) translate([-5.65,3,3]) cylinder(r=5.5/2, h=20);
		rotate([0,90,0]) translate([-42.3+5.65,3,3]) cylinder(r=5.5/2, h=20);
	}
}

motor_mount();