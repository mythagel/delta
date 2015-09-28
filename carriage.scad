use <bearings.scad>

lm8uu_r = 7.5;
lm8uu_h = 24;

gt2_width = 13+1; // 12.8mm = outer dimension of belt on pulley
gt2_belt_width = 6;

between_centers = 32;

d = 17;
w = between_centers + (lm8uu_r*2) + 1 + 1;
h = lm8uu_h*2;

module carriage() {
space = (between_centers - (lm8uu_r*2) - gt2_width)/2;
echo("space", space);

difference() {
	difference() {
		linear_extrude(height=h) polygon([[0,0],[w,0],[w,d],[0,d]]);
		//translate([-0.5, d/2, -0.5]) cube([w+1, (d/2)+1, h+1]);
	}

	// belt path
	translate([(w/2)-(gt2_width/2), (d/2)-(gt2_belt_width+2)/2, -1]) cube([gt2_width, gt2_belt_width+10, h+10]);
	//translate([w/2-(gt2_width/2), d/2-((gt2_belt_width+2)/2), -1]) cnc(gt2_width, (gt2_belt_width+2)/2, h+10);

	union() {
		translate([7.5+1, d/2, -1]) cylinder(h=h+10, r=7.5);
		translate([between_centers+(7.5+1), d/2, -1]) cylinder(h=h+10, r=7.5);
	}
}

translate([lm8uu_r+1, d/2, 0]) lm8uu();
translate([lm8uu_r+1, d/2, lm8uu_h]) lm8uu();

translate([w-lm8uu_r-1, d/2, 0]) lm8uu();
translate([w-lm8uu_r-1, d/2, lm8uu_h]) lm8uu();
}

carriage();