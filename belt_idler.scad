use <local.scad>

h = (7*2) + 6;

module belt_idler() {
	module bearing_mount() {
		difference() {
			rotate([90,0,0]) cylinder(h=7, r=22/2, center=true);
			rotate([90,0,0]) translate([0, 0, -0.5]) cylinder(h=8, r=3.9, center=true);
		}
	}

	difference() {
		rotate([90,0,0]) cylinder(r=13/2, h=h, center=true);
		translate([0,-(h/2)+(7/2)-0.0001,0]) bearing_mount();
		translate([0,(h/2)-(7/2)+0.0001,0]) bearing_mount();
	}
}

function belt_idler_conn(conn) = 
	(conn == "a") ? new_cs(origin=[0,h/2,0], axes=[[0,-1,0],[0,0,1]]) :
	(conn == "b") ? new_cs(origin=[0,-h/2,0], axes=[[0,1,0],[0,0,1]]) :
	"Error unknown connection";

belt_idler();
a = belt_idler_conn("a");
b = belt_idler_conn("b");
show_cs(a);
show_cs(b);
