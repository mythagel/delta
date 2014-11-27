use <ceramic_heater.scad>
use <heater_block.scad>
use <nozzle.scad>
use <cooler.scad>

module hotend() {
	union() {
		heater_block();
		translate([21/2, 21/2, -4]) nozzle();
		rotate([-90, 0, 0]) translate([4, -4, -1])
			ceramic_heater();
		translate([21/2, 21/2, 10]) cooler();
	}
}

hotend();