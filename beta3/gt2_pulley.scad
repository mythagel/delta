include <Pulley_T-MXL-XL-HTD-GT2_N-tooth.scad>

teeth = 16;
profile = 12;
motor_shaft = 5;
retainer = 1;
pulley_t_ht = 7.5;
pulley_b_ht = 7.5;
pulley_b_dia = 15;

module gt2_pulley() {
	pulley ( "GT2 2mm" , GT2_2mm_pulley_dia , 0.764 , 1.494 );
}

gt2_pulley();