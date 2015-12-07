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


function axle_define(loose, tight) = [loose, tight];
function axle_loose(axle) = axle[0];
function axle_tight(axle) = axle[1];

$clearance_m = $clearance_m ? $clearance_m : 0.2;

function fn_current(r) = $fn > 0 ? $fn : ceil( max( min(360 / $fa, r*2*PI / $fs), 5) );

// render array index
// 0  Inside Rotor
// 1  Outside Rotor (s - top half)
// 2  driven shaft (s)
// 3  eccentric (s)
// 4  frnt. cover

// render array value
// 0 = hide
// 1 = display
// 2 = solo (modifications)

module cycloidalDrive(
	n_inner_lobes = 8,
	lobe_diff = 1,
	n_holes = 4,

	axle_input = axle_define(loose = 4/2, tight = 3.5/2),
	axle_output = axle_define(loose = 5/2, tight = 4.5/2),
	axle_pin = axle_define(loose = 4/2, tight = 3.5/2),

	r_o = 50,
	out_padding = 0,
	thickness = 6.1,
	r_bolts = 1,

	output_outside = false,
	render = [1,1,1,1,1],
	t_ratio = 1
) {

//  ==============
hypo_offset = r_o/(n_inner_lobes);
hypo_r = (r_o - hypo_offset) / (n_inner_lobes+lobe_diff+1);
eccentric_offset = lobe_diff * hypo_r;
eccentric_r = eccentric_offset + axle_loose(axle_input) + 2;

output_ratio = output_outside ?
	(n_inner_lobes + lobe_diff) / lobe_diff:
	(n_inner_lobes) / lobe_diff;

r_holes = eccentric_offset + axle_loose(axle_pin);
r_hole_center = (r_o - r_holes)/2;
pin_plate_r = r_hole_center + axle_loose(axle_pin) * 2;

alpha =  2*360*$t * t_ratio;

// This part displays the REDUCTION RATIO ======
//
echo(str(output_ratio, " turns on the input equals 1 turn on the output."));


scale([1,1,thickness]) {

// This part places the INSIDE ROTOR =========
if (render[0] > 0) color([0.5, 0.5, 0.3])
{
	translate(eccentric_offset * [cos(alpha), sin(alpha)])
	rotate(output_outside ? 0 : alpha / -output_ratio)
	scale([1,1, 1 - 2*$clearance_m/thickness])
	inside_rotor(n_inner_lobes,
					hypo_r,
					hypo_offset - $clearance_m,
					r_holes,
					n_holes,
					r_hole_center,
					eccentric_r + $clearance_m);
}


// This part places the pins =========
if (render[2] > 0 ) color([0,0,1]) {
	rotate(output_outside ? 0 : alpha / -output_ratio)
	difference() {
		union() {
			if (render[2] < 2) // render pins
				translate([0,0,output_outside ? 1 : -1] * $clearance_m/thickness)
				pin_pattern(n_holes, r_hole_center)
				cylinder(r = axle_loose(axle_pin), h = 1, center = true);

			if (output_outside) {
				// stationary pin plate above
				translate([0,0,1]) difference() {
					case_outline(r_o + out_padding, r_bolts);
					cylinder(r = axle_loose(axle_input), h = 2, center=true);
				}
			} else {
				// moving pin plate below
				translate([0,0,-1]) difference() {
					cylinder(r = pin_plate_r, h = 1 - 2 * $clearance_m/thickness, center = true);
					cylinder(r = axle_tight(axle_output), h= 3, center=true);
				}
			}
		}
		if (render[2] >= 2) // render holes for pins
			pin_pattern(n_holes, r_hole_center)
			cylinder(r = axle_tight(axle_pin), h = 4, center = true);
	}
}

// This part places the OUTSIDE ROTOR =========
if (render[1] > 0 ) color([1,0,0]) {
	rotate(output_outside ? alpha / output_ratio : 0)
	difference(){
		outside_rotor(n_inner_lobes + lobe_diff,
						hypo_r,
						hypo_offset,
						r_bolts,
						pin_plate_r,
						axle_output,
						output_outside);
		if (render[1] > 1)
			translate([0,0,-1])	cylinder(r = r_o+1, h = 2, center = true);
	}
}

// This part places the ECCENTRIC =========
//
if (render[3] > 0) {
	rotate(alpha)
	difference(){
		union(){
			translate([eccentric_offset, 0, 0])
				cylinder(r = eccentric_r, h = 1, center = true);
			if (render[3] < 2)
				translate([0,0,.5])
				cylinder(r = axle_tight(axle_input), h = 2-2*$clearance_m/thickness, center = true);
		}
		if (render[3] > 1 )
			cylinder(r = axle_tight(axle_input), h = 3, center = true);
	}

}



// This part places the COVER PLATE =========
if (render[4]>0) color([0.2, 0.7, 0.4, 0.6]) {
	translate([0,0, output_outside ? -1 : 1])
	difference() {
		case_outline(r_o + out_padding, r_bolts, layers = output_outside ? 3 : 1);

		if (output_outside)
			translate([0,0,-1/2])
			cylinder(r = r_o + $clearance_m, h = 2.1);

		cylinder(
			r = axle_loose(output_outside ? axle_output : axle_input),
			h = 5,
			center = true);
	}
}
}

}
//
////
////   End of Pump Demo
////===========================================

corner_r = 10;

module case_outline(side, r_bolts, layers = 1) {
	difference() {
		minkowski() {
			cube([side*2 - corner_r*2, side*2 - corner_r*2, layers-.5], center = true);
			cylinder(r = corner_r, h = 1/2, center=true);
		}

		for (x=[-1,1], y=[-1,1])
			translate([x,y] * (side - corner_r))
				cylinder(r = r_bolts, h = 2* layers, center = true);
	}
}


module pin_pattern(n_pins, r_pin_center) {
	for (i = [0 : n_pins-1]) rotate(i/n_pins * 360)
		translate([r_pin_center,0]) children();
}

//===========================================
// Inside Rotor
//
module inside_rotor(	n_lobes, 
				hypo_r,
				hypo_offset,
				r_holes,
				n_pins,
				r_pin_center,
				r_eccentric) {
translate([0, 0, -1/2])
difference(){
	hypotrochoidBandFast(n_lobes, hypo_r, hypo_offset);
	// These are the pins
	pin_pattern(n_pins, r_pin_center)
		cylinder(r = r_holes + $clearance_m, h = 4, center = true);

	cylinder(r = r_eccentric, h = 4, center = true);
}
}
//===========================================			


//===========================================
// Outside Rotor
//
module outside_rotor(	n_lobes, 
				hypo_r,
				hypo_offset,
				r_bolts,
				r_output_plate,
				axle_output,
				output_outside) {
side = (n_lobes+1)*hypo_r + hypo_offset;
difference() {
	if (output_outside)
		cylinder(r = side, h = 1, center = true);
	else
		case_outline(side, r_bolts);

	translate([0, 0, -1]) scale([1,1,2])
		hypotrochoidBandFast(n_lobes, hypo_r, hypo_offset);
}

translate([0,0,-1]) {
	difference() {
		if (output_outside)
			cylinder(r = side, h = 1, center = true);
		else
			case_outline(side, r_bolts);

		cylinder(r = output_outside ? axle_tight(axle_output) : r_output_plate + $clearance_m,
			h = 2, center = true);
	}
}

echo(str("The outside diameter of the stator is " ,((n_lobes+1)*hypo_r + hypo_offset)*2));
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
// r_off 	is the distance that the envelope is offset from the base hypocycloid
// 
// When r_off = zero the output is the same as a hypocycloid.
//
module hypotrochoidBandFast(n, r, r_off) {

	R = r*n;

	// set to 1 for normal size cylinders.  this will leave a tiny cusp in some cases that does
	// not blend in to cylinders.  see below for details.  make hideCuspFactor larger to scale up
	// the cylinders slightly. 1.01 seems to work OK.
	hideCuspFactor = 1.001;

union() {
for  ( i = [0:n-1] ) {
rotate([0,0, 360/n*i]) {

	linear_extrude(height = 1, convexity=3)
		polygon(points = hypotrochoid_points(n, R, r, r_off));

	hypoStart = hypotrochoid(0, R, r);
	translate( [hypoStart[0], hypoStart[1], 1/2])
		cylinder(r = hideCuspFactor*r_off, h = 1, center = true);
	
} //end rotate

} //end for

} // end union()

} // end module hypotrochoidBandFast
//=========================================== 

cycloidalDrive();
