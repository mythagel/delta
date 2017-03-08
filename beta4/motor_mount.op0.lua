local cam = require("cam")

f = 200
d = 3

clear_z = 0.5;

cam.tool(4);
tool_r = 4/2;

if argv[2] == "left" then
    dir = -1
else
    dir = 1
end

move_to(nil, nil, 1);
move_to(42/2 * dir, 42/2, nil);
move_to(nil, nil, clear_z);
cam.helical_plunge((22/2) - tool_r, d+1, 1, f);
move_to(nil, nil, clear_z);

