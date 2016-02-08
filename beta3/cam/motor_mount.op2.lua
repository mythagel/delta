require("common")
local cam = require("cam")

-- stock rotated to machine from back face
cam.tool(18); tool_r = 8/2;

move_to(nil, nil, 1);
move_to(42/2, 42/2, nil);
cam.plunge(1, 20);
for _ = 1, 2 do
    cam.plunge(1, 20)
    cam.polygon((22/2) - tool_r, 64, 64, true, 50)
end
