use <../bearings.scad>
use <../boxes.scad>

module lower_mount(d, w, h) {
	translate([0,-w/2,-h/2])
	union() {
		difference() {
			cube([d,w,h]);

			// see inside!
			//translate([d-1.5,w/2,h/2]) rotate([0,90,0]) cylinder(h=8, r=22/2, center=true);


			// axel hole
			translate([d/2,w/2,h-5]) rotate([0,90,0]) cylinder(h=d+2, r=1, center=true);


			// belt clearance
			// 4mm end mill cutting 14mm deep?
			translate([d/2,w/2,h-(10/2)]) roundedBox([8, 14, 14], 4/2, true);

			translate([d/2,0+((15/2)+1),5]) cylinder(r=4, h=h+1);
			translate([d/2,w-((15/2)+1),5]) cylinder(r=4, h=h+1);
		}
		
		translate([d/2,w/2,h-5]) rotate([0,90,0]) cylinder(h=7, r=10/2, center=true);
	}
}

d=17;
w=42;
h=24;

lower_mount(d, w, h);