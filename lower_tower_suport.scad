$fn=32;

segment_length = 50;
tower_distance = segment_length-3;

length = tower_distance + 2;
width = 20;
height = 24;

echo("length", length);


difference() {
color([0, 0, 1]) cube([length, width, height]);

// Rod holes
color([0, 1, 0]) translate([4+1.5, width/2, -0.1]) cylinder(r=4,h=30);
color([0, 1, 0]) translate([length-(4+1.5), width/2, -0.1]) cylinder(r=4,h=30);

// rod holding threaded screw holes
translate([4+1.5, width/2, height/2]) rotate([90,0,0]) 
	cylinder(r=5/2, h=11);
translate([length-(4+1.5), width/2, height/2]) rotate([90,0,0]) 
	cylinder(r=5/2, h=11);

// bearing holes
color([1, 0, 0]) translate([length/2, 7, height/2]) rotate([90,0,0]) 
	cylinder(r=22/2, h=7.1);
color([1, 0, 0]) translate([length/2, 20+0.1, height/2]) rotate([90,0,0]) 
	cylinder(r=22/2, h=7.1);

// bearing through hole
translate([length/2, 25, height/2]) rotate([90,0,0]) 
	cylinder(r=20/2, h=30);


// mounting screw holes
//translate([(length/2)-(22/2), width/2, -0.1]) cylinder(r=5/2,h=height+0.2);
translate([11, 4, -0.1]) cylinder(r=5/2,h=16);
translate([11, width-4, -0.1]) cylinder(r=5/2,h=16);
translate([length-11, 4, -0.1]) cylinder(r=5/2,h=16);
translate([length-11, width-4, -0.1]) cylinder(r=5/2,h=16);

// belt path
translate([(length/2)-(12/2), (width/2)-(8/2), (height/2)+0.1]) cube([12,8,height/2]);

};
