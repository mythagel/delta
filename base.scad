use <colours.scad>

r = 300/2;	// radius

module base() {
	t = 10;	// degrees to truncate (30=hexagon)

	a0 = [r * cos(0-t), r * sin(0-t)];
	a1 = [r * cos(0+t), r * sin(0+t)];
	b0 = [r * cos(120-t), r * sin(120-t)];
	b1 = [r * cos(120+t), r * sin(120+t)];
	c0 = [r * cos(240-t), r * sin(240-t)];
	c1 = [r * cos(240+t), r * sin(240+t)];

	color(steel) linear_extrude(height=6) polygon([a0,a1,b0,b1,c0,c1]);
}

/* edge length of printable square area
 * i.e. this is a 128x128 min printable area
 * The actual printable area is greater. */
print_size=128;
//color([0, 0, 1]) translate([0, 0, 16]) linear_extrude(height=0.6) square(print_size, center=true);

// Radius of the printable area
print_radius = sqrt(pow(print_size,2)+pow(print_size,2))/2;
//color([1, 0, 0]) translate([0, 0, 16]) linear_extrude(height=0.5) circle(print_radius);


color([0, 1, 0]) translate([0, 0, 0.1]) linear_extrude(height=0.6) circle(r);

base();