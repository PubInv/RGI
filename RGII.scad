

// Put Affero License here

// TODO:
// 1) Add Licence premable
// 1.5) Make all components empty boxes instead of solid cubes - Jahanavi
// 2) Cut the female dovetial -- 
// 3) Add parameterizes margins (0.5 mm)
// 4) Make it two dovetails instead of 1
// 5) Add an empty "chamber" for the cables
// 6) Add a "bottom plate" that does not have a female dovetail
// 7) Add a "top plate" that does not have a male dovetail
// 8) Add a "generic face plate" as a union-izable module
// 9) Add threaded rod holes


// Initial size configuration

depth_mm = 50;
width_mm = 140;
RENDER = 1;
dovetial_margin_mm = 0.5;
knife_margin_mm = 0.01;

module dovetail() {
    y = 10;
    y_in = 7;
    z = 5;
    points = [[0,y_in],[z,y],[z,-y],[0,-y_in]];
    rotate([0,-90,0])
    linear_extrude(height = width_mm,center = true)
    polygon(points);
}

// This will have a male top and female bottom dovetail
// componets facial geometry is centered iin x and y, but 
// bottom is at origin in z

module generic_component(height_mm) {
    difference() 
    {translate([-width_mm/2, -depth_mm/2, 0])
    cube([width_mm, depth_mm, height_mm]);
    
    translate([-width_mm/2 + wall_mm,-depth_mm/2 + wall_mm,wall_mm
        ])
        cube([width_mm - 2*wall_mm,depth_mm - 2*wall_mm, height_mm - wall_mm]);
        }
}

module generic_component(height_mm) {
    translate([-width_mm/2,-depth_mm/2,0])
    cube([width_mm,depth_mm, height_mm]);
    color("yellow");
    translate([0,0,height_mm])
    dovetail();
    
    // TODO: Cut away interior
    
    // Add a femaile dovetail
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


// Example: Create a working system by composing components
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

module generic_component (height_mm) {

    difference() {

        // Main body
        translate([-width_mm/2,-depth_mm/2,0])
            cube([width_mm, depth_mm, height_mm]);

        // Female dovetail socket
            female_dovetail();
    }

    // Male dovetail on top
    translate([0,0,height_mm])
        dovetail();
}