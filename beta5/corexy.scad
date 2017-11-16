use <../nema17.scad>
use <../bearings.scad>
use <../beta3/gt2_pulley.scad>
include <../beta3/gt2_belt.scad>
use <../beta4/e3d_v6_all_metall_hotend.scad>

od = 350 + 6;   // ID == 300
z_width = 180;

y_carriage_position = 150;  // 56 - 244
x_carriage_position = 150;  //56 - 244
z_position = 280;    //48 - 220

module angle(w, h, l, wall) {
    difference() {
        cube([l, h, w]);
        translate([-1, wall, wall]) cube([l+2, h, w]);
    }
}

module channel(f, w, ft, wt, l) difference() {
    cube([l, w, f]);
    translate([-0.5, ft, wt]) cube([l+1, w-ft*2, f]);
}

translate([-70, 50, 0]) {
    rotate([180, 0, 0]) channel(50, 100, 6.7, 4.2, 500);
    translate([0,100, 0]) rotate([180, 0, 0]) channel(50, 100, 6.7, 4.2, 500);
}

module angle50(l) {
    angle(50, 50, l, 3);
}

module rod8(l) {
    cylinder(r=7.89/2, l);
}

module rod30(l) {
    cylinder(r=30/2, l);
}

module bushing() {
    difference() {
        cylinder(r=10/2, h = 10, center=true);
        cylinder(r=8/2, h=10+1, center=true);
    }
}

module m3_washer() {
    difference() {
        cylinder(r=7/2, h=0.5);
        translate([0,0,-0.5]) cylinder(r=3.2/2, h=1.5);
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

idler_pulley_major_d = 11.5;
idler_pulley_minor_d = 10;
module idler_pulley() translate([0,0,2]) {
    f623zz();
    translate([0,0,2]) m3_washer();
    // 0.5mm washer
    translate([0,0,4.5]) rotate([180,0,0]) f623zz();
}

module gt2_belt(l) {
    cube([gt2_belt_height, l, gt2_belt_width]);
}

module extruder() {
}

module inductive_sensor() {
    cylinder(r=12/2, h=62);
}

belt_space_od = 13.5;

module corexy(x, y) {
    all = true;
    frame = true;
    rails = true;
    carriages = true;
    carriage_y = true;
    carriage_x = true;
    hotend = false;
    belts = true;
    pulleys = true;
    motors = false;

    carriage_width = 36;
    x_width = x - 6;
    y_width = y - 6;
    
    angle_w = 3;
    
    // effectively the offset from zero to angle placement.
    angle_h = 31.5;
    
    rail_z = /*rod_d*/8/2;
    
    y_rail_l = 350;
    echo("y_rail_l", y_rail_l);
    
    y_rail_inset = 42/2;
    
    x_rail_l = 350;
    echo("x_rail_l", x_rail_l);
    
    b_belt_z = rail_z + 8/2 + 3/*bushing + wall thickness + bearing base*/ + 0.5;
    a_belt_z =  b_belt_z + 6/*belt width*/ + 2.5/*bearing base + bearing top*/ + 0.5;
    
    // frame
    if (all || frame) %difference() {
        union() {
            difference() {
                translate([0, 0, angle_h]) rotate([-90,0,0]) angle50(x_width);
                
                // Motor mounting holes
                translate([42/2, 42/2, angle_h]) cylinder(r=22.1/2, h=10, center=true);
                translate([x_width-42/2, 42/2, angle_h]) cylinder(r=22.1/2, h=10, center=true);
                
                // Motor screw holes
                union() {
                    translate([5.5,5.5,angle_h]) cylinder(r=4/2, h = 10, center=true);
                    translate([5.5,5.5+31,angle_h]) cylinder(r=4/2, h = 10, center=true);
                    translate([5.5+31,5.5+31,angle_h]) cylinder(r=4/2, h = 10, center=true);
                    translate([5.5+31,5.5,angle_h]) cylinder(r=4/2, h = 10, center=true);
                }
                translate([x_width - 42,0,0]) union() {
                    translate([5.5,5.5,angle_h]) cylinder(r=4/2, h = 10, center=true);
                    translate([5.5,5.5+31,angle_h]) cylinder(r=4/2, h = 10, center=true);
                    translate([5.5+31,5.5+31,angle_h]) cylinder(r=4/2, h = 10, center=true);
                    translate([5.5+31,5.5,angle_h]) cylinder(r=4/2, h = 10, center=true);
                }
            }
            translate([0, y_width, angle_h]) rotate([180,0,0]) angle50(x_width);
            
            translate([x_width, 0,angle_h]) rotate([-90,0,90]) angle50(y_width);
            translate([0, y_width,angle_h]) rotate([-90,0,-90]) angle50(y_width);
        }
        
        // holes for y axis rails
        translate([y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
        translate([x_width - y_rail_inset, -0.5, rail_z]) rotate([-90,0,0]) cylinder(r=8/2, y_rail_l+1);
    }
    
    // y axis rails
    if (all || rails) union() {
        translate([y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
        translate([x_width - y_rail_inset, 0, rail_z]) rotate([-90,0,0]) rod8(y_rail_l);
        
        // x axis rails
        translate([y_rail_inset + 8/2, y_carriage_position - carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
        translate([y_rail_inset + 8/2, y_carriage_position + carriage_width/2, rail_z]) rotate([0,90,0]) rod8(x_rail_l);
    }
    
    carriage_h = 12;
    carriage_depth = 25;
    carriage_block_width = carriage_width + 6*2;
    echo("carriage_block_width", carriage_block_width);
    
    // testing carriage
    // TODO need to fix carriages for new belt height
    module y_carriage() {
        
        // TODO bearing, rod, & idler mounts
        difference() {
            translate([carriage_depth/2 - (/*rod_d*/8/2 + /*bushing*/1 + /*wall thickness*/1), 0, 0]) cube([carriage_depth, carriage_block_width, carriage_h], center=true);
            
            // rod through hold
            rotate([90,0,0]) cylinder(r = 9/2, h=carriage_block_width + 1, center=true);
            
            // bushing mounts
            translate([0,(carriage_block_width)/2-1,0]) rotate([90,0,0]) cylinder(r=5.1, h =10, center=true);
            translate([0,-(carriage_block_width)/2+1,0]) rotate([90,0,0]) cylinder(r=5.1, h =10, center=true);
            
            // rod mounts
            translate([(carriage_depth-12/2)-20,carriage_width/2,0]) rotate([0,90,0]) cylinder(r=8.1/2, h=30);
            translate([(carriage_depth-12/2)-20,-carriage_width/2,0]) rotate([0,90,0]) cylinder(r=8.1/2, h=30);
            
            // pulley mounting holes (M3 threaded)
            translate([belt_space_od - /*gt2 belt width*/2, 0]) cylinder(r=3/2, h=30, center=true);
        }
        
        translate([0, -(carriage_block_width)/2 + 5, 0]) rotate([-90,0,0]) bushing();
        translate([0, (carriage_block_width)/2 - 5, 0]) rotate([-90,0,0]) bushing();
        
        color([0,0,1]) translate([belt_space_od - /*gt2 belt width*/2, 0, carriage_h/2]) m3_washer();
        color([0,0,1]) translate([belt_space_od - /*gt2 belt width*/2, 0, carriage_h/2 + 0.5]) idler_pulley();
        color([1,0,0]) translate([belt_space_od - /*gt2 belt width*/2, 0, carriage_h/2 + 8.5 + 0.5]) m3_washer();
        color([1,0,0]) translate([belt_space_od - /*gt2 belt width*/2, 0, carriage_h/2 + 8.5 + 1]) idler_pulley();
    }
    
    module x_carriage() {
        x_carriage_w = 25;
        x_carriage_h_offset = 0;
        x_carriage_h = carriage_h+x_carriage_h_offset;
        echo("x_carriage_h", x_carriage_h);
        difference() {
            translate([0,0,x_carriage_h_offset/2]) cube([x_carriage_w,carriage_block_width,x_carriage_h], center=true);

            translate([0, -carriage_width/2, 0]) rotate([0,90,0]) cylinder(r=9/2, h=40, center=true);
            translate([0, carriage_width/2, 0]) rotate([0,90,0]) cylinder(r=9/2, h=40, center=true);

            // bushing mounts
            union() {
                translate([x_carriage_w/2 - 10,-carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
                translate([x_carriage_w/2 - 10,carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
                translate([-x_carriage_w/2 - 1,-carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
                translate([-x_carriage_w/2 - 1,carriage_width/2,0]) rotate([0,90,0]) cylinder(r=5.1, h =11);
            }

            cylinder(r=(16+0.5)/2, h=carriage_h+40, center=true);
        }
        
        // belt mounts
        union() {
            translate([x_carriage_w/2 - (5/2)-1, 9, carriage_h/2]) cylinder(r=6/2, h=16);
            translate([x_carriage_w/2 - (5/2)-1, -9, carriage_h/2]) cylinder(r=6/2, h=16);
            translate([-x_carriage_w/2 + (5/2)+1, 9, carriage_h/2]) cylinder(r=6/2, h=16);
            translate([-x_carriage_w/2 + (5/2)+1, -9, carriage_h/2]) cylinder(r=6/2, h=16);
        }
        
        translate([-(x_carriage_w/2) + 5,-carriage_width/2,0]) rotate([0,90,0]) bushing();
        translate([(x_carriage_w/2) - 5,-carriage_width/2,0]) rotate([0,90,0]) bushing();
        translate([-(x_carriage_w/2) + 5,carriage_width/2,0]) rotate([0,90,0]) bushing();
        translate([(x_carriage_w/2) - 5,carriage_width/2,0]) rotate([0,90,0]) bushing();
    }
    
    if (all || carriages) {
        if (all || carriage_y) {
            translate([y_rail_inset, y_carriage_position, rail_z]) y_carriage();
            translate([y_width-y_rail_inset, y_carriage_position, rail_z]) rotate([0,0,180]) y_carriage();
        }
        
        if (all || carriage_x) translate([x_carriage_position, y_carriage_position, rail_z]) {
            x_carriage();
            
            if (all || hotend) {
                // hotend
                translate([0,0,10]) rotate([0,180,0]) e3d();
                
                translate([0,-30,-55]) inductive_sensor();
            }
        }
    }
    
    // somewhat fudged....
    module belts() {
        belt_l = (y_carriage_position - 20) + (270) + (245) + (x - y_carriage_position - 16) + (x_carriage_position - 35) + (x - x_carriage_position - 40) +
                (y_carriage_position - 20) + (270) + (245) + (x - y_carriage_position - 17) + (x_carriage_position - 35) + (x - x_carriage_position - 40);
        echo("belt_l", belt_l);
        color([1,0,0]) {
            translate([42/2 + 12/2, 42/2, a_belt_z]) gt2_belt(y_carriage_position - 20);
            translate([42/2 - 15/2, 42/2, a_belt_z]) gt2_belt(270);
            translate([42/2 - 15/2, y_width-5, a_belt_z]) rotate([0,0,-92.5]) gt2_belt(255);
            translate([x_width - (42/2 + 12/2), y_width - 16, a_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position - 16);
            translate([y_rail_inset+10, y_carriage_position + 6, a_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width - 43, a_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
        
        color([0,0,1]) {
            translate([x_width - 42/2 - 15/2, 42/2, b_belt_z]) gt2_belt(y_carriage_position - 20);
            translate([x_width - 42/2 + 6, 42/2, b_belt_z]) gt2_belt(270);
            translate([x_width - 42/2 + 6, y_width - 5, b_belt_z]) rotate([0,0,92.5]) gt2_belt(255);
            translate([(42/2 + 15/2), y_width - 16, b_belt_z]) rotate([0,0,180]) gt2_belt(x - y_carriage_position - 17);
            translate([y_rail_inset+10, y_carriage_position -5, b_belt_z]) rotate([0,0,-90]) gt2_belt(x_carriage_position - 35);
            translate([x_width - y_rail_inset - 10, y_carriage_position +carriage_width/2 - 13, b_belt_z]) rotate([0,0,90]) gt2_belt(x - x_carriage_position - 40);
        }
    }
    
    if (all || belts) belts();
    
    if (all || pulleys) {
        // crossover idlers
        /*delta between idler & gt2 pulley*/
        gt2_idler_radius_delta = 1;
        color([0,0,1]) {
            translate([x_width-y_rail_inset + gt2_idler_radius_delta, y_width-idler_pulley_major_d/2 - 4, b_belt_z -1]) {
                translate([0,0,8.5]) m3_washer();
                idler_pulley();
            }
            translate([y_rail_inset + belt_space_od - gt2_idler_radius_delta,y_width-idler_pulley_major_d/2 - 4 - idler_pulley_major_d, b_belt_z - 1]) {
                translate([0,0,8.5]) m3_washer();
                idler_pulley();
            }
        }
        color([1,0,0]) {
            translate([y_rail_inset - gt2_idler_radius_delta, y_width-idler_pulley_major_d/2 - 4, a_belt_z -1]) {
                translate([0,0,8.5]) m3_washer();
                idler_pulley();
            }
            translate([x_width-y_rail_inset - belt_space_od + gt2_idler_radius_delta, y_width-idler_pulley_major_d/2 - 4 - idler_pulley_major_d, a_belt_z -1]) {
                translate([0,0,8.5]) m3_washer();
                idler_pulley();
            }
        }
    }
    
    // Motors sit on top of rail
    // Circle for motor flange must be milled
    if (all || motors) {
        color([1,0,0]) translate([42/2, 42/2, angle_h]) rotate([0,180,0]) union() {
            nema17();
            translate([0,0,20]) rotate([180,0,0]) offset_idler();//gt2_pulley();
        }
        color([0,0,1]) translate([x_width - (42/2), 42/2, angle_h]) rotate([0,180,0]) union() {
            nema17();
            translate([0,0,3]) offset_idler();//gt2_pulley();
        }
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
    color([0,0.5,0.5]) include <../beta4/rrd_graphic_smart_controller.scad>
}

module heatbed() {
    cube([214, 214, 3]);
}

// testing z motor
module z_axis() {
    angle_h = 3;
    
    if (false) {
        l = 42;//z_width + 20;
        translate([od/2 - l/2, 25,3]) union() {
            // Motor screw holes
            rotate([90,0,0]) difference() {
                intersection() {
                    angle50(l);
                    cube([l, 50, 25 - 3]);
                }
                
                translate([(l/2 - 42/2) + 42/2, 42/2, angle_h]) cylinder(r=22.1/2, h=10, center=true);
                translate([(l/2 - 42/2) + 5.5,5.5,angle_h]) cylinder(r=4/2, h = 10, center=true);
                translate([(l/2 - 42/2) + 5.5,5.5+31,angle_h]) cylinder(r=4/2, h = 10, center=true);
                translate([(l/2 - 42/2) + 5.5+31,5.5+31,angle_h]) cylinder(r=4/2, h = 10, center=true);
                translate([(l/2 - 42/2) + 5.5+31,5.5,angle_h]) cylinder(r=4/2, h = 10, center=true);
            }
        }
    }
    
    z_insert = 8/2 + 42/2;
    color([0,1,0]) translate([od/2 - (z_width/2 - z_insert), 3+4+8, od]) rotate([-90,0,0]) idler_pulley();
    color([0,1,0]) translate([od/2 + (z_width/2 - z_insert), 3+4, od]) rotate([-90,0,0]) idler_pulley();
    color([0,1,0]) translate([od/2 + (z_width/2 - z_insert), 3+4+8, 42/2 + 3]) rotate([-90,0,0]) idler_pulley();

    color([0,1,0]) translate([od/2 - (z_width/2 - z_insert), 25, 42/2+ 3]) rotate([-90,0,180]) union() {
        nema17();
        translate([0,0,3]) rotate([0,0,0]) offset_idler();//gt2_pulley();
    }

    translate([od/2 - z_width/2, 25/2, 3]) rod8(350);
    translate([od/2 + z_width/2, 25/2, 3]) rod8(350);
    
    module belts() {
        z_belt_l = (260 - z_position) + (30 + z_position) + (310) +
                    (260 - z_position) + (30 + z_position) + 310;
        echo ("z_belt_l", z_belt_l);
        color([0,1,0]) {
            translate([od/2 - (z_width/2 - z_insert) - 13/2, 15, 42/2]) rotate([90,0,0]) gt2_belt(260 - z_position);
            translate([od/2 + (z_width/2 - z_insert) + 13/2, 8, od]) rotate([-90,0,0]) gt2_belt(30 + z_position);
            translate([od/2 - (z_width/2 - z_insert) + 13/2, 15, 42/2]) rotate([90,22,0]) gt2_belt(310);
        }
        color([0,1,0]) {
            translate([od/2 + (z_width/2 - z_insert) + 13/2, 15+8, 42/2]) rotate([90,0,0]) gt2_belt(260 - z_position);
            translate([od/2 - (z_width/2 - z_insert) - 13/2, 8+8, od]) rotate([-90,0,0]) gt2_belt(30 + z_position);
            translate([od/2 + (z_width/2 - z_insert) - 13/2, 15+8, 42/2]) rotate([90,-22,0]) gt2_belt(310);
        }
    }
    
    belts();
}

module z_platform() {
    translate([-214/2, -214/2, 0]) heatbed();
    translate([-z_width/2, -214/2 - 33, -24 + 3]) lm8uu();
    translate([z_width/2, -214/2 - 33, -24 + 3]) lm8uu();
}

/*translate([0,15,0]) rod20(400);
translate([0,-15,0]) rod20(400);
translate([350,15,0]) rod20(400);
translate([350,-15,0]) rod20(400);*/

translate([-25,0,0]) rod30(400);
translate([375,0,0]) rod30(400);

union () {
    all = false;
    frame = true;
    corexy = true;
    zaxis = false;
    
    id_x = 600-(30*2);
    id_y = 630-(30*2);
    id_z = 800-(30*2);
    echo("id_x", id_x);
    echo("id_y", id_y);
    echo("id_z", id_z);
    
    if (all || frame) translate([0,630,0]) rotate([90,0,0]) frame(600, 800, 630);
    if (all || corexy) translate([0,-100,z_position+52]) corexy(od, od);

    //rotate([0,0,90]) translate([200+3, -200 - 3, 3]) psu();

    //translate([od/2 + 100, od/2 + 20, od+35]) rotate([0,0,-90]) arduino_ramps();
    //translate([200,50,od+62]) rotate([0,0,90]) lcd();

    if (all || zaxis) {
        z_axis();
        translate([od/2, od/2, od - z_position - 30]) z_platform();
    }
}


/*difference() {
    square([gt2_belt_width+2.5, (12 + (gt2_belt_height*2))/2]);
projection(cut = false) rotate([0,90,0]) idler_pulley();
}*/