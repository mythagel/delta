use <threads.scad>
use <bolts/BOLTS.scad>

module belt_connector_a() {
	difference() {
		cube([3,24,7]);
		translate([2.5,-0.5,0.5]) cube([1,25,6]);
		translate([-0.5,24/2,7/2]) rotate([0,90,0]) metric_thread(3, 0.8, 4, internal=true);
	}
}

module belt_connector_b() {
	$fn=32;
	difference() {
		cube([3,24,7]);
		translate([-0.5,24/2,7/2]) rotate([0,90,0]) cylinder(r=1.5, h=4);
		translate([3.001,24/2,7/2]) rotate([0,-90,0]) MetricHexSocketCountersunkHeadScrew(key="M3", l=6, part_mode="default");
		for ( y = [0 : 2 : 24] ) {
			if (y!=12) translate([-1+0.75,y,-0.5]) cylinder(r=0.5, h=8);
		}
	}
}

belt_connector_a();
translate([3,0,0]) belt_connector_b();
translate([6,24/2,7/2]) rotate([0,-90,0]) MetricHexSocketCountersunkHeadScrew(key="M3", l=6, part_mode="default");