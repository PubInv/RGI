// Used under Creative-Commons BY-SA from You Magazine by "amcmichael" https://youmagine.com/amcmichael
// Buckle Dimensions
buckle_width  = 25.4; // Buckle dimension based on the inner width of the strap connector
buckle_height = 10;
buckle_length = buckle_width*2;

// Clip Dimensions
clip_length       = 24; 
clip_width        = 6.35; // extra material added to side of clip 
clip_clasp_length = 5;

// Prong Dimensions
prong_length       = buckle_length - clip_length;
prong_center_width = 6; // width of the center prong
prong_center_tap   = prong_center_width/2;
prong_side_width   = 4; // width of the side prongs
prong_offset       = 3; // difference between prong location and overall buckle width

// Locking Mechanism
lock_length = 10;
lock_width  = 5;
lock_offset = 2; // the latching angle (decrease for smaller locking angle)

// Casing Dimensions
case_thickness     = 2;   // must be equal to or less than the locking mechanism prong
sf                 = 1;   // safety factor for fitting between male and female buckle
track_thickness    = 2;   // the center prong track thickness
track_height       = 2;
wiggle_room_factor = 1.2; // the room the locking mechanism is allowed to move forward and backward while connected

// Rounded edges
minkowski_rad    = 2;
minkowski_height = 0.1;
$fn = 120;

// Make Buckle
//translate([12, 40, 0])female_buckle();
//female_buckle();
male_buckle();


// Female
module female_buckle(){
    
    difference(){
        union(){
            female_clip();
            female_casing();
        }        
  
        // Locking mechanism access ellipse 1
        translate([lock_length+lock_offset+clip_length/2, 0, -2])
            scale([1, 0.5])            
                linear_extrude(height=buckle_height*2)
                    circle(d=20);
        
        // Locking mechanism access ellipse 2        
        translate([lock_length+lock_offset+clip_length/2, buckle_width+2*(clip_width-minkowski_rad)+2*sf+case_thickness, -2])
            scale([1, 0.5])
                linear_extrude(height=buckle_height*2)
                    circle(d=20);
    }
}

module female_clip(){    
    
    // back
    minkowski(){   
        translate([minkowski_rad, minkowski_rad, 0])
            cube([clip_clasp_length-2*minkowski_rad, buckle_width+2*(clip_width-minkowski_rad), buckle_height/2-minkowski_height+2*case_thickness+sf]);      
        cylinder(r=minkowski_rad, h=minkowski_height);       
    } 
    
    // side 1
    minkowski(){
        translate([minkowski_rad, minkowski_rad, 0])
            cube([clip_length/2, clip_width-2*minkowski_rad, buckle_height-minkowski_height+2*case_thickness+sf]);
        cylinder(r=minkowski_rad, h=minkowski_height);
    } 
    
    // side 2  
    minkowski(){
        translate([minkowski_rad, buckle_width+clip_width+minkowski_rad, 0])
            cube([clip_length/2, clip_width-2*minkowski_rad, buckle_height-minkowski_height+2*case_thickness+sf]);
        cylinder(r=minkowski_rad, h=minkowski_height);
    } 
    
    // base of clip and start of casing
    minkowski(){
        translate([clip_length/2+minkowski_rad, minkowski_rad, 0])
            cube([clip_clasp_length-2*minkowski_rad, buckle_width+2*(clip_width-minkowski_rad), buckle_height-minkowski_height+2*case_thickness+sf]);
        cylinder(r=minkowski_rad, h=minkowski_height);
    } 
}

module female_casing(){
    
    // bottom
    translate([clip_length/2+2*minkowski_rad, 0, 0])
            cube([prong_length*wiggle_room_factor, buckle_width+2*clip_width, case_thickness]);
    
    // top
    translate([clip_length/2+2*minkowski_rad, 0, buckle_height+case_thickness+sf])
            cube([prong_length*wiggle_room_factor, buckle_width+2*clip_width, case_thickness]);
    
    // side 1
    difference(){
        translate([clip_length/2, 0, 0])
            cube([prong_length*wiggle_room_factor+2*minkowski_rad, case_thickness, buckle_height+2*case_thickness+sf]);        
       translate([lock_length+clip_length/2, -sf/2, (buckle_height+sf)/6])
            cube([lock_length+lock_offset, case_thickness+sf, buckle_height+sf]); 
    }        
    
    // side 2
    difference(){
        translate([clip_length/2, buckle_width+2*(clip_width-minkowski_rad)+2*sf, 0])
            cube([prong_length*wiggle_room_factor+2*minkowski_rad, case_thickness, buckle_height+2*case_thickness+sf]);
        translate([lock_length+clip_length/2, buckle_width+2*(clip_width-minkowski_rad)+2*sf-sf/2, (buckle_height+sf)/6])
            cube([lock_length+lock_offset, case_thickness+sf, buckle_height+sf]);        
    }   
    
    // center prong tracks    
    center = buckle_width+2*(clip_width-minkowski_rad)+2*sf; // reference point to the center of the casing (y direction)
    top_track_ref = buckle_height+case_thickness-track_height/2; // reference point for top tracks (z direction)
    
    translate([clip_length/2, (center+prong_center_width)/2+track_thickness, case_thickness])
            cube([prong_length*wiggle_room_factor+2*minkowski_rad, track_thickness, track_height]); // bot side 2
    translate([clip_length/2, (center-prong_center_width)/2-track_thickness, case_thickness])
            cube([prong_length*wiggle_room_factor+2*minkowski_rad, track_thickness, track_height]); // bot side 1
    translate([clip_length/2, (center+prong_center_width)/2+track_thickness, top_track_ref])
            cube([prong_length*wiggle_room_factor+2*minkowski_rad, track_thickness, track_height]); // top side 2
    translate([clip_length/2, (center-prong_center_width)/2-track_thickness, top_track_ref])
            cube([prong_length*wiggle_room_factor+2*minkowski_rad, track_thickness, track_height]); // top side 1
}

// Male
module male_buckle(){
    
    union(){
        male_clip();
        male_prongs();
    }    
}

module male_clip(){
    
    // back
    minkowski(){   
        translate([minkowski_rad, minkowski_rad, 0])
            cube([clip_clasp_length-2*minkowski_rad, buckle_width+2*(clip_width-minkowski_rad), buckle_height-minkowski_height]);      
        cylinder(r=minkowski_rad, h=minkowski_height);       
    } 
    
    // side 1
    minkowski(){
        translate([minkowski_rad, minkowski_rad, 0])
            cube([clip_length, clip_width-2*minkowski_rad, buckle_height-minkowski_height]);
        cylinder(r=minkowski_rad, h=minkowski_height);
    }     
    
    // side 2  
    minkowski(){
        translate([minkowski_rad, buckle_width+clip_width+minkowski_rad, 0])
            cube([clip_length, clip_width-2*minkowski_rad, buckle_height-minkowski_height]);
        cylinder(r=minkowski_rad, h=minkowski_height);
    }    
   
    // center
    translate([clip_length/2, 0, 0])
        cube([clip_clasp_length, buckle_width+2*clip_width, buckle_height]);     
    
    // base of clip and start of prongs
    minkowski(){
        translate([clip_length+minkowski_rad, minkowski_rad, 0])
            cube([clip_clasp_length-2*minkowski_rad, buckle_width+2*(clip_width-minkowski_rad), buckle_height-minkowski_height]);
        cylinder(r=minkowski_rad, h=minkowski_height);
    } 
}

module male_prongs(){
    
    // side 1: prong
    translate([clip_length+clip_clasp_length, prong_offset, 0])
        cube([prong_length, prong_side_width, buckle_height]);    
    
    // side 1: locking mechanism
    locking_mechanism(); 
    
    // side 2: prong    
    translate([clip_length+clip_clasp_length, buckle_width+2*clip_width-prong_side_width-prong_offset, 0])
        cube([prong_length, prong_side_width, buckle_height]);
    
    // side 2: locking mechanism
    translate([0, buckle_width+2*clip_width, 0])
        mirror([0, 1, 0])
            locking_mechanism();
    
    // center
    hull(){
        translate([clip_length+clip_clasp_length-prong_center_tap, (buckle_width-prong_center_width)/2+clip_width, 0])
        cube([prong_length, prong_center_width, buckle_height]);
        translate([clip_length+clip_clasp_length+prong_length-prong_center_tap, buckle_width/2+clip_width, 0])
            cylinder(r=prong_center_tap, h=buckle_height);        
    }
}

module locking_mechanism(){
    
    vert_pos = prong_offset - 3; // offset of locking mechanism from prong
    
    hull(){
        translate([buckle_length+clip_clasp_length-11, vert_pos, 0])
            linear_extrude(buckle_height)
                polygon(points=[[0, 0],[lock_length, 0],[lock_length+lock_offset, lock_width],[lock_offset, lock_width]]); 
        translate([buckle_length+clip_clasp_length, 6+vert_pos, 0])
            cylinder(r=2, h=buckle_height); 
       translate([buckle_length+clip_clasp_length, 2.8, 0])
            rotate([0, 0, 60])
                scale([1, 0.5])                 
                linear_extrude(height=buckle_height)
                    circle(d=6);
        
    } 
}
