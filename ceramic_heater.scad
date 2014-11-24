steel = [0.8, 0.8, 0.9];

module ceramic_heater() {
    color(steel) render() union() {
        cylinder(r=6, h=23);
    }
}

ceramic_heater();
