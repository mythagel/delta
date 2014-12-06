use <local.scad>
use <base.scad>
use <rod.scad>
use <rod_support.scad>
use <effector.scad>
use <idler_assy.scad>

base();

module rod_with_supports() {
	translate([0,0,350-(12+6)]) rod_support();
	rod(350, 4);
	translate([0,0,6]) rod_support();
}

r0_cs = base_conn(0);
r1_cs = base_conn(1);
r2_cs = base_conn(2);
r3_cs = base_conn(3);
r4_cs = base_conn(4);
r5_cs = base_conn(5);
rod_cs = rod_conn("bottom", 350, 4);

align(rod_cs, r0_cs) rod_with_supports();
align(rod_cs, r1_cs) rod_with_supports();
align(rod_cs, r2_cs) rod_with_supports(); 
align(rod_cs, r3_cs) rod_with_supports();
align(rod_cs, r4_cs) rod_with_supports();
align(rod_cs, r5_cs) rod_with_supports();

translate([85,0,6]) rotate([0,0,90]) idler_assy();
translate([100*cos(120),100*sin(120),6]) rotate([0,0,30]) idler_assy();

translate([0, 0, 350-6]) base();

translate([0,0,100+6]) rotate([0,0,30]) effector(true);

