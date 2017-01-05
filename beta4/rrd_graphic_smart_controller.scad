// RRD (Reprap Discount) graphic smart controler
// Scad based on 

difference() {
	union(){
		// LCD module
		translate([17.4,0,4.2]) cube([70,93,1.7]); 			// PCB
		translate([27.1,7.6,5.9])cube([51.2,78.2,8]); 		// LCD
		translate([30,85.8,5.9])cube([43,6.27,3.4]); 		// Backlight
		
		// Base board PCB
		cube([87,93,1.6]); 									// PCB
		// Buzzer
		translate([8.7,27.8,1.6])cylinder(r=5.9,h=9.7,$fn=36); 
		// Encoder
		translate([8.7-(12.5/2),10-(14/2),1.6])cube([12.5,14,6.1]); 		
		translate([8.7,10,1.6])cylinder(r=3,h=20.4,$fn=36);
		// 2 X 10 pins connectors
		translate([71,21,-8.7]) cube([8.7,20.3,9]); 
		translate([72,51,-8.7]) cube([8.7,20.3,9]);
		// emergency stop switch
		translate ([8.7-(6.2/2),43-(6.2/2),1.6])cube([6.2,6.2,3.5]);	
		translate ([8.7,43,1.6+3.5])cylinder(r=1.75,h=1.5,$fn=24);	
		// sd card slot
		translate([39.2,67,-2.93]) cube([26.8,25.2,2.93]); 
		// Backlight pot
		translate([8.8,79.6,0]) cube([6.8,8,8.5]); 
		translate([12.2,83.7,8.5]) cylinder(r=3.1,h=1.85,$fn=16); 
	}

	// Mounting holes
	translate([19.45,2.55,0])cylinder(r=2.05,h=10,$fn=12); 
	translate([19.45,90.45,0])cylinder(r=2.05,h=10,$fn=12);
	translate([84.45,2.55,0])cylinder(r=2.05,h=10,$fn=12);
	translate([84.45,90.45,0])cylinder(r=2.05,h=10,$fn=12);
}
