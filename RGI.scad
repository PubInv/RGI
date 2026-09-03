include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// Put Affero License here

height= 100;
dt_width = 15;
dt_height = 8;
dt_knife_width= 11;




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

// dt_height = 8; //height = CE; 
// dt_width = 16; //shoulder_width = AB; 
dt_narrow_width = 10; //neck_width = CD; 
shoulder_leftover = (dt_width - dt_narrow_width)/2; 
//for left and right 
cheek_length = sqrt(shoulder_leftover*shoulder_leftover +dt_height*dt_height);
theta= atan(dt_height/ shoulder_leftover);

function coordinates(wall_mm,dt_height,dt_width, dt_narrow_width) = let(A = [-dt_width/2, dt_height],B = [ dt_width/2, dt_height],C = [-dt_narrow_width/2, 0],D = [ dt_narrow_width/2, 0],
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
)
[A, B, C, D, A_offset,B_offset, C_offset, D_offset];


depth_mm = 50;
width_mm = 140;

dovetail_margin_mm = 0.5; // this is the tolerance gap between the tail and cado
knife_margin_mm = 0.01;
cap_margin_mm = 4;
corner_radius_mm = 2;
horizontal_radius_mm = 2;
fillet_fn = 64;

RENDER = 1;
RENDER_BOTTOM = 0;
RENDER_TOP = 1;
RENDER_FIT_TEST = 1;
RENDER_FIRST = 0;
RENDER_SECOND = 1;
RENDER_MALE_BUCKLE=0;
RENDER_FEMALE_BUCKLE=0;
USE_RENDER_KNIFE = 0;
 
heightx= 100;

// TODO for James
module BOSL2_socket(dt_width, height, dt_height) {

    cuboid([0, 0, 0]) {
        tag("remove")
            attach(FRONT)
                dovetail(
                    "female",
                    slide = 120,
                    width = dt_width,
                    height = dt_height,
                    angle = 30,
                    $slop = dovetail_margin_mm
                );
    }
}

module bottom_plate(dt_width, height, dt_height) {

    translate([0, -wall_mm/2,-10])
    diff()
  cuboid([0,0,0]){
    attach(BACK) dovetail("male", slide=120, width=dt_width, height=dt_height, angle=30, $slop=dovetail_margin_mm);
    tag("remove")attach(BACK) rotate([180,0,0]) dovetail("female", slide=120, width=dt_knife_width, height=dt_height-1.5, angle=30, $slop=dovetail_margin_mm);
  }
}

module cut_bottom_plate() {
    slit_width = 4;
    slit_margin = 20;
    difference() {
        bottom_plate(dt_width,height,dt_height);
        cube([slit_width,50,height-slit_margin*2],center = true);
    }
}
// Top plate fits into the socket of the bottom plate
module top_plate(dt_width,height,dt_height) { 
echo("height",height);
echo("dt_width",dt_width);
translate([0,-wall_mm/2,0])
diff()
  cuboid([50,wall_mm,height]){
    attach(BACK) dovetail("male", slide=height, width=dt_width, height=dt_height, angle=30);
    tag("remove")attach(BACK) rotate([180,0,0]) dovetail("female", slide=height, width=dt_knife_width, height=dt_height-1.5, angle=30);
  }
}
  
module cut_top_plate() {
    slit_width = 4;
    slit_margin = 20;
    difference() {
        top_plate(dt_width,height,dt_height);
        cube([slit_width,50,height-slit_margin*2],center = true);
    }
}

cut_top_plate();


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

module pi_dovetail(dt_h = dt_height,dt_w = dt_width, dt_n_w = dt_narrow_width) {
    y = dt_w;
    y_in = dt_n_w;
    z = dt_h;
    points = [[0,y_in],[z,y],[z,-y],[0,-y_in]];
    rotate([0,-90,0])
    linear_extrude(height = width_mm,center = true)
    polygon(points);
}


module female_dovetail_knife(dt_h = dt_height,dt_w = dt_width, dt_n_w = dt_narrow_width) {

    y = dt_w + dovetail_margin_mm;
    y_in = dt_n_w + dovetail_margin_mm;
    z = dt_h + dovetail_margin_mm;

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
    translate([-prong_length/2,0,0])
    rotate([0,-90,0])
    difference() {
        linear_extrude(height = width_mm-prong_length-clip_clasp_length, center = true)
        polygon(points);
        rotate([0,90,0])
        female_dovetail_knife(dt_h,dt_w,dt_n_w);
    }
}


// Used under Creative-Commons BY-SA from You Magazine by "amcmichael"
// https://youmagine.com/amcmichael

// ============================================================
// Clip Dimensions
// ============================================================

clip_length       = 24; 
clip_width        = 6.35; // extra material added to side of clip 
clip_clasp_length = 5;

// ============================================================
// Buckle Dimensions
// ============================================================

buckle_width  = depth_mm-2*clip_width; // Buckle dimension based on the inner width of the strap connector
buckle_height = 10;
buckle_length = 50;


// ============================================================
// Prong Dimensions
// ============================================================

prong_length       = buckle_length - clip_length;
prong_center_width = 6; // width of the center prong
prong_center_tap   = prong_center_width/2;
prong_side_width   = 4; // width of the side prongs
prong_offset       = 3; // difference between prong location and overall buckle width


// ============================================================
// Locking Mechanism
// ============================================================

lock_length = 10;
lock_width  = 5;
lock_offset = 2; // the latching angle (decrease for smaller locking angle)


// ============================================================
// Casing Dimensions
// ============================================================

case_thickness     = 2;
sf                 = 1;
track_thickness    = 2;
track_height       = 2;
wiggle_room_factor = 1.2;


// ============================================================
// Rounded Edges
// ============================================================

minkowski_rad    = 2;
minkowski_height = 0.1;

$fn = 120;


module female_buckle(){
    
    difference(){
        
        union(){
            female_clip();
            female_casing();
        }        
  
        // Locking mechanism access ellipse 1
        translate([
            lock_length + lock_offset + clip_length/2,
            0,
            -2
        ])
            scale([1, 0.5])            
                linear_extrude(height = buckle_height*2)
                    circle(d = 20);
        
        // Locking mechanism access ellipse 2        
        translate([
            lock_length + lock_offset + clip_length/2,
            buckle_width + 2*(clip_width-minkowski_rad)
                + 2*sf + case_thickness,
            -2
        ])
            scale([1, 0.5])
                linear_extrude(height = buckle_height*2)
                    circle(d = 20);
    }
}


module female_clip(){    
    
    // Back
    minkowski(){   
        translate([minkowski_rad, minkowski_rad, 0])
            cube([
                clip_clasp_length - 2*minkowski_rad,
                buckle_width + 2*(clip_width-minkowski_rad),
                buckle_height/2 - minkowski_height
                    + 2*case_thickness + sf
            ]);      
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );       
    } 
    
    // Side 1
    minkowski(){
        translate([minkowski_rad, minkowski_rad, 0])
            cube([
                clip_length/2,
                clip_width - 2*minkowski_rad,
                buckle_height - minkowski_height
                    + 2*case_thickness + sf
            ]);
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );
    } 
    
    // Side 2
    minkowski(){
        translate([
            minkowski_rad,
            buckle_width + clip_width + minkowski_rad,
            0
        ])
            cube([
                clip_length/2,
                clip_width - 2*minkowski_rad,
                buckle_height - minkowski_height
                    + 2*case_thickness + sf
            ]);
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );
    } 
    
    // Base of clip and start of casing
    minkowski(){
        translate([
            clip_length/2 + minkowski_rad,
            minkowski_rad,
            0
        ])
            cube([
                clip_clasp_length - 2*minkowski_rad,
                buckle_width + 2*(clip_width-minkowski_rad),
                buckle_height - minkowski_height
                    + 2*case_thickness + sf
            ]);
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );
    } 
}


module female_casing(){
    
    // Bottom
    translate([
        clip_length/2 + 2*minkowski_rad,
        0,
        0
    ])
        cube([
            prong_length * wiggle_room_factor,
            buckle_width + 2*clip_width,
            case_thickness
        ]);
    
    // Top
    translate([
        clip_length/2 + 2*minkowski_rad,
        0,
        buckle_height + case_thickness + sf
    ])
        cube([
            prong_length * wiggle_room_factor,
            buckle_width + 2*clip_width,
            case_thickness
        ]);
    
    // Side 1
    difference(){
        translate([
            clip_length/2,
            0,
            0
        ])
            cube([
                prong_length * wiggle_room_factor
                    + 2*minkowski_rad,
                case_thickness,
                buckle_height + 2*case_thickness + sf
            ]);        
        
        translate([
            lock_length + clip_length/2,
            -sf/2,
            (buckle_height+sf)/6
        ])
            cube([
                lock_length + lock_offset,
                case_thickness + sf,
                buckle_height + sf
            ]); 
    }        
    
    // Side 2
    difference(){
        translate([
            clip_length/2,
            buckle_width + 2*(clip_width-minkowski_rad)
                + 2*sf,
            0
        ])
            cube([
                prong_length * wiggle_room_factor
                    + 2*minkowski_rad,
                case_thickness,
                buckle_height + 2*case_thickness + sf
            ]);
        
        translate([
            lock_length + clip_length/2,
            buckle_width + 2*(clip_width-minkowski_rad)
                + 2*sf - sf/2,
            (buckle_height+sf)/6
        ])
            cube([
                lock_length + lock_offset,
                case_thickness + sf,
                buckle_height + sf
            ]);        
    }   
    
    // Center prong tracks
    center = buckle_width
        + 2*(clip_width-minkowski_rad)
        + 2*sf;
    
    top_track_ref = buckle_height
        + case_thickness
        - track_height/2;
    
    translate([
        clip_length/2,
        (center+prong_center_width)/2 + track_thickness,
        case_thickness
    ])
        cube([
            prong_length * wiggle_room_factor
                + 2*minkowski_rad,
            track_thickness,
            track_height
        ]);
    
    translate([
        clip_length/2,
        (center-prong_center_width)/2 - track_thickness,
        case_thickness
    ])
        cube([
            prong_length * wiggle_room_factor
                + 2*minkowski_rad,
            track_thickness,
            track_height
        ]);
    
    translate([
        clip_length/2,
        (center+prong_center_width)/2 + track_thickness,
        top_track_ref
    ])
        cube([
            prong_length * wiggle_room_factor
                + 2*minkowski_rad,
            track_thickness,
            track_height
        ]);
    
    translate([
        clip_length/2,
        (center-prong_center_width)/2 - track_thickness,
        top_track_ref
    ])
        cube([
            prong_length * wiggle_room_factor
                + 2*minkowski_rad,
            track_thickness,
            track_height
        ]);
}


// ============================================================
// Male
// ============================================================

module male_buckle(){
    
    union(){
        male_clip();
        male_prongs();
    }    
}


// ============================================================
// Male Clip
// ============================================================

module male_clip(){
    
    // ========================================================
    // BACK REMOVED
    // ========================================================
    //
    // The original back/strap attachment geometry was here:
    //
    // minkowski(){
    //     translate([minkowski_rad, minkowski_rad, 0])
    //         cube([
    //             clip_clasp_length-2*minkowski_rad,
    //             buckle_width+2*(clip_width-minkowski_rad),
    //             buckle_height-minkowski_height
    //         ]);
    //     cylinder(r=minkowski_rad, h=minkowski_height);
    // }
    //
    // ========================================================


    // Side 1
    minkowski(){
        translate([
            minkowski_rad,
            minkowski_rad,
            0
        ])
            cube([
                clip_length,
                clip_width - 2*minkowski_rad,
                buckle_height - minkowski_height
            ]);
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );
    }     
    
    
    // Side 2
    minkowski(){
        translate([
            minkowski_rad,
            buckle_width + clip_width + minkowski_rad,
            0
        ])
            cube([
                clip_length,
                clip_width - 2*minkowski_rad,
                buckle_height - minkowski_height
            ]);
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );
    }    
   
    
    // Center section
    translate([
        clip_length/2,
        0,
        0
    ])
        cube([
            clip_clasp_length,
            buckle_width + 2*clip_width,
            buckle_height
        ]);     
    

    // Base of clip and start of prongs
    minkowski(){
        translate([
            clip_length + minkowski_rad,
            minkowski_rad,
            0
        ])
            cube([
                clip_clasp_length - 2*minkowski_rad,
                buckle_width + 2*(clip_width-minkowski_rad),
                buckle_height - minkowski_height
            ]);
        
        cylinder(
            r = minkowski_rad,
            h = minkowski_height
        );
    } 
}


// ============================================================
// Male Prongs
// ============================================================

module male_prongs(){
    
    // Side 1: prong
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
    
    
    // Side 1: locking mechanism
    locking_mechanism(); 
    
    
    // Side 2: prong
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
    
    
    // Side 2: locking mechanism
    translate([
        0,
        buckle_width + 2*clip_width,
        0
    ])
        mirror([0, 1, 0])
            locking_mechanism();
    
    
    // Center prong
    hull(){
        translate([
            clip_length + clip_clasp_length
                - prong_center_tap,
            (buckle_width-prong_center_width)/2
                + clip_width,
            0
        ])
            cube([
                prong_length,
                prong_center_width,
                buckle_height
            ]);
        
        translate([
            clip_length + clip_clasp_length
                + prong_length
                - prong_center_tap,
            buckle_width/2 + clip_width,
            0
        ])
            cylinder(
                r = prong_center_tap,
                h = buckle_height
            );        
    }
}


// ============================================================
// Locking Mechanism
// ============================================================

module locking_mechanism(){
    
    vert_pos = prong_offset - 3;
    
    hull(){
        
        // Main locking section
        translate([
            buckle_length + clip_clasp_length - 11,
            vert_pos,
            0
        ])
            linear_extrude(buckle_height)
                polygon(points = [
                    [0, 0],
                    [lock_length, 0],
                    [lock_length+lock_offset, lock_width],
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
                    linear_extrude(
                        height = buckle_height
                    )
                        circle(d = 6);
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
    cap_height = dt_height + cap_margin_mm + buckle_height + case_thickness
) {

    top_plate_length = width_mm - prong_length - clip_clasp_length;

    difference() {
translate([(-prong_length-clip_clasp_length)/2,0,0])
        intersection() {

            vertical_corner_chamfer(
                top_plate_length,
                depth_mm,
                cap_height,
                corner_radius_mm,
                fillet_fn
            );

            horizontal_top_chamfer(
                top_plate_length,
                depth_mm,
                cap_height,
                horizontal_radius_mm,
                fillet_fn
            );
        }

        // Interior cavity
        translate([
            -top_plate_length/2 + wall_mm,
            -depth_mm/2 + wall_mm,
            wall_mm
        ])
        cube([
            top_plate_length - 2*wall_mm,
            depth_mm - 2*wall_mm,
            cap_height - 2*wall_mm
        ]);
        translate([-10,0,0])
        rotate([90,0,90])
            BOSL2_socket(
            dt_width,
            height,
            dt_height
        );
    }
        translate([0,0,wall_mm/2])
        rotate([90,0,90])
            cut_bottom_plate(
            dt_width,
            height,
            dt_height
        );

    // Male buckle
    translate([
        prong_length/2 - clip_clasp_length,
        -(buckle_width/2) - clip_width,
        dt_height + cap_margin_mm
    ])
    male_buckle();
}
module generic_female_buckle(height_mm) {

    buckle_case_length = prong_length + clip_clasp_length;

    difference() {

        intersection() {

            vertical_corner_chamfer(
                buckle_case_length,
                depth_mm,
                height_mm,
                corner_radius_mm,
                fillet_fn
            );

            horizontal_top_chamfer(
                buckle_case_length,
                depth_mm,
                height_mm,
                horizontal_radius_mm,
                fillet_fn
            );
        }
        
   // Interior cavity + open negative-X wall
translate([
    -buckle_case_length/2,
    -depth_mm/2 + wall_mm,
    wall_mm
])
cube([
    buckle_case_length - wall_mm,
    depth_mm - 2*wall_mm,
    height_mm - 2*wall_mm
]);
    translate([3.5,depth_mm/2,18])
    scale([7.5, 3,11]) 
    circle(r = 1, $fn = 100);
    translate([3.5,-depth_mm/2,18])
    scale([7.5, 3,11]) 
    circle(r = 1, $fn = 100);    
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

        // TODO: Change to the BOSL library
        // Female dovetail socket
        //female_dovetail_knife(
           // dt_height,
           // dt_width,
          //  dt_narrow_width
       // );
     translate([-10,0,-wall_mm/2])
    rotate([90,0,90])
        BOSL2_socket(
        dt_width,
        height_mm,
        dt_height
    );
    }
    translate([-10,0,0])
    rotate([90,0,90])
    cut_bottom_plate(
    dt_width,
    height_mm,
    dt_height
);
    
    //male BOSL dovetail
    translate([-12,0,height_mm])
    rotate([90,0,90])
    cut_top_plate();

    translate([(width_mm/2)-(prong_length + clip_clasp_length)/2,0,height_mm])
        generic_female_buckle(24);
}

module render() {
    if (RENDER) { 
        if (RENDER_MALE_BUCKLE)
            translate([200,0,0])
            male_buckle();
        
        if (RENDER_FEMALE_BUCKLE)
            rotate([0,0,180])
            translate([-275,-38,0])
            female_buckle();
       

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

        if (RENDER_SECOND) {
         // Second component
          translate([0,0,50])
          color("green")
          generic_component(30);
        }
      
        
        if (RENDER_TOP) {
            // Top cap
            translate([-35,0,50+30])
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