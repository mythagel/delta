local cam = require("cam")

f = 200
d = 3

clear_z = 0.5;

cam.tool(18);
tool_r = 8/2;

move_to(nil, nil, 1);
move_to(42/2, 42/2, nil);
move_to(nil, nil, clear_z);
cam.helical_plunge((22/2) - tool_r, d+1, 0.25, f);
move_to(nil, nil, clear_z);

