# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

all: base.stl bearing_block.stl bearings.stl bed_plate.stl belt_idler.stl carriage.stl ceramic_heater.stl cooler.stl delta.stl effector.stl gt2_belt_connector.stl heater_block.stl hotend.stl idler_assy.stl motor_mount.stl nozzle.stl rod.stl rod_support.stl

%.stl: %.scad
	openscad -D $fn=32 -m make -o $@ -d $@.deps $<
