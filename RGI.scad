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
//maths
wall_mm = 2; //thickness = distance
dt_height = 8; //height = CE; 
dt_width = 15; //shoulder_width = AB; 
dt_narrow_width = 4; //neck_width = CD; 
shoulder_leftover = (dt_width - dt_narrow_width)/2; 
//for left and right 
cheek_length = sqrt(shoulder_leftover*shoulder_leftover +dt_height*dt_height);
theta= atan(dt_height/ shoulder_leftover);

function coordinates(wall_mm,dt_height,dt_width, dt_narrow_width, shoulder_leftover,theta)= 
let(A = [-dt_width/2, dt_height],B = [ dt_width/2, dt_height],C = [-dt_narrow_width/2, 0],D = [ dt_narrow_width/2, 0], 
//now for A', B', C', D'
//X  = X1 + (Distance * sin theta) 
//Y = Y1 + (Distance * cos theta) 
A_offset = [A[0] + wall_mm*sin(theta), A[1] + wall_mm*cos(theta)],
B_offset = [B[0] + wall_mm*sin(theta),B[1] + wall_mm*cos(theta)],
C_offset = [C[0] + wall_mm*sin(theta), C[1] + wall_mm*cos(theta)],
D_offset = [D[0] + wall_mm* sin(theta),D[1] + wall_mm*cos(theta)]
)
[A, B, C, D, A_offset,B_offset, C_offset, D_offset];

depth_mm = 50;
width_mm = 140;

dovetial_margin_mm = 0.5;
knife_margin_mm = 0.01;
wall_mm = 2;
cap_margin_mm = 4;

RENDER = 1;
RENDER_BOTTOM = 1;
RENDER_TOP = 1;
RENDER_FIT_TEST = 1;
RENDER_FIRST = 0;

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
    corner_radius_mm,
    fn = 64) 
{

    linear_extrude(height = size_z)
        offset(r = corner_radius_mm, $fn = fn)
            offset(delta = -corner_radius_mm)
                square(
                    [
                        size_x,
                        size_y
                    ],
                    center = true
                );
}

module top_end_plate(cap_height = dt_height + cap_margin_mm) {

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
            cap_height - 2*wall_mm
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

        if (RENDER_BOTTOM) {
                // Bottom cap
            color("gray")
            bottom_end_plate();
        }

        if (RENDER_FIRST) {
            // First component
            color("blue")
            generic_component(50);
        }

        // Second component
        translate([0,0,50])
        color("green")
        generic_component(30);

        
        if (RENDER_TOP) {
            // Top cap
            translate([0,0,50+30])
            color("gray")
            top_end_plate();
        }

        if (RENDER_FIT_TEST) {
            // Existing examples
            translate([141,0,0])
            color("red")
            speaker_component();
        }

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
