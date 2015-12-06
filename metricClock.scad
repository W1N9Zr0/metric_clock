use <cycloidalGear.scad>;
inch = 25.4;

tube_3_16 = axle_define(loose = .188*inch/2, tight = .179*inch/2);
tube_7_32 = axle_define(loose = .220*inch/2, tight = .209*inch/2);
tube_1_4  = axle_define(loose = .252*inch/2, tight = .242*inch/2);

// tight = hole size for tapping
pin_rod   = axle_define(loose = .188*inch/2, tight = .135*inch/2);

axle_seconds = tube_1_4;
axle_minutes = tube_7_32;
axle_idler   = axle_minutes;
axle_hours   = tube_3_16;

thickness = 6.1;
size = 50;

cycloidalDrive(
	n_inner_lobes = 10,
	lobe_diff = 1,
	n_holes = 4,

	axle_input = axle_seconds,
	axle_output = axle_idler,
	axle_pin = pin_rod,

	r_o = size,
	out_padding = 0,
	thickness = thickness,
	r_bolts = axle_loose(tube_3_16),

	output_outside = false,

	render = [1,0,2,1,1,1],
	t_ratio = 100
	);

translate([0,0,-thickness * (2) * 2])
cycloidalDrive(
	n_inner_lobes = 10,
	lobe_diff = 1,
	n_holes = 4,

	axle_input = axle_idler,
	axle_output = axle_minutes,
	axle_pin = pin_rod,

	r_o = size,
	out_padding = 0,
	thickness = thickness,
	r_bolts = axle_loose(tube_3_16),

	output_outside = false,

	render = [1,0,2,2,0,1],
	t_ratio = -10);


translate([0,0,-thickness * (2+3) * 2])
cycloidalDrive(
	n_inner_lobes = 9,
	lobe_diff = 1,
	n_holes = 4,

	axle_input = axle_minutes,
	axle_output = axle_hours,
	axle_pin = pin_rod,

	r_o = size - 5,
	out_padding = 5,
	thickness = thickness,
	r_bolts = axle_loose(tube_3_16),

	output_outside = true,
	render = [1,1,2,2,0,1],
	t_ratio = 1);
