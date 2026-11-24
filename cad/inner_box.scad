// =====================================================================
//  remote_condo_gate - INNER box: 230 V -> 5 V supply (Hi-Link HLK-5M05B on a
//  4x6 perfboard), ESP32 DevKit 30 pin in a cradle, MT3608 or XL6009 5 -> 12 V step-up.
//  Sealing: 1.5 mm silicone O-ring cord in a groove on top of the walls +
//  cap-style lid with skirt. Partition between the 230 V and low-voltage areas.
//  Parametric - OpenSCAD 2021+
//
//  part = "assembly" | "box" | "lid" | "socket_test"
//  Print: light ASA, 4 walls, 5 top/bottom layers, 25-30% gyroid.
//  box: floor on the bed. lid: exported already flipped (outer face on the bed).
//
//  Coordinates: X width, Y vertical when mounted (Y=0 at the bottom),
//  Z depth (floor against the wall).
// =====================================================================

part = "assembly";
box_name = "inner";     // used by the optional private emblem file
lid_flip = true;   // true: lid flipped for printing (outer face on the bed). false: upright
$fn = 40;

// ---------------- walls and sealing (same as the outer box) ----------------
wall     = 3.0;
floor_t  = 2.4;
lid_t    = 2.4;
cord_d   = 1.5;
gr_w     = 2.0;
gr_d     = 1.15;
sk_g     = 0.3;
sk_t     = 1.2;
sk_h     = 3.0;
corner_r = 5;

// ---------------- components ----------------
// power supply perfboard 40 x 60, d2 holes in the corners
psu_w = 40; psu_l = 60; psu_t = 1.6;
psu_comp  = 25;      // Hi-Link height above the board
psu_so    = 5;       // supports: jumpers and a ceramic capacitor sit under the board
psu_hin   = 2.1;     // hole centre to edge: estimated from photo (spacing ~35.8 x 55.8)
psu_pin   = 1.6;     // pin in the 2 mm hole (clearance for the estimate uncertainty)
psu_stake = 2.5;     // pin protrusion above the board, to be heat-staked
// ESP32 DevKit 30 pin: 52 x 29.5, header pins pointing down
esp_w = 29.5; esp_l = 52;
esp_h = 16;          // board bottom height: 16 with wires soldered to the pins, 26 with Dupont connectors
esp_rib = 18;        // central support rib (between the two pin rows)
// 5 -> 12 V step-up module: "MT3608" (17 x 37) or "XL6009" (21 x 43, ~14 mm tall)
stepup = "XL6009";
mt_w = stepup == "XL6009" ? 21 : 17;
mt_l = stepup == "XL6009" ? 43 : 37;
mt_h = 3;            // rails under the module (solder joint clearance)
mt_comp = stepup == "XL6009" ? 12.5 : 6;   // component height above the module PCB (preview)

cl     = 2;          // general clearance
part_t = 2;          // 230 V / low-voltage partition

cl_l = 8;            // space on the left for the cable gland locknut
Li = cl_l + psu_w + cl + part_t + cl + esp_w + 3 + mt_w + cl;   // ~105.5
Hi = 76;
Di = max(psu_so + psu_t + psu_comp, esp_h + 1.6 + 6) + 4;     // ~34.6

L_ext  = Li + 2*wall;
H_ext  = Hi + 2*wall;
D_base = floor_t + Di;

psu_x0  = wall + cl_l;          psu_y0 = wall + 8;     // 230 V terminal at the bottom left
part_x0 = psu_x0 + psu_w + cl;
esp_x0  = part_x0 + part_t + cl; esp_y0 = wall + 14;   // USB at the bottom, antenna at the top
mt_x0   = esp_x0 + esp_w + 3;    mt_y0  = wall + 20;

post_d = 6;
posts = [ [wall + post_d/2,      wall + post_d/2],
          [wall + post_d/2,      wall + Hi - post_d/2],
          [wall + Li - post_d/2, wall + post_d/2],
          [wall + Li - post_d/2, wall + Hi - post_d/2] ];

// entries: 230 V on the LEFT side, conduit to the remote on the RIGHT side
// (left/right as seen looking at the lid)
gland_d  = 16.3;                       // M16x1.5 cable gland for the 230 V cable
gland_y  = wall + 22;                  // above the corner boss
tube_od  = 10.5; tube_p = 2.5;         // conduit to the outer box: measured OD (annular corrugation)
sock_bore = tube_od + 0.4;
sock_wall = 1.6; sock_od = sock_bore + 2*sock_wall;
sock_len = 14; snap_n = 2; snap_d = tube_od - 0.8;
sock_y   = wall + 12;                 // below the step-up
sock_zc  = sock_od/2;                  // tangent to the floor: prints without supports

// wall mounting ears (outside the sealed area)
ear_w = 16; ear_l = 10; ear_t = 4; ear_hole = 4.5;

// =====================================================================
module outline2d() {
  translate([corner_r, corner_r]) offset(r=corner_r)
    square([L_ext - 2*corner_r, H_ext - 2*corner_r]);
}
module ring2d(w) {
  difference() {
    offset(r = -(wall/2 - w/2)) outline2d();
    offset(r = -(wall/2 + w/2)) outline2d();
  }
}

module box() {
  difference() {
    union() {
      linear_extrude(D_base) outline2d();
      // conduit socket on the right side
      translate([L_ext - 0.01, sock_y, sock_zc]) rotate([0,90,0]) cylinder(d=sock_od, h=sock_len + 0.01);
      // mounting ears, top and bottom
      for (top = [0,1]) translate([L_ext/2 - ear_w/2, top ? H_ext - 0.01 : -ear_l + 0.01, 0])
        difference() {
          cube([ear_w, ear_l, ear_t]);
          translate([ear_w/2, top ? ear_l/2 + 1 : ear_l/2 - 1, -1]) cylinder(d=ear_hole, h=ear_t + 2);
        }
    }
    // cavity
    translate([0, 0, floor_t]) linear_extrude(Di + 1) offset(r=-wall) outline2d();
    // cord groove
    translate([0, 0, D_base - gr_d]) linear_extrude(gr_d + 1) ring2d(gr_w);
    // M16 cable gland hole on the left side (230 V area)
    translate([-1, gland_y, floor_t + Di/2]) rotate([0,90,0]) cylinder(d=gland_d, h=wall + 2);
    // conduit socket on the right side: seat (1 mm stop), snap rings, passage
    difference() {
      translate([L_ext + 1, sock_y, sock_zc]) rotate([0,90,0]) cylinder(d=sock_bore, h=sock_len + 1);
      for (i = [1 : snap_n]) if (snap_n > 0)
        translate([L_ext + sock_len - i*tube_p*2 - 0.25, sock_y, sock_zc]) rotate([0,90,0])
          difference() { cylinder(d=sock_bore + 1, h=0.5); translate([0,0,-1]) cylinder(d=snap_d, h=3); }
    }
    translate([L_ext - wall - 1, sock_y, sock_zc]) rotate([0,90,0]) cylinder(d=5.5, h=wall + 2.5);
    // condensation drain (low-voltage area)
    translate([esp_x0 + esp_w - 3, -1, floor_t + 0.9]) rotate([-90,0,0]) cylinder(d=1.5, h=wall + 2);
  }
  // lid screw bosses
  for (p = posts) translate([p[0], p[1], floor_t]) difference() {
    cylinder(d=post_d, h=Di);
    translate([0,0,Di-10]) cylinder(d=2.5, h=11);
  }
  // supports + retaining pins for the PSU board (heat-staked, no screws)
  for (ix=[0,1], iy=[0,1])
    translate([psu_x0 + psu_hin + ix*(psu_w - 2*psu_hin),
               psu_y0 + psu_hin + iy*(psu_l - 2*psu_hin), floor_t]) {
      cylinder(d=4, h=psu_so);
      cylinder(d=psu_pin, h=psu_so + psu_t + psu_stake, $fn=24);
    }
  // 230 V / low-voltage partition, with an opening at the top for the 5 V wires
  translate([part_x0, wall, floor_t]) difference() {
    cube([part_t, Hi, Di - 0.6]);
    translate([-1, Hi - 16, Di - 14]) cube([part_t + 2, 10, 15]);
  }
  // ESP32 cradle: central rib between the pin rows + end stops
  translate([esp_x0 + esp_w/2 - esp_rib/2, esp_y0 + 6, floor_t]) cube([esp_rib, esp_l - 12, esp_h]);
  for (e = [0,1]) translate([esp_x0 + esp_w/2 - 5, e ? esp_y0 + esp_l + 0.3 : esp_y0 - 2.3, floor_t])
    cube([10, 2, esp_h + 1.0]);
  // step-up cradle: two rails with a tunnel for a cable tie
  for (s = [0,1]) translate([mt_x0 + s*(mt_w - 2.5), mt_y0 + 5, floor_t]) difference() {
    cube([2.5, mt_l - 10, mt_h]);
    translate([-1, (mt_l - 10)/2 - 2, -0.01]) cube([4.5, 4, 1.6]);
  }
  for (e = [0,1]) translate([mt_x0 + mt_w/2 - 4, e ? mt_y0 + mt_l + 0.3 : mt_y0 - 2.3, floor_t])
    cube([8, 2, mt_h + 1.2]);
}

module lid() {
  o = sk_g + sk_t;
  difference() {
    union() {
      linear_extrude(lid_t) offset(r=o) outline2d();
      translate([0,0,-sk_h]) linear_extrude(sk_h + 0.01) difference() {
        offset(r=o) outline2d();
        offset(r=sk_g) outline2d();
      }
    }
    for (p = posts) translate([p[0], p[1], -1]) cylinder(d=3.4, h=lid_t + 2);
    if (!is_undef(logo_available)) logo_cut();
  }
}

// ---------------- preview ----------------
module preview_parts() {
  // power supply
  color("green") translate([psu_x0, psu_y0, floor_t + psu_so]) cube([psu_w, psu_l, psu_t]);
  color("black") translate([psu_x0 + 8, psu_y0 + 12, floor_t + psu_so + psu_t]) cube([30, 45, psu_comp]);
  color("limegreen") translate([psu_x0 + 2, psu_y0 + 1, floor_t + psu_so + psu_t]) cube([10, 7, 10]);
  color("limegreen") translate([psu_x0 + 2, psu_y0 + psu_l - 8, floor_t + psu_so + psu_t]) cube([10, 7, 10]);
  // ESP32
  color("dimgray") translate([esp_x0, esp_y0, floor_t + esp_h]) cube([esp_w, esp_l, 1.6]);
  color("silver") translate([esp_x0 + 5, esp_y0 + esp_l - 25, floor_t + esp_h + 1.6]) cube([18, 25, 3]);
  for (s=[0,1]) color("black") translate([esp_x0 + 0.8 + s*(esp_w - 4.1), esp_y0 + 4, floor_t + esp_h - 8.5])
    cube([2.5, 38, 8.5]);
  // step-up module
  color("royalblue") translate([mt_x0, mt_y0, floor_t + mt_h]) cube([mt_w, mt_l, 1.6]);
  color("silver") translate([mt_x0 + 3, mt_y0 + mt_l/2 - 7, floor_t + mt_h + 1.6]) cube([mt_w - 6, 14, mt_comp]);
  // cable gland and conduit
  color("gray") translate([0, gland_y, floor_t + Di/2]) rotate([0,-90,0]) cylinder(d=20, h=15, $fn=6);
  color("white") translate([L_ext + 1, sock_y, sock_zc]) rotate([0,90,0]) cylinder(d=tube_od, h=40);
}

module assembly() {
  color("ivory") box();
  preview_parts();
  color("ivory", 0.3) translate([0, 0, D_base + 20]) lid();
}

if      (part == "box") box();
else if (part == "lid")    { if (lid_flip) translate([0,0,lid_t]) rotate([180,0,0]) lid(); else lid(); }
else if (part == "socket_test")   // quick fit test: only the conduit socket with a piece of wall and floor
  intersection() {
    box();
    translate([L_ext - wall - 4, sock_y - 12, -1]) cube([wall + 4 + sock_len + 2, 24, sock_od + 4]);
  }
else if (part == "logo_mod") { if (!is_undef(logo_available)) logo_mod(); else echo("logo_mod: cad/logo_local.scad not found"); }
else                    assembly();

echo(str("Outer size: ", L_ext, " x ", H_ext, " x ", D_base + lid_t, " mm"));

// ---------------- optional private emblem ----------------
// If cad/logo_local.scad exists (it is git-ignored and never published) it is
// included here and can engrave an emblem on the lid or provide a slicer
// modifier (part = "logo_mod"). Without it OpenSCAD only prints a warning
// about the missing include file and the lid stays plain.
include <logo_local.scad>
