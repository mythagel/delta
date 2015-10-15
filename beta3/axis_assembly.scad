use <../nema17.scad>
use <motor_mount.scad>
use <carriage.scad>
use <lower_mount.scad>

use <../bearings.scad>
use <gt2_pulley.scad>
use <../rod.scad>

$fn=64;

d=17;
//w=15+2+(15*2)+2;
w=42;
h=42;
carriage_h=24;
lower_mount_h=24;

motor_mount(d, w, h);
rotate([0,90,0]) nema17();
translate([3,0,0]) rotate([0,90,0]) gt2_pulley();

translate([d/2,-12.5,-320]) rod(320, 8/2);
translate([d/2,12.5,-320]) rod(320, 8/2);

translate([0,0,-280]) union() {
	carriage(d, w, carriage_h);
	translate([d/2,w/2 - (15/2) - 1,-24/2]) lm8uu();
	translate([d/2,-w/2 + (15/2) + 1,-24/2]) lm8uu();
}

translate([0,0,-312]) lower_mount(d, w, lower_mount_h);