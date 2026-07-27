

// Put Affero License here
// TODO FOR JAHNAVI:
// 1. Fix the narrowness in the wall thickness
// 2. Add a slot on top where the mail dovetail is.
// 3. Make all the dovetail consistently resizable (make sure it all fits)

// TODO:
// 1) Add Licence premable
// 1.5) Make boxes instead of solid cubes - Jahanavi (DONE)
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
wall_mm = 2;
cap_margin = 3;

dt_height = 8; // Height is difference from flat top to base.
dt_width = 10;
dt_narrow_width = 4;


USE_RENDER_KNIFE = 0;

module dovetail(dt_h = dt_height,dt_w = dt_width, dt_n_w = dt_narrow_width) {
    y = dt_w;
    y_in = dt_n_w;
    z = dt_h;
    points = [[0,y_in],[z,y],[z,-y],[0,-y_in]];
    rotate([0,-90,0])
    linear_extrude(height = width_mm,center = true)
    polygon(points);
}


module female_dovetail_knife(dt_h = dt_height,dt_w = dt_width, dt_n_w = dt_narrow_width) {

    y = dt_w + dovetial_margin_mm;
    y_in = dt_n_w + dovetial_margin_mm;
    z = dt_h + dovetial_margin_mm;

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

module dove_tail_shell(dt_h = dt_height,dt_w = dt_width, dt_n_w = dt_narrow_width) {
    y = dt_w + wall_mm;
    y_in = dt_n_w + wall_mm;
    z = dt_h + wall_mm;

    points = [
       [0, y_in],
       [z, y],
       [z,-y],
       [0,-y_in]
    ];
    
    rotate([0,-90,0])
    difference() {
        linear_extrude(height = width_mm, center = true)
        polygon(points);
        rotate([0,90,0])
        female_dovetail_knife(dt_h,dt_w,dt_n_w);
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

// ---------------------------------------------------------
// Chamfered exterior corners
//
// Chamfers the 4 vertical outside corners only.
// Top and bottom faces remain square for mating.
// ---------------------------------------------------------
module vertical_corner_chamfer(
    size_x,
    size_y,
    size_z,
    chamfer_mm
) {

    x = size_x / 2;
    y = size_y / 2;
    c = chamfer_mm;

    points = [
        // Bottom
        [-x+c,-y,0],
        [ x-c,-y,0],
        [ x,-y+c,0],
        [ x,y-c,0],
        [ x-c,y,0],
        [-x+c,y,0],
        [-x,y-c,0],
        [-x,-y+c,0],

        // Top
        [-x+c,-y,size_z],
        [ x-c,-y,size_z],
        [ x,-y+c,size_z],
        [ x,y-c,size_z],
        [ x-c,y,size_z],
        [-x+c,y,size_z],
        [-x,y-c,size_z],
        [-x,-y+c,size_z]
    ];

    faces = [

        // Bottom
        [0,1,2,3,4,5,6,7],

        // Outside walls
        [0,8,9,1],
        [1,9,10,2],
        [2,10,11,3],
        [3,11,12,4],
        [4,12,13,5],
        [5,13,14,6],
        [6,14,15,7],
        [7,15,8,0],

        // Top
        [8,15,14,13,12,11,10,9]
    ];

    polyhedron(
        points = points,
        faces = faces,
        convexity = 10
    );
}



module top_end_plate(cap_height = dt_height + cap_margin) {

    chamfer_mm = 2;

    difference() {

        
        // Main outer body
        // Vertical outside corners are chamfered.
        // Bottom mating face remains square.
       
        vertical_corner_chamfer(
            width_mm,
            depth_mm,
            cap_height,
            chamfer_mm
        );

  
        // Interior cavity
        // Leaves 2 mm walls on the sides
        // and a 2 mm solid top surface
        translate([
            -width_mm/2 + wall_mm,
            -depth_mm/2 + wall_mm,
            wall_mm
        ])
        cube([
            width_mm - 2*wall_mm,
            depth_mm - 2*wall_mm,
            cap_height - wall_mm
        ]);
        
        // Female dovetail socket
        female_dovetail_knife(
            dt_height,
            dt_width,
            dt_narrow_width
        );
    }

   
    // Female dovetail shell
 
    dove_tail_shell(dt_height);
}

module bottom_end_plate() {

    cap_height = wall_mm;
    chamfer_mm = 2;

    union() {

        // 
        // Bottom cap with chamfered vertical outside corners
        // 
        translate([0,0,-cap_height])
        vertical_corner_chamfer(
            width_mm,
            depth_mm,
            cap_height,
            chamfer_mm
        );

        // 
        // Male dovetail
        //
        dovetail(
            dt_height,
            dt_width,
            dt_narrow_width
        );
    }
}

module blank_face_plate() {
}




module generic_component (height_mm) {

    difference() {

        // Main body with chamfered vertical outside corners
        vertical_corner_chamfer(
            width_mm,
            depth_mm,
            height_mm,
            2
        );

        // Interior cavity
        translate([
            -width_mm/2 + wall_mm,
            -depth_mm/2 + wall_mm,
            wall_mm
        ])
        cube([
            width_mm - 2*wall_mm,
            depth_mm - 2*wall_mm,
            height_mm - 2*wall_mm
        ]);

        // Female dovetail socket
        female_dovetail_knife(
            dt_height,
            dt_width,
            dt_narrow_width
        );
    }

    // Female dovetail shell
    dove_tail_shell(dt_height);

    // Male dovetail on top
    translate([0,0,height_mm])
        dove_tail_shell(
            dt_height+1,
            dt_width+1,
            dt_narrow_width+1
        );
}



// Example: Create a working system by composing components
module render() {
    if (RENDER) {       
                // Bottom cap
        color("gray")
        bottom_end_plate();

        // First component
        color("blue")
        generic_component(50);

        // Second component
        translate([0,0,50])
        color("green")
        generic_component(30);

        // Top cap
        translate([0,0,50+30
        ])
        color("gray")
        top_end_plate();

        // Existing examples
        translate([150,0,0])
        color("red")
        speaker_component();

        color("green")
        translate([0,40,0])
        dove_tail_shell(dt_height+3);
    }
}

if (USE_RENDER_KNIFE) {
    difference() {
        render();
        translate([300/2,0,0])
        cube([300,300,300],center=true);
    }
} else {
    render();
}
