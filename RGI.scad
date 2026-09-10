include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

// one line to give the program's name and a brief idea of what it does.>
//
//    Copyright (C) 2026  James Denney, Robert L. Read
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Affero General Public License as
//    published by the Free Software Foundation, either version 3 of the
//    License, or (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Affero General Public License for more details.
//
//    You should have received a copy of the GNU Affero General Public License
//    along with this program.  If not, see 
//    http://www.gnu.org/licenses/.



RENDER = 1;
RENDER_BOTTOM = 1;
RENDER_TOP = 1;
RENDER_FIT_TEST = 0;
RENDER_FIRST = 1;
RENDER_SECOND = 1;
RENDER_MALE_BUCKLE=0;
RENDER_FEMALE_BUCKLE=0;
USE_RENDER_KNIFE = 0;

// Use this to scale for small, test prints...
GLOBAL_SCALE_DOWN = 1; // default = 1;

// Components macro dimenstions
height= 100;
wall_mm = 2; // This may not scale linearly if you print small
depth_mm = 50;
width_mm = 140;


dt_angle = 30;
dt_width = 20;
dt_height = 8;
dt_knife_width= 15;
dovetail_margin_mm = 0.5; // this is the tolerance gap between the tail and cado
knife_margin_mm = 0.01;

// These concern chamfering
cap_margin_mm = 4;
corner_radius_mm = 2;
horizontal_radius_mm = 2;
fillet_fn = 64;

// ============================================================
// Casing Dimensions
// ============================================================

case_thickness     = 2;
sf                 = 1;
track_thickness    = 2;
track_height       = 2;
wiggle_room_factor = 1.2;

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

//  Buckle sizing
buckle_height = 9;
buckle_length = 50;

cap_height_mm = dt_height + cap_margin_mm + buckle_height + wall_mm;

// Slit dimensions
slit_width = 4;
slit_margin = 20; 
 
module BOSL2_socket(dt_width, height, dt_height) {
    cuboid([0, 0, 0]) {
        tag("remove")
            attach(FRONT)
                dovetail(
                    "female",
                    slide = width_mm,
                    width = dt_width+2*wall_mm,
                    height = dt_height+wall_mm/2,
                    angle = dt_angle,
                );
    }
}

module bottom_plate(dt_width, height, dt_height) {

    translate([0,0,0])
    diff()
  cuboid([0,0,0]){
    attach(BACK) dovetail("male", slide=110, width=dt_width+6*wall_mm, height=dt_height+wall_mm*1.5, angle=30);
    tag("remove")attach(BACK) rotate([180,0,0]) dovetail("female", slide=111, width=dt_width, height=dt_height, angle=30, $slop=dovetail_margin_mm);
  }
}

module cut_bottom_plate() {
    difference() {
        bottom_plate(dt_width,height,dt_height);
        cube([slit_width,50,height-slit_margin*2],center = true);
    }
}

module component_dovetail(dt_width,height,dt_height) { 
    translate([0,0,0])
    diff()
      cuboid([0,0,0]){
        attach(BACK) dovetail("male", slide=110, width=dt_width, height=dt_height, angle=dt_angle);
        tag("remove")attach(BACK) rotate([180,0,0]) dovetail("female", slide=width_mm, width=dt_knife_width/1.8, height=(dt_height-1.5)-1, angle=30);
      }
}
  
module cut_top_plate() {
    difference() {
        component_dovetail(dt_width,height,dt_height);
        cube([slit_width,50,height-slit_margin*2],center = true);
    }
}



// Used under Creative-Commons BY-SA from You Magazine by "amcmichael"
// https://youmagine.com/amcmichael




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
lock_offset = 1.5; // the latching angle (decrease for smaller locking angle)





// ============================================================
// Rounded Edges
// ============================================================

minkowski_rad    = 2;
minkowski_height = 0.1;

$fn = 120;



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

// TODO: May syntax more compact
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
                [[-size_x/2, size_z]],

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
        
    // TODO: Remove these "magic numbers"
    translate([3.75,depth_mm/2,11])
    scale([7.5, 4,11.5]) 
    linear_extrude(height =2)
    circle(r = 1, $fn = 100);
    translate([3.75,-depth_mm/2,11])
    scale([7, 4,11.5]) 
    linear_extrude(height =2)
    circle(r = 1, $fn = 100);    
    }
}


module top_end_plate(
    cap_height = dt_height + cap_margin_mm + buckle_height + case_thickness
) {

    top_plate_length = width_mm - prong_length - clip_clasp_length;

    difference() {
        translate([(-prong_length-clip_clasp_length)/2,0,0])
        intersection() {

        vertical_corner_chamfer(top_plate_length,       depth_mm, cap_height, corner_radius_mm      , fillet_fn);

        horizontal_top_chamfer( top_plate_length,       depth_mm, cap_height,                      horizontal_radius_mm,                       fillet_fn);
         }

        // Interior cavity
        translate([-top_plate_length/2 + wall_mm,
        -depth_mm/2 + wall_mm, wall_mm])
        
        cube([top_plate_length - 2*wall_mm,
            depth_mm - 2*wall_mm, cap_height - 2*           wall_mm]);
     
  
// TODO: What are these "magic numbers"  
//       #translate([-10,0,0])
//       #translate([-20,0,0])
        rotate([90,0,90])
            BOSL2_socket(dt_width, height,                      dt_height);
    }
    
        translate([-15,0,0])
        rotate([90,0,90])
            cut_bottom_plate();

    // Male buckle
    translate([prong_length/2 - clip_clasp_length,
        -(buckle_width/2) - clip_width,
        dt_height + cap_margin_mm])
    
    male_buckle();
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
        // TODO: Replace with proper call to BOSL library
//        dovetail(
//            dt_height,
//            dt_width,
//            dt_narrow_width
//        );
    }
}

module blank_face_plate() {
}




module generic_component (height_mm) {
    
    buckle_case_length = prong_length + clip_clasp_length;
    
    cap_height = dt_height + cap_margin_mm + buckle_height + case_thickness;
   

    difference() {

        // Main body with chamfered vertical outside corners
        vertical_corner_chamfer(
            width_mm,
            depth_mm,
            height_mm,
            2
        );
        

        translate([-50/2+10,0,height/2])
        rotate([90,0,90])
        cube([slit_width,50,height-slit_margin*2],center = true);

        // Interior cavity
        translate([-width_mm/2 + wall_mm, -         depth_mm/2 + wall_mm,wall_mm])
        cube([width_mm - 2*wall_mm, depth_mm - 2*       wall_mm, height_mm - 2*wall_mm]);

        // recess for male buckle
         translate([width_mm/2-buckle_case_length,-25,0])
        
         cube([buckle_case_length,depth_mm,cap_height]);
        
   
        //BOSL2 Socket
     translate([-15,0,0])
    rotate([90,0,90])
        BOSL2_socket(dt_width, height_mm, dt_height);
    }
    
    //Female BOSL2 Dovetail shell
    translate([-15,0,0])
    rotate([90,0,90])
    cut_bottom_plate();
    
    //male BOSL dovetail
    translate([-15,0,height_mm])
    rotate([90,0,90])
    difference() {
        cut_top_plate();
        cube([slit_width,50,height-slit_margin*2],center = true);
    }
    
    //Female Buckle
    translate([(width_mm/2)-(prong_length + clip_clasp_length)/2,0,height_mm-1.5])
        generic_female_buckle(cap_height_mm);
    
    // Male buckle
    translate([prong_length/2 - clip_clasp_length,
        -(buckle_width/2) - clip_width,
        dt_height + cap_margin_mm-1])
    
    male_buckle();
}

module render() {
    scale([1/GLOBAL_SCALE_DOWN,1/GLOBAL_SCALE_DOWN,1/GLOBAL_SCALE_DOWN])
    union() {
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
                translate([35,0,0])
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
                translate([0,0,50+30])
                color("gray")
                top_end_plate();
            }
        }
    }
}


if (USE_RENDER_KNIFE) {
    difference() {
        render();
        translate([0,300/2,0])
        cube([300,300,300],center=true);
    }
} else {
    render();
}