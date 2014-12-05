use <BOLTS.scad>
use <bearing_block.scad>
use <belt_idler.scad>

module idler_assy() {
	bearing_cs = bearing_block_conn("bearing");
	bb_cs = new_cs(origin=[0,0,0], axes=[[0,0,1],[0,1,0]]);
	idler_a_cs = belt_idler_conn("a");
	idler_b_cs = belt_idler_conn("b");

	translate([0,0,16]) union() {
		belt_idler();
		align(bb_cs, idler_a_cs)
			RadialBallBearing(key="608", type="open", part_mode="default");
		align(bearing_cs, idler_a_cs)
			bearing_block();
		align(bb_cs, idler_b_cs)
			RadialBallBearing(key="608", type="open", part_mode="default");
		align(bearing_cs, idler_b_cs)
			bearing_block();
	}
}

idler_assy();