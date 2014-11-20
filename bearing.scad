steel = [0.8, 0.8, 0.9];

module lm8uu() {
    module groove() {
        difference() {
            cylinder(h=1.1, r=7.5);
            cylinder(h=1.2, r=7.5-(0.7/2));
        }
    }
    color(steel) render() difference() {
        cylinder(h=24, r=7.5);
        cylinder(h=25, r=4);
        translate([0, 0, 3.25-1.1]) groove();
        translate([0, 0, 24-3.25]) groove();
    }
}

// lm8uu();