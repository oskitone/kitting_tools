module tape_comb(
    count = 20,

    width = 20,
    height = 2,

    plot = 5,

    tine = 2,

    tolerance = .1,
    clearance = 1,

    engraving_depth = 1,

    2d_projection = false,

    visualize_leads = true,
    lead_diameter = .75
) {
    e = .0319;

    length = count * plot;

    module _leads(
        _width = width,
        _length = lead_diameter,
        _height = lead_diameter,
        x = 0
    ) {
        z = (height - _height) / 2;

        for (i = [0 : count - 1]) {
            y = i * plot + (plot - _length) / 2;

            translate([x, y, z]) {
                cube([_width, _length, _height]);
            }
        }
    }

    module _engraving(projection = true) {
        x = (width - (tine + clearance)) / 2;
        z = projection ? -e : engraving_depth;

        translate([x, length / 2, z]) {
            rotate([0, 0, 90]) {
                linear_extrude(projection ? height + e * 2 : engraving_depth + e) {
                    offset(delta = tolerance) text(
                        font="Orbitron",
                        text = str(count, "x", plot),
                        halign = "center",
                        valign = "center"
                    );
                }
            }
        }
    }

    module _output() {
        difference() {
            cube([width, length, height]);

            _leads(
                _width = tine + clearance,
                _length = lead_diameter + clearance * 2,
                _height = height + 1,
                x = width - tine - clearance
            );

            _engraving();
        }
    }

    if (2d_projection) {
        projection() _output();
    } else {
        _output();

        if (visualize_leads) {
            % # _leads(x = width - tine);
        }
    }
}

tape_comb(2d_projection = 0);
