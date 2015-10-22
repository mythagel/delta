all: motor_mount.op1.off

#motor_mount.off: motor_mount.stock.1.off
#	cp motor_mount.final... motor_mount.off

# op 1
motor_mount.op1.off: motor_mount.op1.ngc motor_mount.op1.stock
	nc_model --stock motor_mount.op1.stock < motor_mount.op1.ngc > motor_mount.op1.off
motor_mount.op1.stock: motor_mount.op0.off
	nc_transform -a 90 -y 17 < motor_mount.op0.off > motor_mount.op1.stock
motor_mount.op1.ngc: motor_mount.op1.lua
	turtlecam motor_mount.op1.lua > motor_mount.op1.ngc

# op 0
motor_mount.op0.off: motor_mount.op0.ngc motor_mount.op0.stock
	nc_model --stock motor_mount.op0.stock < motor_mount.op0.ngc > motor_mount.op0.off
motor_mount.op0.stock:
	nc_stock --box -x 42 -y 42 -z -17 > motor_mount.op0.stock
motor_mount.op0.ngc: motor_mount.op0.lua
	turtlecam motor_mount.op0.lua 0 > motor_mount.op0.ngc

