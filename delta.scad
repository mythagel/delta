use <base.scad>
use <rod.scad>
use <rod_support.scad>

translate([0,0,12]) base();

t = 10;
r=270/2;
r0 = [r * cos(0-t), r * sin(0-t), 0];
r1 = [r * cos(0+t), r * sin(0+t), 0];
r2 = [r * cos(120-t), r * sin(120-t), 0];
r3 = [r * cos(120+t), r * sin(120+t), 0];
r4 = [r * cos(240-t), r * sin(240-t), 0];
r5 = [r * cos(240+t), r * sin(240+t), 0];

module rod_with_supports() {
	translate([0,0,350-12]) rod_support();
	rod(350, 4);
	rod_support();
}

translate(r0) rod_with_supports();
translate(r1) rod_with_supports();
translate(r2) rod_with_supports();
translate(r3) rod_with_supports();
translate(r4) rod_with_supports();
translate(r5) rod_with_supports();

translate([0, 0, 350-12-6]) base();