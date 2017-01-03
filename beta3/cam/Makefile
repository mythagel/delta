all: motor_mount.off lower_mount.off
clean:
	rm *.off *.ngc *.stock

# motor mount

# op 0 - front face
motor_mount.op0.ngc: motor_mount.op0.lua
	turtlecam motor_mount.op0.lua > motor_mount.op0.ngc
motor_mount.op0.stock:
	nc_stock --box -x 42 -y 42 -z -17 > motor_mount.op0.stock
motor_mount.op0.off: motor_mount.op0.ngc motor_mount.op0.stock
	nc_model --stock motor_mount.op0.stock < motor_mount.op0.ngc > motor_mount.op0.off

# op 1 - bottom face
motor_mount.op1.ngc: motor_mount.op1.lua
	turtlecam motor_mount.op1.lua > motor_mount.op1.ngc
motor_mount.op1.stock: motor_mount.op0.off
	nc_transform -a 90 -y 17 < motor_mount.op0.off > motor_mount.op1.stock
motor_mount.op1.off: motor_mount.op1.ngc motor_mount.op1.stock
	nc_model --stock motor_mount.op1.stock < motor_mount.op1.ngc > motor_mount.op1.off

# op 2 - back face
motor_mount.op2.ngc: motor_mount.op2.lua
	turtlecam motor_mount.op2.lua > motor_mount.op2.ngc
motor_mount.op2.stock: motor_mount.op1.off
	nc_transform -y -17 -a -90 -b 180 -z -17 -x 42 < motor_mount.op1.off > motor_mount.op2.stock
motor_mount.op2.off: motor_mount.op2.ngc motor_mount.op2.stock
	nc_model --stock motor_mount.op2.stock < motor_mount.op2.ngc > motor_mount.op2.off

motor_mount.off: motor_mount.op2.off
	cp motor_mount.op2.off motor_mount.off


# lower mount

# op 0 - top face
lower_mount.op0.ngc: lower_mount.op0.lua
	turtlecam lower_mount.op0.lua > lower_mount.op0.ngc
lower_mount.op0.stock:
	nc_stock --box -x 42 -y 17 -z -24 > lower_mount.op0.stock
lower_mount.op0.off: lower_mount.op0.ngc lower_mount.op0.stock
	nc_model --stock lower_mount.op0.stock < lower_mount.op0.ngc > lower_mount.op0.off

# op 1 - bottom face
lower_mount.op1.ngc: lower_mount.op1.lua
	turtlecam lower_mount.op1.lua > lower_mount.op1.ngc
lower_mount.op1.stock: lower_mount.op0.off
	nc_transform -a 90 -y 24 < lower_mount.op0.off > lower_mount.op1.stock
lower_mount.op1.off: lower_mount.op1.ngc lower_mount.op1.stock
	nc_model --stock lower_mount.op1.stock < lower_mount.op1.ngc > lower_mount.op1.off

lower_mount.off: lower_mount.op1.off
	cp lower_mount.op1.off lower_mount.off
