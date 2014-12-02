steel = [0.8, 0.8, 0.9];

module lm8uu() {
	$fn = 32;
   module groove() {
       difference() {
           cylinder(h=1.1, r=7.5);
           cylinder(h=1.2, r=7.5-(0.7/2));
       }
   }
   color(steel) render() difference() {
       cylinder(h=24, r=7.5);
       translate([0, 0, -0.5]) cylinder(h=25, r=4);
       translate([0, 0, 3.25-1.1]) groove();
       translate([0, 0, 24-3.25]) groove();
   }
}

module 608zz() {
	$fn = 32;
	difference() {
		cylinder(h=7, r=22/2);
		translate([0, 0, -0.5]) cylinder(h=8, r=4);
	}
}

translate([0, 0, 10]) lm8uu();
608zz();