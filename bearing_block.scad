use <threads.scad>
use <local.scad>

h = 16;
d = 8;

module bearing_block() {	
	difference() {
		union() {
			translate([-12,-d/2,0]) cube([24, d, h]);
			translate([0,0,h]) rotate([90,0,0]) cylinder(r=12, h=d, center=true);
		}

		color([1,0,0]) union() {
			translate([0,0,h]) rotate([90,0,0]) cylinder(r=10, h=d+1, center=true);
			translate([0,-0.5,h]) rotate([90,0,0]) cylinder(r=11, h=7.5, center=true);
		}

		translate([-8,0,0]) metric_thread(3, 0.8, 10, internal=true);
		translate([8,0,0]) metric_thread(3, 0.8, 10, internal=true);
	}
}

function bearing_block_conn(conn) = 
	(conn == "bearing")    ? new_cs(origin=[0,3,h], axes=[[0,-1,0],[0,0,1]]) :
	(conn == "left") ? new_cs(origin=[0,0,0], axes=[[0,0,1],[1,0,0]]) :
	(conn == "right") ? new_cs(origin=[0,0,0], axes=[[0,0,1],[1,0,0]]) :
	"Error unknown connection";

bearing_block();
show_cs(bearing_block_conn("bearing"));
