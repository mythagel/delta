local cam = require("cam")

-- Drill motor mounting holes

-- 5.5 = Nema17 motor mount offset
nema17_offset = (42 - 31) /2
move_to(nil, nil, 1);
move_to(nema17_offset, nema17_offset, nil);
move_to(nil, nil, 0.5);


f = 50
d = 3

-- Screw through holes
cam.tool(3)
for i = 1, 4 do
    cam.peck_drill(d+1, 1, f)
    move(31); turn(90);
end

