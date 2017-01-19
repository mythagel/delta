use <../nema17.scad>
use <../bearings.scad>
use <../beta3/gt2_pulley.scad>
include <../beta3/gt2_belt.scad>
use <e3d_v6_all_metall_hotend.scad>

od = 300 + 6;   // ID == 300
y_carriage_position = 220;  // 56 - 244
x_carriage_position = 220;  //56 - 244
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

module bushing() {
    difference() {
        cylinder(r=10/2, h = 10, center=true);
        cylinder(r=8/2, h=10+1, center=true);
    }
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
        translate([0,0,-0.5]) cylinder(r=3/2, h=(gt2_belt_width + 0.25*2 + cap_h*2) + 1);
        translate([0,0,(gt2_belt_width + 0.25*2 + cap_h*2) - 2]) cylinder(r=5/2, h=3);
    }
}

module gt2_belt(l) {
    cube([gt2_belt_height, l, gt2_belt_width]);
}

module groove_mount() {
    //https://github.com/josefprusa/Prusa3-vanilla/blob/master/src/groovemount.scad
    union(){
        //cube([50,20,6]);

        translate([5,10,0])cylinder(r=3.5,h=3.2);
        translate([45,10,0])cylinder(r=3.5,h=3.2);

        translate([5,10,3.5])cylinder(r=2,h=3.5);
        translate([45,10,3.5])cylinder(r=2,h=3.5);


        translate([20,10,0])cylinder(r=6.1,h=10);
        translate([20,10,4.5])cylinder(r=8.5,h=10);

        translate([20-6.1,0,0]) cube([12.2,10,10]);

        translate([20-8.5,0,4.5]) cube([17,10,10]);
    }
}

module extruder() {
}

module corexy(x, y) {
    carriage_width = 36;
    x_width = x - 6;
    y_width = y - 6;
    
    angle_w = 3;
    angle_h = 30;
    
    rail_z = /*rod_d*/8/2 + 2;
    
    y_rail_l = y_width; // 350
    echo("y_rail_l", y_rail_l);
    
    y_rail_inset = 42/2;  // TODO calculate clearance for carriages & motors.
                          // Currently using nema17 od
    
    x_rail_l = 250;
    echo("x_rail_l", x_rail_l);
    
    a_belt_z =  rail_z + 8/2 + 3 + 7;
    b_belt_z = rail_z + 8/2 + 3;
    
    // frame
    %difference() {
        union() {
            translate([x_width, 0, angle_h]) rotate([0,180,0]) angle30(x_width);
            translate([0, y_width, angle_h]) rotate([0,180,180]) angle30(x_width);
        }
        
        // holes for y axis rails
        translate([y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
        translate([x_width - y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
    }
    
    // y axis rails
    translate([y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
    translate([x_width - y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
    
    // x axis rails
    translate([y_rail_inset + 8/2, y_carriage_position - carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    translate([y_rail_inset + 8/2, y_carriage_position + carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    
    carriage_h = 12;
    carriage_depth = 25;
    
    // testing carriage
    // TODO need to fix carriages for new belt height
    module y_carriage() {
        
        // TODO bearing, rod, & idler mounts
        difference() {
            translate([carriage_depth/2 - 12/2, 0, 0]) cube([carriage_depth, carriage_width + 8*2, carriage_h], center=true);
            
            // rod through hold
            rotate([90,0,0]) cylinder(r = 9/2, h=carriage_width + 8*2 + 1, center=true);
            
            // bushing mounts
            translate([0,(carriage_width+16)/2-1,0]) rotate([90,0,0]) cylinder(r=5.1, h =10, center=true);
            translate([0,-(carriage_width+16)/2+1,0]) rotate([90,0,0]) cylinder(r=5.1, h =10, center=true);
            
            // rod mounts
            translate([(carriage_depth-12/2)-20,carriage_width/2,0]) rotate([0,90,0]) cylinder(r=8.1/2, h=30);
            translate([(carriage_depth-12/2)-20,-carriage_width/2,0]) rotate([0,90,0]) cylinder(r=8.1/2, h=30);
        }
        
        translate([0, -(carriage_width+16)/2 + 5, 0]) rotate([-90,0,0]) bushing();
        translate([0, (carriage_width+16)/2 - 5, 0]) rotate([-90,0,0]) bushing();
        
        color([0,0,1]) translate([/*idler_id*/12+/*gt2 belt width*/2, (carriage_width/2) - 8, 8/2 + 2]) idler_pulley();
        color([1,0,0]) translate([/*idler_id*/12+/*gt2 belt width*/2, -(carriage_width/2) + 8, 8/2 + 2 + 7]) idler_pulley();
    }
    translate([y_rail_inset, y_carriage_position, rail_z]) y_carriage();
    translate([y_width-y_rail_inset, y_carriage_position, rail_z]) rotate([0,0,180]) y_carriage();
    
    module x_carriage() {
        // TODO groovemount
        translate([0,0,10]) rotate([0,180,0]) e3d();

        x_carriage_w = 25;
        difference() {
            translate([0,0,0]) cube([x_carriage_w,carriage_width+8*2,carriage_h], center=true);

            translate([0, -carriage_width/2, 0]) rotate([0,90,0]) cylinder(r=9/2, h=40, center=true);
            translate([0, carriage_width/2, 0]) rotate([0,90,0]) cylinder(r=9/2, h=40, center=true);

            // bushing mounts
            union() {
                translate([x_carriage_w/2 - 10,-carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
                translate([x_carriage_w/2 - 10,carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
                translate([-x_carriage_w/2 - 1,-carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
                translate([-x_carriage_w/2 - 1,carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
            }

            //translate([12.1,-50/2,3]) rotate([0,0,90]) groove_mount();
        }
        translate([-(x_carriage_w/2) + 5,-carriage_width/2,0]) rotate([0,90,0]) bushing();
        translate([(x_carriage_w/2) - 5,-carriage_width/2,0]) rotate([0,90,0]) bushing();
        translate([-(x_carriage_w/2) + 5,carriage_width/2,0]) rotate([0,90,0]) bushing();
        translate([(x_carriage_w/2) - 5,carriage_width/2,0]) rotate([0,90,0]) bushing();
    }
    translate([x_carriage_position, y_carriage_position, rail_z]) x_carriage();
    
    // somewhat fudged....
    module belts() {
        color([1,0,0]) {
            translate([42/2 + 12/2, 42/2, a_belt_z]) gt2_belt(y_carriage_position - 28);
            translate([42/2 - 15/2, 42/2, a_belt_z]) gt2_belt(270);
            translate([42/2 - 15/2, y_width-5, a_belt_z]) rotate([0,0,-92.5]) gt2_belt(245);
            translate([x_width - (42/2 + 15/2), y_width - 16, a_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position - 28);
            translate([y_rail_inset+10, y_carriage_position - 3, a_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width -33, a_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
        
        color([0,0,1]) {
            translate([x_width - 42/2 - 7.5, 42/2, b_belt_z]) gt2_belt(y_carriage_position - 28);
            translate([x_width - 42/2 + 6, 42/2, b_belt_z]) gt2_belt(270);
            translate([x_width - 42/2 + 6, y_width - 5, b_belt_z]) rotate([0,0,92.5]) gt2_belt(245);
            translate([(42/2 + 9), y_width - 16, b_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position - 28);
            translate([y_rail_inset+10, y_carriage_position + 3, b_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width/2 - 23, b_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
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
        translate([x_width, 0, 25]) rotate([0,180,0]) angle30(x_width);
        translate([0, y_width, 25]) rotate([0,180,180]) angle30(x_width);
    }
}

// testing z motor
module z_platform() {
    translate([od/2, od - 45, 42/2+ 3]) rotate([-90,0,0]) union () color([0,1,0]) {
        nema17();
        translate([0,0,3+16]) rotate([180,0,0]) offset_idler();//gt2_pulley();
    }
    translate([od/2 - 60, od - 25/2, 0]) rod8(od);
    translate([od/2 + 60, od - 25/2, 0]) rod8(od);
    
    color([0,1,0]) {
        translate([od/2 - 7.5, od - 35, 42/2]) rotate([90,0,0]) gt2_belt(350);
        translate([od/2 + 5, od - 35, 42/2]) rotate([90,0,0]) gt2_belt(350);
    }
}

union () {
    frame(od, od, od+75);
    translate([3,3,od - 25]) corexy(od, od);
    translate([3,3, 40]) lower_frame(od, od);
    translate([3, od - (200+42) - 3, 3]) psu();

    //translate([od/2 + 100, od/2 + 20, od+35]) rotate([0,0,-90]) arduino_ramps();
    //translate([200,50,od+62]) rotate([0,0,90]) lcd();

    z_platform();

    translate([od/2 - 214/2, od/2 - 214/2, od - z_position - 30]) heatbed();
}


/*difference() {
    square([gt2_belt_width+2.5, (12 + (gt2_belt_height*2))/2]);
projection(cut = false) rotate([0,90,0]) idler_pulley();
}*/