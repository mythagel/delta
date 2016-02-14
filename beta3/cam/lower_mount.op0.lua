require("common")
local cam = require("cam")

-- stock rotated to machine from top
cam.tool(8)

bearing_radius = 10/2;

move_to(nil, nil, 1)

move_to(0+(bearing_radius+1), d/2, nil);
move_to(nil, nil, 0)
cam.peck_drill(20, 1, 50);

move_to(w-(bearing_radius+1), d/2, nil);
move_to(nil, nil, 0)
cam.peck_drill(20, 1, 50);


