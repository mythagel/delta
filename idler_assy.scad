use <BOLTS.scad>
use <bearing_block.scad>
use <belt_idler.scad>

translate([20,3,(-23/2)-2]) rotate([0,0,90]) bearing_block();

translate([0,(7+6)-3,0]) rotate([90,0,0]) RadialBallBearing(key="608", type="shielded, double", part_mode="default");
belt_idler();
translate([0,-6+3,0]) rotate([90,0,0]) RadialBallBearing(key="608", type="shielded, double", part_mode="default");

translate([-20,-3,(-23/2)-2]) rotate([0,0,-90]) bearing_block();


//bearing_cs = bearing_block_conn("bearing");

//RadialBallBearing_conn(location,key="608", type="open", part_mode="default");
//bb_cs = new_cs(origin=[0,0,0], axes=[[0,0,1],[0,1,0]]);

//align(bb_cs, bearing_cs) RadialBallBearing(key="608", type="open", part_mode="default");
