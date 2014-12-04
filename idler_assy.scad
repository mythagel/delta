use <bolts/BOLTS.scad>
use <bearing_block.scad>
use <belt_idler.scad>

translate([20,3,(-23/2)-2]) rotate([0,0,90]) bearing_block();

translate([0,(7+6)-3,0]) rotate([90,0,0]) RadialBallBearing(key="608", type="shielded, double", part_mode="default");
belt_idler();
translate([0,-6+3,0]) rotate([90,0,0]) RadialBallBearing(key="608", type="shielded, double", part_mode="default");

translate([-20,-3,(-23/2)-2]) rotate([0,0,-90]) bearing_block();