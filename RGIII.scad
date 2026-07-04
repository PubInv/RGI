depth_mm = 50;
width_mm = 140;
RENDER = 1;
dovetail_margin_mm = 0.5;
knife_margin_mm = 0.01;
wall_mm = 2;

module dovetail() {
    y = 10;
    y_in = 7;
    z = 5;
    points = [[0,y_in],[z,y],[z,-y],[0,-y_in]];
    rotate([0,-90,0])
    linear_extrude(height = width_mm,center = true)
    polygon(points);
}

module generic_component(height_mm) {
    difference() 
    {translate([-width_mm/2, -depth_mm/2, 0])
    cube([width_mm, depth_mm, height_mm]);
    
    translate([-width_mm/2 + wall_mm,-depth_mm/2 + wall_mm,wall_mm
        ])
        cube([width_mm - 2*wall_mm,depth_mm - 2*wall_mm, height_mm - wall_mm]);
        }
}

module speaker_component() {
    difference() {
        generic_component(50);
        translate([0,0,25])
        rotate([90,0,0])
        cylinder(100,10,10,center=true);
    }
}
module top_end_plate() {
}

module bottom_end_plate() {
}

module blank_face_plate() {
}


if (RENDER) {
    color("blue")
    generic_component(50);
    
    
    translate([0,0,50])
    color("green")
    generic_component(30);
    
    translate([150,0,0])
    color("red")
    speaker_component();
}

module female_dovetail() {

    y = 10 + dovetial_margin_mm;
    y_in = 7 + dovetial_margin_mm;
    z = 5 + dovetial_margin_mm;

    points = [
        [0-knife_margin_mm, y_in],
        [z, y],
        [z,-y],
        [0-knife_margin_mm,-y_in]
    ];

    rotate([0,-90,0])
        linear_extrude(height = width_mm + 2, center = true)
            polygon(points);
}


