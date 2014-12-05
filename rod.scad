use <local.scad>
use <colours.scad>

module rod(l, r) {
    color(steel) render() union() {
        translate([0, 0, l-1]) cylinder(r1=r, r2=r-1, h=1);
        translate([0, 0, 1])   cylinder(r=r, h=l-2);
        cylinder(r1=r-1, r2=r, h=1);
    }
}

function rod_conn(conn, l, r) = 
	(conn == "top")    ? new_cs(origin=[0,0,l], axes=[[0,0,1],[1,0,0]]) :
	(conn == "bottom") ? new_cs(origin=[0,0,0], axes=[[0,0,1],[1,0,0]]) :
	"Error unknown connection";

rod(300, 4);
//rod_cs = rod_conn("bottom",300, 4);
//show_cs(rod_cs);
