//===========================================
//   Public Domain Cycloidal Speed Reducer in OpenSCAD
//   version 1.0
//   by Matt Moses, 2011, mmoses152@gmail.com
//   http://www.thingiverse.com/thing:8348
//
//   This file is public domain.  Use it for any purpose, including commercial
//   applications.  Attribution would be nice, but is not required.  There is
//   no warranty of any kind, including its correctness, usefulness, or safety.
//
//===========================================

$fn = 80;
pi = 3.14159265;

// =================

// Based on Igor's rod sizes:
shaft3= 9/32     * 25.4 /2;
shaft2 = 1/4     * 25.4 /2;
shaft1 = 7/32    * 25.4 /2;

// ===============
// These parameters are for a speed reducer with 
//
// 10 : 1 speed ratio
// 10 inner lobes
// 11 outer lobes
// 5 output cam holes


n_inner_lobes = 10;
lobe_diff = 1;
thickness = 8;
r_gen = 6;
r_offset = 10;
r_pins = 6.35/2; // 1/4"
r_holes = r_pins + lobe_diff*r_gen;
n_holes = 5;
r_hole_center = 32;
r_rotor_shaft = 16;
r_bolts = 2;
driven_shaft_od = 50;
r_drive_shaft = shaft1; // see above
output_shaft_od = shaft2; // See above
square_side = 10;
alpha =  2*360*$t;

//  ==============

// This part displays the REDUCTION RATIO ======
//
echo(str(n_inner_lobes/lobe_diff, " turns on the input equals 1 turn on the output."));




render=[1,1,1,2,1,0]; // normal view

//render=[1,2,0,2,0,0]; // cycloidal drive input section
//render=[0,0,2,0,0,2]; // output section only

//render=[1,2,2,2,0,2]; // panelized view combo...
//render=[0,0,2,0,0,0]; // panelized view combo...

// 0 = hide
// 1 = display
// 2 = solo (modifications)

// 0  Inside Rotor
// 1  Outside Rotor (s - top half)
// 2  driven shaft (s)
// 3  eccentric (s)
// 4  frnt. cover
// 5  outside rotor - bottom half. (s)

// This part places the INSIDE ROTOR =========
if (render[0] > 0)
{
translate([lobe_diff*r_gen*cos(alpha), lobe_diff* r_gen*sin(alpha), 0])
rotate([0,0,-lobe_diff*alpha/n_inner_lobes])
color([0.5, 0.5, 0.3])
inside_rotor(n_inner_lobes, 
				r_gen,
				0.99*r_offset,
				r_holes,
				n_holes,
				r_hole_center,
				r_rotor_shaft,
				thickness);
}

// This part places the OUTSIDE ROTOR =========
if (render[1] > 0 ){
color([1,0,0])
difference(){
outside_rotor(n_inner_lobes + lobe_diff, 
				r_gen,
				r_offset,
				r_bolts,
				driven_shaft_od,
				1.1*thickness);
  if (render[1] > 1) 
translate([0,0,-thickness*1.1])	cylinder(r = (n_inner_lobes+lobe_diff+1)*r_gen +r_offset+1, h = thickness*1.1+0.05, center = true);
}

}

// This part places the DRIVEN SHAFT =========
//
if (render[2] > 0 )
 rotate([0,0,-lobe_diff*alpha/n_inner_lobes])
  color([0,0,1])
   difference(){
    driven_shaft_round(r_pins, n_holes, r_hole_center, thickness, driven_shaft_od, output_shaft_od) ;
   if (render[2] > 1 )
    translate([0,0,-thickness])scale([1,1,2*thickness])difference(){
      driven_shaft_round(r_pins, n_holes, r_hole_center, thickness, driven_shaft_od, output_shaft_od) ;
      translate([0,0,-thickness]) cylinder(h=thickness,r=driven_shaft_od,center=true);
     }
 }

// This part places the ECCENTRIC =========
//
if (render[3] > 0)
 rotate([0,0,alpha])
 difference(){
  eccentric(thickness, lobe_diff*r_gen, r_rotor_shaft, r_drive_shaft);
  if (render[3] > 1 )
  translate([0,0, (5/2 -1 )*thickness])
    cylinder(r = 0.98 * r_drive_shaft, h = 6*thickness, center = true);
  }



// This part places the COVER PLATE =========
if (render[4]>0)
 color([0.2, 0.7, 0.4, 0.6])
  translate([0,0, 1.1*thickness/2 + thickness/4])
   cover_plate(n_inner_lobes + lobe_diff, 
 				r_gen,
				r_offset,
				r_bolts,
				1.02*r_drive_shaft,
				thickness/2);
                
        
// This part places the OUTSIDE ROTOR =========
if (render[5] > 1 ){
color([0.7, 0.2, 0.4, 0.6])
intersection(){
outside_rotor(n_inner_lobes + lobe_diff, 
				r_gen,
				r_offset,
				r_bolts,
				driven_shaft_od,
				1.1*thickness);
    
translate([0,0,-thickness*1.1])	cylinder(r = (n_inner_lobes+lobe_diff+1)*r_gen +r_offset, h = thickness*1.1, center = true);
}
}


//
////
////   End of Pump Demo
////===========================================







//===========================================
// Cover Plate
//
module cover_plate(	n_lobes, 
				r_gen,
				w_gen,
				r_bolts,
				r_shaft,
				thickness) {

difference() {
	cylinder(r = (n_lobes+1)*r_gen + w_gen, h = thickness, center = true);
	cylinder(r = 1.01 * r_shaft, h = 2*thickness, center = true);
	for (i=[0:n_lobes-1]) {
		rotate([0,0,360/n_lobes * (i + 0.5)])
		translate([ (n_lobes+1)*r_gen + w_gen - 4*r_bolts, 0, 0])
			cylinder(r = r_bolts, h = 2*thickness, center = true);
}

}

}
//===========================================	


//===========================================
// Driven Shaft
//
module driven_shaft(r_pins, n_pins, r_pin_center, thickness, driven_shaft_od, square_side) {
translate([0,0,-thickness])
	difference() {
	cylinder(r = driven_shaft_od, h = thickness, center = true);
	cube(size=[square_side, square_side, 1.1*thickness], center = true);
	}

//shaft_length = 2;
//translate([0,0, -shaft_length/2 -3*thickness/2])
//	cylinder(r = 1, h = shaft_length, center = true);

color([1,0.2,0.8])
for  ( i = [0:n_pins-1] ) {
	rotate([0,0,360/n_pins * i])
	translate([r_pin_center,0,0])
		cylinder(r = r_pins, h = thickness, center = true);
}



}
//===========================================

module driven_shaft_round(r_pins, n_pins, r_pin_center, thickness, driven_shaft_od, output_shaft_od) {
translate([0,0,-thickness])
	difference() {
	cylinder(r = driven_shaft_od, h = thickness, center = true);
    cylinder( r=output_shaft_od, h= 1.1*thickness,center=true);
	}
color([1,0.2,0.8])
for  ( i = [0:n_pins-1] ) {
	rotate([0,0,360/n_pins * i])
	translate([r_pin_center,0,0])
		cylinder(r = r_pins, h = thickness, center = true);
}

}


//===========================================
// Eccentric
//
module eccentric(thickness, ecc, rotor_gear_outer_radius, housing_hole_rad){
union(){
translate([0,0, 5/2*thickness])
cylinder(r = 0.98 * housing_hole_rad, h = 4*thickness, center = true);
translate([ecc, 0, 0])
	cylinder(r = 0.98 * rotor_gear_outer_radius, h = thickness, center = true);
}
}
//===========================================


//===========================================
// Inside Rotor
//
module inside_rotor(	n_lobes, 
				r_gen,
				w_gen,
				r_holes,
				n_holes,
				r_hole_center,
				r_shaft,
				thickness) {
translate([0, 0, -thickness/2])
difference(){

	hypotrochoidBandFast(n_lobes, r_gen, thickness, w_gen);
	// These are the pins
	union() {
		for ( i = [0:n_holes-1] ) {
			rotate([0, 0, i*360/n_holes])
			translate([r_hole_center, 0, 0])
				cylinder(r = r_holes, h = 4*thickness, center = true);
		}	
	}
	cylinder(r = r_shaft, h = 4*thickness, center = true);

}

}
//===========================================			


//===========================================
// Outside Rotor
//
module outside_rotor(	n_lobes, 
				r_gen,
				w_gen,
				r_bolts,
				r_shaft,
				thickness) {
difference() {
	cylinder(r = (n_lobes+1)*r_gen + w_gen, h = thickness, center = true);
	translate([0, 0, -thickness])
		hypotrochoidBandFast(n_lobes, r_gen, 2*thickness, w_gen);
	for (i=[0:n_lobes-1]) {
		rotate([0,0,360/n_lobes * (i + 0.5)])
		translate([ (n_lobes+1)*r_gen + w_gen - 4*r_bolts, 0, 0])
			cylinder(r = r_bolts, h = 2*thickness, center = true);
}
}

translate([0,0,-thickness]) {
	difference() {
		cylinder(r = (n_lobes+1)*r_gen + w_gen, h = thickness, center = true);
		cylinder(r = 1.01 * r_shaft, h = 2*thickness, center = true);
		for (i=[0:n_lobes-1]) {
			rotate([0,0,360/n_lobes * (i + 0.5)])
			translate([ (n_lobes+1)*r_gen + w_gen - 4*r_bolts, 0, 0])
				cylinder(r = r_bolts, h = 2*thickness, center = true);
	}
	}
}

echo(str("The outside diameter of the stator is " ,(n_lobes+1)*r_gen + w_gen));
}
//===========================================	


//===========================================
// Hypotrochoid Band Fast
//
// This generates the normal vector to a hypocycloid, pointing outward,
// and extrudes a profile approximating the envelope of normals.
//
// n 		is the number of lobes
// r		is the radius of the little rolling circle that generates the hypocycloid
// thickness 	is the height of extrusion
// r_off 	is the distance that the envelope is offset from the base hypocycloid
// 
// When r_off = zero the output is the same as a hypocycloid.
//
// As far as I know, OpenSCAD does not do arrays, hence the funny big blocks of
// hardcoded numbers you will see below.
//
module hypotrochoidBandFast(n, r, thickness, r_off) {

	R = r*n;
	d = r;

	// set to 1 for normal size cylinders.  this will leave a tiny cusp in some cases that does
	// not blend in to cylinders.  see below for details.  make hideCuspFactor larger to scale up
	// the cylinders slightly. 1.01 seems to work OK.
	hideCuspFactor = 1.01;

	// dth stands for dtheta - i.e. a small change of the angle "theta"
	// there are 14 intermediate points on the curve, so a wedge is
	// divided into 14 + 1 = 15.  You may be tempted to change this, but it really is 15.
	dth = 360/n/15;

	// X points on base hypotrochoid
	xbStart = (R-r) + d;
	xbEnd =  (R-r)*cos(360/n) + d*cos((R-r)/r*360/n);	

	// Instead of an array and a for-loop we just hard-code these 
	// intermediate points, this if for X coords on the base hypocycloid.
	//
	xb1 = (R-r)*cos(dth*1) + d*cos((R-r)/r*dth*1);
	xb2 = (R-r)*cos(dth*2) + d*cos((R-r)/r*dth*2);
	xb3 = (R-r)*cos(dth*3) + d*cos((R-r)/r*dth*3);
	xb4 = (R-r)*cos(dth*4) + d*cos((R-r)/r*dth*4);
	xb5 = (R-r)*cos(dth*5) + d*cos((R-r)/r*dth*5);
	xb6 = (R-r)*cos(dth*6) + d*cos((R-r)/r*dth*6);
	xb7 = (R-r)*cos(dth*7) + d*cos((R-r)/r*dth*7);	
	xb8 = (R-r)*cos(dth*8) + d*cos((R-r)/r*dth*8);
	xb9 = (R-r)*cos(dth*9) + d*cos((R-r)/r*dth*9);
	xb10 = (R-r)*cos(dth*10) + d*cos((R-r)/r*dth*10);
	xb11 = (R-r)*cos(dth*11) + d*cos((R-r)/r*dth*11);
	xb12 = (R-r)*cos(dth*12) + d*cos((R-r)/r*dth*12);
	xb13 = (R-r)*cos(dth*13) + d*cos((R-r)/r*dth*13);
	xb14 = (R-r)*cos(dth*14) + d*cos((R-r)/r*dth*14);	

	// Y points on base hypotrochoid
	ybStart = 0;
	ybEnd =   (R-r)*sin(360/n) - d*sin((R-r)/r*360/n);

	// Instead of an array and a for-loop we just hard-code these 
	// intermediate points, this if for Y coords on the base hypocycloid.
	//
	yb1 =  (R-r)*sin(dth*1) - d*sin((R-r)/r*dth*1);
	yb2 =  (R-r)*sin(dth*2) - d*sin((R-r)/r*dth*2);
	yb3 =  (R-r)*sin(dth*3) - d*sin((R-r)/r*dth*3);
	yb4 =  (R-r)*sin(dth*4) - d*sin((R-r)/r*dth*4);
	yb5 =  (R-r)*sin(dth*5) - d*sin((R-r)/r*dth*5);
	yb6 =  (R-r)*sin(dth*6) - d*sin((R-r)/r*dth*6);
	yb7 =  (R-r)*sin(dth*7) - d*sin((R-r)/r*dth*7);
	yb8 =  (R-r)*sin(dth*8) - d*sin((R-r)/r*dth*8);
	yb9 =  (R-r)*sin(dth*9) - d*sin((R-r)/r*dth*9);
	yb10 =  (R-r)*sin(dth*10) - d*sin((R-r)/r*dth*10);
	yb11 =  (R-r)*sin(dth*11) - d*sin((R-r)/r*dth*11);
	yb12 =  (R-r)*sin(dth*12) - d*sin((R-r)/r*dth*12);
	yb13 =  (R-r)*sin(dth*13) - d*sin((R-r)/r*dth*13);
	yb14 =  (R-r)*sin(dth*14) - d*sin((R-r)/r*dth*14);

	// Now we do the offset points.  The tangent to the
	// hypotrochoid is [dx/dtheta, dy/dtheta].
	// We take the tangent, normalize it, rotate it, and scale it 
	// to get the offsets in X and Y coords.
	
	// X offset points
	xfStart = 0;
	xfEnd =  r_off*cos(360/n - 90);

	// hard-coded offset points for X
	//
	xf1 = (R-r)*cos(dth*1) - r*cos( (R-r)/r*dth*1) * (R-r)/r ;
	xf2 = (R-r)*cos(dth*2) - r*cos( (R-r)/r*dth*2) * (R-r)/r ;
	xf3 = (R-r)*cos(dth*3) - r*cos( (R-r)/r*dth*3) * (R-r)/r ;
	xf4 = (R-r)*cos(dth*4) - r*cos( (R-r)/r*dth*4) * (R-r)/r ;
	xf5 = (R-r)*cos(dth*5) - r*cos( (R-r)/r*dth*5) * (R-r)/r ;
	xf6 = (R-r)*cos(dth*6) - r*cos( (R-r)/r*dth*6) * (R-r)/r ;
	xf7 = (R-r)*cos(dth*7) - r*cos( (R-r)/r*dth*7) * (R-r)/r ;	
	xf8 = (R-r)*cos(dth*8) - r*cos( (R-r)/r*dth*8) * (R-r)/r ;
	xf9 = (R-r)*cos(dth*9) - r*cos( (R-r)/r*dth*9) * (R-r)/r ;
	xf10 = (R-r)*cos(dth*10) - r*cos( (R-r)/r*dth*10) * (R-r)/r ;
	xf11 = (R-r)*cos(dth*11) - r*cos( (R-r)/r*dth*11) * (R-r)/r ;
	xf12 = (R-r)*cos(dth*12) - r*cos( (R-r)/r*dth*12) * (R-r)/r ;
	xf13 = (R-r)*cos(dth*13) - r*cos( (R-r)/r*dth*13) * (R-r)/r ;
	xf14 = (R-r)*cos(dth*14) - r*cos( (R-r)/r*dth*14) * (R-r)/r ;	

	// Y offset points
	yfStart = r_off;
	yfEnd =  r_off*sin(360/n - 90);

	yf1 =  (R-r)*sin(dth*1) + r*sin( (R-r)/r*dth*1) * (R-r)/r ;
	yf2 =  (R-r)*sin(dth*2) + r*sin( (R-r)/r*dth*2) * (R-r)/r ;
	yf3 =  (R-r)*sin(dth*3) + r*sin( (R-r)/r*dth*3) * (R-r)/r ;
	yf4 =  (R-r)*sin(dth*4) + r*sin( (R-r)/r*dth*4) * (R-r)/r ;
	yf5 =  (R-r)*sin(dth*5) + r*sin( (R-r)/r*dth*5) * (R-r)/r ;
	yf6 =  (R-r)*sin(dth*6) + r*sin( (R-r)/r*dth*6) * (R-r)/r ;
	yf7 =  (R-r)*sin(dth*7) + r*sin( (R-r)/r*dth*7) * (R-r)/r ;
	yf8 =  (R-r)*sin(dth*8) + r*sin( (R-r)/r*dth*8) * (R-r)/r ;
	yf9 =  (R-r)*sin(dth*9) + r*sin( (R-r)/r*dth*9) * (R-r)/r ;
	yf10 =  (R-r)*sin(dth*10) + r*sin( (R-r)/r*dth*10) * (R-r)/r ;
	yf11 =  (R-r)*sin(dth*11) + r*sin( (R-r)/r*dth*11) * (R-r)/r ;
	yf12 =  (R-r)*sin(dth*12) + r*sin( (R-r)/r*dth*12) * (R-r)/r ;
	yf13 =  (R-r)*sin(dth*13) + r*sin( (R-r)/r*dth*13) * (R-r)/r ;
	yf14 =  (R-r)*sin(dth*14) + r*sin( (R-r)/r*dth*14) * (R-r)/r ;

	m1 = sqrt(xf1*xf1 + yf1*yf1)/r_off;
	m2 = sqrt(xf2*xf2 + yf2*yf2)/r_off;
	m3 = sqrt(xf3*xf3 + yf3*yf3)/r_off;
	m4 = sqrt(xf4*xf4 + yf4*yf4)/r_off;
	m5 = sqrt(xf5*xf5 + yf5*yf5)/r_off;
	m6 = sqrt(xf6*xf6 + yf6*yf6)/r_off;
	m7 = sqrt(xf7*xf7 + yf7*yf7)/r_off;
	m8 = sqrt(xf8*xf8 + yf8*yf8)/r_off;
	m9 = sqrt(xf9*xf9 + yf9*yf9)/r_off;
	m10 = sqrt(xf10*xf10 + yf10*yf10)/r_off;
	m11 = sqrt(xf11*xf11 + yf11*yf11)/r_off;
	m12 = sqrt(xf12*xf12 + yf12*yf12)/r_off;
	m13 = sqrt(xf13*xf13 + yf13*yf13)/r_off;
	m14 = sqrt(xf14*xf14 + yf14*yf14)/r_off;

// Now that we have the points, we make a polygon and extrude it.
	
union() {
for  ( i = [0:n-1] ) {
rotate([0,0, 360/n*i]) {

	linear_extrude(height = thickness)
		// the first point in the polygon is moved slightly off the origin
		 polygon(points= [
			[-R/20 * cos(360/n/2) , -R/20 * sin(360/n/2)],
			[xbStart, ybStart],
			[xbStart + xfStart, ybStart + yfStart], 

			[xb1 + xf1/m1, yb1 + yf1/m1], 
			[xb2 + xf2/m2, yb2 + yf2/m2], 
			[xb3 + xf3/m3, yb3 + yf3/m3], 
			[xb4 + xf4/m4, yb4 + yf4/m4], 
			[xb5 + xf5/m5, yb5 + yf5/m5], 
			[xb6 + xf6/m6, yb6 + yf6/m6], 
			[xb7 + xf7/m7, yb7 + yf7/m7], 
			[xb8 + xf8/m8, yb8 + yf8/m8], 
			[xb9 + xf9/m9, yb9 + yf9/m9], 
			[xb10 + xf10/m10, yb10 + yf10/m10], 
			[xb11 + xf11/m11, yb11 + yf11/m11], 
			[xb12 + xf12/m12, yb12 + yf12/m12], 
			[xb13 + xf13/m13, yb13 + yf13/m13], 
			[xb14 + xf14/m14, yb14 + yf14/m14], 

			[xbEnd + xfEnd, ybEnd + yfEnd],
			[xbEnd, ybEnd]],
			paths = [[0,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1]],
			convexity = 10);

	// If you look at just the wedge extruded above, without the cylinders below,
	// you can see a small cusp as the band radius gets larger.  The radius of 
	// the cylinder is manually increased a slight bit so that the cusp is contained 
	// within the cylinder.  With unlimited resolution, the cusp and cylinder would
	// blend together perfectly (I think), but this workaround is needed because
	// we are only using piecewise linear approximations to these curves.
	
	translate([xbStart, ybStart, thickness/2])
		cylinder(r = hideCuspFactor*r_off, h = thickness, center = true);
	
} //end rotate

} //end for

} // end union()

} // end module hypotrochoidBandFast
//=========================================== 

