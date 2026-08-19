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
dt_width = 16; //shoulder_width = AB; 
dt_narrow_width = 10; //neck_width = CD; 
shoulder_leftover = (dt_width - dt_narrow_width)/2; 
//for left and right 
cheek_length = sqrt(shoulder_leftover*shoulder_leftover +dt_height*dt_height);
theta= atan(dt_height/ shoulder_leftover);

function coordinates(wall_mm,dt_height,dt_width, dt_narrow_width)= 
let(A = [-dt_width/2, dt_height],B = [ dt_width/2, dt_height],C = [-dt_narrow_width/2, 0],D = [ dt_narrow_width/2, 0],
 shoulder_leftover = (dt_width - dt_narrow_width)/2,
 theta= atan(dt_height/ shoulder_leftover),
 x = wall_mm/ tan(theta),
 echo("theta",theta),
//now for A', B', C', D'
//X  = X1 + (Distance * sin theta) 
//Y = Y1 + (Distance * cos theta) 
A_offset = [A[0] + wall_mm + x, A[1] - wall_mm],
B_offset = [B[0] + -(wall_mm+x),B[1] - wall_mm],
C_offset = [C[0] + wall_mm, C[1] ],
D_offset = [D[0] + -wall_mm,D[1] ]
) // TODO: Change naming of points to match traveling around a polygon
[A, B, C, D, A_offset,B_offset, C_offset, D_offset];

depth_mm = 50;
width_mm = 140;

dovetial_margin_mm = 0.5; // this is the tolerance gap between the tail and cado
knife_margin_mm = 0.01;
cap_margin_mm = 4;
corner_radius_mm = 2;
horizontal_radius_mm = 2;
fillet_fn = 64;

RENDER = 1;
RENDER_BOTTOM = 1;
RENDER_TOP = 1;
RENDER_FIT_TEST = 1;
RENDER_FIRST = 1;

USE_RENDER_KNIFE = 0;


module test_coordinates() { 
    values = 
        coordinates(wall_mm,dt_height,dt_width, dt_narrow_width);
    A = values[0];
    B = values[1];
    C = values[2];
    D = values[3];
    Ap = values[4];
    Bp = values[5];
    Cp = values[6];
    Dp = values[7];
    // , B, C, D, A_offset,B_offset, C_offset, D_offset]
    echo("Test Values");
   echo(A); 
   
   color("red")
   linear_extrude(height=1,center=true)
   polygon([A,B,D,C]);
    translate([0,0,2])
    color("green")
    linear_extrude(height=1,center=true)
    polygon([Ap,Bp,Dp,Cp]);
}

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

module horizontal_top_chamfer(
    size_x,
    size_y,
    size_z,
    radius,
    fn = 64
) {

    intersection() {


        rotate([90,0,0])
        linear_extrude(
            height = size_y,
            center = true
        )
        polygon(
            concat(

                // Bottom-left
                [
                    [-size_x/2, 0]
                ],

                // Bottom-right
                [
                    [size_x/2, 0]
                ],

                // Right vertical wall
                [
                    [size_x/2, size_z-radius]
                ],

                // Right top quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            size_x/2-radius
                                + radius*cos(i*90/(fn/4)),
                            size_z-radius
                                + radius*sin(i*90/(fn/4))
                        ]
                ],

                // Top
                [
                    [-size_x/2+radius, size_z]
                ],

                // Left top quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            -size_x/2+radius
                                - radius*sin(i*90/(fn/4)),
                            size_z-radius
                                + radius*cos(i*90/(fn/4))
                        ]
                ]
            )
        );

        rotate([90,0,90])
        linear_extrude(
            height = size_x,
            center = true
        )
        polygon(
            concat(

                // Bottom-left
                [
                    [-size_y/2, 0]
                ],

                // Bottom-right
                [
                    [size_y/2, 0]
                ],

                // Right vertical wall
                [
                    [size_y/2, size_z-radius]
                ],

                // Right top quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            size_y/2-radius
                                + radius*cos(i*90/(fn/4)),
                            size_z-radius
                                + radius*sin(i*90/(fn/4))
                        ]
                ],

                // Top
                [
                    [-size_y/2+radius, size_z]
                ],

                // Left top quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            -size_y/2+radius
                                - radius*sin(i*90/(fn/4)),
                            size_z-radius
                                + radius*cos(i*90/(fn/4))
                        ]
                ]
            )
        );
    }
}
module horizontal_bottom_chamfer(
    size_x,
    size_y,
    size_z,
    radius,
    fn = 64
) {

    intersection() {

        rotate([90,0,0])
        linear_extrude(
            height = size_y,
            center = true
        )
        polygon(
            concat(

                // Top-left
                [
                    [-size_x/2, size_z]
                ],

                // Top-right
                [
                    [size_x/2, size_z]
                ],

                // Right vertical wall
                [
                    [size_x/2, radius]
                ],

                // Right bottom quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            size_x/2-radius
                                + radius*cos(i*90/(fn/4)),
                            radius
                                - radius*sin(i*90/(fn/4))
                        ]
                ],

                // Bottom
                [
                    [-size_x/2+radius, 0]
                ],

                // Left bottom quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            -size_x/2+radius
                                - radius*sin(i*90/(fn/4)),
                            radius
                                - radius*cos(i*90/(fn/4))
                        ]
                ]
            )
        );

        rotate([90,0,90])
        linear_extrude(
            height = size_x,
            center = true
        )
        polygon(
            concat(

                // Top-left
                [
                    [-size_y/2, size_z]
                ],

                // Top-right
                [
                    [size_y/2, size_z]
                ],

                // Right vertical wall
                [
                    [size_y/2, radius]
                ],

                // Right bottom quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            size_y/2-radius
                                + radius*cos(i*90/(fn/4)),
                            radius
                                - radius*sin(i*90/(fn/4))
                        ]
                ],

                // Bottom
                [
                    [-size_y/2+radius, 0]
                ],

                // Left bottom quarter-circle
                [
                    for (i = [0:fn/4])
                        [
                            -size_y/2+radius
                                - radius*sin(i*90/(fn/4)),
                            radius
                                - radius*cos(i*90/(fn/4))
                        ]
                ]
            )
        );
    }
}
module top_end_plate(
    cap_height = dt_height + cap_margin_mm
) {

    difference() {

        intersection() {

            vertical_corner_chamfer(
                width_mm,
                depth_mm,
                cap_height,
                corner_radius_mm,
                fillet_fn
            );

            horizontal_top_chamfer(
                width_mm,
                depth_mm,
                cap_height,
                horizontal_radius_mm,
                fillet_fn
            );
        }
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

        female_dovetail_knife(
            dt_height,
            dt_width,
            dt_narrow_width
        );
        
        buckle_clip_slot();
    }
}
module bottom_end_plate() {

    cap_height = wall_mm;
    union() {

        // Rounded bottom cap body
        translate([0,0,-cap_height])
        intersection() {

            vertical_corner_chamfer(
                width_mm,
                depth_mm,
                cap_height,
                corner_radius_mm,
                fillet_fn
            );

            horizontal_bottom_chamfer(
                width_mm,
                depth_mm,
                cap_height,
                corner_radius_mm,
                fillet_fn
            );
        }

        // Male dovetail
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

// Used under Creative-Commons BY-SA from You Magazine by "amcmichael" https://youmagine.com/amcmichael
// Buckle dimensions
buckle_width  = depth_mm-12.35;
buckle_height = 5;
buckle_length = depth_mm;

// Clip dimensions
clip_length       = 20;
clip_width        = 6.35;
clip_clasp_length = 5;

// Prong dimensions
prong_length     = buckle_length - clip_length;
prong_side_width = 4;
prong_offset     = 3;

// Locking mechanism
lock_length = 10;
lock_width  = 5;
lock_offset = 2;

// Rounded edges
minkowski_rad    = 2;
minkowski_height = 0.1;

$fn = 120;


// ============================================================
// Male Buckle
// ============================================================

module male_buckle() {
    union() {
        male_prongs();
    }
}


// ============================================================
// Two Side Prongs + Locking Mechanisms
// ============================================================

module male_prongs() {

    // Lower/left prong
    translate([
        clip_length + clip_clasp_length,
        prong_offset,
        0
    ])
        cube([
            prong_length,
            prong_side_width,
            buckle_height
        ]);

    // Lower/left locking mechanism
    locking_mechanism();


    // Upper/right prong
    translate([
        clip_length + clip_clasp_length,
        buckle_width + 2*clip_width
            - prong_side_width
            - prong_offset,
        0
    ])
        cube([
            prong_length,
            prong_side_width,
            buckle_height
        ]);

    // Upper/right locking mechanism
    translate([
        0,
        buckle_width + 2*clip_width,
        0
    ])
        mirror([0, 1, 0])
            locking_mechanism();
}


// ============================================================
// Locking Mechanism
// ============================================================
module locking_mechanism() {

    vert_pos = prong_offset - 3;

    hull() {

        // Main angled locking section
        translate([
            buckle_length + clip_clasp_length - 11,
            vert_pos,
            0
        ])
            linear_extrude(buckle_height)
                polygon(points = [
                    [0, 0],
                    [lock_length, 0],
                    [lock_length + lock_offset, lock_width],
                    [lock_offset, lock_width]
                ]);

        // Rounded end
        translate([
            buckle_length + clip_clasp_length,
            6 + vert_pos,
            0
        ])
            cylinder(
                r = 2,
                h = buckle_height
            );

        // Rounded transition
        translate([
            buckle_length + clip_clasp_length,
            2.8,
            0
        ])
            rotate([0, 0, 60])
                scale([1, 0.5])
                    linear_extrude(height = buckle_height)
                        circle(d = 6);
    }
}

translate([
    (buckle_length/2)-clip_length,
    -(buckle_width + 2*clip_width)/2,
    81.5
])
    male_buckle();

// ============================================================
// Buckle clip slot
// ============================================================
module buckle_clip_slot(
    length = lock_length+.5,
    width = buckle_width + 2*clip_width,
    height = buckle_height + .5
) {

    translate([(buckle_length),
        -(buckle_width + 2*clip_width)/2,
        +1
    ])
        cube([
            length,
            width,
            height
        ]);
}
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

//        // Second component
//        translate([0,0,50])
//        color("green")
//        generic_component(30);

        
        if (RENDER_TOP) {
            // Top cap
            translate([0,0,50+30])
            color("gray")
            top_end_plate();
        }

        if (RENDER_FIT_TEST) {
            // Existing examples
 //           speaker_component();
            test_coordinates();
        }

//        color("green")
//        translate([0,40,0])
//        dove_tail_shell(dt_height+3);
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
