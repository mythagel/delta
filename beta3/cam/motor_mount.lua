local cam = require("cam")

d=17;
w=42;
h=42;

cam.tool(2)

-- 5.5 = Nema17 motor mount offset
move_to(5.5, 5.5, 0);

for i = 1, 4 do
    cam.peck_drill(d+1, 1, 50)
    move(31); turn(90);
end

cam.tool(8); tool_r = 8/2;
move_to(42/2, 42/2, 0);
cam.helical_plunge((16/2) - tool_r, d+1, 0.5, 50);
move_to(nil, nil, 0);

turn_to(90)
move_to((42/2)-((16/2)-tool_r), 0, nil)

for i = 1, 7 do
    cam.rectangle((42/2), 16-(tool_r*2), -1, 50);
    if i < 7 then
        cam.plunge(1, 50)
    end
end

