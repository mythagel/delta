use <../nema17.scad>
use <../bearings.scad>
use <../beta3/gt2_pulley.scad>
include <../beta3/gt2_belt.scad>

od = 300;
y_carriage_position = 125;
x_carriage_position = 120;
z_position = 200;

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

module offset_idler() {
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

module idler_pulley() {
    minor_d = 12;
    major_d = minor_d + (gt2_belt_height*2);
    echo("idler_pulley.major_d", major_d);
    cap_h = 1;
    difference() {
        union () {
            cylinder(r=major_d/2, h=cap_h);
            translate([0,0,cap_h]) cylinder(r=minor_d/2, h=gt2_belt_width + 0.25*2);
            translate([0,0,gt2_belt_width + 0.25*2 + cap_h]) cylinder(r=major_d/2, h=cap_h);
        }
        translate([0,0,-0.5]) cylinder(r=5/2, h=(gt2_belt_width + 0.25*2 + cap_h*2) + 1);
    }
}

module gt2_belt(l) {
    cube([gt2_belt_height, l, gt2_belt_width]);
}

module corexy(x, y) {
    carriage_width = 60;
    x_width = x - 6;
    y_width = y - 6;
    
    angle_w = 3;
    angle_h = 30;
    
    rail_z = /*rod_d*/8/2 + 2;
    
    y_rail_l = y_width; // 350
    echo("y_rail_l", y_rail_l);
    
    y_rail_inset = 42/2;  // TODO calculate clearance for carriages & motors.
                          // Currently using nema17 od
    
    x_rail_l = (x_width - y_rail_inset*2) - 24/2; // 350
    echo("x_rail_l", x_rail_l);
    
    // frame
    difference() {
        union() {
            translate([x_width, 0, angle_h]) rotate([0,180,0]) angle30(x_width);
            translate([0, y_width, angle_h]) rotate([0,180,180]) angle30(x_width);
        }
        
        // holes for y axis rails
        translate([y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
        translate([x_width - y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
    }
    
    // y axis rails
    %translate([y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
    //translate([y_rail_inset, angle_w/2 + angle_w, rail_z]) rotate([-90,0,0]) rod_clamp();
    //translate([y_rail_inset, y_width-(angle_w/2 + angle_w), rail_z]) rotate([-90,0,0]) rod_clamp();
    %translate([x_width - y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
    //translate([x_width - y_rail_inset, angle_w/2 + angle_w, rail_z]) rotate([-90,0,0]) rod_clamp();
    //translate([x_width - y_rail_inset, y_width-(angle_w/2 + angle_w), rail_z]) rotate([-90,0,0]) rod_clamp();
    
    // x axis rails
    translate([y_rail_inset + 12/2, y_carriage_position - carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    translate([y_rail_inset + 12/2, y_carriage_position + carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    
    // testing carriage
    // TODO need to fix carriages for new belt height
    module y_carriage() {
        carriage_od = 24;
        
        // TODO bearing, rod, & idler mounts
        translate([8/2, 0, 0]) cube([carriage_od+8, carriage_width + 8*2, carriage_od], center=true);
        
        translate([0, 8+8, 0]) rotate([-90,0,0]) lm8uu();
        translate([0, -24 - 8 -8, 0]) rotate([-90,0,0]) lm8uu();
        
        color([0,0,1]) translate([/*idler_id*/12+/*gt2 belt width*/2, carriage_width/2 - /*idler_od*/16/2, carriage_od/2 +/*idler_h*/16]) rotate([180,0,0]) offset_idler();
        color([1,0,0]) translate([/*idler_id*/12+/*gt2 belt width*/2, -carriage_width/2 + /*idler_od*/16/2, carriage_od/2 + 2]) offset_idler();
    }
    translate([y_rail_inset, y_carriage_position, rail_z]) y_carriage();
    translate([y_width-y_rail_inset, y_carriage_position, rail_z]) rotate([0,0,180]) y_carriage();
    
    module x_carriage() {
        // TODO groovemount
        translate([0,0,7.5]) cube([24,75,4], center=true);
        translate([-12,-30,0]) rotate([0,90,0]) lm8uu();
        translate([-12,30,0]) rotate([0,90,0]) lm8uu();
    }
    translate([x_carriage_position, y_carriage_position, rail_z]) x_carriage();
    
    // somewhat fudged....
    a_belt_z =  rail_z + 8/2 + 2 + 7.5;
    b_belt_z = rail_z + 8/2 + 3;
    module belts() {
        

        color([1,0,0]) {
            translate([42/2 + 12/2, 42/2, a_belt_z]) gt2_belt(y_carriage_position - 40);
            translate([42/2 - 15/2, 42/2, a_belt_z]) gt2_belt(270);
            translate([42/2 - 15/2, y_width-5, a_belt_z]) rotate([0,0,-92.5]) gt2_belt(245);
            translate([x_width - (42/2 + 15/2), y_width - 16, a_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position - 40);
            translate([y_rail_inset+10, y_carriage_position - 14, a_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width -46, a_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
        
        color([0,0,1]) {
            translate([x_width - 42/2 - 7.5, 42/2, b_belt_z]) gt2_belt(y_carriage_position - 40);
            translate([x_width - 42/2 + 6, 42/2, b_belt_z]) gt2_belt(270);
            translate([x_width - 42/2 + 6, y_width - 5, b_belt_z]) rotate([0,0,92.5]) gt2_belt(245);
            translate([(42/2 + 9), y_width - 16, b_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position -40);
            translate([y_rail_inset+10, y_carriage_position + 16, b_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width/2 - 46, b_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
    }
    belts();
    
    // crossover idlers
    color([0,0,1]) translate([x_width-y_rail_inset, y_width-/*idler major_d*/16/2 - 4, b_belt_z -1.25]) idler_pulley();
    color([0,0,1]) translate([y_rail_inset + 16, (y_width-angle_h) + /*idler major_d*/16/2, b_belt_z - 1.25]) idler_pulley();
    color([1,0,0]) translate([y_rail_inset, y_width-/*idler major_d*/16/2 - 4, a_belt_z - 1.25]) idler_pulley();
    color([1,0,0]) translate([x_width-y_rail_inset - 16, (y_width-angle_h) + /*idler major_d*/16/2, a_belt_z - 1.25]) idler_pulley();
    
    // Motors sit on top of rail
    // Circle for motor flange must be milled
    color([1,0,0]) translate([42/2, 42/2, angle_h]) rotate([0,180,0]) union() {
        nema17();
        translate([0,0,20]) rotate([180,0,0]) offset_idler();//gt2_pulley();
    }
    color([0,0,1]) translate([x_width - (42/2), 42/2, angle_h]) rotate([0,180,0])     union() {
        nema17();
        translate([0,0,3]) offset_idler();//gt2_pulley();
    }
    
    
}

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

module lower_frame(x, y) {
    x_width = x - 6;
    y_width = y - 6;
    
    union() {
        translate([x_width, 0, 25]) rotate([0,180,0]) angle25(x_width);
        translate([0, y_width, 25]) rotate([0,180,180]) angle25(x_width);
    }
}

// testing z motor
module z_platform() {
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

//frame(od, od, od+75);
translate([3,3,od - 25]) corexy(od, od);
//translate([3,3, 40]) lower_frame(od, od);
//translate([3, od - (200+42) - 3, 3]) psu();

//translate([od/2 + 100, od/2 + 20, od+35]) rotate([0,0,-90]) arduino_ramps();
//translate([200,50,od+62]) rotate([0,0,90]) lcd();

//z_platform();

//translate([od/2 - 214/2, od/2 - 214/2, od - z_position - 30]) heatbed();