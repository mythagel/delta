use <base.scad>
use <rod.scad>
use <rod_support.scad>

base();

t = 10;
r=270/2;
r0 = [r * cos(0-t),   r * sin(0-t),   6];
r1 = [r * cos(0+t),   r * sin(0+t),   6];
r2 = [r * cos(120-t), r * sin(120-t), 6];
r3 = [r * cos(120+t), r * sin(120+t), 6];
r4 = [r * cos(240-t), r * sin(240-t), 6];
r5 = [r * cos(240+t), r * sin(240+t), 6];

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

translate([0, 0, 350+6]) base();