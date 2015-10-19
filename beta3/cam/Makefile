all: motor_mount.off

motor_mount.stock.off:
	nc_stock --box -x 42 -y 42 -z -17 > motor_mount.stock.off

motor_mount.off: motor_mount.lua motor_mount.stock.off
	turtlecam motor_mount.lua | nc_model --stock motor_mount.stock.off > motor_mount.off
