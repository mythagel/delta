include <colours.scad>
use <local.scad>

r = 264/2;	// radius
segment_length = 30;
tower_distance = segment_length-3;
tower_inset = 12;

/* Variables for firmware */
/*  =========== Parameter essential for delta calibration ===================

            C, Y-Axis
            |                        |___| CARRIAGE_HORIZONTAL_OFFSET
            |                        |   \
            |_________ X-axis        |    \
           / \                       |     \  DELTA_DIAGONAL_ROD
          /   \                             \
         /     \                             \    Carriage is at printer center!
         A      B                             \_____/
                                              |--| END_EFFECTOR_HORIZONTAL_OFFSET
                                         |----| DELTA_RADIUS
                                     |-----------| PRINTER_RADIUS
*/

//DELTA_DIAGONAL_ROD = ;

DELTA_ALPHA_A = 210;
DELTA_ALPHA_B = 330;
DELTA_ALPHA_C = 90;

//DELTA_MAX_RADIUS = ?!?!?;

//END_EFFECTOR_HORIZONTAL_OFFSET = 33;
//CARRIAGE_HORIZONTAL_OFFSET = 18;

PRINTER_RADIUS = r - tower_inset;


DELTA_RADIUS = (PRINTER_RADIUS-END_EFFECTOR_HORIZONTAL_OFFSET-CARRIAGE_HORIZONTAL_OFFSET);


echo("DELTA_DIAGONAL_ROD", DELTA_DIAGONAL_ROD);

echo("DELTA_ALPHA_A", DELTA_ALPHA_A);
echo("DELTA_ALPHA_B", DELTA_ALPHA_B);
echo("DELTA_ALPHA_C", DELTA_ALPHA_C);

echo("DELTA_MAX_RADIUS", DELTA_MAX_RADIUS);

echo("END_EFFECTOR_HORIZONTAL_OFFSET", END_EFFECTOR_HORIZONTAL_OFFSET);
echo("CARRIAGE_HORIZONTAL_OFFSET", CARRIAGE_HORIZONTAL_OFFSET);

echo("PRINTER_RADIUS", PRINTER_RADIUS);

echo("DELTA_RADIUS", DELTA_RADIUS);

//  =========== Parameter essential for delta calibration ===================


t = 2 * asin((segment_length/2)/r);
t0 = 2 * asin((tower_distance/2)/r);

module base() {

	a0 = [r * cos(DELTA_ALPHA_A-t), r * sin(DELTA_ALPHA_A-t)];
	a1 = [r * cos(DELTA_ALPHA_A+t), r * sin(DELTA_ALPHA_A+t)];
	b0 = [r * cos(DELTA_ALPHA_B-t), r * sin(DELTA_ALPHA_B-t)];
	b1 = [r * cos(DELTA_ALPHA_B+t), r * sin(DELTA_ALPHA_B+t)];
	c0 = [r * cos(DELTA_ALPHA_C-t), r * sin(DELTA_ALPHA_C-t)];
	c1 = [r * cos(DELTA_ALPHA_C+t), r * sin(DELTA_ALPHA_C+t)];

	color(steel) difference() {
		linear_extrude(height=6) polygon([a0,a1,b0,b1,c0,c1]);
		for ( i = [DELTA_ALPHA_A, DELTA_ALPHA_B, DELTA_ALPHA_C] ) {
			translate([(r-tower_inset) * cos(i-t0), (r-tower_inset) * sin(i-t0), -0.5]) cylinder(r=4,h=7);
			translate([(r-tower_inset) * cos(i+t0), (r-tower_inset) * sin(i+t0), -0.5]) cylinder(r=4,h=7);
		}
	}
}

function base_conn(conn) = 
	(conn == "center")    ? new_cs(origin=[0,0,6], axes=[[0,0,1],[1,0,0]]) :
	(conn == 0) ? new_cs(origin=[(r-12) * cos(DELTA_ALPHA_A-t0), (r-12) * sin(DELTA_ALPHA_A-t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 1) ? new_cs(origin=[(r-12) * cos(DELTA_ALPHA_A+t0), (r-12) * sin(DELTA_ALPHA_A+t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 2) ? new_cs(origin=[(r-12) * cos(DELTA_ALPHA_B-t0), (r-12) * sin(DELTA_ALPHA_B-t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 3) ? new_cs(origin=[(r-12) * cos(DELTA_ALPHA_B+t0), (r-12) * sin(DELTA_ALPHA_B+t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 4) ? new_cs(origin=[(r-12) * cos(DELTA_ALPHA_C-t0), (r-12) * sin(DELTA_ALPHA_C-t0),0], axes=[[0,0,1],[1,0,0]]) :
	(conn == 5) ? new_cs(origin=[(r-12) * cos(DELTA_ALPHA_C+t0), (r-12) * sin(DELTA_ALPHA_C+t0),0], axes=[[0,0,1],[1,0,0]]) :
	"Error unknown connection";


/* edge length of printable square area
 * The actual printable area is the circle
 * that bounds this square. */
print_size=120;
color([0, 0, 1]) translate([0, 0, 8]) linear_extrude(height=0.6) square(print_size, center=true);

// Radius of the printable area
print_radius = sqrt(pow(print_size,2)+pow(print_size,2))/2;
color([1, 0, 0]) translate([0, 0, 8]) linear_extrude(height=0.5) circle(print_radius);
color([0, 1, 0]) translate([0, 0, 0.1]) linear_extrude(height=0.6) circle(r);

base();
