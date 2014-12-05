/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

BOLTS_MODE = "draft";

//can be "in" and "mm"
BOLTS_DEFAULT_UNIT = "mm";

BOLTS_THREAD_COLOR = [0,1,0];
/*
Copyright (c) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/*
local.scad local coordinate systems for OpenSCAD

for more information, see https://github.com/jreinhardt/local-scad
*/

//a few utility functions
function norm(a) = sqrt(a*a);
function unit_vector(v) = v/norm(v);
function clamp(v,lower_bound,upper_bound) = min(max(v,lower_bound),upper_bound);
function cross_product(a,b) = [
	a[1]*b[2]-a[2]*b[1],
	a[2]*b[0]-a[0]*b[2],
	a[0]*b[1]-a[1]*b[0]
];

//works for both numbers and vectors
function almost_equal(number, ref, tol) = sqrt((number-ref)*(number-ref)) < tol;

function _rotation_angle(a,b) = (a*b > 0) ? 
	asin(clamp(norm(cross_product(b,a))/norm(a)/norm(b),-1,1)) :
	180 - asin(clamp(norm(cross_product(b,a))/norm(a)/norm(b),-1,1));

//The (non-unit) rotation axis and angle around which a has to be rotated to be colinear to b
function calculate_rotation_axis(a,b) =
	//if the two vectors are not colinear find a rotation axis using the cross product
	(norm(cross_product(b,a)) != 0) ? [unit_vector(cross_product(b,a)),_rotation_angle(a,b)] :
	//if they are colinear and do not lie in the yz plane, choose the rotation axis from the yz plane
	(a*[1,0,0] < 0) ? [unit_vector([0,-a[1],+a[0]]),acos(clamp(a*b/norm(a)/norm(b),-1,1))] :
	(a*[1,0,0] > 0) ? [unit_vector([0,+a[1],-a[0]]),acos(clamp(a*b/norm(a)/norm(b),-1,1))] :
	//otherwise use the x axis
	[[1,0,0],acos(clamp(a*b/norm(a)/norm(b),-1,1))];

function calculate_axes(x,y) = [unit_vector(x),unit_vector(y), unit_vector(cross_product(x,y))];

function new_cs(origin=[0,0,0],axes=[[1,0,0],[0,1,0],[0,0,1]]) = (len(axes) == 2) ?
	[origin,calculate_axes(axes[0],axes[1])] :
	is_orthonormal([origin,axes]) ?
		[origin,axes] :
		"Error: Axes are not orthonormal";

function is_orthonormal(cs,tol=1e-3) =
	(almost_equal(norm(cs[1][0]),1,tol)) &&
	(almost_equal(norm(cs[1][1]),1,tol)) &&
	(almost_equal(norm(cs[1][2]),1,tol)) &&
	(almost_equal(cross_product(cs[1][0],cs[1][1]),cs[1][2],tol)) &&
	(almost_equal(cross_product(cs[1][1],cs[1][2]),cs[1][0],tol)) &&
	(almost_equal(cross_product(cs[1][2],cs[1][0]),cs[1][1],tol));

function unit_matrix3() = [
[1,0,0],
[0,1,0],
[0,0,1]];

function tensor_product_matrix3(u,v) = [
[u[0]*v[0], u[0]*v[1], u[0]*v[2]],
[u[1]*v[0], u[1]*v[1], u[1]*v[2]],
[u[2]*v[0], u[2]*v[1], u[2]*v[2]]];

function cross_product_matrix3(v) = [
[   0 , -v[2], +v[1]],
[+v[2],    0 , -v[0]],
[-v[1],  v[0],    0 ]];

function rotation_matrix3(n,angle) =
	cos(angle)*unit_matrix3() +
	sin(angle)*cross_product_matrix3(n) +
	(1-cos(angle))*tensor_product_matrix3(n,n);

//the modules are used directly by the user
module show_cs(cs){
	origin = cs[0];
	axes = cs[1];
	x_rot = calculate_rotation_axis(axes[0],[0,0,1]);
	y_rot = calculate_rotation_axis(axes[1],[0,0,1]);
	z_rot = calculate_rotation_axis(axes[2],[0,0,1]);
	translate(origin){
		color("Gray") sphere(0.2);
		rotate(x_rot[1],x_rot[0]) color("Red") cylinder(r=0.1,h=norm(axes[0]));
		rotate(y_rot[1],y_rot[0]) color("Green") cylinder(r=0.1,h=norm(axes[1]));
		rotate(z_rot[1],z_rot[0]) color("Blue") cylinder(r=0.1,h=norm(axes[2]));
	}
}

module translate_local(cs,v=[0,0,0]){
	origin = cs[0];
	axes = cs[1];
	x_rot = calculate_rotation_axis(axes[0],[1,0,0]);
	y_rot = calculate_rotation_axis(axes[1],
		rotation_matrix3(x_rot[0],x_rot[1])*[0,1,0]);
	translate(origin+v*axes){
		//align y axes
		rotate(y_rot[1],y_rot[0]){
			//align x axes
			rotate(x_rot[1],x_rot[0]){
				child(0);
			}
		}
	}
}

module in_cs(cs){
	origin = cs[0];
	axes = cs[1];
	x_rot = calculate_rotation_axis(axes[0],[1,0,0]);
	y_rot = calculate_rotation_axis(axes[1],
		rotation_matrix3(x_rot[0],x_rot[1])*[0,1,0]);
	translate(origin){
		//align y axes
		rotate(y_rot[1],y_rot[0]){
			//align x axes
			rotate(x_rot[1],x_rot[0]){
				child(0);
			}
		}
	}
}

module align(cs, cs_dst, displacement=[0,0,0]){
	x_rot = calculate_rotation_axis(cs[1][0],cs_dst[1][0]);
	y_rot = _rotation_angle(cs[1][1],
		rotation_matrix3(x_rot[0],x_rot[1])*cs_dst[1][1]);
	translate(cs_dst[0]+displacement*cs_dst[1])
		//align x axes
		rotate(-x_rot[1],x_rot[0])
				//align y axes
				rotate(-y_rot,cs[1][0])
				translate(-cs[0])
					child(0);
}


/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

module BOLTS_error(msg){
	echo(str("BOLTS Error: ",msg));
}

module BOLTS_warning(msg){
	echo(str("BOLTS Warning: ",msg));
}


module BOLTS_check_dimension_defined(dim, descr){
	if(dim == "None"){
		BOLTS_error(str("Dimension unspecified",descr));
	}
}

module BOLTS_check_dimension_positive(dim, message){
	if(dim < 0){
		BOLTS_error(message);
	}
}

function BOLTS_convert_to_default_unit(value,unit) =
	(BOLTS_DEFAULT_UNIT == unit) ? value :
		(unit == "in") ? value*25.4 :
			value/25.4;

function get_dim(dims,pname) = dims[search([pname],dims,1)[0]][1];

//see http://rocklinux.net/pipermail/openscad/2013-September/005522.html
function type(P) =
	(len(P) == undef)
	?	(P == true || P == false)
		? "boolean"
		: (P == undef)
			? "undef"
			: "number"
	:	(P + [1] == undef)
		?	"string"
		:	"vector";

module BOLTS_check_parameter_type(part_name,name,value,param_type){
	if(param_type=="Length (mm)"){
		if(type(value) != "number"){
			BOLTS_error(str("Expected a Length (mm) as parameter ",name," for ",part_name,", but ",value," is not numerical"));
		} else if(value < 0){
			BOLTS_error(str("Expected a Length (mm) as parameter ",name," for ",part_name,", but ",value," is negative"));
		}
	} else if(param_type=="Length (in)"){
		if(type(value) != "number"){
			BOLTS_error(str("Expected a Length (in) as parameter ",name," for ",part_name,", but ",value," is not numerical"));
		} else if(value < 0){
			BOLTS_error(str("Expected a Length (in) as parameter ",name," for ",part_name,", but ",value," is negative"));
		}
	} else if(param_type=="Number"){
		if(type(value) != "number"){
			BOLTS_error(str("Expected a Number as parameter ",name," for ",part_name,", but ",value," is not numerical"));
		}
	} else if(param_type=="Bool"){
		if(type(value) != "boolean"){
			BOLTS_error(str("Expected a Bool as parameter ",name," for ",part_name,", but ",value," is not boolean"));
		}
	} else if(param_type=="Table Index"){
		if(type(value) != "string"){
			BOLTS_error(str("Expected a Table Index as parameter ",name," for ",part_name,", but ",value," is not a string"));
		}
	} else if(param_type=="String"){
		if(type(value) != "string"){
			BOLTS_error(str("Expected a String as parameter ",name," for ",part_name,", but ",value," is not a string"));
		}
	} else {
		BOLTS_error(str("Unknown type in parameter check. This should not happen, please report this bug to BOLTS"));
	}
}


module BOLTS_thread_external(d1,l){
	color(BOLTS_THREAD_COLOR)
		cylinder(r=0.5*d1,h= l);
}

module BOLTS_hex_head(k,s){
	a = s/tan(60);
	translate([0,0,-k/2]) union(){
		rotate([0,0, 30]) cube([a,s,k],true);
		rotate([0,0,150]) cube([a,s,k],true);
		rotate([0,0,270]) cube([a,s,k],true);
	}
}

module BOLTS_hex_socket_neg(t,s){
	a = s/tan(60);
	//The fudging here is to avoid coincident faces when subtracting from a
	//body (see e.g. hex_socket)
	translate([0,0,t/2-0.01]) union(){
		rotate([0,0, 30]) cube([a,s,t+0.01],true);
		rotate([0,0,150]) cube([a,s,t+0.01],true);
		rotate([0,0,270]) cube([a,s,t+0.01],true);
	}
}
function BOLTS_version() = "201408251944";
function BOLTS_date() = [2014,8,25];
function BOLTS_license() = "LGPL 2.1+";
//  Modules for the Bosch Rexroth series of aluminium profiles
//  Sourced from http://www.kjnltd.co.uk/
//  Author - Damian Axford
//  Public Domain


eta = 0.01;


// Bore Types
BR_20x20_Bore = [5.5, 1.5, 7];

function aluProBore_r(boreType) = boreType[0]/2;
function aluProBore_outsetW(boreType) = boreType[1];
function aluProBore_outsetR(boreType) = boreType[2]/2;

// Core Types
BR_20x20_Core = [9,2,0.75];

function aluProCore_w(coreType) = coreType[0];
function aluProCore_keyW(coreType) = coreType[1];
function aluProCore_keyD(coreType) = coreType[2];

//Corner Types
BR_20x20_Corner = [20, 7, 1.5, 0.5, 4];

// Side Types  - for closed slots
BR_20x20_Side = [20, 1.5];

// Side Styles
BR_0 = [0,0,0,0];
BR_1S = [0,1,1,1];
BR_2S = [0,1,0,1];
BR_3S = [0,1,0,0];
BR_2SA = [1,1,0,0];

// Profiles - combination of elements

BR_20x20 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 1, "BR_20x20"];
BR_20x20_1S = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_1S, 1, 1, "BR_20x20_1S"];
BR_20x20_2S = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_2S, 1, 1, "BR_20x20_2S"];
BR_20x20_3S = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_3S, 1, 1, "BR_20x20_3S"];
BR_20x20_2SA = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_2SA, 1, 1, "BR_20x20_2SA"];

BR_20x40 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 2, "BR_20x40"];

BR_20x60 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 3, "BR_20x60"];

BR_20x80 = [BR_20x20_Bore, BR_20x20_Core, BR_20x20_Corner, BR_20x20_Side, BR_0, 1, 4, "BR_20x80"];

function aluPro_label(type) = type[7];

//twistLockNutType

BR_20x20_TwistLockNut = [5.8,11.3,4,0.8,1.5];


// gussets
// width, wall_thickness, slot width, slot height, slot offset from base, nib depth
BR_20x20_Gusset = [18, 3, 4.5, 7, 7.7, 1, "BR20x20Gusset"];

module aluProBore(boreType, $fn=16) {
	union() {
		circle(r=aluProBore_r(boreType));
	
		intersection() {
			circle(r=aluProBore_outsetR(boreType));
			for (i=[0:3]) 
				rotate([0,0,i*90 + 45]) 	
				square([aluProBore_outsetR(boreType)*2,aluProBore_outsetW(boreType)], center=true);
		}
	}
}


module aluProCore(coreType) {
	w = aluProCore_w(coreType);
	keyW = aluProCore_keyW(coreType);
	keyD = aluProCore_keyD(coreType);

	difference() {
		square([w,w],center=true);

		// remove keys
		for (i=[0:3]) 
			rotate([0,0,i*90])
			translate([w/2,0,0])
			polygon([[eta,keyW/2], 
                      [-keyD,0], 
                      [eta,-keyW/2]]); 
	}
}


module aluProCorner(cornerType, $fn=8) {
	// xy corner
	w1 = cornerType[0];
	w2 = cornerType[1];
	t = cornerType[2];
	cham = cornerType[3];
	w3 = cornerType[4];	

	union() {	
		// radial arm
		rotate([0,0,45]) translate([0,-t/2,0]) square([w1/2+t,t]);

		// outer radius
		translate([w1/2-t,w1/2-t,0]) circle(r=t);

		// corner block
		translate([w1/2-w3,w1/2-w3]) square([w3-t+eta,w3-t+eta]);

		// returns
		for (i=[0,1]) mirror([i,i,0]) {
			translate([w1/2-w2,w1/2-t,0]) square([w2-t,t-cham]);
			translate([w1/2-w2+cham,w1/2-cham-eta,0]) square([w2-t-cham,cham+eta]);
		}
	}
}

module aluProSide(sideType) {
	// x side
	w = sideType[0];
	t = sideType[1];
	translate([w/2-t-eta,-w/4,0]) square([t+eta,w/2]);	
}

module aluProHollow(cornerType) {
	// x hollow
	w1 = cornerType[0];
	t = cornerType[2];
	w3 = cornerType[4];	

	translate([w1/2,0]) square([2*w3 - 2*t, w1 - 2*t],center=true);
}

// TSlot - to be unioned onto a printed part for engaging tightly with the aluprofile
//  same centre and orientation as a full profile section, x+ side
// protrudes eta beyond external boundary of section to allow for union
// requires linear_extrude'ing
module aluProTSlot(profileType, $fn=8) {
	//BR_20x20_Corner = [20, 7, 1.5, 0.5, 4];
	//BR_20x20_Core = [9,2,0.75];
	
	coreType = profileType[1];
	cornerType = profileType[2];
	 
	w1 = cornerType[0];
	w2 = cornerType[1];
	t = cornerType[2];
	cham = cornerType[3];
	w3 = cornerType[4];	

	tol = 0.5;  // mm tolerance, total per gap

	slotW = w1- 2*w2 - tol;
	slotD = (w1 - coreType[0]) / 2 - tol;
	slotOffset = coreType[0]/2 + tol;
	
	wingW = w1 - 2*w3 - 4*tol;
	wingInset = t + tol/2;

	union() {	
		// central block
		translate([slotOffset,-slotW/2,0]) square([slotD+eta, slotW]);
	
		// wings
		for (i=[0,1]) mirror([0,i,0]) {
			polygon(points=[[slotOffset,slotW/2],[w1/2-w3/2-tol,wingW/2],[w1/2-wingInset,wingW/2],[w1/2-wingInset, slotW/2]], paths=[[0,1,2,3]]);
		}
	}
}

// TSlotLug - to be unioned onto a printed part for engaging tightly with the aluprofile slot
//  same centre and orientation as a full profile section, x+ side
// protrudes eta beyond external boundary of section to allow for union
// NB: solid part
module aluProTSlotLug(profileType, l=5, $fn=8) {
	//BR_20x20_Corner = [20, 7, 1.5, 0.5, 4];
	//BR_20x20_Core = [9,2,0.75];
	
	coreType = profileType[1];
	cornerType = profileType[2];
	 
	w1 = cornerType[0];
	w2 = cornerType[1];
	t = cornerType[2];
	cham = cornerType[3];
	w3 = cornerType[4];	

	tol = 0.5;  // mm tolerance, total per gap

	slotW = w1- 2*w2 - tol;
	slotD = (w1 - coreType[0]) / 2 - tol;
	slotD2 = l < slotD ? l : slotD;
	slotOffset = coreType[0]/2 + tol;
	
	wingW = w1 - 2*w3 - 4*tol;
	wingInset = t + tol/2;

	union() {	
		// central block
		translate([slotOffset,-slotW/2,0]) square([slotD2+eta, slotW]);
	}
}



module aluProBasicSection(profileType) {
	difference() {
		union() {
			aluProCore(profileType[1]);
			
			for (i=[0:3]) rotate([0,0,i*90]) {
				aluProCorner(profileType[2]);

				if (profileType[4][i] == 1)
					aluProSide(profileType[3]);
			}
		}
		aluProBore(profileType[0]);
	}
}

module aluProSection(profileType,detailed) {
	x = profileType[5];
	y = profileType[6];
	w = profileType[3][0];
	sx = -(x-1)*w/2;
	sy = -(y-1)*w/2;
	
	w1 = profileType[2][0];
	
	if (!detailed) {
		// simple rectangle
		square([w1 * x,w1 * y],center=true);
	
	} else {
		difference() {
			union() {
				for (i=[0:x-1])
					for (j=[0:y-1])
						translate([sx + w * i, sy + w * j,0]) aluProBasicSection(profileType);
			
				// fill-in sides
				if (y > 1)
					for (i=[0:y-2])
						for (j=[0,1]) 
							mirror([j,0,0])
								translate([sx + (x-1) * w/2, sy + i*w + w/2,0])
									aluProSide(profileType[3]);
			}

			// remove hollows
			if (y > 1)
				for (i=[0:y-2])
					for (j=[0,1]) 
						mirror([j,0,0])
							translate([sx + (x-1) * w/2, sy + i*w,0])
								rotate([0,0,90]) aluProHollow(profileType[2]);
		}
	}
		
}


module aluProExtrusion(profileType, l, detailed) {
	render()
	    translate([0,0,center?-l/2:0]) 
		linear_extrude(height=l)
		aluProSection(profileType, detailed=detailed);
}



// utility functions to generate common profiles with gussets
// set gusset array values to 1 to indicate where a gusset should be present
// numbering is anticlockwise from y+
module BR20x20WG(l=100, startGussets=[0,0,0,0], endGussets=[0,0,0,0], screws=true) {
	gussetType=BR_20x20_Gusset;
	profileType = BR_20x20;
	
	aluProExtrusion(profileType, l);
	
	// gussets
	for (i=[0:3]) {
		//start
		if (startGussets[i]==1)
			rotate([0,0,i*90]) 
			translate([0,10,0]) 
			aluProGusset(gussetType, screws=screws);
		
		
		//end
		if (endGussets[i]==1)
			rotate([0,0,i*90]) 
			translate([0,10,l]) 
			mirror([0,0,1])
			aluProGusset(gussetType, screws=screws);
	}
}

// same as above, but between points
module BR20x20WGBP(p1,p2,roll=0,startGussets=[0,0,0,0], endGussets=[0,0,0,0], screws=true) {
	v = subv(p2,p1);
	l = mod(v);
	translate(p1) orientate(v,roll=roll) BR20x20WG(l, startGussets, endGussets, screws);
}

// for 20x40...  gusset numbering is from y+ anticlockwise
module BR20x40WG(l=100, startGussets=[0,0,0,0,0,0], endGussets=[0,0,0,0,0,0], screws=true) {
	gussetType=BR_20x20_Gusset;
	profileType = BR_20x40;
	
	aluProExtrusion(profileType, l);
	
	// gussets
	
	for (i=[0,1]) {
	
		//y+
		if (i==0?startGussets[0]==1:endGussets[0]==1)
			translate([0,20,i==0?0:l]) 
			rotate([0,0,0])
			mirror([0,0,i]) 
			aluProGusset(gussetType, screws=screws);
	
	
		//y-
		if (i==0?startGussets[3]==1:endGussets[3]==1)
			translate([0,-20,i==0?0:l]) 
			rotate([0,0,180])
			mirror([0,0,i]) 
			aluProGusset(gussetType, screws=screws);
		
		// x-
		for (j=[0,1])
			if (i==0?startGussets[1+j]==1:endGussets[1+j]==1)
			translate([-10,10-j*20,i==0?0:l]) 
			rotate([0,0,90])
			mirror([0,0,i]) 
			aluProGusset(gussetType, screws=screws);
	
		// x+
		for (j=[0,1])
			if (i==0?startGussets[4+j]==1:endGussets[4+j]==1)
			translate([10,-10+j*20,i==0?0:l]) 
			rotate([0,0,270])
			mirror([0,0,i]) 
			aluProGusset(gussetType, screws=screws);
	
	}
}

// same as above, but between points
module BR20x40WGBP(p1,p2,roll=0,startGussets=[0,0,0,0,0,0], endGussets=[0,0,0,0,0,0], screws=true) {
	v = subv(p2,p1);
	l = mod(v);
	translate(p1) orientate(v,roll=roll) BR20x40WG(l, startGussets, endGussets, screws);
}




module aluProExtrusionBetweenPoints(p1,p2,profileType=BR_20x20,roll=0) {
	v = subv(p2,p1);
	l = mod(v);
	translate(p1) orientate(v,roll=roll) aluProExtrusion(profileType, l);
}



// width, wall_thickness, slot width, slot height, slot offset from base, nib depth
//BR_20x20_Gusset = [18, 3, 4.5, 7, 7.7, 1];

module aluProGusset(tg,screws=false) {
	// sits on z=0
	// faces along y+ and z+	
	
	w = tg[0];
	t = tg[1];
	slotw = tg[2];
	sloth = tg[3];
	sloto = tg[4];
	nib = tg[5];
	
	vitamin(str(tg[6],": ",tg[6]));
	
	color(grey80)
	render()
	union() {
		// ends
		for (i=[0,1])
			mirror([0,-i,i])
			linear_extrude(t) {
				difference() {
					translate([-w/2,0,0]) square([w,w]);
					translate([(-w/2+slotw)/2,sloto,0]) square([slotw,sloth]);
				}
			}
			
		// nibs - must add these at some point!
		
		//sides
		for (i=[0,1])
			mirror([i,0,0])
			translate([w/2-t/2,t,t])
			rotate([0,-90,0])
			right_triangle(width=w-t, height=w-t, h=t, center = true);
	}
	
	if (screws) {
		for (i=[0,1])
			mirror([0,-i,i]) {
				translate([0,12,t]) screw(M4_cap_screw,8);
				translate([0,12,0]) aluProTwistLockNut(BR_20x20_TwistLockNut);
			}
	}
}


//BR_20x20_TwistLockNut = [5.8,11.3,4,0.8,1.5];
// aligned such that the origin is level with the surface of the profile when the nut is locked
module aluProTwistLockNut(tlnt) {
	vitamin(str("AluExtTwistNut: Aluminium Extrusion Twist Nut"));

	if (simplify) {
		color("silver")
		render()
		translate([0,0,-tlnt[2] -tlnt[3] - (tlnt[4] - tlnt[3])])
		translate([0,0,(tlnt[2]-1)/2]) rotate([90,0,0]) trapezoidPrism(tlnt[1],tlnt[0],tlnt[2]-1,-(tlnt[1] - tlnt[0])/2,tlnt[0],center=true);
	
	} else {
		color("silver")
		render()
		translate([0,0,-tlnt[2] -tlnt[3] - (tlnt[4] - tlnt[3])]) 
		difference() {
			union() {
				translate([0,0,tlnt[2]-0.5-eta]) cube([tlnt[1],tlnt[0],1+2*eta],center=true);
				translate([0,0,(tlnt[2]-1)/2]) rotate([90,0,0]) trapezoidPrism(tlnt[1],tlnt[0],tlnt[2]-1,-(tlnt[1] - tlnt[0])/2,tlnt[0],center=true);
			
				translate([0,0,tlnt[3]/2 + tlnt[2]-eta]) cube([tlnt[0],tlnt[0],tlnt[3] + eta],center=true);
			}
	
			translate([0,0,-1]) cylinder(h=20, r=tlnt[2]/2, $fn=8);
		}
	}
}

module tslot_20x20_base(l,detailed){
	aluProExtrusion(BR_20x20, l=l, detailed=detailed);
}

module tslot_20x20_1s_base(l,detailed){
	aluProExtrusion(BR_20x20_1S, l=l, detailed=detailed);
}

module tslot_20x20_2s_base(l,detailed){
	aluProExtrusion(BR_20x20_2S, l=l, detailed=detailed);
}

module tslot_20x20_2sa_base(l,detailed){
	aluProExtrusion(BR_20x20_2SA, l=l, detailed=detailed);
}

module tslot_20x20_3s_base(l,detailed){
	aluProExtrusion(BR_20x20_3S, l=l, detailed=detailed);
}

//	aluProExtrusion(BR_20x40, l=70, center=false);
//	aluProExtrusion(BR_20x60, center=true);
// aluProExtrusion(BR_20x80, center=false);
/* Generated by BOLTS, do not modify */
function tslot20x20_dims(l=100, detailed=false, part_mode="default") = [
	["detailed", detailed],
	["l", l]];

module tslot20x20_geo(l, detailed, part_mode){
	tslot_20x20_base(
		get_dim(tslot20x20_dims(l, detailed, part_mode),"l"),
		get_dim(tslot20x20_dims(l, detailed, part_mode),"detailed")
	);
};

module TSlotExtrusion20x20(l=100, detailed=false, part_mode="default"){
	BOLTS_check_parameter_type("TSlotExtrusion20x20","l",l,"Length (mm)");
	BOLTS_check_parameter_type("TSlotExtrusion20x20","detailed",detailed,"Bool");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("T slot extrusion 20x20x",l,""));
		}
		cube();
	} else {
		tslot20x20_geo(l, detailed, part_mode);
	}
};

function TSlotExtrusion20x20_dims(l=100, detailed=false, part_mode="default") = tslot20x20_dims(l, detailed, part_mode);

function TSlotExtrusion20x20_conn(location,l=100, detailed=false, part_mode="default") = tslot20x20_conn(location,l, detailed, part_mode);

/* Generated by BOLTS, do not modify */
function tslot20x20_2sa_dims(l=100, detailed=false, part_mode="default") = [
	["detailed", detailed],
	["l", l]];

module tslot20x20_2sa_geo(l, detailed, part_mode){
	tslot_20x20_2sa_base(
		get_dim(tslot20x20_2sa_dims(l, detailed, part_mode),"l")
	);
};

module TSlotExtrusionTwoSlots20x20(l=100, detailed=false, part_mode="default"){
	BOLTS_check_parameter_type("TSlotExtrusionTwoSlots20x20","l",l,"Length (mm)");
	BOLTS_check_parameter_type("TSlotExtrusionTwoSlots20x20","detailed",detailed,"Bool");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("T slot extrusion two slots 20x20x",l,""));
		}
		cube();
	} else {
		tslot20x20_2sa_geo(l, detailed, part_mode);
	}
};

function TSlotExtrusionTwoSlots20x20_dims(l=100, detailed=false, part_mode="default") = tslot20x20_2sa_dims(l, detailed, part_mode);

function TSlotExtrusionTwoSlots20x20_conn(location,l=100, detailed=false, part_mode="default") = tslot20x20_2sa_conn(location,l, detailed, part_mode);

/* Generated by BOLTS, do not modify */
function tslot20x20_2s_dims(l=100, detailed=false, part_mode="default") = [
	["detailed", detailed],
	["l", l]];

module tslot20x20_2s_geo(l, detailed, part_mode){
	tslot_20x20_2s_base(
		get_dim(tslot20x20_2s_dims(l, detailed, part_mode),"l"),
		get_dim(tslot20x20_2s_dims(l, detailed, part_mode),"detailed")
	);
};

module TSlotExtrusionTwoSlotsopp20x20(l=100, detailed=false, part_mode="default"){
	BOLTS_check_parameter_type("TSlotExtrusionTwoSlotsopp20x20","l",l,"Length (mm)");
	BOLTS_check_parameter_type("TSlotExtrusionTwoSlotsopp20x20","detailed",detailed,"Bool");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("T slot extrusion two slots (opp.) 20x20x",l,""));
		}
		cube();
	} else {
		tslot20x20_2s_geo(l, detailed, part_mode);
	}
};

function TSlotExtrusionTwoSlotsopp20x20_dims(l=100, detailed=false, part_mode="default") = tslot20x20_2s_dims(l, detailed, part_mode);

function TSlotExtrusionTwoSlotsopp20x20_conn(location,l=100, detailed=false, part_mode="default") = tslot20x20_2s_conn(location,l, detailed, part_mode);

/* Generated by BOLTS, do not modify */
function tslot20x20_3s_dims(l=100, detailed=false, part_mode="default") = [
	["detailed", detailed],
	["l", l]];

module tslot20x20_3s_geo(l, detailed, part_mode){
	tslot_20x20_3s_base(
		get_dim(tslot20x20_3s_dims(l, detailed, part_mode),"l"),
		get_dim(tslot20x20_3s_dims(l, detailed, part_mode),"detailed")
	);
};

module TSlotExtrusionThreeSlots20x20(l=100, detailed=false, part_mode="default"){
	BOLTS_check_parameter_type("TSlotExtrusionThreeSlots20x20","l",l,"Length (mm)");
	BOLTS_check_parameter_type("TSlotExtrusionThreeSlots20x20","detailed",detailed,"Bool");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("T slot extrusion three slots 20x20x",l,""));
		}
		cube();
	} else {
		tslot20x20_3s_geo(l, detailed, part_mode);
	}
};

function TSlotExtrusionThreeSlots20x20_dims(l=100, detailed=false, part_mode="default") = tslot20x20_3s_dims(l, detailed, part_mode);

function TSlotExtrusionThreeSlots20x20_conn(location,l=100, detailed=false, part_mode="default") = tslot20x20_3s_conn(location,l, detailed, part_mode);

/* Generated by BOLTS, do not modify */
function tslot20x20_1s_dims(l=100, detailed=false, part_mode="default") = [
	["detailed", detailed],
	["l", l]];

module tslot20x20_1s_geo(l, detailed, part_mode){
	tslot_20x20_1s_base(
		get_dim(tslot20x20_1s_dims(l, detailed, part_mode),"l"),
		get_dim(tslot20x20_1s_dims(l, detailed, part_mode),"detailed")
	);
};

module TSlotExtrusionOneSlot20x20(l=100, detailed=false, part_mode="default"){
	BOLTS_check_parameter_type("TSlotExtrusionOneSlot20x20","l",l,"Length (mm)");
	BOLTS_check_parameter_type("TSlotExtrusionOneSlot20x20","detailed",detailed,"Bool");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("T slot extrusion one slot 20x20x",l,""));
		}
		cube();
	} else {
		tslot20x20_1s_geo(l, detailed, part_mode);
	}
};

function TSlotExtrusionOneSlot20x20_dims(l=100, detailed=false, part_mode="default") = tslot20x20_1s_dims(l, detailed, part_mode);

function TSlotExtrusionOneSlot20x20_conn(location,l=100, detailed=false, part_mode="default") = tslot20x20_1s_conn(location,l, detailed, part_mode);

/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
module nut1(d1, s, m_max){
	//hex sidelength
	a = s/tan(60);
	translate([0,0,m_max]){
		difference(){
			BOLTS_hex_head(m_max,s);
			translate([0,0,-d1]) cylinder(r=d1/2,h=m_max+ 2*d1);
		}
	}
}

function nutConn(m_max,location) =
	(location == "bottom") ? [[0,0,0],[[0,0,1],[0,1,0]]] :
	(location == "top")    ? [[0,0,m_max],[[0,0,1],[0,1,0]]] :
	"Error";
/* Generated by BOLTS, do not modify */
function hexagonthinnut1_table_0(idx) =
//d1, s, m_max, e_min
idx == "M2.6" ? [2.6, 5.5, 1.8, 6.01] :
idx == "M2.5" ? [2.5, 5.0, 1.6, 5.45] :
idx == "M56" ? [56.0, 85.0, 28.0, 93.56] :
idx == "M2.3" ? [2.3, 4.5, 1.2, 5.2] :
idx == "M39" ? [39.0, 60.0, 19.5, 66.44] :
idx == "M3.5" ? [3.5, 6.0, 2.0, 6.58] :
idx == "M36" ? [36.0, 55.0, 18.0, 60.79] :
idx == "M33" ? [33.0, 50.0, 16.5, 55.37] :
idx == "M30" ? [20.0, 46.0, 15.0, 50.85] :
idx == "M5" ? [5.0, 8.0, 2.7, 8.79] :
idx == "M4" ? [4.0, 7.0, 2.2, 7.66] :
idx == "M6" ? [6.0, 10.0, 3.2, 11.05] :
idx == "M3" ? [3.0, 5.5, 1.8, 6.01] :
idx == "M2" ? [2.0, 4.0, 1.2, 4.32] :
idx == "M8" ? [8.0, 13.0, 4.0, 14.38] :
idx == "M52" ? [42.0, 80.0, 26.0, 88.25] :
idx == "M24" ? [24.0, 36.0, 12.0, 39.55] :
idx == "M60" ? [60.0, 90.0, 30.0, 99.21] :
idx == "M48" ? [48.0, 75.0, 24.0, 82.6] :
idx == "M64" ? [64.0, 95.0, 32.0, 104.86] :
idx == "M42" ? [42.0, 65.0, 21.0, 71.3] :
idx == "M27" ? [27.0, 41.0, 13.5, 45.2] :
idx == "M20" ? [20.0, 30.0, 10.0, 32.95] :
idx == "M22" ? [22.0, 34.0, 11.0, 37.29] :
idx == "M45" ? [45.0, 70.0, 22.5, 76.95] :
idx == "M16" ? [16.0, 24.0, 8.0, 26.75] :
idx == "M10" ? [10.0, 16.0, 5.0, 17.77] :
idx == "M12" ? [12.0, 18.0, 6.0, 20.03] :
idx == "M14" ? [14.0, 21.0, 7.0, 23.35] :
idx == "M1.6" ? [1.6, 3.2, 1.0, 3.48] :
idx == "M1.7" ? [1.7, 3.2, 1.0, 3.48] :
idx == "M18" ? [18.0, 27.0, 9.0, 29.56] :
"Error";

function hexagonthinnut1_dims(key="M3", part_mode="default") = [
	["e_min", BOLTS_convert_to_default_unit(hexagonthinnut1_table_0(key)[3],"mm")],
	["s", BOLTS_convert_to_default_unit(hexagonthinnut1_table_0(key)[1],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexagonthinnut1_table_0(key)[0],"mm")],
	["key", key],
	["m_max", BOLTS_convert_to_default_unit(hexagonthinnut1_table_0(key)[2],"mm")]];

function hexagonthinnut1_conn(location,key="M3", part_mode="default") = new_cs(
	origin=nutConn(BOLTS_convert_to_default_unit(hexagonthinnut1_table_0(key)[2],"mm"), location)[0],
	axes=nutConn(BOLTS_convert_to_default_unit(hexagonthinnut1_table_0(key)[2],"mm"), location)[1]);

module hexagonthinnut1_geo(key, part_mode){
	nut1(
		get_dim(hexagonthinnut1_dims(key, part_mode),"d1"),
		get_dim(hexagonthinnut1_dims(key, part_mode),"s"),
		get_dim(hexagonthinnut1_dims(key, part_mode),"m_max")
	);
};

module ISO4035(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("ISO4035","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon thin nut ISO 4035 ",key,""));
		}
		cube();
	} else {
		hexagonthinnut1_geo(key, part_mode);
	}
};

function ISO4035_dims(key="M3", part_mode="default") = hexagonthinnut1_dims(key, part_mode);

function ISO4035_conn(location,key="M3", part_mode="default") = hexagonthinnut1_conn(location,key, part_mode);

module DINENISO4035(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINENISO4035","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon thin nut DINENISO 4035 ",key,""));
		}
		cube();
	} else {
		hexagonthinnut1_geo(key, part_mode);
	}
};

function DINENISO4035_dims(key="M3", part_mode="default") = hexagonthinnut1_dims(key, part_mode);

function DINENISO4035_conn(location,key="M3", part_mode="default") = hexagonthinnut1_conn(location,key, part_mode);

module MetricHexagonThinNut(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("MetricHexagonThinNut","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Metric hexagon thin nut ",key,""));
		}
		cube();
	} else {
		hexagonthinnut1_geo(key, part_mode);
	}
};

function MetricHexagonThinNut_dims(key="M3", part_mode="default") = hexagonthinnut1_dims(key, part_mode);

function MetricHexagonThinNut_conn(location,key="M3", part_mode="default") = hexagonthinnut1_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function hexagonthinnut2_table_0(idx) =
//d1, s, m_max, e_min
idx == "M2.6" ? [2.6, 5.5, 1.8, 6.01] :
idx == "M2.5" ? [2.5, 5.0, 1.6, 5.45] :
idx == "M56" ? [56.0, 85.0, 28.0, 93.56] :
idx == "M2.3" ? [2.3, 4.5, 1.2, 5.2] :
idx == "M39" ? [39.0, 60.0, 19.5, 66.44] :
idx == "M3.5" ? [3.5, 6.0, 2.0, 6.58] :
idx == "M36" ? [36.0, 55.0, 18.0, 60.79] :
idx == "M33" ? [33.0, 50.0, 16.5, 55.37] :
idx == "M30" ? [20.0, 46.0, 15.0, 50.85] :
idx == "M5" ? [5.0, 8.0, 2.7, 8.79] :
idx == "M4" ? [4.0, 7.0, 2.2, 7.66] :
idx == "M6" ? [6.0, 10.0, 3.2, 11.05] :
idx == "M3" ? [3.0, 5.5, 1.8, 6.01] :
idx == "M2" ? [2.0, 4.0, 1.2, 4.32] :
idx == "M8" ? [8.0, 13.0, 4.0, 14.38] :
idx == "M52" ? [42.0, 80.0, 26.0, 88.25] :
idx == "M24" ? [24.0, 36.0, 12.0, 39.55] :
idx == "M60" ? [60.0, 90.0, 30.0, 99.21] :
idx == "M48" ? [48.0, 75.0, 24.0, 82.6] :
idx == "M64" ? [64.0, 95.0, 32.0, 104.86] :
idx == "M42" ? [42.0, 65.0, 21.0, 71.3] :
idx == "M27" ? [27.0, 41.0, 13.5, 45.2] :
idx == "M20" ? [20.0, 30.0, 10.0, 32.95] :
idx == "M22" ? [22.0, 32.0, 11.0, 35.03] :
idx == "M45" ? [45.0, 70.0, 22.5, 76.95] :
idx == "M16" ? [16.0, 24.0, 8.0, 26.75] :
idx == "M10" ? [10.0, 17.0, 5.0, 18.9] :
idx == "M12" ? [12.0, 19.0, 6.0, 21.1] :
idx == "M14" ? [14.0, 22.0, 7.0, 24.49] :
idx == "M1.6" ? [1.6, 3.2, 1.0, 3.48] :
idx == "M1.7" ? [1.7, 3.2, 1.0, 3.48] :
idx == "M18" ? [18.0, 27.0, 9.0, 29.56] :
"Error";

function hexagonthinnut2_dims(key="M3", part_mode="default") = [
	["e_min", BOLTS_convert_to_default_unit(hexagonthinnut2_table_0(key)[3],"mm")],
	["s", BOLTS_convert_to_default_unit(hexagonthinnut2_table_0(key)[1],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexagonthinnut2_table_0(key)[0],"mm")],
	["key", key],
	["m_max", BOLTS_convert_to_default_unit(hexagonthinnut2_table_0(key)[2],"mm")]];

function hexagonthinnut2_conn(location,key="M3", part_mode="default") = new_cs(
	origin=nutConn(BOLTS_convert_to_default_unit(hexagonthinnut2_table_0(key)[2],"mm"), location)[0],
	axes=nutConn(BOLTS_convert_to_default_unit(hexagonthinnut2_table_0(key)[2],"mm"), location)[1]);

module hexagonthinnut2_geo(key, part_mode){
	nut1(
		get_dim(hexagonthinnut2_dims(key, part_mode),"d1"),
		get_dim(hexagonthinnut2_dims(key, part_mode),"s"),
		get_dim(hexagonthinnut2_dims(key, part_mode),"m_max")
	);
};

module DIN439B(key="M3", part_mode="default"){
	BOLTS_warning("The standard DIN439B is withdrawn.");
	BOLTS_check_parameter_type("DIN439B","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon thin nut DIN 439 ",key,""));
		}
		cube();
	} else {
		hexagonthinnut2_geo(key, part_mode);
	}
};

function DIN439B_dims(key="M3", part_mode="default") = hexagonthinnut2_dims(key, part_mode);

function DIN439B_conn(location,key="M3", part_mode="default") = hexagonthinnut2_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function hexagonnut1_table_0(idx) =
//d1, s, m_max, e_min
idx == "M72" ? [72.0, 105.0, 58.0, 116.16] :
idx == "M2.5" ? [2.5, 5.0, 2.0, 5.45] :
idx == "M56" ? [56.0, 85.0, 45.0, 93.56] :
idx == "M2.3" ? [2.3, 4.5, 1.8, 4.88] :
idx == "M76" ? [76.0, 110.0, 61.0, 121.81] :
idx == "M39" ? [39.0, 60.0, 33.4, 66.44] :
idx == "M3.5" ? [3.5, 6.0, 2.8, 6.58] :
idx == "M36" ? [36.0, 55.0, 31.0, 60.79] :
idx == "M33" ? [33.0, 50.0, 28.7, 55.37] :
idx == "M30" ? [30.0, 46.0, 25.6, 50.85] :
idx == "M5" ? [5.0, 8.0, 4.7, 8.79] :
idx == "M4" ? [4.0, 7.0, 3.2, 7.66] :
idx == "M7" ? [7.0, 11.0, 5.5, 12.12] :
idx == "M6" ? [6.0, 10.0, 5.2, 11.05] :
idx == "M1" ? [1.0, 2.5, 0.8, 2.71] :
idx == "M3" ? [3.0, 5.5, 2.4, 6.01] :
idx == "M2" ? [2.0, 4.0, 1.6, 4.32] :
idx == "M8" ? [8.0, 13.0, 6.8, 14.38] :
idx == "M85" ? [85.0, 120.0, 68.0, 133.11] :
idx == "M110" ? [110.0, 155.0, 88.0, 172.32] :
idx == "M80" ? [80.0, 115.0, 64.0, 127.46] :
idx == "M42" ? [42.0, 65.0, 34.0, 71.3] :
idx == "M68" ? [68.0, 100.0, 54.0, 110.51] :
idx == "M60" ? [60.0, 90.0, 48.0, 99.21] :
idx == "M48" ? [48.0, 75.0, 38.0, 82.6] :
idx == "M64" ? [64.0, 95.0, 51.0, 104.86] :
idx == "M24" ? [24.0, 36.0, 21.5, 39.55] :
idx == "M27" ? [27.0, 41.0, 23.8, 45.29] :
idx == "M20" ? [20.0, 30.0, 18.0, 32.95] :
idx == "M22" ? [22.0, 34.0, 19.4, 37.29] :
idx == "M45" ? [45.0, 70.0, 36.0, 76.95] :
idx == "M16" ? [16.0, 24.0, 14.8, 26.75] :
idx == "M140" ? [140.0, 200.0, 112.0, 220.8] :
idx == "M125" ? [125.0, 180.0, 100.0, 200.57] :
idx == "M100" ? [100.0, 145.0, 80.0, 161.02] :
idx == "M120" ? [120.0, 170.0, 96.0, 190.29] :
idx == "M105" ? [105.0, 150.0, 84.0, 167.69] :
idx == "M52" ? [52.0, 80.0, 42.0, 88.25] :
idx == "M90" ? [90.0, 130.0, 72.0, 144.08] :
idx == "M95" ? [95.0, 135.0, 76.0, 150.74] :
idx == "M10" ? [10.0, 16.0, 8.4, 17.77] :
idx == "M1.2" ? [1.2, 3.0, 1.0, 3.28] :
idx == "M12" ? [12.0, 18.0, 10.8, 20.03] :
idx == "M1.4" ? [1.4, 3.0, 1.2, 3.28] :
idx == "M14" ? [14.0, 21.0, 12.8, 23.35] :
idx == "M1.6" ? [1.6, 3.2, 1.3, 3.48] :
idx == "M1.7" ? [1.7, 3.4, 1.4, 3.82] :
idx == "M1.8" ? [1.8, 3.5, 1.4, 3.82] :
idx == "M18" ? [18.0, 27.0, 15.8, 29.56] :
"Error";

function hexagonnut1_dims(key="M3", part_mode="default") = [
	["e_min", BOLTS_convert_to_default_unit(hexagonnut1_table_0(key)[3],"mm")],
	["s", BOLTS_convert_to_default_unit(hexagonnut1_table_0(key)[1],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexagonnut1_table_0(key)[0],"mm")],
	["key", key],
	["m_max", BOLTS_convert_to_default_unit(hexagonnut1_table_0(key)[2],"mm")]];

function hexagonnut1_conn(location,key="M3", part_mode="default") = new_cs(
	origin=nutConn(BOLTS_convert_to_default_unit(hexagonnut1_table_0(key)[2],"mm"), location)[0],
	axes=nutConn(BOLTS_convert_to_default_unit(hexagonnut1_table_0(key)[2],"mm"), location)[1]);

module hexagonnut1_geo(key, part_mode){
	nut1(
		get_dim(hexagonnut1_dims(key, part_mode),"d1"),
		get_dim(hexagonnut1_dims(key, part_mode),"s"),
		get_dim(hexagonnut1_dims(key, part_mode),"m_max")
	);
};

module ISO4032(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("ISO4032","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon nut ISO 4032 ",key,""));
		}
		cube();
	} else {
		hexagonnut1_geo(key, part_mode);
	}
};

function ISO4032_dims(key="M3", part_mode="default") = hexagonnut1_dims(key, part_mode);

function ISO4032_conn(location,key="M3", part_mode="default") = hexagonnut1_conn(location,key, part_mode);

module MetricHexagonNut(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("MetricHexagonNut","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Metric hexagon nut ",key,""));
		}
		cube();
	} else {
		hexagonnut1_geo(key, part_mode);
	}
};

function MetricHexagonNut_dims(key="M3", part_mode="default") = hexagonnut1_dims(key, part_mode);

function MetricHexagonNut_conn(location,key="M3", part_mode="default") = hexagonnut1_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function hexagonnut2_table_0(idx) =
//d1, s, m_max, e_min
idx == "M72" ? [72.0, 105.0, 58.0, 116.16] :
idx == "M2.5" ? [2.5, 5.0, 2.0, 5.45] :
idx == "M56" ? [56.0, 85.0, 45.0, 93.56] :
idx == "M2.3" ? [2.3, 4.5, 1.8, 4.88] :
idx == "M76" ? [76.0, 110.0, 61.0, 121.81] :
idx == "M39" ? [39.0, 60.0, 31.0, 66.44] :
idx == "M3.5" ? [3.5, 6.0, 2.8, 6.58] :
idx == "M36" ? [36.0, 55.0, 29.0, 60.79] :
idx == "M33" ? [33.0, 50.0, 26.0, 55.37] :
idx == "M30" ? [30.0, 46.0, 24.0, 50.85] :
idx == "M5" ? [5.0, 8.0, 4.0, 8.79] :
idx == "M4" ? [4.0, 7.0, 3.2, 7.66] :
idx == "M7" ? [7.0, 11.0, 5.5, 12.12] :
idx == "M6" ? [6.0, 10.0, 5.0, 11.05] :
idx == "M1" ? [1.0, 2.5, 0.8, 2.71] :
idx == "M3" ? [3.0, 5.5, 2.4, 6.01] :
idx == "M2" ? [2.0, 4.0, 1.6, 4.32] :
idx == "M8" ? [8.0, 13.0, 6.5, 14.38] :
idx == "M85" ? [85.0, 120.0, 68.0, 133.11] :
idx == "M110" ? [110.0, 155.0, 88.0, 172.32] :
idx == "M80" ? [80.0, 115.0, 64.0, 127.46] :
idx == "M42" ? [42.0, 65.0, 34.0, 71.3] :
idx == "M68" ? [68.0, 100.0, 54.0, 110.51] :
idx == "M60" ? [60.0, 90.0, 48.0, 99.21] :
idx == "M48" ? [48.0, 75.0, 38.0, 82.6] :
idx == "M64" ? [64.0, 95.0, 51.0, 104.86] :
idx == "M24" ? [24.0, 36.0, 19.0, 39.55] :
idx == "M27" ? [27.0, 41.0, 22.0, 45.29] :
idx == "M20" ? [20.0, 30.0, 16.0, 32.95] :
idx == "M22" ? [22.0, 32.0, 18.0, 35.03] :
idx == "M45" ? [45.0, 70.0, 36.0, 76.95] :
idx == "M16" ? [16.0, 24.0, 13.0, 26.75] :
idx == "M140" ? [140.0, 200.0, 112.0, 220.8] :
idx == "M125" ? [125.0, 180.0, 100.0, 200.57] :
idx == "M100" ? [100.0, 145.0, 80.0, 161.02] :
idx == "M120" ? [120.0, 170.0, 96.0, 190.29] :
idx == "M105" ? [105.0, 150.0, 84.0, 167.69] :
idx == "M52" ? [52.0, 80.0, 42.0, 88.25] :
idx == "M90" ? [90.0, 130.0, 72.0, 144.08] :
idx == "M95" ? [95.0, 135.0, 76.0, 150.74] :
idx == "M10" ? [10.0, 17.0, 8.0, 18.9] :
idx == "M1.2" ? [1.2, 3.0, 1.0, 3.28] :
idx == "M12" ? [12.0, 19.0, 10.0, 21.1] :
idx == "M1.4" ? [1.4, 3.0, 1.2, 3.28] :
idx == "M14" ? [14.0, 22.0, 11.0, 24.49] :
idx == "M1.6" ? [1.6, 3.2, 1.3, 3.48] :
idx == "M1.7" ? [1.7, 3.4, 1.4, 3.82] :
idx == "M1.8" ? [1.8, 3.5, 1.4, 3.82] :
idx == "M18" ? [18.0, 27.0, 15.0, 29.56] :
"Error";

function hexagonnut2_dims(key="M3", part_mode="default") = [
	["e_min", BOLTS_convert_to_default_unit(hexagonnut2_table_0(key)[3],"mm")],
	["s", BOLTS_convert_to_default_unit(hexagonnut2_table_0(key)[1],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexagonnut2_table_0(key)[0],"mm")],
	["key", key],
	["m_max", BOLTS_convert_to_default_unit(hexagonnut2_table_0(key)[2],"mm")]];

function hexagonnut2_conn(location,key="M3", part_mode="default") = new_cs(
	origin=nutConn(BOLTS_convert_to_default_unit(hexagonnut2_table_0(key)[2],"mm"), location)[0],
	axes=nutConn(BOLTS_convert_to_default_unit(hexagonnut2_table_0(key)[2],"mm"), location)[1]);

module hexagonnut2_geo(key, part_mode){
	nut1(
		get_dim(hexagonnut2_dims(key, part_mode),"d1"),
		get_dim(hexagonnut2_dims(key, part_mode),"s"),
		get_dim(hexagonnut2_dims(key, part_mode),"m_max")
	);
};

module DIN934(key="M3", part_mode="default"){
	BOLTS_warning("The standard DIN934 is withdrawn.");
	BOLTS_check_parameter_type("DIN934","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon nut DIN 934 ",key,""));
		}
		cube();
	} else {
		hexagonnut2_geo(key, part_mode);
	}
};

function DIN934_dims(key="M3", part_mode="default") = hexagonnut2_dims(key, part_mode);

function DIN934_conn(location,key="M3", part_mode="default") = hexagonnut2_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function hexagonnut3_table_0(idx) =
//d1, s, m_max
idx == "1.375 in" ? [1.375, 2.0625, 1.171875] :
idx == "0.5 in" ? [0.5, 0.75, 0.4375] :
idx == "1.625 in" ? [1.625, 2.4375, 1.390625] :
idx == "0.4375 in" ? [0.4375, 0.6875, 0.375] :
idx == "0.75 in" ? [0.75, 1.125, 0.640625] :
idx == "3 in" ? [3.0, 4.5, 2.59375] :
idx == "2.75 in" ? [2.75, 4.125, 2.375] :
idx == "2 in" ? [2.0, 3.0, 1.71875] :
idx == "2.5 in" ? [2.5, 3.75, 2.15625] :
idx == "2.25 in" ? [2.25, 3.375, 1.9375] :
idx == "0.25 in" ? [0.25, 0.4375, 0.21875] :
idx == "0.625 in" ? [0.625, 0.9375, 0.546875] :
idx == "1.75 in" ? [1.75, 2.625, 1.5] :
idx == "0.375 in" ? [0.375, 0.5625, 0.328125] :
idx == "0.3125 in" ? [0.3125, 0.5, 0.265625] :
idx == "0.5625 in" ? [0.5625, 0.875, 0.484375] :
idx == "1.5 in" ? [1.5, 2.25, 1.28125] :
idx == "1 in" ? [1.0, 1.5, 0.859375] :
idx == "0.875 in" ? [0.875, 1.3125, 0.75] :
idx == "1.125 in" ? [1.125, 1.6875, 0.96875] :
"Error";

function hexagonnut3_dims(key="0.375 in", part_mode="default") = [
	["s", BOLTS_convert_to_default_unit(hexagonnut3_table_0(key)[1],"in")],
	["d1", BOLTS_convert_to_default_unit(hexagonnut3_table_0(key)[0],"in")],
	["key", key],
	["m_max", BOLTS_convert_to_default_unit(hexagonnut3_table_0(key)[2],"in")]];

function hexagonnut3_conn(location,key="0.375 in", part_mode="default") = new_cs(
	origin=nutConn(BOLTS_convert_to_default_unit(hexagonnut3_table_0(key)[2],"in"), location)[0],
	axes=nutConn(BOLTS_convert_to_default_unit(hexagonnut3_table_0(key)[2],"in"), location)[1]);

module hexagonnut3_geo(key, part_mode){
	nut1(
		get_dim(hexagonnut3_dims(key, part_mode),"d1"),
		get_dim(hexagonnut3_dims(key, part_mode),"s"),
		get_dim(hexagonnut3_dims(key, part_mode),"m_max")
	);
};

module ANSIB1822(key="0.375 in", part_mode="default"){
	BOLTS_check_parameter_type("ANSIB1822","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon nut ANSI B18.2.2 ",key,""));
		}
		cube();
	} else {
		hexagonnut3_geo(key, part_mode);
	}
};

function ANSIB1822_dims(key="0.375 in", part_mode="default") = hexagonnut3_dims(key, part_mode);

function ANSIB1822_conn(location,key="0.375 in", part_mode="default") = hexagonnut3_conn(location,key, part_mode);

module ASMEB1822(key="0.375 in", part_mode="default"){
	BOLTS_check_parameter_type("ASMEB1822","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon nut ASME B18.2.2 ",key,""));
		}
		cube();
	} else {
		hexagonnut3_geo(key, part_mode);
	}
};

function ASMEB1822_dims(key="0.375 in", part_mode="default") = hexagonnut3_dims(key, part_mode);

function ASMEB1822_conn(location,key="0.375 in", part_mode="default") = hexagonnut3_conn(location,key, part_mode);

module ImperialHexagonNut(key="0.375 in", part_mode="default"){
	BOLTS_check_parameter_type("ImperialHexagonNut","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Imperial hexagon nut"));
		}
		cube();
	} else {
		hexagonnut3_geo(key, part_mode);
	}
};

function ImperialHexagonNut_dims(key="0.375 in", part_mode="default") = hexagonnut3_dims(key, part_mode);

function ImperialHexagonNut_conn(location,key="0.375 in", part_mode="default") = hexagonnut3_conn(location,key, part_mode);

/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
module hex1(d1,k,s,h,l){
	union(){
		BOLTS_hex_head(k,s);
		//possibly unthreaded shaft
		cylinder(r=d1/2,h=h);
		//threaded shaft
		translate([0,0,h]) BOLTS_thread_external(d1,l-h);
	}
}

module hex2(d1, k, s, b1, b2, b3, l){
	b = (l < 125) ? b1 :
		(l < 200) ? b2 :
		b3;
	BOLTS_check_dimension_defined(b, "threaded shaft length b");

	union(){
		BOLTS_hex_head(k,s);
		//unthreaded shaft
		cylinder(r=d1/2,h=l-b);
		//threaded shaft
		translate([0,0,l-b]) BOLTS_thread_external(d1,b);
	}
}

function hexConn(k,l,location) = 
	(location == "root") ? [[0,0,0],[[0,0,1],[0,1,0]]] :
	(location == "tip") ? [[0,0,l],[[0,0,1],[0,1,0]]] :
	(location == "head") ? [[0,0,-k],[[0,0,-1],[0,-1,0]]] :
	"Error";
/* Generated by BOLTS, do not modify */
function hexbolt2_table_0(idx) =
//d1, k, s, b1, b2, b3, e
idx == "M56" ? [56.0, 35.0, 85.0, "None", 124.0, 137.0, 93.56] :
idx == "M39" ? [39.0, 25.0, 60.0, 84.0, 90.0, 103.0, 66.44] :
idx == "M52" ? [52.0, 33.0, 80.0, "None", 116.0, 129.0, 88.25] :
idx == "M36" ? [36.0, 22.5, 55.0, 78.0, 84.0, 97.0, 60.79] :
idx == "M33" ? [33.0, 21.0, 50.0, 72.0, 78.0, 91.0, 55.37] :
idx == "M30" ? [30.0, 18.7, 46.0, 66.0, 72.0, 85.0, 50.85] :
idx == "M5" ? [5.0, 3.5, 8.0, 16.0, "None", "None", 8.79] :
idx == "M4" ? [4.0, 2.8, 7.0, 14.0, "None", "None", 7.66] :
idx == "M7" ? [7.0, 4.8, 11.0, 20.0, 26.0, "None", 12.12] :
idx == "M6" ? [6.0, 4.0, 10.0, 18.0, 24.0, "None", 11.05] :
idx == "M3" ? [3.0, 2.0, 5.5, 12.0, "None", "None", 6.01] :
idx == "M8" ? [8.0, 5.3, 13.0, 22.0, 28.0, "None", 14.38] :
idx == "M24" ? [24.0, 15.0, 36.0, 54.0, 60.0, 73.0, 39.98] :
idx == "M60" ? [60.0, 38.0, 90.0, "None", 132.0, 145.0, 99.21] :
idx == "M48" ? [48.0, 30.0, 75.0, 102.0, 108.0, 121.0, 82.6] :
idx == "M64" ? [64.0, 40.0, 95.0, "None", 140.0, 153.0, 104.86] :
idx == "M42" ? [42.0, 26.0, 65.0, 90.0, 96.0, 109.0, 71.3] :
idx == "M27" ? [27.0, 17.0, 41.0, 60.0, 66.0, 79.0, 45.2] :
idx == "M20" ? [20.0, 12.5, 30.0, 46.0, 52.0, 65.0, 33.53] :
idx == "M22" ? [22.0, 14.0, 34.0, 50.0, 56.0, 69.0, 35.72] :
idx == "M45" ? [45.0, 28.0, 70.0, 96.0, 102.0, 115.0, 76.95] :
idx == "M10" ? [10.0, 6.4, 16.0, 26.0, 32.0, 45.0, 18.9] :
idx == "M12" ? [12.0, 7.5, 18.0, 30.0, 36.0, 49.0, 21.1] :
idx == "M14" ? [14.0, 8.8, 21.0, 34.0, 40.0, 53.0, 24.49] :
idx == "M16" ? [16.0, 10.0, 24.0, 38.0, 44.0, 57.0, 26.75] :
idx == "M18" ? [18.0, 11.5, 27.0, 42.0, 48.0, 61.0, 30.14] :
"Error";

function hexbolt2_dims(key="M3", l=20, part_mode="default") = [
	["e", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[6],"mm")],
	["key", key],
	["k", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[1],"mm")],
	["l", l],
	["s", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[2],"mm")],
	["b1", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[3],"mm")],
	["b2", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[4],"mm")],
	["b3", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[5],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[0],"mm")]];

function hexbolt2_conn(location,key="M3", l=20, part_mode="default") = new_cs(
	origin=hexConn(BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[1],"mm"), l, location)[0],
	axes=hexConn(BOLTS_convert_to_default_unit(hexbolt2_table_0(key)[1],"mm"), l, location)[1]);

module hexbolt2_geo(key, l, part_mode){
	hex2(
		get_dim(hexbolt2_dims(key, l, part_mode),"d1"),
		get_dim(hexbolt2_dims(key, l, part_mode),"k"),
		get_dim(hexbolt2_dims(key, l, part_mode),"s"),
		get_dim(hexbolt2_dims(key, l, part_mode),"b1"),
		get_dim(hexbolt2_dims(key, l, part_mode),"b2"),
		get_dim(hexbolt2_dims(key, l, part_mode),"b3"),
		get_dim(hexbolt2_dims(key, l, part_mode),"l")
	);
};

module DINEN24014(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DINEN24014","key",key,"Table Index");
	BOLTS_check_parameter_type("DINEN24014","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head bolt DINEN 24014 ",key," - ",l,""));
		}
		cube();
	} else {
		hexbolt2_geo(key, l, part_mode);
	}
};

function DINEN24014_dims(key="M3", l=20, part_mode="default") = hexbolt2_dims(key, l, part_mode);

function DINEN24014_conn(location,key="M3", l=20, part_mode="default") = hexbolt2_conn(location,key, l, part_mode);

module DINENISO4014(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DINENISO4014","key",key,"Table Index");
	BOLTS_check_parameter_type("DINENISO4014","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head bolt DINENISO 4014 ",key," - ",l,""));
		}
		cube();
	} else {
		hexbolt2_geo(key, l, part_mode);
	}
};

function DINENISO4014_dims(key="M3", l=20, part_mode="default") = hexbolt2_dims(key, l, part_mode);

function DINENISO4014_conn(location,key="M3", l=20, part_mode="default") = hexbolt2_conn(location,key, l, part_mode);

module ISO4014(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("ISO4014","key",key,"Table Index");
	BOLTS_check_parameter_type("ISO4014","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head bolt ISO 4014 ",key," - ",l,""));
		}
		cube();
	} else {
		hexbolt2_geo(key, l, part_mode);
	}
};

function ISO4014_dims(key="M3", l=20, part_mode="default") = hexbolt2_dims(key, l, part_mode);

function ISO4014_conn(location,key="M3", l=20, part_mode="default") = hexbolt2_conn(location,key, l, part_mode);

/* Generated by BOLTS, do not modify */
function hexbolt1_table_0(idx) =
//d1, k, s, b1, b2, b3, e
idx == "M56" ? [56.0, 35.0, 85.0, "None", 124.0, 137.0, 93.56] :
idx == "M39" ? [39.0, 25.0, 60.0, 84.0, 90.0, 103.0, 66.44] :
idx == "M52" ? [52.0, 33.0, 80.0, "None", 116.0, 129.0, 88.25] :
idx == "M36" ? [36.0, 22.5, 55.0, 78.0, 84.0, 97.0, 60.79] :
idx == "M33" ? [33.0, 21.0, 50.0, 72.0, 78.0, 91.0, 55.37] :
idx == "M30" ? [30.0, 18.7, 46.0, 66.0, 72.0, 85.0, 50.85] :
idx == "M5" ? [5.0, 3.5, 8.0, 16.0, "None", "None", 8.79] :
idx == "M4" ? [4.0, 2.8, 7.0, 14.0, "None", "None", 7.66] :
idx == "M7" ? [7.0, 4.8, 11.0, 20.0, 26.0, "None", 12.12] :
idx == "M6" ? [6.0, 4.0, 10.0, 18.0, 24.0, "None", 11.05] :
idx == "M3" ? [3.0, 2.0, 5.5, 12.0, "None", "None", 6.01] :
idx == "M8" ? [8.0, 5.3, 13.0, 22.0, 28.0, "None", 14.38] :
idx == "M24" ? [24.0, 15.0, 36.0, 54.0, 60.0, 73.0, 39.98] :
idx == "M60" ? [60.0, 38.0, 90.0, "None", 132.0, 145.0, 99.21] :
idx == "M48" ? [48.0, 30.0, 75.0, 102.0, 108.0, 121.0, 82.6] :
idx == "M64" ? [64.0, 40.0, 95.0, "None", 140.0, 153.0, 104.86] :
idx == "M42" ? [42.0, 26.0, 65.0, 90.0, 96.0, 109.0, 71.3] :
idx == "M27" ? [27.0, 17.0, 41.0, 60.0, 66.0, 79.0, 45.2] :
idx == "M20" ? [20.0, 12.5, 30.0, 46.0, 52.0, 65.0, 33.53] :
idx == "M22" ? [22.0, 14.0, 32.0, 50.0, 56.0, 69.0, 35.72] :
idx == "M45" ? [45.0, 28.0, 70.0, 96.0, 102.0, 115.0, 76.95] :
idx == "M10" ? [10.0, 6.4, 17.0, 26.0, 32.0, 45.0, 18.9] :
idx == "M12" ? [12.0, 7.5, 19.0, 30.0, 36.0, 49.0, 21.1] :
idx == "M14" ? [14.0, 8.8, 22.0, 34.0, 40.0, 53.0, 24.49] :
idx == "M16" ? [16.0, 10.0, 24.0, 38.0, 44.0, 57.0, 26.75] :
idx == "M18" ? [18.0, 11.5, 27.0, 42.0, 48.0, 61.0, 30.14] :
"Error";

function hexbolt1_dims(key="M3", l=20, part_mode="default") = [
	["e", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[6],"mm")],
	["key", key],
	["k", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[1],"mm")],
	["l", l],
	["s", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[2],"mm")],
	["b1", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[3],"mm")],
	["b2", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[4],"mm")],
	["b3", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[5],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[0],"mm")]];

function hexbolt1_conn(location,key="M3", l=20, part_mode="default") = new_cs(
	origin=hexConn(BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[1],"mm"), l, location)[0],
	axes=hexConn(BOLTS_convert_to_default_unit(hexbolt1_table_0(key)[1],"mm"), l, location)[1]);

module hexbolt1_geo(key, l, part_mode){
	hex2(
		get_dim(hexbolt1_dims(key, l, part_mode),"d1"),
		get_dim(hexbolt1_dims(key, l, part_mode),"k"),
		get_dim(hexbolt1_dims(key, l, part_mode),"s"),
		get_dim(hexbolt1_dims(key, l, part_mode),"b1"),
		get_dim(hexbolt1_dims(key, l, part_mode),"b2"),
		get_dim(hexbolt1_dims(key, l, part_mode),"b3"),
		get_dim(hexbolt1_dims(key, l, part_mode),"l")
	);
};

module DIN931(key="M3", l=20, part_mode="default"){
	BOLTS_warning("The standard DIN931 is withdrawn.");
	BOLTS_check_parameter_type("DIN931","key",key,"Table Index");
	BOLTS_check_parameter_type("DIN931","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head bolt DIN 931 ",key," - ",l,""));
		}
		cube();
	} else {
		hexbolt1_geo(key, l, part_mode);
	}
};

function DIN931_dims(key="M3", l=20, part_mode="default") = hexbolt1_dims(key, l, part_mode);

function DIN931_conn(location,key="M3", l=20, part_mode="default") = hexbolt1_conn(location,key, l, part_mode);

module hexagonHeadBolt(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("hexagonHeadBolt","key",key,"Table Index");
	BOLTS_check_parameter_type("hexagonHeadBolt","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head bolt ",key," - ",l,""));
		}
		cube();
	} else {
		hexbolt1_geo(key, l, part_mode);
	}
};

function hexagonHeadBolt_dims(key="M3", l=20, part_mode="default") = hexbolt1_dims(key, l, part_mode);

function hexagonHeadBolt_conn(location,key="M3", l=20, part_mode="default") = hexbolt1_conn(location,key, l, part_mode);

/* Generated by BOLTS, do not modify */
function hexscrew2_table_0(idx) =
//d1, k, s, e, h
idx == "M2.5" ? [2.5, 1.7, 5.0, 5.45, "None"] :
idx == "M39" ? [39.0, 25.0, 60.0, 66.44, "None"] :
idx == "M52" ? [52.0, 33.0, 80.0, 88.25, "None"] :
idx == "M36" ? [36.0, 22.5, 55.0, 60.79, 12.0] :
idx == "M33" ? [33.0, 21.0, 50.0, 55.37, 10.5] :
idx == "M30" ? [30.0, 18.7, 46.0, 50.85, 10.5] :
idx == "M5" ? [5.0, 3.5, 8.0, 8.79, 2.4] :
idx == "M4" ? [4.0, 2.8, 7.0, 7.66, 2.1] :
idx == "M7" ? [7.0, 4.8, 11.0, 12.12, "None"] :
idx == "M6" ? [6.0, 4.0, 10.0, 11.05, 3.0] :
idx == "M3" ? [3.0, 2.0, 5.5, 6.01, 1.5] :
idx == "M2" ? [2.0, 1.4, 4.0, 4.32, "None"] :
idx == "M8" ? [8.0, 5.3, 13.0, 14.38, 3.75] :
idx == "M3.5" ? [3.5, 2.4, 6.0, 6.58, "None"] :
idx == "M24" ? [24.0, 15.0, 36.0, 39.98, 9.0] :
idx == "M48" ? [48.0, 30.0, 75.0, 82.6, "None"] :
idx == "M64" ? [64.0, 40.0, 95.0, 104.86, "None"] :
idx == "M42" ? [42.0, 26.0, 65.0, 71.3, "None"] :
idx == "M27" ? [27.0, 17.0, 41.0, 45.2, 9.0] :
idx == "M20" ? [20.0, 12.5, 30.0, 33.53, 7.5] :
idx == "M22" ? [22.0, 14.0, 32.0, 35.72, 7.5] :
idx == "M45" ? [45.0, 28.0, 70.0, 76.95, "None"] :
idx == "M10" ? [10.0, 6.4, 16.0, 18.9, 4.5] :
idx == "M12" ? [12.0, 7.5, 18.0, 21.1, 5.25] :
idx == "M14" ? [14.0, 8.8, 22.0, 24.49, 6.0] :
idx == "M1.6" ? [1.6, 1.1, 3.2, 3.48, "None"] :
idx == "M16" ? [16.0, 10.0, 24.0, 26.75, 6.0] :
idx == "M18" ? [18.0, 11.5, 27.0, 30.14, 7.5] :
"Error";

function hexscrew2_dims(key="M3", l=20, part_mode="default") = [
	["e", BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[3],"mm")],
	["h", BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[4],"mm")],
	["k", BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[1],"mm")],
	["l", l],
	["s", BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[2],"mm")],
	["key", key],
	["d1", BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[0],"mm")]];

function hexscrew2_conn(location,key="M3", l=20, part_mode="default") = new_cs(
	origin=hexConn(BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[1],"mm"), l, location)[0],
	axes=hexConn(BOLTS_convert_to_default_unit(hexscrew2_table_0(key)[1],"mm"), l, location)[1]);

module hexscrew2_geo(key, l, part_mode){
	hex1(
		get_dim(hexscrew2_dims(key, l, part_mode),"d1"),
		get_dim(hexscrew2_dims(key, l, part_mode),"k"),
		get_dim(hexscrew2_dims(key, l, part_mode),"s"),
		get_dim(hexscrew2_dims(key, l, part_mode),"h"),
		get_dim(hexscrew2_dims(key, l, part_mode),"l")
	);
};

module ENISO24017(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("ENISO24017","key",key,"Table Index");
	BOLTS_check_parameter_type("ENISO24017","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head screw EN ISO 24017 ",key," - ",l,""));
		}
		cube();
	} else {
		hexscrew2_geo(key, l, part_mode);
	}
};

function ENISO24017_dims(key="M3", l=20, part_mode="default") = hexscrew2_dims(key, l, part_mode);

function ENISO24017_conn(location,key="M3", l=20, part_mode="default") = hexscrew2_conn(location,key, l, part_mode);

module ISO4017(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("ISO4017","key",key,"Table Index");
	BOLTS_check_parameter_type("ISO4017","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("hexagon_head_screw_ISO4017_",key,"_",l,""));
		}
		cube();
	} else {
		hexscrew2_geo(key, l, part_mode);
	}
};

function ISO4017_dims(key="M3", l=20, part_mode="default") = hexscrew2_dims(key, l, part_mode);

function ISO4017_conn(location,key="M3", l=20, part_mode="default") = hexscrew2_conn(location,key, l, part_mode);

module DINENISO4017(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DINENISO4017","key",key,"Table Index");
	BOLTS_check_parameter_type("DINENISO4017","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head screw DIN EN ISO 4017 ",key," - ",l,""));
		}
		cube();
	} else {
		hexscrew2_geo(key, l, part_mode);
	}
};

function DINENISO4017_dims(key="M3", l=20, part_mode="default") = hexscrew2_dims(key, l, part_mode);

function DINENISO4017_conn(location,key="M3", l=20, part_mode="default") = hexscrew2_conn(location,key, l, part_mode);

module hexagonHeadScrew(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("hexagonHeadScrew","key",key,"Table Index");
	BOLTS_check_parameter_type("hexagonHeadScrew","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head screw ",key," - ",l,""));
		}
		cube();
	} else {
		hexscrew2_geo(key, l, part_mode);
	}
};

function hexagonHeadScrew_dims(key="M3", l=20, part_mode="default") = hexscrew2_dims(key, l, part_mode);

function hexagonHeadScrew_conn(location,key="M3", l=20, part_mode="default") = hexscrew2_conn(location,key, l, part_mode);

/* Generated by BOLTS, do not modify */
function hexscrew1_table_0(idx) =
//d1, k, s, e, h, pitch
idx == "M2.5" ? [2.5, 1.7, 5.0, 5.45, "None", 0.45] :
idx == "M39" ? [39.0, 25.0, 60.0, 66.44, "None", 4.0] :
idx == "M52" ? [52.0, 33.0, 80.0, 88.25, "None", 5.0] :
idx == "M36" ? [36.0, 22.5, 55.0, 60.79, 12.0, 4.0] :
idx == "M33" ? [33.0, 21.0, 50.0, 55.37, 10.5, 3.5] :
idx == "M30" ? [30.0, 18.7, 46.0, 50.85, 10.5, 3.5] :
idx == "M5" ? [5.0, 3.5, 8.0, 8.79, 2.4, 0.8] :
idx == "M4" ? [4.0, 2.8, 7.0, 7.66, 2.1, 0.7] :
idx == "M7" ? [7.0, 4.8, 11.0, 12.12, "None", 1.0] :
idx == "M6" ? [6.0, 4.0, 10.0, 11.05, 3.0, 1.0] :
idx == "M3" ? [3.0, 2.0, 5.5, 6.01, 1.5, 0.5] :
idx == "M2" ? [2.0, 1.4, 4.0, 4.32, "None", 0.4] :
idx == "M8" ? [8.0, 5.3, 13.0, 14.38, 3.75, 1.25] :
idx == "M3.5" ? [3.5, 2.4, 6.0, 6.58, "None", 0.6] :
idx == "M24" ? [24.0, 15.0, 36.0, 39.98, 9.0, 3.0] :
idx == "M48" ? [48.0, 30.0, 75.0, 82.6, "None", 5.0] :
idx == "M64" ? [64.0, 40.0, 95.0, 104.86, "None", 6.0] :
idx == "M42" ? [42.0, 26.0, 65.0, 71.3, "None", 4.5] :
idx == "M27" ? [27.0, 17.0, 41.0, 45.2, 9.0, 3.0] :
idx == "M20" ? [20.0, 12.5, 30.0, 33.53, 7.5, 2.5] :
idx == "M22" ? [22.0, 14.0, 32.0, 35.72, 7.5, 2.5] :
idx == "M45" ? [45.0, 28.0, 70.0, 76.95, "None", 4.5] :
idx == "M10" ? [10.0, 6.4, 17.0, 18.9, 4.5, 1.5] :
idx == "M12" ? [12.0, 7.5, 19.0, 21.1, 5.25, 1.75] :
idx == "M14" ? [14.0, 8.8, 22.0, 24.49, 6.0, 2.0] :
idx == "M1.6" ? [1.6, 1.1, 3.2, 3.48, "None", 0.35] :
idx == "M16" ? [16.0, 10.0, 24.0, 26.75, 6.0, 2.0] :
idx == "M18" ? [18.0, 11.5, 27.0, 30.14, 7.5, 2.5] :
"Error";

function hexscrew1_table2d_0(rowidx,colidx) =
colidx == "coarse" ? hexscrew1_table2d_rows_0(rowidx)[0] :
colidx == "fine I" ? hexscrew1_table2d_rows_0(rowidx)[1] :
colidx == "fine II" ? hexscrew1_table2d_rows_0(rowidx)[2] :
colidx == "fine III" ? hexscrew1_table2d_rows_0(rowidx)[3] :
colidx == "fine IV" ? hexscrew1_table2d_rows_0(rowidx)[4] :
"Error";

function hexscrew1_table2d_rows_0(rowidx) =
rowidx == "M2.6" ? [0.45, 0.35, "None", "None", "None"] :
rowidx == "M2.5" ? [0.45, 0.35, "None", "None", "None"] :
rowidx == "M56" ? [5.5, "None", 4.0, "None", 2.0] :
rowidx == "M2.3" ? [0.4, 0.25, "None", "None", "None"] :
rowidx == "M2.2" ? [0.45, 0.25, "None", "None", "None"] :
rowidx == "M39" ? [4.0, 3.0, 2.0, 1.5, "None"] :
rowidx == "M3.5" ? [0.6, 0.35, "None", "None", "None"] :
rowidx == "M36" ? [4.0, 3.0, 2.0, 1.5, "None"] :
rowidx == "M33" ? [3.5, 3.0, 2.0, 1.5, "None"] :
rowidx == "M32" ? ["None", "None", 2.0, 1.5, "None"] :
rowidx == "M30" ? [3.5, 3.0, 2.0, 1.5, 1.0] :
rowidx == "M5" ? [0.8, 0.5, "None", "None", "None"] :
rowidx == "M4" ? [0.7, 0.5, "None", "None", "None"] :
rowidx == "M7" ? [1.0, 0.75, "None", "None", "None"] :
rowidx == "M6" ? [1.0, 0.75, "None", "None", "None"] :
rowidx == "M1" ? [0.25, 0.2, "None", "None", "None"] :
rowidx == "M3" ? [0.5, 0.35, "None", "None", "None"] :
rowidx == "M2" ? [0.4, 0.25, "None", "None", "None"] :
rowidx == "M64" ? [6.0, "None", 4.0, "None", "None"] :
rowidx == "M9" ? [1.25, 1.0, 0.75, "None", "None"] :
rowidx == "M8" ? [1.25, 1.0, 0.75, "None", "None"] :
rowidx == "M10" ? [1.5, 1.25, 1.0, 0.75, "None"] :
rowidx == "M38" ? ["None", "None", "None", 1.5, "None"] :
rowidx == "M42" ? [4.5, 4.0, 3.0, 2.0, 1.5] :
rowidx == "M1.4" ? [0.3, 0.2, "None", "None", "None"] :
rowidx == "M40" ? ["None", 3.0, 2.0, 1.5, "None"] :
rowidx == "M60" ? [5.5, "None", 4.0, "None", 2.0] :
rowidx == "M48" ? [5.0, 4.0, 3.0, 2.0, 1.5] :
rowidx == "M28" ? ["None", 2.0, 1.5, 1.0, "None"] :
rowidx == "M24" ? [3.0, 2.0, 1.5, 1.0, "None"] :
rowidx == "M26" ? ["None", "None", 1.5, "None", "None"] :
rowidx == "M27" ? [3.0, 2.0, 1.5, 1.0, "None"] :
rowidx == "M20" ? [2.5, 2.0, 1.5, 1.0, "None"] :
rowidx == "M22" ? [2.5, 2.0, 1.5, 1.0, "None"] :
rowidx == "M45" ? [4.5, 4.0, 3.0, 2.0, 1.5] :
rowidx == "M16" ? [2.0, 1.5, "None", 1.0, "None"] :
rowidx == "M52" ? [5.0, 4.0, 3.0, 2.0, 1.5] :
rowidx == "M68" ? [6.0, "None", 4.0, "None", "None"] :
rowidx == "M11" ? [1.5, "None", 1.0, 0.75, "None"] :
rowidx == "M1.1" ? [0.25, 0.2, "None", "None", "None"] :
rowidx == "M1.2" ? [0.25, 0.2, "None", "None", "None"] :
rowidx == "M12" ? [1.75, 1.5, 1.25, 1.0, "None"] :
rowidx == "M4.5" ? [0.75, 0.5, "None", "None", "None"] :
rowidx == "M14" ? [2.0, 1.5, 1.25, 1.0, "None"] :
rowidx == "M1.6" ? [0.35, 0.2, "None", "None", "None"] :
rowidx == "M1.7" ? [0.35, 0.2, "None", "None", "None"] :
rowidx == "M1.8" ? [0.35, 0.2, "None", "None", "None"] :
rowidx == "M18" ? [2.5, 2.0, 1.5, 1.0, "None"] :
"Error";

function hexscrew1_table2d_1(rowidx,colidx) =
colidx == "coarse" ? hexscrew1_table2d_rows_1(rowidx)[0] :
colidx == "fine I" ? hexscrew1_table2d_rows_1(rowidx)[1] :
colidx == "fine II" ? hexscrew1_table2d_rows_1(rowidx)[2] :
colidx == "fine III" ? hexscrew1_table2d_rows_1(rowidx)[3] :
colidx == "fine IV" ? hexscrew1_table2d_rows_1(rowidx)[4] :
"Error";

function hexscrew1_table2d_rows_1(rowidx) =
rowidx == "M2.6" ? ["", "x0.35", "", "", ""] :
rowidx == "M2.5" ? ["", "x0.35", "", "", ""] :
rowidx == "M56" ? ["", "", "x4", "", "x2"] :
rowidx == "M2.3" ? ["", "x0.25", "", "", ""] :
rowidx == "M2.2" ? ["", "x0.25", "", "", ""] :
rowidx == "M39" ? ["", "x3", "x2", "x1.5", ""] :
rowidx == "M3.5" ? ["", "x0.35", "", "", ""] :
rowidx == "M36" ? ["", "x3", "x2", "x1.5", ""] :
rowidx == "M33" ? ["", "x3", "x2", "x1.5", ""] :
rowidx == "M32" ? ["", "", "x2", "x1.5", ""] :
rowidx == "M30" ? ["", "x3", "x2", "x1.5", "x1"] :
rowidx == "M5" ? ["", "x0.5", "", "", ""] :
rowidx == "M4" ? ["", "x0.5", "", "", ""] :
rowidx == "M7" ? ["", "x0.75", "", "", ""] :
rowidx == "M6" ? ["", "x0.75", "", "", ""] :
rowidx == "M1" ? ["", "x0.2", "", "", ""] :
rowidx == "M3" ? ["", "x0.35", "", "", ""] :
rowidx == "M2" ? ["", "x0.25", "", "", ""] :
rowidx == "M64" ? ["", "", "x4", "", ""] :
rowidx == "M9" ? ["", "x1", "x0.75", "", ""] :
rowidx == "M8" ? ["", "x1", "x0.75", "", ""] :
rowidx == "M10" ? ["", "x1.25", "x1", "x0.75", ""] :
rowidx == "M38" ? ["", "", "", "x1.5", ""] :
rowidx == "M42" ? ["", "x4", "x3", "x2", "x1.5"] :
rowidx == "M1.4" ? ["", "x0.2", "", "", ""] :
rowidx == "M40" ? ["", "x3", "x2", "x1.5", ""] :
rowidx == "M60" ? ["", "", "x4", "", "x2"] :
rowidx == "M48" ? ["", "x4", "x3", "x2", "x1.5"] :
rowidx == "M28" ? ["", "x2", "x1.5", "x1", ""] :
rowidx == "M24" ? ["", "x2", "x1.5", "x1", ""] :
rowidx == "M26" ? ["", "", "x1.5", "", ""] :
rowidx == "M27" ? ["", "x2", "x1.5", "x1", ""] :
rowidx == "M20" ? ["", "x2", "x1.5", "x1", ""] :
rowidx == "M22" ? ["", "x2", "x1.5", "x1", ""] :
rowidx == "M45" ? ["", "x4", "x3", "x2", "x1.5"] :
rowidx == "M16" ? ["", "x1.5", "", "x1", ""] :
rowidx == "M52" ? ["", "x4", "x3", "x2", "x1.5"] :
rowidx == "M68" ? ["", "", "x4", "", ""] :
rowidx == "M11" ? ["", "", "x1", "x0.75", ""] :
rowidx == "M1.1" ? ["", "x0.2", "", "", ""] :
rowidx == "M1.2" ? ["", "x0.2", "", "", ""] :
rowidx == "M12" ? ["", "x1.5", "x1.25", "x1", ""] :
rowidx == "M4.5" ? ["", "x0.5", "", "", ""] :
rowidx == "M14" ? ["", "x1.5", "x1.25", "x1", ""] :
rowidx == "M1.6" ? ["", "x0.2", "", "", ""] :
rowidx == "M1.7" ? ["", "x0.2", "", "", ""] :
rowidx == "M1.8" ? ["", "x0.2", "", "", ""] :
rowidx == "M18" ? ["", "x2", "x1.5", "x1", ""] :
"Error";

function hexscrew1_dims(key="M3", l=20, thread_type="coarse", part_mode="default") = [
	["e", BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[3],"mm")],
	["h", BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[4],"mm")],
	["k", BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[1],"mm")],
	["thread_type", thread_type],
	["l", l],
	["s", BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[2],"mm")],
	["key", key],
	["pitch", BOLTS_convert_to_default_unit(hexscrew1_table2d_0(key,thread_type),"mm")],
	["pitch_name", hexscrew1_table2d_1(key,thread_type)],
	["d1", BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[0],"mm")]];

function hexscrew1_conn(location,key="M3", l=20, thread_type="coarse", part_mode="default") = new_cs(
	origin=hexConn(BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[1],"mm"), l, location)[0],
	axes=hexConn(BOLTS_convert_to_default_unit(hexscrew1_table_0(key)[1],"mm"), l, location)[1]);

module hexscrew1_geo(key, l, thread_type, part_mode){
	hex1(
		get_dim(hexscrew1_dims(key, l, thread_type, part_mode),"d1"),
		get_dim(hexscrew1_dims(key, l, thread_type, part_mode),"k"),
		get_dim(hexscrew1_dims(key, l, thread_type, part_mode),"s"),
		get_dim(hexscrew1_dims(key, l, thread_type, part_mode),"h"),
		get_dim(hexscrew1_dims(key, l, thread_type, part_mode),"l")
	);
};

module DIN933(key="M3", l=20, thread_type="coarse", part_mode="default"){
	BOLTS_warning("The standard DIN933 is withdrawn.");
	BOLTS_check_parameter_type("DIN933","key",key,"Table Index");
	BOLTS_check_parameter_type("DIN933","l",l,"Length (mm)");
	BOLTS_check_parameter_type("DIN933","thread_type",thread_type,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hexagon head screw DIN 933 ",key,"",hexscrew1_table2d_1(key,thread_type)," - ",l,""));
		}
		cube();
	} else {
		hexscrew1_geo(key, l, thread_type, part_mode);
	}
};

function DIN933_dims(key="M3", l=20, thread_type="coarse", part_mode="default") = hexscrew1_dims(key, l, thread_type, part_mode);

function DIN933_conn(location,key="M3", l=20, thread_type="coarse", part_mode="default") = hexscrew1_conn(location,key, l, thread_type, part_mode);

/* Pipe module for OpenSCAD
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

module roundBatteryBase(h,d){
	union(){
		//nub
		cylinder(r=d/6,h=h);
		//cell
		cylinder(r=d/2,h=0.97*h);
	}
}

function roundBatteryConn(h,location) = 
	(location == "plus")  ? [[0,0,h],[[0,0,1],[0,1,0]]] :
	(location == "minus") ? [[0,0,0],[[0,0,1],[0,1,0]]] :
	"Error";
/* Generated by BOLTS, do not modify */
function round_battery_table_0(idx) =
//h, d
idx == "AA" ? [50.5, 14.5] :
idx == "A" ? [50.0, 17.0] :
idx == "C" ? [50.0, 26.2] :
idx == "AAA" ? [44.5, 10.5] :
idx == "D" ? [61.5, 34.2] :
idx == "N" ? [30.2, 12.0] :
idx == "AAAA" ? [42.5, 8.3] :
idx == "Half-AA" ? [24.0, 14.5] :
idx == "Sub-C" ? [42.9, 22.2] :
"Error";

function round_battery_dims(T="AAA", part_mode="default") = [
	["h", BOLTS_convert_to_default_unit(round_battery_table_0(T)[0],"mm")],
	["T", T],
	["d", BOLTS_convert_to_default_unit(round_battery_table_0(T)[1],"mm")]];

function round_battery_conn(location,T="AAA", part_mode="default") = new_cs(
	origin=roundBatteryConn(BOLTS_convert_to_default_unit(round_battery_table_0(T)[0],"mm"), location)[0],
	axes=roundBatteryConn(BOLTS_convert_to_default_unit(round_battery_table_0(T)[0],"mm"), location)[1]);

module round_battery_geo(T, part_mode){
	roundBatteryBase(
		get_dim(round_battery_dims(T, part_mode),"h"),
		get_dim(round_battery_dims(T, part_mode),"d")
	);
};

module IEC60086Cat1(T="AAA", part_mode="default"){
	BOLTS_check_parameter_type("IEC60086Cat1","T",T,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("IEC 60086 Category 1 Battery ",T,""));
		}
		cube();
	} else {
		round_battery_geo(T, part_mode);
	}
};

function IEC60086Cat1_dims(T="AAA", part_mode="default") = round_battery_dims(T, part_mode);

function IEC60086Cat1_conn(location,T="AAA", part_mode="default") = round_battery_conn(location,T, part_mode);

module RoundBatteries(T="AAA", part_mode="default"){
	BOLTS_check_parameter_type("RoundBatteries","T",T,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("",T," Battery"));
		}
		cube();
	} else {
		round_battery_geo(T, part_mode);
	}
};

function RoundBatteries_dims(T="AAA", part_mode="default") = round_battery_dims(T, part_mode);

function RoundBatteries_conn(location,T="AAA", part_mode="default") = round_battery_conn(location,T, part_mode);

/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
module hex_socket1(d1,d2,b1,b2,b3,k_max,s,t,L,h_max,l){
	b = (l <= L) ? l - k_max - h_max : 
		l < 125 ? b1 :
		l < 200 ? b2 :
		b3;
	h = l - k_max - b;

	//TODO: These checks are not very careful
	BOLTS_check_dimension_defined(b,"threaded shaft length b");
	BOLTS_check_dimension_defined(t,"socket depth t");
	BOLTS_check_dimension_defined(h_max,"unthreaded shaft length h_max");

	difference(){
		union(){
			//Head
			cylinder(r1=d2/2,r2=d1/2,h = k_max);
			//unthreaded shaft
			cylinder(r=d1/2,h=k_max+h);
			//threaded shaft
			translate([0,0,k_max+h]) BOLTS_thread_external(d1,b);
		}
		BOLTS_hex_socket_neg(t,s);
	}
}

module hex_socket2(d1,d2,b,k,s,t_min,L,l){
	h = (l<= L) ? 0 : l - b;

	BOLTS_check_dimension_positive(h,"l too short");

	difference(){
		union(){
			//Head
			translate([0,0,-k]) cylinder(r=d2/2,h = k);
			//unthreaded shaft
			cylinder(r=d1/2,h=h);
			//threaded shaft
			translate([0,0,h]) BOLTS_thread_external(d1,b);
		}
		translate([0,0,-k]) BOLTS_hex_socket_neg(t_min,s);
	}
}

/* Generated by BOLTS, do not modify */
function hexsocketcountersunk_table_0(idx) =
//d1, d2, b1, b2, b3, k_max, s, t, alpha, L, h_max
idx == "M2.5" ? [2.5, 5.0, "None", "None", "None", 1.5, 1.5, "None", 90.0, 16.0, "None"] :
idx == "M10" ? [10.0, 20.0, 26.0, 32.0, 45.0, 5.5, 6.0, 4.4, 90.0, 55.0, 10.0] :
idx == "M24" ? [24.0, 39.0, 54.0, 60.0, "None", 14.0, 14.0, 10.3, 60.0, 90.0, 23.0] :
idx == "M16" ? [16.0, 30.0, 38.0, 44.0, 57.0, 7.5, 10.0, 5.3, 90.0, 70.0, 13.5] :
idx == "M20" ? [20.0, 36.0, 46.0, 52.0, 65.0, 8.5, 12.0, 5.9, 90.0, 90.0, 16.0] :
idx == "M22" ? [22.0, 36.0, "None", "None", "None", 13.1, 14.0, "None", "None", "None", "None"] :
idx == "M5" ? [5.0, 10.0, 16.0, "None", "None", 2.8, 3.0, 2.3, 90.0, 35.0, 5.2] :
idx == "M4" ? [4.0, 8.0, 14.0, "None", "None", 2.3, 2.5, 1.8, 90.0, 30.0, 4.4] :
idx == "M6" ? [6.0, 12.0, 18.0, 24.0, "None", 3.3, 4.0, 2.5, 90.0, 40.0, 6.3] :
idx == "M14" ? [14.0, 27.0, 34.0, 40.0, "None", 7.0, 10.0, 4.8, 90.0, 65.0, 13.0] :
idx == "M3" ? [3.0, 6.0, 12.0, "None", "None", 1.7, 2.0, 1.2, 90.0, 30.0, 3.2] :
idx == "M2" ? [2.0, 4.0, "None", "None", "None", 1.2, 1.25, "None", 90.0, 12.0, "None"] :
idx == "M18" ? [18.0, 33.0, 43.0, "None", "None", 8.0, 12.0, "None", 90.0, 60.0, "None"] :
idx == "M12" ? [12.0, 24.0, 30.0, 36.0, 49.0, 6.5, 8.0, 4.6, 90.0, 60.0, 11.8] :
idx == "M8" ? [8.0, 16.0, 22.0, 28.0, "None", 4.4, 5.0, 3.5, 90.0, 45.0, 8.2] :
"Error";

function hexsocketcountersunk_dims(key="M3", l=20, part_mode="default") = [
	["b2", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[3],"mm")],
	["h_max", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[10],"mm")],
	["l", l],
	["L", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[9],"mm")],
	["k_max", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[5],"mm")],
	["s", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[6],"mm")],
	["t", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[7],"mm")],
	["key", key],
	["b3", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[4],"mm")],
	["alpha", hexsocketcountersunk_table_0(key)[8]],
	["d1", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[0],"mm")],
	["d2", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[1],"mm")],
	["b1", BOLTS_convert_to_default_unit(hexsocketcountersunk_table_0(key)[2],"mm")]];

module hexsocketcountersunk_geo(key, l, part_mode){
	hex_socket1(
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"d1"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"d2"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"b1"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"b2"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"b3"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"k_max"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"s"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"t"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"L"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"h_max"),
		get_dim(hexsocketcountersunk_dims(key, l, part_mode),"l")
	);
};

module DINISO10642(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DINISO10642","key",key,"Table Index");
	BOLTS_check_parameter_type("DINISO10642","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket countersunk head screw DIN ISO 10642 ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketcountersunk_geo(key, l, part_mode);
	}
};

function DINISO10642_dims(key="M3", l=20, part_mode="default") = hexsocketcountersunk_dims(key, l, part_mode);

function DINISO10642_conn(location,key="M3", l=20, part_mode="default") = hexsocketcountersunk_conn(location,key, l, part_mode);

module DIN7991(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DIN7991","key",key,"Table Index");
	BOLTS_check_parameter_type("DIN7991","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket countersunk head screw DIN 7991 ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketcountersunk_geo(key, l, part_mode);
	}
};

function DIN7991_dims(key="M3", l=20, part_mode="default") = hexsocketcountersunk_dims(key, l, part_mode);

function DIN7991_conn(location,key="M3", l=20, part_mode="default") = hexsocketcountersunk_conn(location,key, l, part_mode);

module ISO10642(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("ISO10642","key",key,"Table Index");
	BOLTS_check_parameter_type("ISO10642","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket countersunk head screw ISO 10642 ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketcountersunk_geo(key, l, part_mode);
	}
};

function ISO10642_dims(key="M3", l=20, part_mode="default") = hexsocketcountersunk_dims(key, l, part_mode);

function ISO10642_conn(location,key="M3", l=20, part_mode="default") = hexsocketcountersunk_conn(location,key, l, part_mode);

module MetricHexSocketCountersunkHeadScrew(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("MetricHexSocketCountersunkHeadScrew","key",key,"Table Index");
	BOLTS_check_parameter_type("MetricHexSocketCountersunkHeadScrew","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket countersunk head screw ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketcountersunk_geo(key, l, part_mode);
	}
};

function MetricHexSocketCountersunkHeadScrew_dims(key="M3", l=20, part_mode="default") = hexsocketcountersunk_dims(key, l, part_mode);

function MetricHexSocketCountersunkHeadScrew_conn(location,key="M3", l=20, part_mode="default") = hexsocketcountersunk_conn(location,key, l, part_mode);

/* Generated by BOLTS, do not modify */
function hexsocketheadcap_table_0(idx) =
//d1, d2, b, k, s, t_min, L
idx == "M2.5" ? [2.5, 4.5, 17.0, 2.5, 2.0, 1.1, 25.0] :
idx == "M56" ? [56.0, 84.0, 124.0, 56.0, 41.0, 34.0, "None"] :
idx == "M52" ? [52.0, 78.0, 116.0, 52.0, 36.0, 31.0, "None"] :
idx == "M36" ? [36.0, 54.0, 84.0, 36.0, 27.0, 19.0, 110.0] :
idx == "M33" ? [33.0, 50.0, 78.0, 33.0, 24.0, 18.0, 100.0] :
idx == "M30" ? [30.0, 45.0, 72.0, 30.0, 22.0, 15.5, 100.0] :
idx == "M5" ? [5.0, 8.5, 22.0, 5.0, 4.0, 2.5, 25.0] :
idx == "M4" ? [4.0, 7.0, 20.0, 4.0, 3.0, 2.0, 25.0] :
idx == "M6" ? [6.0, 10.0, 24.0, 6.0, 5.0, 3.0, 30.0] :
idx == "M3" ? [3.0, 5.5, 18.0, 3.0, 2.5, 1.3, 20.0] :
idx == "M2" ? [2.0, 3.8, 16.0, 2.0, 1.5, 1.0, 20.0] :
idx == "M8" ? [8.0, 13.0, 28.0, 8.0, 6.0, 4.0, 35.0] :
idx == "M24" ? [24.0, 36.0, 60.0, 24.0, 19.0, 12.0, 80.0] :
idx == "M48" ? [48.0, 72.0, 108.0, 48.0, 36.0, 28.0, 150.0] :
idx == "M64" ? [64.0, 96.0, 140.0, 64.0, 46.0, 38.0, "None"] :
idx == "M42" ? [42.0, 63.0, 96.0, 42.0, 32.0, 24.0, 130.0] :
idx == "M27" ? [27.0, 40.0, 66.0, 27.0, 19.0, 13.5, 90.0] :
idx == "M20" ? [20.0, 30.0, 52.0, 20.0, 17.0, 10.0, 70.0] :
idx == "M22" ? [22.0, 33.0, 56.0, 22.0, 17.0, 11.0, 75.0] :
idx == "M10" ? [10.0, 16.0, 32.0, 10.0, 8.0, 5.0, 40.0] :
idx == "M12" ? [12.0, 18.0, 36.0, 12.0, 10.0, 6.0, 50.0] :
idx == "M1.4" ? [1.4, 2.6, "None", 1.4, 1.25, "None", 12.0] :
idx == "M14" ? [14.0, 21.0, 40.0, 14.0, 12.0, 7.0, 55.0] :
idx == "M1.6" ? [1.6, 3.0, 15.0, 1.6, 1.5, 0.7, 16.0] :
idx == "M16" ? [16.0, 24.0, 44.0, 16.0, 14.0, 8.0, 60.0] :
idx == "M1.8" ? [1.8, 3.4, "None", 1.8, 1.5, "None", 16.0] :
idx == "M18" ? [18.0, 27.0, 48.0, 18.0, 14.0, 9.0, 65.0] :
"Error";

function hexsocketheadcap_dims(key="M3", l=20, part_mode="default") = [
	["b", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[2],"mm")],
	["t_min", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[5],"mm")],
	["k", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[3],"mm")],
	["l", l],
	["L", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[6],"mm")],
	["s", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[4],"mm")],
	["key", key],
	["d2", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[1],"mm")],
	["d1", BOLTS_convert_to_default_unit(hexsocketheadcap_table_0(key)[0],"mm")]];

module hexsocketheadcap_geo(key, l, part_mode){
	hex_socket2(
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"d1"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"d2"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"b"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"k"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"s"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"t_min"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"L"),
		get_dim(hexsocketheadcap_dims(key, l, part_mode),"l")
	);
};

module DINENISO4762(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DINENISO4762","key",key,"Table Index");
	BOLTS_check_parameter_type("DINENISO4762","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket head cap screw DINENISO 4762 ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketheadcap_geo(key, l, part_mode);
	}
};

function DINENISO4762_dims(key="M3", l=20, part_mode="default") = hexsocketheadcap_dims(key, l, part_mode);

function DINENISO4762_conn(location,key="M3", l=20, part_mode="default") = hexsocketheadcap_conn(location,key, l, part_mode);

module ISO4762(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("ISO4762","key",key,"Table Index");
	BOLTS_check_parameter_type("ISO4762","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket head cap screw ISO 4762 ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketheadcap_geo(key, l, part_mode);
	}
};

function ISO4762_dims(key="M3", l=20, part_mode="default") = hexsocketheadcap_dims(key, l, part_mode);

function ISO4762_conn(location,key="M3", l=20, part_mode="default") = hexsocketheadcap_conn(location,key, l, part_mode);

module DIN912(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("DIN912","key",key,"Table Index");
	BOLTS_check_parameter_type("DIN912","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket head cap screw DIN 912 ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketheadcap_geo(key, l, part_mode);
	}
};

function DIN912_dims(key="M3", l=20, part_mode="default") = hexsocketheadcap_dims(key, l, part_mode);

function DIN912_conn(location,key="M3", l=20, part_mode="default") = hexsocketheadcap_conn(location,key, l, part_mode);

module MetricHexSocketHeadCapScrew(key="M3", l=20, part_mode="default"){
	BOLTS_check_parameter_type("MetricHexSocketHeadCapScrew","key",key,"Table Index");
	BOLTS_check_parameter_type("MetricHexSocketHeadCapScrew","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Hex socket head cap screw ",key," ",l,""));
		}
		cube();
	} else {
		hexsocketheadcap_geo(key, l, part_mode);
	}
};

function MetricHexSocketHeadCapScrew_dims(key="M3", l=20, part_mode="default") = hexsocketheadcap_dims(key, l, part_mode);

function MetricHexSocketHeadCapScrew_conn(location,key="M3", l=20, part_mode="default") = hexsocketheadcap_conn(location,key, l, part_mode);

/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

//square torus, r1 is big radius, r2 is small radius
module makeSquorus(r1,r2){
	difference(){
		cylinder(r=r1+r2,h=2*r2,center=true);
		cylinder(r=r1-r2,h=3*r2,center=true);
	}
}

//r1 is inner, r2 is outer
module makeRing(r1,r2,h){
	difference(){
		cylinder(r=r2,h=h,center=true);
		cylinder(r=r1,h=2*h,center=true);
	}
}

module singlerowradialbearing(d1,d2,B){
	rb = B/4;
	n = ceil((d2-d1)/rb);
	translate([0,0,B/2]){
		union(){
			difference(){
				cylinder(r=d2/2,h=B,center=true);
				cylinder(r=d1/2,h=B+0.01,center=true);
				//gap
				makeRing(d1/2+0.3*(d2-d1)/2,d1/2+0.6*(d2-d1)/2,2*B);
				//track
				makeSquorus((d2-d1)/2,rb);
			}
			for ( i = [0 : n-1] ){
				rotate( i * 360 / n, [0, 0,1])
				translate([0, (d2-d1)/2, 0])
					sphere(r = rb);
			}
		}
	}
}

module axialthrustbearing(d1_w,d2_w,d1_g,d2_g,B){
	rb = B/4;
	n = ceil((d2_w+d1_w)/2/rb);
	union(){
		difference(){
			union(){
				translate([0,0,-0.35*B]) makeRing(d1_g/2,d2_g/2,0.3*B);
				translate([0,0,+0.35*B]) makeRing(d1_w/2,d2_w/2,0.3*B);
			}
			//track
			makeSquorus((d2_w+d1_w)/4,rb);
		}
		for ( i = [0 : n-1] ){
			rotate( i * 360 / n, [0, 0,1])
			translate([0, (d2_w+d1_w)/4, 0])
				sphere(r = rb);
		}
	}
}
/* Generated by BOLTS, do not modify */
function singlerowradialbearing_table_0(idx) =
//d1, d2, B, r_fillet
idx == "623" ? [3.0, 10.0, 4.0, 0.3] :
idx == "607" ? [7.0, 19.0, 6.0, 0.5] :
idx == "627" ? [7.0, 22.0, 7.0, 0.5] :
idx == "626" ? [6.0, 19.0, 6.0, 0.5] :
idx == "625" ? [5.0, 16.0, 5.0, 0.5] :
idx == "624" ? [4.0, 13.0, 5.0, 0.4] :
idx == "629" ? [9.0, 26.0, 8.0, 1.0] :
idx == "609" ? [9.0, 24.0, 7.0, 0.5] :
idx == "608" ? [8.0, 22.0, 7.0, 0.5] :
idx == "6006" ? [30.0, 55.0, 13.0, 1.5] :
idx == "6007" ? [35.0, 62.0, 14.0, 1.5] :
idx == "6004" ? [20.0, 42.0, 12.0, 1.0] :
idx == "6005" ? [25.0, 47.0, 12.0, 1.0] :
idx == "6002" ? [15.0, 32.0, 9.0, 0.5] :
idx == "6003" ? [17.0, 35.0, 10.0, 0.5] :
idx == "6000" ? [10.0, 26.0, 8.0, 0.5] :
idx == "6001" ? [12.0, 28.0, 8.0, 0.5] :
idx == "6204" ? [20.0, 47.0, 14.0, 1.5] :
idx == "16003" ? [17.0, 35.0, 8.0, 0.5] :
idx == "6206" ? [30.0, 62.0, 16.0, 1.5] :
idx == "16006" ? [30.0, 55.0, 9.0, 0.5] :
idx == "16007" ? [35.0, 62.0, 9.0, 0.5] :
idx == "16004" ? [20.0, 42.0, 8.0, 0.5] :
idx == "6203" ? [17.0, 40.0, 12.0, 1.0] :
idx == "6305" ? [25.0, 62.0, 17.0, 2.0] :
idx == "6200" ? [10.0, 30.0, 9.0, 1.0] :
idx == "6301" ? [12.0, 37.0, 12.0, 1.5] :
idx == "6300" ? [10.0, 35.0, 11.0, 1.0] :
idx == "6303" ? [17.0, 47.0, 14.0, 1.5] :
idx == "6201" ? [12.0, 32.0, 10.0, 1.0] :
idx == "634" ? [4.0, 16.0, 5.0, 0.5] :
idx == "635" ? [5.0, 19.0, 6.0, 0.5] :
idx == "16101" ? [12.0, 30.0, 8.0, 0.5] :
idx == "16100" ? [10.0, 28.0, 8.0, 0.5] :
idx == "6205" ? [25.0, 52.0, 15.0, 1.5] :
idx == "6304" ? [20.0, 52.0, 15.0, 2.0] :
idx == "16002" ? [15.0, 32.0, 8.0, 0.5] :
idx == "6202" ? [15.0, 35.0, 11.0, 1.0] :
idx == "16005" ? [25.0, 47.0, 8.0, 0.5] :
idx == "6302" ? [15.0, 42.0, 13.0, 1.5] :
"Error";

function singlerowradialbearing_table_1(idx) =
//postfix
idx == "shielded, single" ? ["-Z"] :
idx == "shielded, double" ? ["-ZZ"] :
idx == "open" ? [""] :
idx == "sealed, double" ? ["-2RS"] :
idx == "sealed, single" ? ["-RS"] :
"Error";

function singlerowradialbearing_dims(key="608", type="open", part_mode="default") = [
	["B", BOLTS_convert_to_default_unit(singlerowradialbearing_table_0(key)[2],"mm")],
	["postfix", singlerowradialbearing_table_1(type)[0]],
	["type", type],
	["r_fillet", BOLTS_convert_to_default_unit(singlerowradialbearing_table_0(key)[3],"mm")],
	["key", key],
	["d2", BOLTS_convert_to_default_unit(singlerowradialbearing_table_0(key)[1],"mm")],
	["d1", BOLTS_convert_to_default_unit(singlerowradialbearing_table_0(key)[0],"mm")]];

module singlerowradialbearing_geo(key, type, part_mode){
	singlerowradialbearing(
		get_dim(singlerowradialbearing_dims(key, type, part_mode),"d1"),
		get_dim(singlerowradialbearing_dims(key, type, part_mode),"d2"),
		get_dim(singlerowradialbearing_dims(key, type, part_mode),"B")
	);
};

module DIN625_1(key="608", type="open", part_mode="default"){
	BOLTS_check_parameter_type("DIN625_1","key",key,"Table Index");
	BOLTS_check_parameter_type("DIN625_1","type",type,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Radial Ball Bearing DIN625-1 ",key,"",singlerowradialbearing_table_1(type)[0],""));
		}
		cube();
	} else {
		singlerowradialbearing_geo(key, type, part_mode);
	}
};

function DIN625_1_dims(key="608", type="open", part_mode="default") = singlerowradialbearing_dims(key, type, part_mode);

function DIN625_1_conn(location,key="608", type="open", part_mode="default") = singlerowradialbearing_conn(location,key, type, part_mode);

module RadialBallBearing(key="608", type="open", part_mode="default"){
	BOLTS_check_parameter_type("RadialBallBearing","key",key,"Table Index");
	BOLTS_check_parameter_type("RadialBallBearing","type",type,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Radial Ball Bearing ",key,"",singlerowradialbearing_table_1(type)[0],""));
		}
		cube();
	} else {
		singlerowradialbearing_geo(key, type, part_mode);
	}
};

function RadialBallBearing_dims(key="608", type="open", part_mode="default") = singlerowradialbearing_dims(key, type, part_mode);

function RadialBallBearing_conn(location,key="608", type="open", part_mode="default") = singlerowradialbearing_conn(location,key, type, part_mode);

/* Generated by BOLTS, do not modify */
function axialthrustbearing_table_0(idx) =
//d_w, d_g, D_g, D_w, T, r_fillet
idx == "51109" ? [45.0, 47.0, 65.0, 65.0, 14.0, 1.0] :
idx == "51305" ? [25.0, 27.0, 52.0, 52.0, 18.0, 1.5] :
idx == "51306" ? [30.0, 32.0, 60.0, 60.0, 21.0, 1.5] :
idx == "51307" ? [35.0, 37.0, 68.0, 68.0, 24.0, 1.5] :
idx == "51268" ? [340.0, 345.0, 460.0, 455.0, 96.0, 4.0] :
idx == "51144" ? [220.0, 223.0, 270.0, 267.0, 37.0, 2.0] :
idx == "51264" ? [320.0, 325.0, 440.0, 435.0, 95.0, 4.0] :
idx == "51308" ? [40.0, 42.0, 78.0, 78.0, 26.0, 1.5] :
idx == "51309" ? [45.0, 47.0, 85.0, 85.0, 28.0, 1.5] :
idx == "51260" ? [300.0, 304.0, 420.0, 415.0, 95.0, 4.0] :
idx == "51209" ? [45.0, 47.0, 73.0, 73.0, 20.0, 1.5] :
idx == "51208" ? [40.0, 42.0, 68.0, 68.0, 19.0, 1.5] :
idx == "51236" ? [180.0, 183.0, 250.0, 247.0, 56.0, 2.5] :
idx == "51160" ? [300.0, 304.0, 380.0, 376.0, 62.0, 3.0] :
idx == "51164" ? [320.0, 324.0, 400.0, 396.0, 63.0, 3.0] :
idx == "51168" ? [340.0, 344.0, 420.0, 416.0, 64.0, 3.0] :
idx == "51200" ? [10.0, 12.0, 26.0, 26.0, 11.0, 1.0] :
idx == "51407" ? [35.0, 37.0, 80.0, 80.0, 32.0, 2.0] :
idx == "51220" ? [100.0, 103.0, 150.0, 150.0, 38.0, 2.0] :
idx == "51115" ? [75.0, 77.0, 100.0, 100.0, 19.0, 1.5] :
idx == "51114" ? [70.0, 72.0, 95.0, 95.0, 18.0, 1.5] :
idx == "51117" ? [85.0, 87.0, 110.0, 110.0, 19.0, 1.5] :
idx == "51116" ? [80.0, 82.0, 105.0, 105.0, 19.0, 1.5] :
idx == "51111" ? [55.0, 57.0, 78.0, 78.0, 16.0, 1.0] :
idx == "51110" ? [50.0, 52.0, 70.0, 70.0, 14.0, 1.0] :
idx == "51113" ? [65.0, 67.0, 90.0, 90.0, 18.0, 1.5] :
idx == "51112" ? [60.0, 62.0, 85.0, 85.0, 17.0, 1.5] :
idx == "51205" ? [25.0, 27.0, 47.0, 47.0, 15.0, 1.0] :
idx == "51204" ? [20.0, 22.0, 40.0, 40.0, 14.0, 1.0] :
idx == "51207" ? [35.0, 37.0, 62.0, 62.0, 18.0, 1.5] :
idx == "51206" ? [30.0, 32.0, 52.0, 52.0, 16.0, 1.0] :
idx == "51201" ? [12.0, 14.0, 28.0, 28.0, 11.0, 1.0] :
idx == "51118" ? [90.0, 92.0, 120.0, 120.0, 22.0, 1.5] :
idx == "51203" ? [17.0, 19.0, 35.0, 35.0, 12.0, 1.0] :
idx == "51202" ? [15.0, 17.0, 32.0, 32.0, 12.0, 1.0] :
idx == "51428" ? [140.0, 144.0, 280.0, 275.0, 112.0, 5.0] :
idx == "51424" ? [120.0, 123.0, 250.0, 245.0, 102.0, 5.0] :
idx == "51426" ? [130.0, 133.0, 270.0, 265.0, 110.0, 5.0] :
idx == "51420" ? [100.0, 103.0, 210.0, 205.0, 85.0, 4.0] :
idx == "51422" ? [110.0, 113.0, 230.0, 225.0, 95.0, 4.0] :
idx == "51106" ? [30.0, 32.0, 47.0, 47.0, 11.0, 1.0] :
idx == "51107" ? [35.0, 37.0, 52.0, 52.0, 12.0, 1.0] :
idx == "51104" ? [20.0, 21.0, 35.0, 35.0, 10.0, 0.5] :
idx == "51105" ? [25.0, 26.0, 42.0, 42.0, 11.0, 1.0] :
idx == "51102" ? [15.0, 16.0, 28.0, 28.0, 9.0, 0.5] :
idx == "51103" ? [17.0, 18.0, 30.0, 30.0, 9.0, 0.5] :
idx == "51100" ? [10.0, 11.0, 24.0, 24.0, 9.0, 0.5] :
idx == "51101" ? [12.0, 13.0, 26.0, 26.0, 9.0, 0.5] :
idx == "51216" ? [80.0, 82.0, 115.0, 115.0, 28.0, 1.5] :
idx == "51217" ? [85.0, 88.0, 125.0, 125.0, 31.0, 1.5] :
idx == "51214" ? [70.0, 72.0, 105.0, 105.0, 27.0, 1.5] :
idx == "51215" ? [75.0, 77.0, 110.0, 110.0, 27.0, 1.5] :
idx == "51212" ? [60.0, 62.0, 95.0, 95.0, 26.0, 1.5] :
idx == "51213" ? [65.0, 67.0, 100.0, 100.0, 27.0, 1.5] :
idx == "51210" ? [50.0, 52.0, 78.0, 78.0, 22.0, 1.5] :
idx == "51211" ? [55.0, 57.0, 90.0, 90.0, 25.0, 1.5] :
idx == "51344" ? [220.0, 225.0, 360.0, 355.0, 112.0, 5.0] :
idx == "51348" ? [240.0, 245.0, 380.0, 375.0, 112.0, 5.0] :
idx == "51340" ? [200.0, 205.0, 340.0, 335.0, 110.0, 5.0] :
idx == "51434" ? [170.0, 174.0, 340.0, 335.0, 135.0, 6.0] :
idx == "51432" ? [160.0, 164.0, 320.0, 315.0, 130.0, 6.0] :
idx == "51430" ? [150.0, 154.0, 300.0, 295.0, 120.0, 5.0] :
idx == "51132" ? [160.0, 162.0, 200.0, 198.0, 31.0, 1.5] :
idx == "51130" ? [150.0, 152.0, 190.0, 188.0, 31.0, 1.5] :
idx == "51136" ? [180.0, 183.0, 225.0, 222.0, 34.0, 2.0] :
idx == "51134" ? [170.0, 172.0, 215.0, 213.0, 34.0, 2.0] :
idx == "51222" ? [110.0, 113.0, 160.0, 160.0, 38.0, 2.0] :
idx == "51138" ? [190.0, 193.0, 240.0, 237.0, 37.0, 2.0] :
idx == "51226" ? [130.0, 133.0, 190.0, 187.0, 45.0, 2.5] :
idx == "51224" ? [120.0, 123.0, 170.0, 170.0, 39.0, 2.0] :
idx == "51234" ? [170.0, 173.0, 240.0, 237.0, 55.0, 2.5] :
idx == "51409" ? [45.0, 47.0, 100.0, 100.0, 39.0, 2.0] :
idx == "51408" ? [40.0, 42.0, 90.0, 90.0, 36.0, 2.0] :
idx == "51230" ? [150.0, 153.0, 215.0, 212.0, 50.0, 2.5] :
idx == "51232" ? [160.0, 163.0, 225.0, 222.0, 51.0, 2.5] :
idx == "51238" ? [190.0, 194.0, 270.0, 267.0, 62.0, 3.0] :
idx == "51406" ? [30.0, 32.0, 70.0, 70.0, 28.0, 1.5] :
idx == "51405" ? [25.0, 27.0, 60.0, 60.0, 24.0, 1.5] :
idx == "51128" ? [140.0, 142.0, 180.0, 178.0, 31.0, 1.5] :
idx == "51338" ? [190.0, 195.0, 320.0, 315.0, 105.0, 5.0] :
idx == "51356" ? [280.0, 285.0, 440.0, 435.0, 130.0, 6.0] :
idx == "51124" ? [120.0, 122.0, 155.0, 155.0, 25.0, 1.5] :
idx == "51334" ? [170.0, 174.0, 280.0, 275.0, 87.0, 4.0] :
idx == "51126" ? [130.0, 132.0, 170.0, 170.0, 30.0, 1.5] :
idx == "51336" ? [180.0, 184.0, 300.0, 295.0, 95.0, 4.0] :
idx == "51120" ? [100.0, 102.0, 135.0, 135.0, 25.0, 1.5] :
idx == "51330" ? [150.0, 154.0, 250.0, 245.0, 80.0, 3.5] :
idx == "51122" ? [110.0, 112.0, 145.0, 145.0, 25.0, 1.5] :
idx == "51332" ? [160.0, 164.0, 270.0, 265.0, 87.0, 4.0] :
idx == "51352" ? [260.0, 265.0, 420.0, 415.0, 130.0, 6.0] :
idx == "51414" ? [70.0, 73.0, 150.0, 150.0, 60.0, 3.0] :
idx == "51415" ? [75.0, 78.0, 160.0, 160.0, 65.0, 3.0] :
idx == "51416" ? [80.0, 83.0, 170.0, 170.0, 68.0, 3.5] :
idx == "51417" ? [85.0, 88.0, 180.0, 177.0, 72.0, 3.5] :
idx == "51410" ? [50.0, 52.0, 110.0, 110.0, 43.0, 2.5] :
idx == "51411" ? [55.0, 57.0, 120.0, 120.0, 48.0, 2.5] :
idx == "51412" ? [60.0, 62.0, 130.0, 130.0, 51.0, 2.5] :
idx == "51413" ? [65.0, 68.0, 140.0, 140.0, 56.0, 3.0] :
idx == "51418" ? [90.0, 93.0, 190.0, 187.0, 77.0, 3.5] :
idx == "51240" ? [200.0, 204.0, 280.0, 277.0, 62.0, 3.0] :
idx == "51244" ? [220.0, 224.0, 300.0, 297.0, 63.0, 3.0] :
idx == "51248" ? [240.0, 244.0, 340.0, 335.0, 78.0, 3.5] :
idx == "51328" ? [140.0, 144.0, 240.0, 235.0, 80.0, 3.5] :
idx == "51326" ? [130.0, 134.0, 225.0, 220.0, 75.0, 3.5] :
idx == "51228" ? [140.0, 143.0, 200.0, 197.0, 46.0, 2.5] :
idx == "51324" ? [120.0, 123.0, 210.0, 205.0, 70.0, 3.5] :
idx == "51152" ? [260.0, 263.0, 320.0, 317.0, 45.0, 2.5] :
idx == "51322" ? [110.0, 110.0, 190.0, 187.0, 63.0, 3.0] :
idx == "51320" ? [100.0, 103.0, 170.0, 170.0, 55.0, 2.5] :
idx == "51156" ? [280.0, 283.0, 350.0, 347.0, 53.0, 2.5] :
idx == "51218" ? [90.0, 93.0, 135.0, 135.0, 35.0, 2.0] :
idx == "51311" ? [55.0, 57.0, 105.0, 105.0, 35.0, 2.0] :
idx == "51252" ? [260.0, 264.0, 360.0, 355.0, 79.0, 3.5] :
idx == "51256" ? [280.0, 284.0, 380.0, 375.0, 80.0, 3.5] :
idx == "51148" ? [240.0, 243.0, 300.0, 297.0, 45.0, 2.5] :
idx == "51318" ? [90.0, 93.0, 155.0, 155.0, 50.0, 2.5] :
idx == "51108" ? [40.0, 42.0, 60.0, 60.0, 13.0, 1.0] :
idx == "51313" ? [65.0, 67.0, 115.0, 115.0, 36.0, 2.0] :
idx == "51312" ? [60.0, 62.0, 110.0, 110.0, 35.0, 2.0] :
idx == "51140" ? [200.0, 203.0, 250.0, 247.0, 37.0, 2.0] :
idx == "51310" ? [50.0, 52.0, 95.0, 95.0, 31.0, 2.0] :
idx == "51317" ? [85.0, 88.0, 150.0, 150.0, 49.0, 2.5] :
idx == "51316" ? [80.0, 82.0, 140.0, 140.0, 44.0, 2.5] :
idx == "51315" ? [75.0, 77.0, 135.0, 135.0, 44.0, 2.5] :
idx == "51314" ? [70.0, 72.0, 125.0, 125.0, 40.0, 2.0] :
"Error";

function axialthrustbearing_dims(key="51200", part_mode="default") = [
	["D_w", BOLTS_convert_to_default_unit(axialthrustbearing_table_0(key)[3],"mm")],
	["d_w", BOLTS_convert_to_default_unit(axialthrustbearing_table_0(key)[0],"mm")],
	["r_fillet", BOLTS_convert_to_default_unit(axialthrustbearing_table_0(key)[5],"mm")],
	["D_g", BOLTS_convert_to_default_unit(axialthrustbearing_table_0(key)[2],"mm")],
	["T", BOLTS_convert_to_default_unit(axialthrustbearing_table_0(key)[4],"mm")],
	["key", key],
	["d_g", BOLTS_convert_to_default_unit(axialthrustbearing_table_0(key)[1],"mm")]];

module axialthrustbearing_geo(key, part_mode){
	axialthrustbearing(
		get_dim(axialthrustbearing_dims(key, part_mode),"d_w"),
		get_dim(axialthrustbearing_dims(key, part_mode),"D_w"),
		get_dim(axialthrustbearing_dims(key, part_mode),"d_g"),
		get_dim(axialthrustbearing_dims(key, part_mode),"D_g"),
		get_dim(axialthrustbearing_dims(key, part_mode),"T")
	);
};

module DIN711(key="51200", part_mode="default"){
	BOLTS_check_parameter_type("DIN711","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Axial thrust bearing DIN 711 ",key,""));
		}
		cube();
	} else {
		axialthrustbearing_geo(key, part_mode);
	}
};

function DIN711_dims(key="51200", part_mode="default") = axialthrustbearing_dims(key, part_mode);

function DIN711_conn(location,key="51200", part_mode="default") = axialthrustbearing_conn(location,key, part_mode);

module ISO104(key="51200", part_mode="default"){
	BOLTS_check_parameter_type("ISO104","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Axial thrust bearing ISO 104 ",key,""));
		}
		cube();
	} else {
		axialthrustbearing_geo(key, part_mode);
	}
};

function ISO104_dims(key="51200", part_mode="default") = axialthrustbearing_dims(key, part_mode);

function ISO104_conn(location,key="51200", part_mode="default") = axialthrustbearing_conn(location,key, part_mode);

module AxialThrustBearing(key="51200", part_mode="default"){
	BOLTS_check_parameter_type("AxialThrustBearing","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Axial thrust bearing ",key,""));
		}
		cube();
	} else {
		axialthrustbearing_geo(key, part_mode);
	}
};

function AxialThrustBearing_dims(key="51200", part_mode="default") = axialthrustbearing_dims(key, part_mode);

function AxialThrustBearing_conn(location,key="51200", part_mode="default") = axialthrustbearing_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function singlerowradialbearingimperial_table_0(idx) =
//d1, d2, B, r_fillet
idx == "RLS7" ? [0.875, 2.0, 0.5625, 0.0625] :
idx == "RLS6" ? [0.75, 1.875, 0.5625, 0.0625] :
idx == "RLS5" ? [0.625, 1.5625, 0.4375, 0.03125] :
idx == "RLS4" ? [0.5, 1.3125, 0.375, 0.03125] :
idx == "RLS9" ? [1.125, 2.5, 0.625, 0.0625] :
idx == "RLS8" ? [1.0, 2.25, 0.625, 0.0625] :
idx == "RLS16" ? [2.0, 4.0, 0.8125, 0.09375] :
idx == "RLS15" ? [1.875, 4.0, 0.8125, 0.09375] :
idx == "RLS14" ? [1.75, 3.75, 0.8125, 0.09375] :
idx == "RLS13" ? [1.625, 3.5, 0.75, 0.09375] :
idx == "RLS12" ? [1.5, 3.25, 0.75, 0.09375] :
idx == "RLS11" ? [1.375, 3.0, 0.6875, 0.0625] :
idx == "RLS10" ? [1.25, 2.75, 0.6875, 0.0625] :
idx == "RLS18" ? [2.25, 4.5, 0.875, 0.09375] :
idx == "RMS20" ? [2.5, 5.5, 1.25, 0.125] :
idx == "RMS22" ? [2.75, 6.125, 1.375, 0.125] :
idx == "RMS24" ? [3.0, 7.0, 1.5625, 0.15625] :
idx == "RMS26" ? [3.25, 7.5, 1.5625, 0.15625] :
idx == "RMS18" ? [2.25, 5.0, 1.25, 0.125] :
idx == "RMS6" ? [0.75, 2.0, 0.6875, 0.0625] :
idx == "RMS7" ? [0.875, 2.25, 0.6875, 0.0625] :
idx == "RMS4" ? [0.5, 1.625, 0.625, 0.0625] :
idx == "RMS5" ? [0.625, 1.8125, 0.625, 0.0625] :
idx == "RMS8" ? [1.0, 2.5, 0.75, 0.09375] :
idx == "RMS9" ? [1.125, 2.8125, 0.8125, 0.09375] :
idx == "RMS10" ? [1.25, 3.125, 0.875, 0.09375] :
idx == "RMS11" ? [1.375, 3.5, 0.875, 0.09375] :
idx == "RMS12" ? [1.5, 3.75, 0.9375, 0.09375] :
idx == "RMS13" ? [1.625, 4.0, 0.9375, 0.09375] :
idx == "RMS14" ? [1.75, 4.25, 1.0625, 0.09375] :
idx == "RMS15" ? [1.875, 4.5, 1.0625, 0.09375] :
idx == "RMS16" ? [2.0, 4.5, 1.0625, 0.09375] :
idx == "RLS22" ? [2.75, 5.25, 0.9375, 0.09375] :
idx == "RLS20" ? [2.5, 5.0, 0.9375, 0.09375] :
idx == "RLS26" ? [3.25, 6.0, 1.0625, 0.09375] :
idx == "RLS24" ? [3.0, 5.75, 1.0625, 0.09375] :
"Error";

function singlerowradialbearingimperial_dims(key="RLS8", part_mode="default") = [
	["B", BOLTS_convert_to_default_unit(singlerowradialbearingimperial_table_0(key)[2],"in")],
	["type", open],
	["r_fillet", BOLTS_convert_to_default_unit(singlerowradialbearingimperial_table_0(key)[3],"in")],
	["key", key],
	["d2", BOLTS_convert_to_default_unit(singlerowradialbearingimperial_table_0(key)[1],"in")],
	["d1", BOLTS_convert_to_default_unit(singlerowradialbearingimperial_table_0(key)[0],"in")]];

module singlerowradialbearingimperial_geo(key, part_mode){
	singlerowradialbearing(
		get_dim(singlerowradialbearingimperial_dims(key, part_mode),"d1"),
		get_dim(singlerowradialbearingimperial_dims(key, part_mode),"d2"),
		get_dim(singlerowradialbearingimperial_dims(key, part_mode),"B")
	);
};

module RadialBallBearingImperial(key="RLS8", part_mode="default"){
	BOLTS_check_parameter_type("RadialBallBearingImperial","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("imperial Radial Ball Bearing ",key,""));
		}
		cube();
	} else {
		singlerowradialbearingimperial_geo(key, part_mode);
	}
};

function RadialBallBearingImperial_dims(key="RLS8", part_mode="default") = singlerowradialbearingimperial_dims(key, part_mode);

function RadialBallBearingImperial_conn(location,key="RLS8", part_mode="default") = singlerowradialbearingimperial_conn(location,key, part_mode);

/*
 * BOLTS - Open Library of Technical Specifications
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
module washer1(d1,d2,s){
	difference(){
		cylinder(r=d2/2,h=s);
		translate([0,0,-0.1*s])
			cylinder(r=d1/2,h=1.2*s);
	}
}

module washer2(d1,d2,s){
	intersection(){
		difference(){
			cylinder(r=d2/2,h=s);
			translate([0,0,-0.1*s])
				cylinder(r=d1/2,h=1.2*s);
			cylinder(r1=d1/2-s,r2 = d1/2+s,1.1*s);
		}
		cylinder(r1 = d2/2+s, r2 = d2/2-s,1.1*s);
	}
}

function washerConn(d2,s,location) =
	(location == "bottom") ? [[0,0,0],[[0,0,1],[0,1,0]]] :
	(location == "top")    ? [[0,0,s],[[0,0,1],[0,1,0]]] :
	(location == "outer")  ? [[d2/2,0,0],[[1,0,0],[0,1,0]]] :
	"Error";
/* Generated by BOLTS, do not modify */
function heavydutyplainwasher_table_0(idx) =
//d1, d2, s
idx == "M10" ? [10.5, 25.0, 4.0] :
idx == "M24" ? [25.0, 50.0, 10.0] :
idx == "M27" ? [28.0, 60.0, 10.0] :
idx == "M20" ? [21.0, 44.0, 8.0] :
idx == "M22" ? [23.0, 50.0, 8.0] :
idx == "M30" ? [31.0, 68.0, 10.0] :
idx == "M5" ? [5.3, 15.0, 2.0] :
idx == "M4" ? [4.3, 12.0, 1.6] :
idx == "M6" ? [6.4, 17.0, 3.0] :
idx == "M14" ? [15.0, 36.0, 6.0] :
idx == "M3" ? [3.2, 9.0, 1.0] :
idx == "M16" ? [17.0, 40.0, 6.0] :
idx == "M18" ? [19.0, 44.0, 8.0] :
idx == "M12" ? [13.0, 30.0, 6.0] :
idx == "M8" ? [8.4, 21.0, 4.0] :
"Error";

function heavydutyplainwasher_dims(key="M10", part_mode="default") = [
	["s", BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[2],"mm")],
	["d2", BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[1],"mm")],
	["key", key],
	["d1", BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[0],"mm")]];

function heavydutyplainwasher_conn(location,key="M10", part_mode="default") = new_cs(
	origin=washerConn(BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[2],"mm"), location)[0],
	axes=washerConn(BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(heavydutyplainwasher_table_0(key)[2],"mm"), location)[1]);

module heavydutyplainwasher_geo(key, part_mode){
	washer1(
		get_dim(heavydutyplainwasher_dims(key, part_mode),"d1"),
		get_dim(heavydutyplainwasher_dims(key, part_mode),"d2"),
		get_dim(heavydutyplainwasher_dims(key, part_mode),"s")
	);
};

module DIN7349(key="M10", part_mode="default"){
	BOLTS_check_parameter_type("DIN7349","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Heavy duty plain washer DIN 7349 ",key,""));
		}
		cube();
	} else {
		heavydutyplainwasher_geo(key, part_mode);
	}
};

function DIN7349_dims(key="M10", part_mode="default") = heavydutyplainwasher_dims(key, part_mode);

function DIN7349_conn(location,key="M10", part_mode="default") = heavydutyplainwasher_conn(location,key, part_mode);

module MetricHeavyDutyPlainWasher(key="M10", part_mode="default"){
	BOLTS_check_parameter_type("MetricHeavyDutyPlainWasher","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Heavy duty plain washer ",key,""));
		}
		cube();
	} else {
		heavydutyplainwasher_geo(key, part_mode);
	}
};

function MetricHeavyDutyPlainWasher_dims(key="M10", part_mode="default") = heavydutyplainwasher_dims(key, part_mode);

function MetricHeavyDutyPlainWasher_conn(location,key="M10", part_mode="default") = heavydutyplainwasher_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function plainwasher1_table_0(idx) =
//d1, d2, s
idx == "M2.6" ? [2.8, 7.0, 0.5] :
idx == "M2.5" ? [2.7, 6.0, 0.5] :
idx == "M56" ? [58.0, 105.0, 9.0] :
idx == "M2.3" ? [2.5, 6.0, 0.5] :
idx == "M2.2" ? [2.4, 6.0, 0.5] :
idx == "M39" ? [40.0, 72.0, 6.0] :
idx == "M3.5" ? [3.7, 8.0, 0.5] :
idx == "M36" ? [37.0, 66.0, 5.0] :
idx == "M33" ? [34.0, 60.0, 5.0] :
idx == "M30" ? [31.0, 56.0, 4.0] :
idx == "M72" ? [74.0, 125.0, 10.0] :
idx == "M4" ? [4.3, 9.0, 0.8] :
idx == "M7" ? [7.4, 14.0, 1.6] :
idx == "M6" ? [6.4, 12.0, 1.6] :
idx == "M1" ? [1.1, 3.0, 0.3] :
idx == "M3" ? [3.2, 7.0, 0.5] :
idx == "M2" ? [2.2, 5.0, 0.3] :
idx == "M8" ? [8.4, 16.0, 1.6] :
idx == "M76" ? [78.0, 135.0, 10.0] :
idx == "M85" ? [87.0, 145.0, 12.0] :
idx == "M80" ? [82.0, 140.0, 12.0] :
idx == "M42" ? [43.0, 78.0, 7.0] :
idx == "M60" ? [62.0, 110.0, 9.0] :
idx == "M48" ? [50.0, 92.0, 8.0] :
idx == "M64" ? [64.0, 115.0, 9.0] :
idx == "M24" ? [25.0, 44.0, 4.0] :
idx == "M27" ? [28.0, 50.0, 4.0] :
idx == "M20" ? [21.0, 37.0, 3.0] :
idx == "M22" ? [23.0, 39.0, 3.0] :
idx == "M45" ? [46.0, 85.0, 7.0] :
idx == "M16" ? [17.0, 30.0, 3.0] :
idx == "M5" ? [5.3, 10.0, 1.0] :
idx == "M100" ? [104.0, 175.0, 14.0] :
idx == "M52" ? [54.0, 98.0, 8.0] :
idx == "M90" ? [93.0, 160.0, 12.0] :
idx == "M68" ? [70.0, 120.0, 10.0] :
idx == "M10" ? [10.0, 20.0, 2.0] :
idx == "M1.2" ? [1.3, 3.5, 0.3] :
idx == "M12" ? [13.0, 24.0, 2.5] :
idx == "M1.4" ? [1.5, 4.0, 0.3] :
idx == "M14" ? [15.0, 28.0, 2.5] :
idx == "M1.6" ? [1.7, 4.0, 0.3] :
idx == "M1.7" ? [1.8, 4.5, 0.3] :
idx == "M18" ? [19.0, 34.0, 3.0] :
"Error";

function plainwasher1_dims(key="M3", part_mode="default") = [
	["s", BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[2],"mm")],
	["d2", BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[1],"mm")],
	["key", key],
	["d1", BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[0],"mm")]];

function plainwasher1_conn(location,key="M3", part_mode="default") = new_cs(
	origin=washerConn(BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[2],"mm"), location)[0],
	axes=washerConn(BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasher1_table_0(key)[2],"mm"), location)[1]);

module plainwasher1_geo(key, part_mode){
	washer1(
		get_dim(plainwasher1_dims(key, part_mode),"d1"),
		get_dim(plainwasher1_dims(key, part_mode),"d2"),
		get_dim(plainwasher1_dims(key, part_mode),"s")
	);
};

module EN7089(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("EN7089","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer EN 7089 ",key,""));
		}
		cube();
	} else {
		plainwasher1_geo(key, part_mode);
	}
};

function EN7089_dims(key="M3", part_mode="default") = plainwasher1_dims(key, part_mode);

function EN7089_conn(location,key="M3", part_mode="default") = plainwasher1_conn(location,key, part_mode);

module ISO7089(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("ISO7089","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer ISO 7089 ",key,""));
		}
		cube();
	} else {
		plainwasher1_geo(key, part_mode);
	}
};

function ISO7089_dims(key="M3", part_mode="default") = plainwasher1_dims(key, part_mode);

function ISO7089_conn(location,key="M3", part_mode="default") = plainwasher1_conn(location,key, part_mode);

module DINENISO7089(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINENISO7089","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer DINENISO 7089 ",key,""));
		}
		cube();
	} else {
		plainwasher1_geo(key, part_mode);
	}
};

function DINENISO7089_dims(key="M3", part_mode="default") = plainwasher1_dims(key, part_mode);

function DINENISO7089_conn(location,key="M3", part_mode="default") = plainwasher1_conn(location,key, part_mode);

module DIN125A(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DIN125A","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer DIN 125A ",key,""));
		}
		cube();
	} else {
		plainwasher1_geo(key, part_mode);
	}
};

function DIN125A_dims(key="M3", part_mode="default") = plainwasher1_dims(key, part_mode);

function DIN125A_conn(location,key="M3", part_mode="default") = plainwasher1_conn(location,key, part_mode);

module DINEN27089(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINEN27089","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer DINEN 27089 ",key,""));
		}
		cube();
	} else {
		plainwasher1_geo(key, part_mode);
	}
};

function DINEN27089_dims(key="M3", part_mode="default") = plainwasher1_dims(key, part_mode);

function DINEN27089_conn(location,key="M3", part_mode="default") = plainwasher1_conn(location,key, part_mode);

module MetricPlainWasher(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("MetricPlainWasher","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer ",key,""));
		}
		cube();
	} else {
		plainwasher1_geo(key, part_mode);
	}
};

function MetricPlainWasher_dims(key="M3", part_mode="default") = plainwasher1_dims(key, part_mode);

function MetricPlainWasher_conn(location,key="M3", part_mode="default") = plainwasher1_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function plainwasherforcheesehead_table_0(idx) =
//d1, d2, s
idx == "M2.6" ? [2.8, 5.5, 0.5] :
idx == "M2.5" ? [2.7, 5.0, 0.5] :
idx == "M2.3" ? [2.5, 5.0, 0.5] :
idx == "M3.5" ? [3.7, 7.0, 0.5] :
idx == "M36" ? [37.0, 60.0, 5.0] :
idx == "M30" ? [31.0, 50.0, 4.0] :
idx == "M5" ? [5.3, 9.0, 1.0] :
idx == "M4" ? [4.3, 8.0, 0.5] :
idx == "M6" ? [6.4, 11.0, 1.6] :
idx == "M1" ? [1.1, 2.5, 0.3] :
idx == "M3" ? [3.2, 6.0, 0.5] :
idx == "M2" ? [2.2, 4.5, 0.3] :
idx == "M8" ? [8.4, 15.0, 1.6] :
idx == "M24" ? [25.0, 39.0, 4.0] :
idx == "M16" ? [17.0, 28.0, 2.5] :
idx == "M20" ? [21.0, 34.0, 3.0] :
idx == "M10" ? [10.5, 18.0, 1.6] :
idx == "M1.2" ? [1.3, 3.0, 0.3] :
idx == "M12" ? [13.0, 20.0, 2.0] :
idx == "M1.4" ? [1.5, 3.0, 0.3] :
idx == "M14" ? [15.0, 24.0, 2.5] :
idx == "M1.6" ? [1.7, 3.5, 0.3] :
idx == "M1.7" ? [1.8, 4.0, 0.3] :
idx == "M1.8" ? [1.9, 4.0, 0.3] :
idx == "M18" ? [19.0, 30.0, 2.5] :
"Error";

function plainwasherforcheesehead_dims(key="M3", part_mode="default") = [
	["s", BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[2],"mm")],
	["d2", BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[1],"mm")],
	["key", key],
	["d1", BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[0],"mm")]];

function plainwasherforcheesehead_conn(location,key="M3", part_mode="default") = new_cs(
	origin=washerConn(BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[2],"mm"), location)[0],
	axes=washerConn(BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasherforcheesehead_table_0(key)[2],"mm"), location)[1]);

module plainwasherforcheesehead_geo(key, part_mode){
	washer1(
		get_dim(plainwasherforcheesehead_dims(key, part_mode),"d1"),
		get_dim(plainwasherforcheesehead_dims(key, part_mode),"d2"),
		get_dim(plainwasherforcheesehead_dims(key, part_mode),"s")
	);
};

module ISO7092(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("ISO7092","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer for cheese head screws ISO 7092 ",key,""));
		}
		cube();
	} else {
		plainwasherforcheesehead_geo(key, part_mode);
	}
};

function ISO7092_dims(key="M3", part_mode="default") = plainwasherforcheesehead_dims(key, part_mode);

function ISO7092_conn(location,key="M3", part_mode="default") = plainwasherforcheesehead_conn(location,key, part_mode);

module DINENISO7092(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINENISO7092","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer for cheese head screws DIN EN ISO 7092 ",key,""));
		}
		cube();
	} else {
		plainwasherforcheesehead_geo(key, part_mode);
	}
};

function DINENISO7092_dims(key="M3", part_mode="default") = plainwasherforcheesehead_dims(key, part_mode);

function DINENISO7092_conn(location,key="M3", part_mode="default") = plainwasherforcheesehead_conn(location,key, part_mode);

module DINISO7092(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINISO7092","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer for cheese head screws DIN ISO 7092 ",key,""));
		}
		cube();
	} else {
		plainwasherforcheesehead_geo(key, part_mode);
	}
};

function DINISO7092_dims(key="M3", part_mode="default") = plainwasherforcheesehead_dims(key, part_mode);

function DINISO7092_conn(location,key="M3", part_mode="default") = plainwasherforcheesehead_conn(location,key, part_mode);

module DIN433(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DIN433","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer for cheese head screws DIN 433 ",key,""));
		}
		cube();
	} else {
		plainwasherforcheesehead_geo(key, part_mode);
	}
};

function DIN433_dims(key="M3", part_mode="default") = plainwasherforcheesehead_dims(key, part_mode);

function DIN433_conn(location,key="M3", part_mode="default") = plainwasherforcheesehead_conn(location,key, part_mode);

module MetricPlainWasherForCheeseHeadScrews(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("MetricPlainWasherForCheeseHeadScrews","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer for cheese head screws ",key,""));
		}
		cube();
	} else {
		plainwasherforcheesehead_geo(key, part_mode);
	}
};

function MetricPlainWasherForCheeseHeadScrews_dims(key="M3", part_mode="default") = plainwasherforcheesehead_dims(key, part_mode);

function MetricPlainWasherForCheeseHeadScrews_conn(location,key="M3", part_mode="default") = plainwasherforcheesehead_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function plainwasher2_table_0(idx) =
//d1, d2, s
idx == "M72" ? [78.0, 125.0, 10.0] :
idx == "M56" ? [62.0, 105.0, 9.0] :
idx == "M39" ? [42.0, 72.0, 6.0] :
idx == "M52" ? [56.0, 98.0, 8.0] :
idx == "M36" ? [39.0, 66.0, 5.0] :
idx == "M33" ? [36.0, 60.0, 5.0] :
idx == "M30" ? [33.0, 56.0, 4.0] :
idx == "M5" ? [5.5, 10.0, 1.0] :
idx == "M7" ? [7.6, 14.0, 1.6] :
idx == "M6" ? [6.6, 12.0, 1.6] :
idx == "M8" ? [9.0, 16.0, 1.6] :
idx == "M80" ? [86.0, 140.0, 12.0] :
idx == "M24" ? [26.0, 44.0, 4.0] :
idx == "M60" ? [66.0, 110.0, 9.0] :
idx == "M48" ? [52.0, 92.0, 8.0] :
idx == "M64" ? [70.0, 115.0, 9.0] :
idx == "M42" ? [45.0, 78.0, 7.0] :
idx == "M27" ? [30.0, 50.0, 4.0] :
idx == "M20" ? [22.0, 37.0, 3.0] :
idx == "M22" ? [24.0, 39.0, 3.0] :
idx == "M45" ? [48.0, 85.0, 7.0] :
idx == "M100" ? [107.0, 175.0, 14.0] :
idx == "M90" ? [96.0, 160.0, 12.0] :
idx == "M10" ? [11.0, 20.0, 2.0] :
idx == "M12" ? [13.5, 24.0, 2.5] :
idx == "M14" ? [15.5, 28.0, 2.5] :
idx == "M16" ? [17.5, 30.0, 3.0] :
"Error";

function plainwasher2_dims(key="M10", part_mode="default") = [
	["s", BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[2],"mm")],
	["d2", BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[1],"mm")],
	["key", key],
	["d1", BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[0],"mm")]];

function plainwasher2_conn(location,key="M10", part_mode="default") = new_cs(
	origin=washerConn(BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[2],"mm"), location)[0],
	axes=washerConn(BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasher2_table_0(key)[2],"mm"), location)[1]);

module plainwasher2_geo(key, part_mode){
	washer1(
		get_dim(plainwasher2_dims(key, part_mode),"d1"),
		get_dim(plainwasher2_dims(key, part_mode),"d2"),
		get_dim(plainwasher2_dims(key, part_mode),"s")
	);
};

module DINENISO7091(key="M10", part_mode="default"){
	BOLTS_check_parameter_type("DINENISO7091","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer DINENISO 7091 ",key,""));
		}
		cube();
	} else {
		plainwasher2_geo(key, part_mode);
	}
};

function DINENISO7091_dims(key="M10", part_mode="default") = plainwasher2_dims(key, part_mode);

function DINENISO7091_conn(location,key="M10", part_mode="default") = plainwasher2_conn(location,key, part_mode);

module ISO7091(key="M10", part_mode="default"){
	BOLTS_check_parameter_type("ISO7091","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer ISO 7091 ",key,""));
		}
		cube();
	} else {
		plainwasher2_geo(key, part_mode);
	}
};

function ISO7091_dims(key="M10", part_mode="default") = plainwasher2_dims(key, part_mode);

function ISO7091_conn(location,key="M10", part_mode="default") = plainwasher2_conn(location,key, part_mode);

module DIN126(key="M10", part_mode="default"){
	BOLTS_check_parameter_type("DIN126","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer DIN 126 ",key,""));
		}
		cube();
	} else {
		plainwasher2_geo(key, part_mode);
	}
};

function DIN126_dims(key="M10", part_mode="default") = plainwasher2_dims(key, part_mode);

function DIN126_conn(location,key="M10", part_mode="default") = plainwasher2_conn(location,key, part_mode);

module DINISO7091(key="M10", part_mode="default"){
	BOLTS_check_parameter_type("DINISO7091","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer DIN ISO 7091 ",key,""));
		}
		cube();
	} else {
		plainwasher2_geo(key, part_mode);
	}
};

function DINISO7091_dims(key="M10", part_mode="default") = plainwasher2_dims(key, part_mode);

function DINISO7091_conn(location,key="M10", part_mode="default") = plainwasher2_conn(location,key, part_mode);

/* Generated by BOLTS, do not modify */
function plainwasherchamfered_table_0(idx) =
//d1, d2, s
idx == "M2.6" ? [2.8, 7.0, 0.5] :
idx == "M2.5" ? [2.7, 6.0, 0.5] :
idx == "M56" ? [58.0, 105.0, 9.0] :
idx == "M2.3" ? [2.5, 6.0, 0.5] :
idx == "M2.2" ? [2.4, 6.0, 0.5] :
idx == "M39" ? [40.0, 72.0, 6.0] :
idx == "M3.5" ? [3.7, 8.0, 0.5] :
idx == "M36" ? [37.0, 66.0, 5.0] :
idx == "M33" ? [34.0, 60.0, 5.0] :
idx == "M30" ? [31.0, 56.0, 4.0] :
idx == "M72" ? [74.0, 125.0, 10.0] :
idx == "M4" ? [4.3, 9.0, 0.8] :
idx == "M7" ? [7.4, 14.0, 1.6] :
idx == "M6" ? [6.4, 12.0, 1.6] :
idx == "M1" ? [1.1, 3.0, 0.3] :
idx == "M3" ? [3.2, 7.0, 0.5] :
idx == "M2" ? [2.2, 5.0, 0.3] :
idx == "M8" ? [8.4, 16.0, 1.6] :
idx == "M76" ? [78.0, 135.0, 10.0] :
idx == "M85" ? [87.0, 145.0, 12.0] :
idx == "M80" ? [82.0, 140.0, 12.0] :
idx == "M42" ? [43.0, 78.0, 7.0] :
idx == "M60" ? [62.0, 110.0, 9.0] :
idx == "M48" ? [50.0, 92.0, 8.0] :
idx == "M64" ? [64.0, 115.0, 9.0] :
idx == "M24" ? [25.0, 44.0, 4.0] :
idx == "M27" ? [28.0, 50.0, 4.0] :
idx == "M20" ? [21.0, 37.0, 3.0] :
idx == "M22" ? [23.0, 39.0, 3.0] :
idx == "M45" ? [46.0, 85.0, 7.0] :
idx == "M16" ? [17.0, 30.0, 3.0] :
idx == "M5" ? [5.3, 10.0, 1.0] :
idx == "M100" ? [104.0, 175.0, 14.0] :
idx == "M52" ? [54.0, 98.0, 8.0] :
idx == "M90" ? [93.0, 160.0, 12.0] :
idx == "M68" ? [70.0, 120.0, 10.0] :
idx == "M10" ? [10.0, 20.0, 2.0] :
idx == "M1.2" ? [1.3, 3.5, 0.3] :
idx == "M12" ? [13.0, 24.0, 2.5] :
idx == "M1.4" ? [1.5, 4.0, 0.3] :
idx == "M14" ? [15.0, 28.0, 2.5] :
idx == "M1.6" ? [1.7, 4.0, 0.3] :
idx == "M1.7" ? [1.8, 4.5, 0.3] :
idx == "M18" ? [19.0, 34.0, 3.0] :
"Error";

function plainwasherchamfered_dims(key="M3", part_mode="default") = [
	["s", BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[2],"mm")],
	["d2", BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[1],"mm")],
	["key", key],
	["d1", BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[0],"mm")]];

function plainwasherchamfered_conn(location,key="M3", part_mode="default") = new_cs(
	origin=washerConn(BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[2],"mm"), location)[0],
	axes=washerConn(BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[1],"mm"), BOLTS_convert_to_default_unit(plainwasherchamfered_table_0(key)[2],"mm"), location)[1]);

module plainwasherchamfered_geo(key, part_mode){
	washer2(
		get_dim(plainwasherchamfered_dims(key, part_mode),"d1"),
		get_dim(plainwasherchamfered_dims(key, part_mode),"d2"),
		get_dim(plainwasherchamfered_dims(key, part_mode),"s")
	);
};

module DINENISO7090(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINENISO7090","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer chamfered DIN EN ISO 7090 ",key,""));
		}
		cube();
	} else {
		plainwasherchamfered_geo(key, part_mode);
	}
};

function DINENISO7090_dims(key="M3", part_mode="default") = plainwasherchamfered_dims(key, part_mode);

function DINENISO7090_conn(location,key="M3", part_mode="default") = plainwasherchamfered_conn(location,key, part_mode);

module DIN125B(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DIN125B","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer chamfered DIN 125B ",key,""));
		}
		cube();
	} else {
		plainwasherchamfered_geo(key, part_mode);
	}
};

function DIN125B_dims(key="M3", part_mode="default") = plainwasherchamfered_dims(key, part_mode);

function DIN125B_conn(location,key="M3", part_mode="default") = plainwasherchamfered_conn(location,key, part_mode);

module ISO7090(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("ISO7090","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer chamfered ISO 7090 ",key,""));
		}
		cube();
	} else {
		plainwasherchamfered_geo(key, part_mode);
	}
};

function ISO7090_dims(key="M3", part_mode="default") = plainwasherchamfered_dims(key, part_mode);

function ISO7090_conn(location,key="M3", part_mode="default") = plainwasherchamfered_conn(location,key, part_mode);

module DINISO7090(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("DINISO7090","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer chamfered DIN ISO 7090 ",key,""));
		}
		cube();
	} else {
		plainwasherchamfered_geo(key, part_mode);
	}
};

function DINISO7090_dims(key="M3", part_mode="default") = plainwasherchamfered_dims(key, part_mode);

function DINISO7090_conn(location,key="M3", part_mode="default") = plainwasherchamfered_conn(location,key, part_mode);

module MetricPlainWasherWithChamfer(key="M3", part_mode="default"){
	BOLTS_check_parameter_type("MetricPlainWasherWithChamfer","key",key,"Table Index");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Plain washer chamfered ",key,""));
		}
		cube();
	} else {
		plainwasherchamfered_geo(key, part_mode);
	}
};

function MetricPlainWasherWithChamfer_dims(key="M3", part_mode="default") = plainwasherchamfered_dims(key, part_mode);

function MetricPlainWasherWithChamfer_conn(location,key="M3", part_mode="default") = plainwasherchamfered_conn(location,key, part_mode);

/* Pipe module for OpenSCAD
 * Copyright (C) 2013 Johannes Reinhardt <jreinhardt@ist-dein-freund.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

module pipe(id,od,l){
	difference(){
		cylinder(r=od/2,h=l,center=true);
		cylinder(r=id/2,h=l+1,center=true);
	}
}

module pipe_wall(od,wall,l){
	difference(){
		cylinder(r=od/2,h=l,center=true);
		cylinder(r=(od - 2*wall)/2,h=l+1,center=true);
	}
}

function pipeConn(l,location) =
	(location == "front-in")  ? [[0,0,-l/2],[[0,0,1],[1,0,0]]] :
	(location == "front-out") ? [[0,0,-l/2],[[0,0,-1],[-1,0,0]]] :
	(location == "back-in")   ? [[0,0,+l/2],[[0,0,-1],[-1,0,0]]] :
	(location == "back-out")  ? [[0,0,+l/2],[[0,0,1],[1,0,0]]] :
	"Error";
	
/* Generated by BOLTS, do not modify */
function genericpipe_dims(od=13, id=10, l=1000, part_mode="default") = [
	["od", od],
	["id", id],
	["l", l]];

function genericpipe_conn(location,od=13, id=10, l=1000, part_mode="default") = new_cs(
	origin=pipeConn(l, location)[0],
	axes=pipeConn(l, location)[1]);

module genericpipe_geo(od, id, l, part_mode){
	pipe(
		get_dim(genericpipe_dims(od, id, l, part_mode),"id"),
		get_dim(genericpipe_dims(od, id, l, part_mode),"od"),
		get_dim(genericpipe_dims(od, id, l, part_mode),"l")
	);
};

module genericPipe(od=13, id=10, l=1000, part_mode="default"){
	BOLTS_check_parameter_type("genericPipe","od",od,"Length (mm)");
	BOLTS_check_parameter_type("genericPipe","id",id,"Length (mm)");
	BOLTS_check_parameter_type("genericPipe","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Pipe OD ",od," ID ",id," length ",l,""));
		}
		cube();
	} else {
		genericpipe_geo(od, id, l, part_mode);
	}
};

function genericPipe_dims(od=13, id=10, l=1000, part_mode="default") = genericpipe_dims(od, id, l, part_mode);

function genericPipe_conn(location,od=13, id=10, l=1000, part_mode="default") = genericpipe_conn(location,od, id, l, part_mode);

/* Generated by BOLTS, do not modify */
function din11850range2_table_0(idx) =
//id, od
idx == "150" ? [150.0, 154.0] :
idx == "200" ? [200.0, 204.0] :
idx == "20" ? [20.0, 23.0] :
idx == "10" ? [10.0, 13.0] :
idx == "25" ? [26.0, 29.0] :
idx == "32" ? [32.0, 35.0] :
idx == "50" ? [50.0, 53.0] :
idx == "40" ? [38.0, 41.0] :
idx == "65" ? [66.0, 70.0] :
idx == "6" ? [6.0, 8.0] :
idx == "15" ? [16.0, 19.0] :
idx == "100" ? [100.0, 104.0] :
idx == "80" ? [81.0, 85.0] :
idx == "125" ? [125.0, 129.0] :
idx == "8" ? [8.0, 10.0] :
"Error";

function din11850range2_dims(dn="10", l=1000, part_mode="default") = [
	["dn", dn],
	["od", BOLTS_convert_to_default_unit(din11850range2_table_0(dn)[1],"mm")],
	["l", l],
	["id", BOLTS_convert_to_default_unit(din11850range2_table_0(dn)[0],"mm")]];

function din11850range2_conn(location,dn="10", l=1000, part_mode="default") = new_cs(
	origin=pipeConn(l, location)[0],
	axes=pipeConn(l, location)[1]);

module din11850range2_geo(dn, l, part_mode){
	pipe(
		get_dim(din11850range2_dims(dn, l, part_mode),"id"),
		get_dim(din11850range2_dims(dn, l, part_mode),"od"),
		get_dim(din11850range2_dims(dn, l, part_mode),"l")
	);
};

module DIN11850Range2(dn="10", l=1000, part_mode="default"){
	BOLTS_check_parameter_type("DIN11850Range2","dn",dn,"Table Index");
	BOLTS_check_parameter_type("DIN11850Range2","l",l,"Length (mm)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("DIN 11850 Range 2 DN ",dn," length ",l,""));
		}
		cube();
	} else {
		din11850range2_geo(dn, l, part_mode);
	}
};

function DIN11850Range2_dims(dn="10", l=1000, part_mode="default") = din11850range2_dims(dn, l, part_mode);

function DIN11850Range2_conn(location,dn="10", l=1000, part_mode="default") = din11850range2_conn(location,dn, l, part_mode);

/* Generated by BOLTS, do not modify */
function nominalpipesize_table_0(idx) =
//od
idx == "NPS 4.5" ? [5.0] :
idx == "NPS 34" ? [34.0] :
idx == "NPS 36" ? [36.0] :
idx == "NPS 2.5" ? [2.875] :
idx == "NPS 30" ? [30.0] :
idx == "NPS 3.5" ? [4.0] :
idx == "NPS 0.25" ? [0.54] :
idx == "NPS 0.5" ? [0.84] :
idx == "NPS 18" ? [18.0] :
idx == "NPS 1.5" ? [1.9] :
idx == "NPS 12" ? [12.75] :
idx == "NPS 10" ? [10.75] :
idx == "NPS 11" ? [11.75] :
idx == "NPS 16" ? [16.0] :
idx == "NPS 14" ? [14.0] :
idx == "NPS 1" ? [1.315] :
idx == "NPS 2" ? [2.375] :
idx == "NPS 3" ? [3.5] :
idx == "NPS 4" ? [4.5] :
idx == "NPS 5" ? [5.563] :
idx == "NPS 6" ? [6.625] :
idx == "NPS 7" ? [7.625] :
idx == "NPS 8" ? [8.625] :
idx == "NPS 9" ? [9.625] :
idx == "NPS 32" ? [32.0] :
idx == "NPS 0.125" ? [0.405] :
idx == "NPS 1.25" ? [1.66] :
idx == "NPS 20" ? [20.0] :
idx == "NPS 26" ? [26.0] :
idx == "NPS 24" ? [24.0] :
idx == "NPS 28" ? [28.0] :
idx == "NPS 0.75" ? [1.05] :
idx == "NPS 42" ? [42.0] :
idx == "NPS 48" ? [48.0] :
idx == "NPS 0.375" ? [0.675] :
"Error";

function nominalpipesize_table2d_0(rowidx,colidx) =
colidx == "5s" ? nominalpipesize_table2d_rows_0(rowidx)[0] :
colidx == "5" ? nominalpipesize_table2d_rows_0(rowidx)[1] :
colidx == "10s" ? nominalpipesize_table2d_rows_0(rowidx)[2] :
colidx == "10" ? nominalpipesize_table2d_rows_0(rowidx)[3] :
colidx == "20" ? nominalpipesize_table2d_rows_0(rowidx)[4] :
colidx == "30" ? nominalpipesize_table2d_rows_0(rowidx)[5] :
colidx == "40s" ? nominalpipesize_table2d_rows_0(rowidx)[6] :
colidx == "40" ? nominalpipesize_table2d_rows_0(rowidx)[7] :
colidx == "60" ? nominalpipesize_table2d_rows_0(rowidx)[8] :
colidx == "80s" ? nominalpipesize_table2d_rows_0(rowidx)[9] :
colidx == "80" ? nominalpipesize_table2d_rows_0(rowidx)[10] :
colidx == "100" ? nominalpipesize_table2d_rows_0(rowidx)[11] :
colidx == "120" ? nominalpipesize_table2d_rows_0(rowidx)[12] :
colidx == "140" ? nominalpipesize_table2d_rows_0(rowidx)[13] :
colidx == "160" ? nominalpipesize_table2d_rows_0(rowidx)[14] :
"Error";

function nominalpipesize_table2d_rows_0(rowidx) =
rowidx == "NPS 4.5" ? ["None", "None", "None", "None", "None", "None", "None", 0.247, "None", "None", 0.355, "None", "None", "None", "None"] :
rowidx == "NPS 34" ? ["None", "None", "None", 0.312, 0.5, 0.625, 0.375, 0.688, "None", "None", "None", "None", "None", "None", "None"] :
rowidx == "NPS 36" ? ["None", "None", "None", 0.312, 0.5, 0.625, 0.375, 0.75, "None", 0.5, "None", "None", "None", "None", "None"] :
rowidx == "NPS 2.5" ? [0.083, 0.083, 0.12, 0.12, "None", "None", 0.203, 0.203, "None", 0.276, 0.276, "None", "None", "None", 0.375] :
rowidx == "NPS 30" ? [0.25, "None", 0.312, 0.312, 0.5, 0.625, 0.375, "None", "None", 0.5, "None", "None", "None", "None", "None"] :
rowidx == "NPS 3.5" ? [0.083, 0.083, 0.12, 0.12, "None", "None", 0.226, 0.226, "None", 0.318, 0.318, "None", "None", "None", "None"] :
rowidx == "NPS 0.25" ? ["None", 0.049, 0.065, 0.065, "None", "None", 0.088, 0.088, "None", 0.119, 0.119, "None", "None", "None", "None"] :
rowidx == "NPS 0.5" ? [0.065, 0.065, 0.083, 0.083, "None", "None", 0.109, 0.109, "None", 0.147, 0.147, "None", "None", "None", 0.187] :
rowidx == "NPS 18" ? [0.165, "None", 0.188, 0.25, 0.312, 0.437, 0.375, 0.562, 0.75, 0.5, 0.937, 1.156, 1.375, 1.562, 1.781] :
rowidx == "NPS 1.5" ? [0.065, 0.065, 0.109, 0.109, "None", "None", 0.145, 0.145, "None", 0.2, 0.2, "None", "None", "None", 0.281] :
rowidx == "NPS 12" ? [0.156, 0.165, 0.18, 0.18, 0.25, 0.33, 0.375, 0.406, 0.562, 0.5, 0.687, 0.843, 1.0, 1.125, 1.312] :
rowidx == "NPS 10" ? [0.134, 0.134, 0.165, 0.165, 0.25, 0.307, 0.365, 0.365, 0.5, 0.5, 0.593, 0.718, 0.843, 1.0, 1.125] :
rowidx == "NPS 11" ? ["None", "None", "None", "None", "None", "None", "None", 0.375, "None", "None", 0.5, "None", "None", "None", "None"] :
rowidx == "NPS 16" ? [0.165, "None", 0.188, 0.25, 0.312, 0.375, 0.375, 0.5, 0.656, 0.5, 0.843, 1.031, 1.218, 1.437, 1.593] :
rowidx == "NPS 14" ? [0.156, "None", 0.188, 0.25, 0.312, 0.375, 0.375, 0.437, 0.593, 0.5, 0.75, 0.937, 1.093, 1.25, 1.406] :
rowidx == "NPS 1" ? [0.065, 0.065, 0.109, 0.109, "None", "None", 0.133, 0.133, "None", 0.179, 0.179, "None", "None", "None", 0.25] :
rowidx == "NPS 2" ? [0.065, 0.065, 0.109, 0.109, "None", "None", 0.154, 0.154, "None", 0.218, 0.218, "None", "None", "None", 0.343] :
rowidx == "NPS 3" ? [0.083, 0.083, 0.12, 0.12, "None", "None", 0.216, 0.216, "None", 0.3, 0.3, "None", "None", "None", 0.437] :
rowidx == "NPS 4" ? [0.083, 0.083, 0.12, 0.12, "None", "None", 0.237, 0.237, 0.281, 0.337, 0.337, "None", 0.437, "None", 0.531] :
rowidx == "NPS 5" ? [0.109, 0.109, 0.134, 0.134, "None", "None", 0.258, 0.258, "None", 0.375, 0.375, "None", 0.5, "None", 0.625] :
rowidx == "NPS 6" ? [0.109, 0.109, 0.134, 0.134, "None", "None", 0.28, 0.28, "None", 0.432, 0.432, "None", 0.562, "None", 0.718] :
rowidx == "NPS 7" ? ["None", "None", "None", "None", "None", "None", "None", 0.301, "None", "None", 0.5, "None", "None", "None", "None"] :
rowidx == "NPS 8" ? [0.109, 0.109, 0.148, 0.148, 0.25, 0.277, 0.322, 0.322, 0.406, 0.5, 0.5, 0.593, 0.718, 0.812, 0.906] :
rowidx == "NPS 9" ? ["None", "None", "None", "None", "None", "None", "None", 0.342, "None", "None", 0.5, "None", "None", "None", "None"] :
rowidx == "NPS 32" ? ["None", "None", "None", 0.312, 0.5, 0.625, 0.375, 0.688, "None", 0.5, "None", "None", "None", "None", "None"] :
rowidx == "NPS 0.125" ? ["None", 0.035, 0.049, 0.049, "None", "None", 0.068, 0.068, "None", 0.095, 0.095, "None", "None", "None", "None"] :
rowidx == "NPS 1.25" ? [0.065, 0.065, 0.109, 0.109, "None", "None", 0.14, 0.14, "None", 0.191, 0.191, "None", "None", "None", 0.25] :
rowidx == "NPS 20" ? [0.188, "None", 0.218, 0.25, 0.375, 0.5, 0.375, 0.593, 0.812, 0.5, 1.031, 1.28, 1.5, 1.75, 1.968] :
rowidx == "NPS 26" ? ["None", "None", "None", 0.312, 0.5, "None", 0.375, "None", "None", 0.5, "None", "None", "None", "None", "None"] :
rowidx == "NPS 24" ? [0.218, "None", 0.25, 0.25, 0.375, 0.562, 0.375, 0.687, 0.968, 0.5, 1.218, 1.531, 1.812, 2.062, 2.343] :
rowidx == "NPS 28" ? ["None", "None", "None", 0.312, 0.5, 0.625, 0.375, "None", "None", "None", "None", "None", "None", "None", "None"] :
rowidx == "NPS 0.75" ? [0.065, 0.065, 0.083, 0.083, "None", "None", 0.113, 0.113, "None", 0.154, 0.154, "None", "None", "None", 0.218] :
rowidx == "NPS 42" ? ["None", "None", "None", "None", "None", "None", 0.375, "None", "None", 0.5, "None", "None", "None", "None", "None"] :
rowidx == "NPS 48" ? ["None", "None", "None", "None", "None", "None", 0.375, "None", "None", 0.5, "None", "None", "None", "None", "None"] :
rowidx == "NPS 0.375" ? ["None", 0.049, 0.065, 0.065, "None", "None", 0.091, 0.091, "None", 0.126, 0.126, "None", "None", "None", "None"] :
"Error";

function nominalpipesize_dims(nps="NPS 0.5", sched="40", l=50, part_mode="default") = [
	["wall", BOLTS_convert_to_default_unit(nominalpipesize_table2d_0(nps,sched),"in")],
	["od", BOLTS_convert_to_default_unit(nominalpipesize_table_0(nps)[0],"in")],
	["sched", sched],
	["l", l],
	["nps", nps]];

function nominalpipesize_conn(location,nps="NPS 0.5", sched="40", l=50, part_mode="default") = new_cs(
	origin=pipeConn(l, location)[0],
	axes=pipeConn(l, location)[1]);

module nominalpipesize_geo(nps, sched, l, part_mode){
	pipe_wall(
		get_dim(nominalpipesize_dims(nps, sched, l, part_mode),"od"),
		get_dim(nominalpipesize_dims(nps, sched, l, part_mode),"wall"),
		get_dim(nominalpipesize_dims(nps, sched, l, part_mode),"l")
	);
};

module API5L(nps="NPS 0.5", sched="40", l=50, part_mode="default"){
	BOLTS_check_parameter_type("API5L","nps",nps,"Table Index");
	BOLTS_check_parameter_type("API5L","sched",sched,"Table Index");
	BOLTS_check_parameter_type("API5L","l",l,"Length (in)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Wrought steel pipe API 5L ",nps," ",sched," Length ",l,""));
		}
		cube();
	} else {
		nominalpipesize_geo(nps, sched, l, part_mode);
	}
};

function API5L_dims(nps="NPS 0.5", sched="40", l=50, part_mode="default") = nominalpipesize_dims(nps, sched, l, part_mode);

function API5L_conn(location,nps="NPS 0.5", sched="40", l=50, part_mode="default") = nominalpipesize_conn(location,nps, sched, l, part_mode);

module ASMEB3610M(nps="NPS 0.5", sched="40", l=50, part_mode="default"){
	BOLTS_check_parameter_type("ASMEB3610M","nps",nps,"Table Index");
	BOLTS_check_parameter_type("ASMEB3610M","sched",sched,"Table Index");
	BOLTS_check_parameter_type("ASMEB3610M","l",l,"Length (in)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Wrought steel pipe ASME B36.10M ",nps," ",sched," Length ",l,""));
		}
		cube();
	} else {
		nominalpipesize_geo(nps, sched, l, part_mode);
	}
};

function ASMEB3610M_dims(nps="NPS 0.5", sched="40", l=50, part_mode="default") = nominalpipesize_dims(nps, sched, l, part_mode);

function ASMEB3610M_conn(location,nps="NPS 0.5", sched="40", l=50, part_mode="default") = nominalpipesize_conn(location,nps, sched, l, part_mode);

module ANSIB3610M(nps="NPS 0.5", sched="40", l=50, part_mode="default"){
	BOLTS_check_parameter_type("ANSIB3610M","nps",nps,"Table Index");
	BOLTS_check_parameter_type("ANSIB3610M","sched",sched,"Table Index");
	BOLTS_check_parameter_type("ANSIB3610M","l",l,"Length (in)");
	if(BOLTS_MODE == "bom"){
		if(!(part_mode == "diff")){
			echo(str("Wrought steel pipe ANSI B36.10M ",nps," ",sched," Length ",l,""));
		}
		cube();
	} else {
		nominalpipesize_geo(nps, sched, l, part_mode);
	}
};

function ANSIB3610M_dims(nps="NPS 0.5", sched="40", l=50, part_mode="default") = nominalpipesize_dims(nps, sched, l, part_mode);

function ANSIB3610M_conn(location,nps="NPS 0.5", sched="40", l=50, part_mode="default") = nominalpipesize_conn(location,nps, sched, l, part_mode);

