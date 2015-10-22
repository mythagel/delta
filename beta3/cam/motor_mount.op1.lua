require("common")
local cam = require("cam")

-- stock rotated to machine from base
cam.tool(8)

move_to(0+((15/2)+1), d/2, 0);
cam.peck_drill(20, 1, 50);

move_to(w-((15/2)+1), d/2, 0);
cam.peck_drill(20, 1, 50);

