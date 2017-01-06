use <../nema17.scad>
use <../bearings.scad>
use <../beta3/gt2_pulley.scad>

module angle(w, h, l, wall) {
    difference() {
        cube([l, h, w]);
        translate([-1, wall, wall]) cube([l+2, h, w]);
    }
}

module angle25(l) {
    angle(25, 25, l, 3);
}

module angle30(l) {
    angle(30, 30, l, 3);
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

module gt2_belt(l) {
    cube([2, l, 6]);
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
    
    y_rail_inset = 42/2;  // TODO calculate clearance for carriages & motors.
                          // Currently using nema17 od
    
    x_rail_l = (x_width - y_rail_inset*2) - 24/2; // 350
    echo("x_rail_l", x_rail_l);
    
    y_carriage_position = x_width/2 + 50;
    x_carriage_position = y_width/2 + 50;
    
    // frame
    difference() {
        union() {
            translate([x_width, 0, 25]) rotate([0,180,0]) angle30(x_width);
            translate([0, y_width, 25]) rotate([0,180,180]) angle30(x_width);
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
    
    // x axis rails
    translate([y_rail_inset + 12/2, y_carriage_position - carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    translate([y_rail_inset + 12/2, y_carriage_position + carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    
    // testing carriage
    module y_carriage() {
        carriage_od = 24;
        
        // TODO bearing, rod, & idler mounts
        translate([8/2, 0, 0]) cube([carriage_od+8, carriage_width + 8*2, carriage_od], center=true);
        
        translate([0, 8+8, 0]) rotate([-90,0,0]) lm8uu();
        translate([0, -24 - 8 -8, 0]) rotate([-90,0,0]) lm8uu();
        
        color([0,0,1]) translate([/*idler_id*/12+/*gt2 belt width*/2, carriage_width/2 - /*idler_od*/16/2, carriage_od/2 +/*idler_h*/16]) rotate([180,0,0]) idler();
        color([1,0,0]) translate([/*idler_id*/12+/*gt2 belt width*/2, -carriage_width/2 + /*idler_od*/16/2, carriage_od/2 + 2]) idler();
    }
    translate([y_rail_inset, y_carriage_position, rail_z]) y_carriage();
    translate([y_width-y_rail_inset, y_carriage_position, rail_z]) rotate([0,0,180]) y_carriage();
    
    module x_carriage() {
        // TODO groovemount
        translate([0,0,7.5]) cube([24,75,4], center=true);
        translate([-12,-30,0]) rotate([0,90,0]) lm8uu();
        translate([-12,30,0]) rotate([0,90,0]) lm8uu();
    }
    translate([x_carriage_position, y_carriage_position, 12]) x_carriage();
    
    // completely fudged....
    module belts() {
        
        a_belt_z = 25+7.5;
        color([1,0,0]) {
            translate([42/2 + 12/2, 42/2, a_belt_z]) gt2_belt(y_carriage_position - 40);
            translate([42/2 - 15/2, 42/2, a_belt_z]) gt2_belt(270);
            translate([42/2 - 15/2, y_width, a_belt_z]) rotate([0,0,-93]) gt2_belt(245);
            translate([x_width - (42/2 + 15/2), y_width - 16, a_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position - 40);
            translate([y_rail_inset+10, y_carriage_position - 14, a_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width -46, a_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
        
        b_belt_z = 25+1;
        color([0,0,1]) {
            translate([x_width - 42/2 - 7.5, 42/2, b_belt_z]) gt2_belt(y_carriage_position - 40);
            translate([x_width - 42/2 + 6, 42/2, b_belt_z]) gt2_belt(270);
            translate([x_width - 42/2 + 6, y_width - 2, b_belt_z]) rotate([0,0,93]) gt2_belt(245);
            translate([(42/2 + 9), y_width - 16, b_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position -40);
            translate([y_rail_inset+10, y_carriage_position + 16, b_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width/2 - 46, b_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
    }
    belts();
    
    //testing
    color([0,0,1]) translate([x_width-y_rail_inset, y_width-/*idler major_d*/16/2, 25+/*idler_h*/16]) rotate([180,0,0]) idler();
    color([1,0,0]) translate([y_rail_inset, y_width-/*idler major_d*/16/2, 25]) idler();
    
    // 16 == idler major_d
    color([1,0,0]) translate([x_width-y_rail_inset - 16, (y_width-25) + 4, 25]) idler();
    color([0,0,1]) translate([y_rail_inset + 16, (y_width-25)+4, 25+/*idler_h*/16]) rotate([180,0,0]) idler();
    
    color([1,0,0]) translate([42/2, (42/2 + 3), 25+/*motor shaft length*/20]) rotate([0,180,0]) union() {
        nema17();
        translate([0,0,20]) rotate([180,0,0]) idler();//gt2_pulley();
    }
    color([0,0,1]) translate([x_width - (42/2), (42/2 + 3), 25+/*motor shaft length*/20]) rotate([0,180,0])     union() {
        nema17();
        translate([0,0,3]) idler();//gt2_pulley();
    }
    
    
}

od = 300;

module psu() {
    cube([100, 200, 50]);
}

module arduino_ramps() color([0,0.5,0.5]) {
    translate([51,-10]) import ("ArduinoMegaBoard.stl");
    translate([95.3,-8.2,11]) import ("Ramps14_3D.stl");
}

module lcd() {
    color([0,0.5,0.5]) include <rrd_graphic_smart_controller.scad>
}

module heatbed() {
    cube([214, 214, 3]);
}

//frame(od, od, od+75);
translate([3,3,od - 25]) corexy(od, od);
//translate([3, od - (200+42) - 3, od+25 - 3]) psu();
//translate([od/2 + 100, od/2 + 20, od+35]) rotate([0,0,-90]) arduino_ramps();
//translate([200,50,od+62]) rotate([0,0,90]) lcd();

// testing z motor
union() {
    translate([od/2, od - 45, od + 50]) rotate([-90,0,0]) union () color([0,1,0]) {
        nema17();
        translate([0,0,3+16]) rotate([180,0,0]) idler();//gt2_pulley();
    }
    translate([od/2 - 60, od - 25/2, 0]) rod8(od);
    translate([od/2 + 60, od - 25/2, 0]) rod8(od);
    
    color([0,1,0]) {
        translate([od/2 - 7.5, od - 35,0]) rotate([90,0,0]) gt2_belt(350);
        translate([od/2 + 5, od - 35,0]) rotate([90,0,0]) gt2_belt(350);
    }
}

translate([od/2 - 214/2, od/2 - 214/2, 250]) heatbed();