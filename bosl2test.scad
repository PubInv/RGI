include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
//diff()
//  cuboid([50,30,10]){
//    attach(BACK) dovetail("male", slide=10, width=15, height=8, angle=30);
//    tag("remove")attach(FRONT) dovetail("female", slide=10, width=15, height=8, angle=30);
//  }
 
height= 100;
dt_width = 15;
dt_height = 8;
dt_knife_width= 11;
 
module top_plate(dt_width,height,dt_height) { 
diff()
  cuboid([50,2,height]){
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