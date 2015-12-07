use <cycloidalGear.scad>;
inch = 25.4;

tube_3_16 = axle_define(loose = .188*inch/2, tight = .179*inch/2);
tube_7_32 = axle_define(loose = .220*inch/2, tight = .209*inch/2);
tube_1_4  = axle_define(loose = .252*inch/2, tight = .242*inch/2);

// tight = hole size for tapping
pin_rod   = axle_define(loose = .188*inch/2, tight = .135*inch/2);

axle_seconds = tube_3_16;
axle_minutes = tube_7_32;
axle_idler   = axle_minutes;
axle_hours   = tube_1_4;
// #10-24 threaded rod has similar nominal
rod_r = (axle_tight(tube_3_16) + axle_loose(tube_3_16))/2;

thickness = 6.1;
size = 50;
$clearance_m = .2;

//$fn = 100;
$fs = .2;
$fa = 1;

layer_n = 0;
slice = false;

if (slice) {
	projection(cut = true)
	translate([0, 0, (layer_n - 1) * thickness])
	metricClock(slice);
}
else {
	//intersection() {
		metricClock();
		//translate([0,100,0])cube([200,200,200], center = true);
	//}
}

module metricClock(slice = false)
{

// seconds to 10s of seconds
if (!slice || layer_n >= 0 && layer_n < 3)
cycloidalDrive(
	n_inner_lobes = 10,
	lobe_diff = 1,
	n_holes = 4,
	output_outside = false,

	axle_input = axle_seconds,
	axle_output = axle_idler,
	axle_pin = pin_rod,

	r_o = size,
	out_padding = 0,
	thickness = thickness,
	r_bolts = rod_r,

	render = slice ? [1,1,2,2,1] : [1,1,1,1,1],
	t_ratio = 100
	);

// 10s of seconds to minutes
if (!slice || layer_n >= 3 && layer_n < 5)
translate([0,0,-thickness * (2)])
cycloidalDrive(
	n_inner_lobes = 10,
	lobe_diff = 1,
	n_holes = 4,
	output_outside = false,

	axle_input = axle_idler,
	axle_output = axle_minutes,
	axle_pin = pin_rod,

	r_o = size,
	out_padding = 0,
	thickness = thickness,
	r_bolts = rod_r,

	render = slice ? [1,1,2,2,0] : [1,1,1,1,0],
	t_ratio = -10);

// minutes to hours
if (!slice || layer_n >= 5)
translate([0,0,-thickness * (2+3)])
cycloidalDrive(
	n_inner_lobes = 9,
	lobe_diff = 1,
	n_holes = 4,
	output_outside = true,

	axle_input = axle_minutes,
	axle_output = axle_hours,
	axle_pin = pin_rod,

	r_o = size - 5,
	out_padding = 5,
	thickness = thickness,
	r_bolts = rod_r,

	render = slice ? [1,1,2,2,1] : [1,1,1,1,1],
	t_ratio = 1);
}
