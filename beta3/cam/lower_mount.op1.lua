require("common")
local cam = require("cam")

-- stock rotated to machine from top
cam.tool(14); tool_r = 3.9875/2;

move_to(nil, nil, 1)

move_to((w/2 - 16/2)+tool_r, 24+tool_r, nil)
move_to(nil, nil, 0)

cam.plunge(7, 10)
turn(-90)

pocket_d = 16-(tool_r*2);
pocket_w = 16-tool_r;

cam.rectangle(pocket_w, pocket_d, 1, 20);
cam.square_zag(pocket_d/6, pocket_w, 6, 1, 20)
--turn(90)
