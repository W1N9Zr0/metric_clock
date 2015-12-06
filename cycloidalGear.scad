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

//$fn = 80;
$fs = .1;
$fa = 360/100;

clearance_m = 0.2;
clearance_s = 0.1;
inch = 25.4;
// =================

// Based on Igor's rod sizes:
shaft3 = 1/4     * inch /2;
shaft3_l = .252  * inch /2;
shaft3_t = .242  * inch /2;
shaft2 = 7/32    * inch /2;
shaft2_l = .220  * inch /2;
shaft2_t = .209  * inch /2;
shaft1 = 3/16    * inch /2;
shaft1_l = .188  * inch /2;
shaft1_t = .179  * inch /2;
shaft1_p = .135  * inch /2;
pin_rod =3/16    * inch /2;

// ===============
// These parameters are for a speed reducer with 
//
// 10 : 1 speed ratio
// 10 inner lobes
// 11 outer lobes
// 5 output cam holes

r_o = 50;
out_padding = 0;
n_inner_lobes = 10;
lobe_diff = 1;
thickness = 6.1;
r_pins_l = pin_rod;
r_pins_tap = shaft1_p;
n_holes = 4;
r_bolts = shaft1_l;
r_drive_shaft_t = shaft3_t; // see above
r_drive_shaft_l = shaft3_l;
output_shaft_or_t = shaft2_t; // See above
output_shaft_or_l = shaft2_l;
square_side = 10;
output_outside = false;
square_outside = true;

//  ==============
r_offset = r_o/(n_inner_lobes);
r_gen = (r_o - r_offset) / (n_inner_lobes+lobe_diff+1);
r_rotor_shaft = lobe_diff * r_gen + r_drive_shaft_l + 2;

output_ratio = output_outside ?
	(n_inner_lobes + lobe_diff) / lobe_diff:
	(n_inner_lobes) / lobe_diff;

r_holes = r_pins_l + lobe_diff*r_gen;
r_hole_center = (r_o - r_holes)/2;
driven_shaft_or = r_hole_center + r_pins_l * 2;

alpha =  2*360*$t;

// This part displays the REDUCTION RATIO ======
//
echo(str(output_ratio, " turns on the input equals 1 turn on the output."));


render=[1,1,2,2,1,1]; // normal view

//render=[1,2,0,2,0,0]; // cycloidal drive input section
//render=[0,0,2,0,0,2]; // output section only

//render=[1,2,2,2,0,2]; // panelized view combo...
//render=[0,0,2,0,0,0]; // panelized view combo...
//render=[2,2,1,0,0,0];
// 0 = hide
// 1 = display
// 2 = solo (modifications)

// 0  Inside Rotor
// 1  Outside Rotor (s - top half)
// 2  driven shaft (s)
// 3  eccentric (s)
// 4  frnt. cover
// 5  outside rotor - bottom half. (s)

function fn_current(r) = $fn > 0 ? $fn : ceil( max( min(360 / $fa, r*2*PI / $fs), 5) );

////projection(cut = true)
translate([0,0,1*thickness]) {
// This part places the INSIDE ROTOR =========
if (render[0] > 0)
{
translate([lobe_diff*r_gen*cos(alpha), lobe_diff* r_gen*sin(alpha), 0])
rotate([0,0,output_outside ? 0 : alpha / -output_ratio])
color([0.5, 0.5, 0.3])
inside_rotor(n_inner_lobes, 
				r_gen,
				r_offset-clearance_m,
				r_holes,
				n_holes,
				r_hole_center,
				r_rotor_shaft,
				thickness);
}

// This part places the OUTSIDE ROTOR =========
if (render[1] > 0 ){
rotate([0,0,output_outside ? alpha / output_ratio : 0])
color([1,0,0])
difference(){
outside_rotor(n_inner_lobes + lobe_diff,
				r_gen,
				r_offset,
				r_bolts,
				driven_shaft_or,
				thickness);
  if (render[1] > 1) 
translate([0,0,-thickness*1.1])	cylinder(r = (n_inner_lobes+lobe_diff+1)*r_gen +r_offset+1, h = thickness*1.2, center = true);
}

}

// This part places the DRIVEN SHAFT =========
//
if (render[2] > 0 )
 rotate([0,0,output_outside ? 0 : alpha / -output_ratio])
  color([0,0,1])
    driven_shaft_round(n_holes, r_hole_center, thickness, driven_shaft_or) ;

// This part places the ECCENTRIC =========
//
if (render[3] > 0)
 rotate([0,0,alpha])
 difference(){
  eccentric(thickness, lobe_diff*r_gen, r_rotor_shaft);
  if (render[3] > 1 )
  translate([0,0, (5/2 -1 )*thickness])
    cylinder(r = r_drive_shaft_t, h = 6*thickness, center = true);
  }



// This part places the COVER PLATE =========
if (render[4]>0)
 color([0.2, 0.7, 0.4, 0.6])
   cover_plate(n_inner_lobes + lobe_diff, 
 				r_gen,
				r_offset,
				r_bolts,
				r_drive_shaft_l,
				thickness);
                
        
// This part places the OUTSIDE ROTOR =========
if (render[5] > 1 ){
color([0.7, 0.2, 0.4, 0.6])
intersection(){
outside_rotor(n_inner_lobes + lobe_diff, 
				r_gen,
				r_offset,
				r_bolts,
				driven_shaft_or,
				thickness);
    
translate([0,0,-thickness*1.1])	cylinder(r = (n_inner_lobes+lobe_diff+1)*r_gen +r_offset, h = thickness*1.1, center = true);
}
}

}
//
////
////   End of Pump Demo
////===========================================

corner_r = 10;

module case_outline(side = r_o, rotates = false, layers = 1) {
	if (square_outside && !rotates)
		minkowski() {
			cube([side*2 - corner_r*2, side*2 - corner_r*2, thickness*(layers-.5)], center = true);
			cylinder(r = corner_r, h = thickness/2, center=true);
		}
	else
		cylinder(r = side, h = thickness*layers, center = true);
}

module hole_pattern(side = r_o, layers = 1) {
	if (square_outside)
		for (c=[[-1,-1],[1,-1],[1,1],[-1,1]])
			translate(c * (side - corner_r))
				cylinder(r = r_bolts, h = 2*thickness* layers, center = true);

}


//===========================================
// Cover Plate
//
module cover_plate(	n_lobes, 
				r_gen,
				w_gen,
				r_bolts,
				r_shaft,
				thickness) {

side = (n_lobes+1)*r_gen + w_gen;
translate([0,0, output_outside ? -thickness : thickness])
difference() {
	side = (n_lobes+1)*r_gen + w_gen;

	case_outline(side + out_padding, layers = output_outside ? 3 : 1);

	if (output_outside)
		translate([0,0,-thickness/2])
		cylinder(r = side + clearance_m, h = thickness*2.1);

	cylinder(
		r = output_outside ? output_shaft_or_l : r_shaft + clearance_m,
		h = 5*thickness,
		center = true);


	hole_pattern(side + out_padding, layers = output_outside ? 3 : 1);
}

}
//===========================================	


//===========================================
// Driven Shaft
//
//===========================================

module driven_shaft_round(n_pins, r_pin_center, thickness, driven_shaft_or) {
difference() {
union() {
if (output_outside)
	translate([0,0,thickness])
		difference() {
			case_outline(r_o + out_padding);
			cylinder(r = r_drive_shaft_l, h = thickness * 2, center=true);
			hole_pattern(r_o + out_padding);
		}
else
	translate([0,0,-thickness])
		difference() {
			cylinder(r = driven_shaft_or, h = thickness - clearance_m*2, center = true);
			cylinder( r=output_shaft_or_t, h= 1.1*thickness,center=true);
	}
color([1,0.2,0.8])
for  ( i = [0:n_pins-1] ) {
	rotate([0,0,360/n_pins * i])
	translate([r_pin_center,0,0])
		cylinder(r = r_pins_l, h = thickness - clearance_m*2, center = true);
}
}
for  ( i = [0:n_pins-1] ) {
	rotate([0,0,360/n_pins * i])
	translate([r_pin_center,0,0])
		cylinder(r = r_pins_tap, h = thickness *4, center = true);
}
}
}


//===========================================
// Eccentric
//
module eccentric(thickness, ecc, rotor_gear_outer_radius){
union(){
translate([0,0, 5/2*thickness])
cylinder(r = r_drive_shaft_t, h = 4*thickness, center = true);
translate([ecc, 0, 0])
	cylinder(r = 0.98 * rotor_gear_outer_radius, h = thickness - clearance_m*2, center = true);
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
	translate([0,0,clearance_m])
	hypotrochoidBandFast(n_lobes, r_gen, thickness - clearance_m*2, w_gen);
	// These are the pins
	union() {
		for ( i = [0:n_holes-1] ) {
			rotate([0, 0, i*360/n_holes])
			translate([r_hole_center, 0, 0])
				cylinder(r = r_holes + clearance_m, h = 4*thickness, center = true);
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
side = (n_lobes+1)*r_gen + w_gen;
difference() {
	case_outline(side, output_outside);

	translate([0, 0, -thickness])
		hypotrochoidBandFast(n_lobes, r_gen, 2*thickness, w_gen);

	hole_pattern(side);
}

translate([0,0,-thickness]) {
	difference() {
		case_outline(side, output_outside);

		cylinder(r = output_outside ? output_shaft_or_t : r_shaft + clearance_m,
			h = 2*thickness, center = true);

		hole_pattern(side);
	}
}

echo(str("The outside diameter of the stator is " ,((n_lobes+1)*r_gen + w_gen)*2));
}
//===========================================	

// hypotrochoid
function hypotrochoid(a, R, r) = [
	(R-r)*cos(a) + r*cos((R-r)/r*a),
	(R-r)*sin(a) - r*sin((R-r)/r*a)
];

// Now we do the offset points.  The tangent to the
// hypotrochoid is [dx/dtheta, dy/dtheta].
// We take the tangent, normalize it, rotate it, and scale it
// to get the offsets in X and Y coords.

function hypotrochoid_normal_unscaled(a, R, r) = [
	(R-r)*cos(a) - r*cos( (R-r)/r*a ) * (R-r)/r,
	(R-r)*sin(a) + r*sin( (R-r)/r*a ) * (R-r)/r
];
function hypotrochoid_normal(a, R, r) =
	hypotrochoid_normal_unscaled(a, R, r) /
	norm(hypotrochoid_normal_unscaled(a, R, r));

function hypo_array_r(lobes, R, r, offset, i, n) =
	i < 1 ?
	[] :
	concat(
		hypo_array_r(lobes, R, r, offset, i-1, n),
		[hypotrochoid(i/n*360/lobes, R, r)
		+ hypotrochoid_normal(i/n*360/lobes, R, r) * offset]
	);

function hypo_array(lobes, R, r, offset, n) =
	hypo_array_r(   lobes, R, r, offset, n - 1, n);

function hypotrochoid_points(lobes, R, r, offset) =
	concat(
		[-R/20 * [cos(360/lobes/2), sin(360/lobes/2)]],
		[hypotrochoid(0, R, r)],
		hypo_array(lobes, R, r, offset, fn_current(r)/2),
		[hypotrochoid(360/lobes, R, r)]);

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

	// set to 1 for normal size cylinders.  this will leave a tiny cusp in some cases that does
	// not blend in to cylinders.  see below for details.  make hideCuspFactor larger to scale up
	// the cylinders slightly. 1.01 seems to work OK.
	hideCuspFactor = 1.01;
// Now that we have the points, we make a polygon and extrude it.

union() {
for  ( i = [0:n-1] ) {
rotate([0,0, 360/n*i]) {

	linear_extrude(height = thickness, convexity=3)
		// the first point in the polygon is moved slightly off the origin
		 polygon(points = hypotrochoid_points(n, R, r, r_off));

	// If you look at just the wedge extruded above, without the cylinders below,
	// you can see a small cusp as the band radius gets larger.  The radius of 
	// the cylinder is manually increased a slight bit so that the cusp is contained 
	// within the cylinder.  With unlimited resolution, the cusp and cylinder would
	// blend together perfectly (I think), but this workaround is needed because
	// we are only using piecewise linear approximations to these curves.
	hypoStart = hypotrochoid(0, R, r);
	translate( [hypoStart[0], hypoStart[1], thickness/2])
		cylinder(r = hideCuspFactor*r_off, h = thickness, center = true);
	
} //end rotate

} //end for

} // end union()

} // end module hypotrochoidBandFast
//=========================================== 

