use <colours.scad>
use <local/local.scad>

r = 200/2;	// radius
segment_length = 30;
tower_distance = segment_length-3;

t = 2 * asin((segment_length/2)/r);
t0 = 2 * asin((tower_distance/2)/r);

module base() {

	a0 = [r * cos(0-t), r * sin(0-t)];
	a1 = [r * cos(0+t), r * sin(0+t)];
	b0 = [r * cos(120-t), r * sin(120-t)];
	b1 = [r * cos(120+t), r * sin(120+t)];
	c0 = [r * cos(240-t), r * sin(240-t)];
	c1 = [r * cos(240+t), r * sin(240+t)];

	color(steel) difference() {
		linear_extrude(height=6) polygon([a0,a1,b0,b1,c0,c1]);
		for ( i = [0 : 120 : 240] ) {
			translate([(r-12) * cos(i-t0), (r-12) * sin(i-t0), -0.5]) cylinder(r=4,h=7);
			translate([(r-12) * cos(i+t0), (r-12) * sin(i+t0), -0.5]) cylinder(r=4,h=7);
		}
	}
}

function base_conn(conn) = 
	(conn == "center")    ? new_cs(origin=[0,0,6], axes=[[0,0,1],[1,0,0]]) :
	(conn == 0) ? new_cs(origin=[(r-12) * cos(0-t0), (r-12) * sin(0-t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 1) ? new_cs(origin=[(r-12) * cos(0+t0), (r-12) * sin(0+t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 2) ? new_cs(origin=[(r-12) * cos(120-t0), (r-12) * sin(120-t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 3) ? new_cs(origin=[(r-12) * cos(120+t0), (r-12) * sin(120+t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 4) ? new_cs(origin=[(r-12) * cos(240-t0), (r-12) * sin(240-t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 5) ? new_cs(origin=[(r-12) * cos(240+t0), (r-12) * sin(240+t0),0], axes=[[0,0,1],[1,0,0]]) :
	"Error unknown connection";


/* edge length of printable square area
 * The actual printable area is the circle
 * that bounds this square. */
print_size=100;
color([0, 0, 1]) translate([0, 0, 8]) linear_extrude(height=0.6) square(print_size, center=true);

// Radius of the printable area
print_radius = sqrt(pow(print_size,2)+pow(print_size,2))/2;
color([1, 0, 0]) translate([0, 0, 8]) linear_extrude(height=0.5) circle(print_radius);
color([0, 1, 0]) translate([0, 0, 0.1]) linear_extrude(height=0.6) circle(r);

base();
