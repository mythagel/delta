require("common")
local cam = require("cam")

-- y, x, z???

-- Drill motor mounting holes

-- 5.5 = Nema17 motor mount offset
move_to(5.5, 5.5, 0);

-- Screw through holes
cam.tool(3)
for i = 1, 4 do
    cam.peck_drill(d+1, 1, 50)
    move(31); turn(90);
end

-- Screw head clearance
cam.tool(5)
for i = 1, 4 do
    cam.peck_drill(d-2, 1, 50)
    move(31); turn(90);
end

cam.tool(18); tool_r = 8/2;
move_to(nil, nil, 1);
move_to(42/2, 42/2, nil);
move_to(nil, nil, 0);
cam.helical_plunge((16/2) - tool_r, d+1, 0.5, 50);
move_to(nil, nil, 0);

turn_to(90)
move_to(nil, nil, 1);
move_to((42/2)-((16/2)-tool_r), -tool_r-1, nil)
move_to(nil, nil, 0);
cam.plunge(7, 10);
cam.trochoidal_slot((42/2)+1, 1, (16/2)-tool_r, 200)

-- finish pass
move_to((42/2)-((16/2)-tool_r), 0, nil)
cam.rectangle((42/2), 16-(tool_r*2), -1, 50);

