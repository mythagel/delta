steel = [0.8, 0.8, 0.9];

module rod(l, r) {
    color(steel) render() union() {
        translate([0, 0, l-1]) cylinder(r1=r, r2=r-1, h=1);
        translate([0, 0, 1]) cylinder(r=r, h=l-2);
        cylinder(r1=r-1, r2=r, h=1);
    }
}

// rod(300, 4);