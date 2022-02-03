module tape_comb(
    count = 20,

    marker_cadence = 5,
    marker_engraving_diameter = 2,

    width = 20,
    height = 1.6,

    plot = 5,

    tine = 2,

    tolerance = .1,
    clearance = .5,

    engraving_depth = 1,
    engraving_clearance = 2,

    2d_projection = false,

    visualize_leads = true,
    lead_diameter = .75
) {
    e = .0319;

    length_between_leads = plot - lead_diameter;
    end_length = length_between_leads / 2 - clearance;

    length = count * plot + end_length * 2;

    engraving_z = 2d_projection ? -e : engraving_depth;
    _engraving_depth = 2d_projection ? height + e * 2 : engraving_depth + e;

    module _leads(
        _width = width,
        _length = lead_diameter,
        _height = lead_diameter,
        x = 0,
        range = [0 : count - 1]
    ) {
        z = (height - _height) / 2;

        for (i = range) {
            y = i * plot + (plot - _length) / 2 + end_length;

            translate([x, y, z]) {
                cube([_width, _length, _height]);

                translate([0, _length / 2, 0]) {
                    cylinder(
                        d = _length,
                        h = _height,
                        $fn = 4
                    );
                }
            }
        }
    }

    module _engraving() {
        available_width = width
            - (tine + marker_engraving_diameter + engraving_clearance);
        size = 6;
        x = engraving_clearance + size / 2;

        translate([x, length - engraving_clearance, engraving_z]) {
            rotate([0, 0, -90]) {
                linear_extrude(_engraving_depth) {
                    offset(delta = tolerance) text(
                        font="Orbitron",
                        text = str(count, "x", plot, "mm"),
                        size = size,
                        halign = "left",
                        valign = "center"
                    );
                }
            }
        }
    }

    module _markers() {
        x = width - (marker_engraving_diameter / 2 + tine
            + engraving_clearance);

        for (i = [1 : count - 1]) {
            if (i % marker_cadence == 0) {
                y = length - i * plot - end_length;

                translate([x, y, engraving_z]) {
                    cylinder(
                        d = marker_engraving_diameter + tolerance * 2,
                        h = _engraving_depth,
                        $fn = 6
                    );
                }
            }
        }
    }

    module _output() {
        difference() {
            cube([width, length, height]);

            _leads(
                _width = tine + tolerance + e,
                _length = lead_diameter + (clearance + tolerance) * 2,
                _height = height + 1,
                x = width - tine - tolerance
            );

            _engraving();

            _markers();
        }
    }

    if (2d_projection) {
        projection() _output();
    } else {
        _output();

        if (visualize_leads) {
            % # _leads(
                x = width - tine,
                range = [-1 : count]
            );
        }
    }
}

tape_comb(
    /* count = 21,
    marker_cadence = 7, */
    2d_projection = false
);
