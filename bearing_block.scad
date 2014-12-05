use <threads.scad>
use <local.scad>

h = 16;

module bearing_block() {	
	difference() {
		union() {
			translate([-12,-4.5,0]) cube([24, 9, h]);
			translate([0,4.5,h]) rotate([90,0,0]) cylinder(r=12, h=9);
		}
		translate([0,5,h]) rotate([90,0,0]) cylinder(r=10, h=10);
		translate([0,5,h]) rotate([90,0,0]) cylinder(r=11, h=7);

		translate([-8,0,0]) metric_thread(3, 0.8, 10, internal=true);
		translate([8,0,0]) metric_thread(3, 0.8, 10, internal=true);
	}
}

function bearing_block_conn(conn) = 
	(conn == "bearing")    ? new_cs(origin=[0,-2,h], axes=[[0,1,0],[0,0,1]]) :
	(conn == "left") ? new_cs(origin=[0,0,0], axes=[[0,0,1],[1,0,0]]) :
	(conn == "right") ? new_cs(origin=[0,0,0], axes=[[0,0,1],[1,0,0]]) :
	"Error unknown connection";


bearing_block();
