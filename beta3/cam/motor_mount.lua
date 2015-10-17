local cam = require("cam")

cam.tool(2)

move_to(5.5, 5.5, 0);

for i = 1, 4 do
    cam.peck_drill(5, 1, 50)
    move(31); turn(90);
end
