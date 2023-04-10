coin_radius = 25;
non_mesh_zone_height = 0.4;


//## Parameters for the "fingers" that mesh together in the middle ##
mesh_zone_height = 3;
mesh_sectors = 10;

//reference boundaries
mesh_end = coin_radius - 2;
mesh_middle = coin_radius - 8;
mesh_start = coin_radius - 11.5;

//tuning, bigger values are looser
outer_finger_offset_from_outer_ring = 0.1;
inner_finger_offset_from_outer_ring = 0.1;
inter_finger_angle = 0.2;
finger_height_reduction = 0.1;
dowel_diameter_increase = 0.15;

//actual values
outer_finger_end = mesh_end - outer_finger_offset_from_outer_ring;
inner_finger_end = mesh_middle - inner_finger_offset_from_outer_ring;


dowel_length = 5;
dowel_diameter_ideal = 1.5;
dowel_diameter = dowel_diameter_ideal + dowel_diameter_increase;
dowel_stickout = 2; //the minimum the dowel should poke out into the outer fingers, when fully sunk into the inner finger
dower_stickin = dowel_length - dowel_stickout;
dowel_cavity_length = dowel_length + dower_stickin;

sector_angle = 360/mesh_sectors;
subunit_angle = sector_angle/2;

retention_overhang = 0.5;

crown_lower_height = 0.3;

module mesh_sector(other_side, holes = true) {
    
    if (other_side) {
        
    //inner finger
    inner_finger_width=inner_finger_end-mesh_start;
    inner_finger_height=mesh_zone_height-finger_height_reduction-crown_lower_height;
    difference () {
        rotate([0,0,inter_finger_angle]) rotate_extrude(angle=subunit_angle-2*inter_finger_angle,$fn=360) translate([mesh_start,0]) 
        //square(size=[inner_finger_end-mesh_start,mesh_zone_height-finger_height_reduction]);
    polygon(points=[[0,0],[inner_finger_width-retention_overhang,0],[inner_finger_width,inner_finger_height],[0,inner_finger_height]]);
        
        if (holes) {
        //cutout the dowel
        rotate([0,0,subunit_angle/2]) translate([mesh_middle-dower_stickin,0,mesh_zone_height/2]) rotate([0,90,0]) cylinder(d=dowel_diameter,h=dowel_cavity_length,$fn=90);
    }
}
    
    }
    
    
    if (!other_side) {
        
    //outer finger
    outer_finger_width=outer_finger_end-mesh_middle;
    outer_finger_height=mesh_zone_height-finger_height_reduction;
    difference() {
        rotate([0,0,subunit_angle+inter_finger_angle]) rotate_extrude(angle=subunit_angle-2*inter_finger_angle,$fn=360) translate([mesh_middle,0]) 
        //square(size=[outer_finger_end-mesh_middle,mesh_zone_height-finger_height_reduction]);
        
        polygon(points=[[0,0],[outer_finger_width,0],[outer_finger_width,outer_finger_height],[-retention_overhang,outer_finger_height]]);
        
        if (holes) {
        //cutout the dowel
        rotate([0,0,3*subunit_angle/2]) translate([mesh_middle-dower_stickin,0,mesh_zone_height/2]) rotate([0,90,0]) cylinder(d=dowel_diameter,h=dowel_cavity_length,$fn=90);
    }
    }
    
    }
}




module coin_half(other_side=false,holes=true){
    union() {
        
    cylinder(r=coin_radius, h=non_mesh_zone_height, $fn=360);

    for (i = [0:(mesh_sectors-1)]) {
        translate([0,0,non_mesh_zone_height]) rotate([0,0,sector_angle * i]) mesh_sector(other_side);    
    }


    //mesh zone outer ring
    translate([0,0,non_mesh_zone_height]) difference() {
       cylinder(r=coin_radius, h=mesh_zone_height/2, $fn=360);
       cylinder(r=mesh_end, h=mesh_zone_height/2, $fn=360); 
    }
    
    }
}

module crown_ring() {
    finger_height = mesh_zone_height-finger_height_reduction;
    
    union() {
        
    translate([0,0,finger_height]) mirror([0,0,1]) translate([0,0,-non_mesh_zone_height]) union() {
        for (i = [0:(mesh_sectors-1)]) {
            translate([0,0,non_mesh_zone_height]) rotate([0,0,sector_angle * i])    mesh_sector(other_side=true,holes=false);    
        }
    }
    
    difference() {
        cylinder(r1=inner_finger_end, r2=inner_finger_end-retention_overhang, h=finger_height, $fn=360);
        translate([0,0,50+crown_lower_height]) cube([100,100,100],center=true);
        cylinder (r=mesh_start,h=finger_height, $fn=90);
    }
    
    }
}

coin_half();
translate([2.5*coin_radius,0]) coin_half(other_side=true);
translate([5*coin_radius,0]) crown_ring();