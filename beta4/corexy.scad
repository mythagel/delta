use <../nema17.scad>
use <../bearings.scad>

module angle(w, h, l, wall) {
    difference() {
        cube([l, h, w]);
        translate([-1, wall, wall]) cube([l+2, h, w]);
    }
}

module angle25(l) {
    angle(25, 25, l, 3);
}

module rod8(l) {
    cylinder(r=7.89/2, l);
}

module frame(x, y, z) {
    module face(x, y) union() {
        angle25(x);
        translate([x, y, 0]) rotate([0,0,180]) angle25(x);

        translate([x, 0, 0]) rotate([0,0,90]) {
            angle25(y);
            translate([y, x, 0]) rotate([0,0,180]) angle25(y);
        }
    }

    // bottom
    face(x, y);

    // top
    translate([0, y, z]) rotate([180,0,0]) face(x, y);

    // back vertical
    union () {
        translate([0,0,z-25]) rotate([0,90,0]) angle25(z-25*2);
        translate([x,0,z-25]) rotate([-90,90,0]) angle25(z-25*2);
    }

    // front vertical
    union() {
        translate([0,y,z-25]) rotate([0,90,-90]) angle25(z-25*2);
        translate([x,y,z-25]) rotate([-90,90,90]) angle25(z-25*2);
    }
}

module rod_clamp() {
    od = 20;
    h = 3;
    difference() {
        cube([od, od, h], center=true);
        translate([0, 0, 0]) cylinder(r=8/2, h=h+1, center=true);
    }
}

module idler() {
    gap = 7.5;
    major_d = 16;
    minor_d = 12;
    id = 5;
    difference() {
        union() {
            translate([0,0,gap*2]) cylinder(r=major_d/2, h=1);
            translate([0,0,gap]) cylinder(r=minor_d/2, h=gap);
            cylinder(r=major_d/2, h=gap);
        }
        translate([0,0,-0.5]) cylinder(r=id/2, h=((gap*2)+1) + 1);
    }
}

module corexy(x, y) {
    carriage_width = 60;
    x_width = x - 6;
    y_width = y - 6;
    angle_w = 3;
    
    // 1/2 angle iron air gap
    rail_z = (25-angle_w)/2;
    
    y_rail_l = y_width; // 350
    echo("y_rail_l", y_rail_l);
    y_rail_inset = 20;  // TODO calculate clearance for carriages.
    
    x_rail_l = (x_width - y_rail_inset*2) - 8; // 350
    echo("x_rail_l", x_rail_l);
    
    // frame
    difference() {
        union() {
            translate([x_width, 0, 25]) rotate([0,180,0]) angle25(x_width);
            translate([0, y_width, 25]) rotate([0,180,180]) angle25(x_width);
        }
        
        // holes for y axis rails
        translate([y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
        translate([x_width - y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
    }
    
    // y axis rails
    translate([y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
    //translate([y_rail_inset, angle_w/2 + angle_w, rail_z]) rotate([-90,0,0]) rod_clamp();
    //translate([y_rail_inset, y_width-(angle_w/2 + angle_w), rail_z]) rotate([-90,0,0]) rod_clamp();
    translate([x_width - y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
    //translate([x_width - y_rail_inset, angle_w/2 + angle_w, rail_z]) rotate([-90,0,0]) rod_clamp();
    //translate([x_width - y_rail_inset, y_width-(angle_w/2 + angle_w), rail_z]) rotate([-90,0,0]) rod_clamp();
    
    translate([y_rail_inset, x/2 - carriage_width/2- 8/2, rail_z]) rotate([-90,0,0]) lm8uu();
    translate([y_rail_inset, x/2 + carriage_width/2 - 24 + 8/2, rail_z]) rotate([-90,0,0]) lm8uu();
    
    // x axis rails
    translate([y_rail_inset + 4, x/2 - carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    translate([y_rail_inset + 4, x/2 + carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
}

od = 300;

module motors() {
    translate([43.2/2 + 3, (43.2/2 + 3),od]) rotate([0,180,0]) nema17();
    translate([od - (43.2/2 + 3), (43.2/2 + 3),od]) rotate([0,180,0]) nema17();
}

module heatbed() {
    cube([214, 214, 3]);
}

frame(od, od, od+75);
translate([3,3,od]) corexy(od, od);
//motors();
translate([od/2 - 214/2, od/2 - 214/2, 50]) heatbed();