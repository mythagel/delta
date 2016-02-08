require("common")
local cam = require("cam")

-- stock rotated to machine from base
cam.tool(8)

bearing_radius = 10/2;

move_to(0+(bearing_radius+1), d/2, 0);
cam.peck_drill(20, 1, 50);

move_to(w-(bearing_radius+1), d/2, 0);
cam.peck_drill(20, 1, 50);

