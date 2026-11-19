// =====================================================================
//  remote_condo_gate - OUTER box: 12 V gate remote + PC817 optocoupler,
//  hung under the balcony copper flashing with a two-part clamp + visor.
//  Parametric - OpenSCAD 2021+
//
//  part = "assembly"  overview: flashing, clamp, visor, box, board, PC817
//                     and wire routing (lid exploded and transparent)
//         "box"       enclosure (print with the floor on the bed)
//         "lid"       lid (exported already flipped: outer face on the bed)
//         "clamp"     clamp body (in the slicer lay it on its SIDE)
//         "visor"     visor + upper jaw (exported flat, ready to print)
//
//  Sealing: 1.5 mm solid silicone O-ring cord (~19 cm) in a groove on top of
//  the walls + cap-style lid with 3 mm drip skirt; nylon M3 screws on the
//  antenna end, M2 screws with rubber washers on the cable end; adhesive
//  heat-shrink between the conduit socket and the conduit.
//  Print: ASA (light colour), 4 walls, 5 top/bottom layers.
//
//  Box coordinates: X = length, Y = vertical when mounted, Z = depth
//  (floor towards the wall, lid facing out).
//  World (assembly): X along the parapet, Y out from the wall, Z up.
// =====================================================================

part = "assembly";
lid_flip = true;   // true: lid flipped for printing (outer face on the bed). false: upright
$fn = 40;

// ---------------- Copper drip flashing ----------------
lip_out  = 33;
lip_drop = 20;
lip_t    = 2.1;
lip_a    = atan(lip_drop / lip_out);
lip_len  = sqrt(lip_out*lip_out + lip_drop*lip_drop);

// ---------------- Remote control board ----------------
// board coordinates: xr along the 28.1 side, yr along the 53 side, origin top-left corner
// (yr = 0 = buttons/antenna end)
rem_len = 53;
rem_w   = 28.1;
rem_th  = 5.1;          // total thickness incl. buttons
pcb_t   = 1.6;
cut_xr  = 18;           // battery cut-out: xr 18..28.1, yr 19..53 (estimated from photo)
cut_yr  = 19;
rem_holes = [ [2.5, 4.5, 2], [26.5, 4.5, 2], [13.5, 51.0, 3] ];   // single hole moved 1 mm up (Y+) after test fit   // xr, yr, diameter
pad_plus  = [16.5, 21.5];   // former battery + contact (estimate, verify)
pad_gnd   = [16.5, 46.0];   // former battery - spring (estimate, verify)
btn_hi    = [3.2, 7.8];     // button pad on the 11.5 V side -> collector (verify!)
btn_lo    = [12.0, 7.8];    // other pad -> emitter

// ---------------- Enclosure ----------------
wall    = 3.0;    // thick walls to host the O-ring cord groove
floor_t = 1.8;
lid_t   = 1.8;

// sealing: 1.5 mm silicone/EPDM O-ring cord in a groove on top of the walls
// + cap-style lid. Groove: width ~1.33 x d, depth ~77% of d
cord_d = 1.5;
gr_w  = 2.0;      // groove width
gr_d  = 1.15;     // groove depth (cord protrudes 0.35 -> ~23% compression)
sk_g  = 0.3;      // clearance between lid skirt and walls
sk_t  = 1.2;      // skirt thickness
sk_h  = 3.0;      // skirt height (drip edge)
corner_r = 4;     // outer corner radius (> wall). Cavity, cord groove and
                  // lid follow concentric radii: uniform wall thickness
so_h    = 2;      // standoffs under the board
stake_h = 5.0;    // pin length beyond (so_h + pcb_t): with 2.5 the pins ended flush in the test fit,
                  // so the board sits ~2.5 mm higher -> expected real protrusion ~2.5
pin_d   = 1.75;   // same diameter for all pins (also in the 3 mm hole: easier to heat-stake)
clr     = 0.5;    // clearance around the board
end_gap = 4.5;    // space on the cable end (lid screws + wire entry)
top_gap = 2.0;    // extra space at the top for the clamp screw heads

Li = clr + rem_len + end_gap;          // 58
Hi = clr + rem_w + top_gap;            // 30.6
Di = so_h + rem_th + 4.0;              // 11.1: the conduit socket (d 12.8) fits within the box depth
L_ext  = Li + 2*wall;
H_ext  = Hi + 2*wall;
D_base = floor_t + Di;

bx0 = wall + clr;
by0 = wall + clr;
function B(p) = [bx0 + p[1], by0 + rem_w - p[0]];   // board -> box coordinates

boss_d  = 4.4;    // lid screw bosses (M2 self-tapping, 1.6 pilot)
bosses  = [ [wall + Li - boss_d/2, wall + boss_d/2],
            [wall + Li - boss_d/2, wall + Hi - boss_d/2] ];

cable_d = 4.5;    // 4 x 0.22 cable

// socket for "6 mm" PP corrugated conduit (OD 9.2, ID 6, pitch 2.5, valley 6.8)
// under the box, cable end. Sealing: 3:1 ADHESIVE-lined heat-shrink across
// socket and conduit. Internal snap rings engage the conduit grooves.
tube_od   = 9.2;
tube_val  = 6.8;     // outer diameter in the grooves (A - 2E)
tube_p    = 2.5;     // corrugation pitch
sock_bore = tube_od + 0.4;
sock_wall = 1.6;
sock_od   = sock_bore + 2*sock_wall;   // ~12.8
sock_len  = 14;      // socket depth
snap_n    = 2;       // snap rings (0 = none)
snap_d    = 8.4;     // ring inner diameter (between valley 6.8 and crest 9.2)
fit_x     = Li + 2*wall - 12;          // position along the box (*_raw coordinates)
fit_zc    = sock_od/2;                 // socket axis: tangent to the floor (z=0), prints without supports
pc_c    = [bx0 + 40, by0 + 5.05];   // PC817 centre in the battery cut-out

// lid closure on the antenna end: 2 EXTERNAL lugs (outside the cord ring)
// with NYLON M3 screw and nylon M3 nut slid sideways into a slot
lug_l   = 7;      // lug protrusion from the wall
lug_w   = 8;      // width
lug_top = 6;      // thickness of the solid part (45 degree gusset below)
lug_ys  = [8, H_ext - 8];
nut_af  = 5.8;    // nylon M3 nut (5.5 + clearance)
nut_t   = 2.7;

// ---------------- Clamp ----------------
cw      = 22;
hole_dx = 6;      // M2 screws from inside the box into the clamp inserts
grip    = 18;
gap     = 6;
jt_up   = 7;
jt_lo   = 5;
sp      = 6;      // back (hosts the M3 joining screws)
c_tip   = 1;
bolt_u  = 11;
y_back  = 20;     // box back distance from the wall
f_t     = 4;
z_fl    = -35;    // flange bottom = box top
fl_d    = D_base - sk_h - 0.6;   // shorter flange: leaves room for the lid skirt

// =====================================================================
module box_raw() {
  difference() {
    union() {
      linear_extrude(D_base) outline2d();
      // tubular conduit socket, pointing down
      translate([fit_x, 0.01, fit_zc]) rotate([90,0,0]) cylinder(d=sock_od, h=sock_len + 0.01);
      // closure lugs on the antenna end (45 degree gusset below: no supports)
      for (y = lug_ys) hull() {
        translate([-lug_l, y - lug_w/2, D_base - lug_top]) cube([lug_l + 0.01, lug_w, lug_top]);
        translate([-0.01, y - lug_w/2, max(0, D_base - lug_top - lug_l)])   // never below the floor
          cube([0.02, lug_w, D_base - max(0, D_base - lug_top - lug_l)]);
      }
    }
    // lugs: M3 through hole and side slot for the nut
    for (y = lug_ys) {
      translate([-lug_l/2, y, D_base - lug_top - lug_l - 1]) cylinder(d=3.4, h=lug_top + lug_l + 2);
      translate([-lug_l - 1, y - nut_af/2, D_base - lug_top + 1.3]) cube([lug_l/2 + 1 + nut_af/2, nut_af, nut_t]);
    }
    // cavity with corners concentric to the outline (uniform wall thickness)
    translate([0, 0, floor_t]) linear_extrude(Di + 1) offset(r=-wall) outline2d();
    // conduit seat in the socket (stop 1 mm from the wall)
    difference() {
      translate([fit_x, -sock_len - 1, fit_zc]) rotate([-90,0,0]) cylinder(d=sock_bore, h=sock_len);
      // snap rings: engage the conduit grooves
      for (i = [1 : snap_n]) if (snap_n > 0)
        translate([fit_x, -sock_len + i*tube_p*2 - 0.25, fit_zc]) rotate([-90,0,0])
          difference() { cylinder(d=sock_bore + 1, h=0.5); translate([0,0,-1]) cylinder(d=snap_d, h=3); }
    }
    // cable passage through the bottom wall
    translate([fit_x, -1.5, fit_zc]) rotate([-90,0,0]) cylinder(d=5.5, h=wall + 2);
    // drain hole on the bottom side
    translate([bx0 + 30, -1, floor_t + 0.9]) rotate([-90,0,0]) cylinder(d=1.5, h=wall + 2);
    // clamp screw holes (top side)
    for (s=[-1,1]) translate([L_ext/2 + s*hole_dx, H_ext - wall - 1, fl_d/2])
      rotate([-90,0,0]) cylinder(d=2.3, h=wall + 2);
    // cord groove on top of the walls
    translate([0,0,D_base - gr_d]) linear_extrude(gr_d + 1) ring2d(gr_w);
  }
  // lid screw bosses
  for (p = bosses) translate([p[0], p[1], floor_t]) difference() {
    cylinder(d=boss_d, h=Di);
    translate([0,0,Di-6]) cylinder(d=1.6, h=7);
  }
  // board supports: a plastic pin in each of the 3 holes, protruding above the
  // board by stake_h mm; heat-stake it with the soldering iron (no metal:
  // the antenna and SMD parts are close to the holes)
  for (h = rem_holes) {
    p = B([h[0], h[1]]);
    translate([p[0], p[1], floor_t]) {
      cylinder(d=h[2] + 1.8, h=so_h);                               // support
      cylinder(d=pin_d, h=so_h + pcb_t + stake_h, $fn=24);          // pin
    }
  }
  // PC817 cradle (mounted upside down, legs up: easy to solder)
  for (s=[-1,1]) translate([pc_c[0] + s*(2.45 + 0.75) - 0.75, pc_c[1] - 2, floor_t])
    cube([1.5, 4, 1.8]);
}

// 2D ring on the wall centre line, width w
// outer outline with rounded corners
module outline2d() {
  translate([corner_r, corner_r]) offset(r=corner_r)
    square([L_ext - 2*corner_r, H_ext - 2*corner_r]);
}

// 2D ring on the wall centre line, width w (follows the rounded corners)
module ring2d(w) {
  difference() {
    offset(r = -(wall/2 - w/2)) outline2d();
    offset(r = -(wall/2 + w/2)) outline2d();
  }
}

// preview only: the cord in its groove
module cord() linear_extrude(cord_d) ring2d(cord_d);

module lid_raw() {
  o = sk_g + sk_t;
  difference() {
    union() {
      linear_extrude(lid_t) offset(r=o) outline2d();
      // lid ears over the lugs
      for (y = lug_ys) translate([-lug_l, y - lug_w/2, 0]) cube([lug_l + 0.01, lug_w, lid_t]);
      // skirt / drip edge all around
      translate([0,0,-sk_h]) linear_extrude(sk_h + 0.01) difference() {
        offset(r=o) outline2d();
        offset(r=sk_g) outline2d();
      }
    }
    for (p = bosses) translate([p[0], p[1], -1]) cylinder(d=2.4, h=lid_t + 2);
    for (y = lug_ys) translate([-lug_l/2, y, -1]) cylinder(d=3.4, h=lid_t + 2);
    // no skirt on the antenna end: the lugs are there
    translate([-10, -10, -sk_h - 1]) cube([10 + corner_r, H_ext + 20, sk_h + 1 - 0.01]);
    // skirt shaped around the socket (0.2 mm clearance): no side gaps.
    // Sealing is done by the continuous cord on top of the walls.
    translate([fit_x, -0.25, fit_zc - D_base]) rotate([90,0,0])
      cylinder(d=sock_od + 0.4, h=sk_g + sk_t + 1, $fn=64);
  }
}

// ---------------- clamp ----------------
module lipframe() {
  multmatrix([[1, 0,           0,          0],
              [0, -cos(lip_a), sin(lip_a), lip_out],
              [0, sin(lip_a),  cos(lip_a), -lip_drop],
              [0, 0,           0,          1]]) children();
}
// The clamp is in TWO PARTS, both printable without supports:
//  - "clamp": lower jaw + back + link to the box flange
//             (print lying on its SIDE)
//  - "visor": visor + upper jaw with M4 nut
//             (print with the visor flat on the bed)
// The two parts are joined with 2 M3 self-tapping screws into the back.
// The flashing slides between the lower jaw (with rubber pad) and the visor;
// the M4 screw goes through the upper jaw and visor and presses the sheet.
vis_ext = 10;                    // overhang beyond the flashing edge
vis_w   = L_ext + 10;            // visor width (box + 5 mm per side)
vis_t   = 1.6;                   // visor thickness
vis_v0  = lip_t/2 + 0.2;         // visor bottom face, just above the sheet metal
scr_dx  = 6;                     // M3 joining screws in the back
v_top   = gap/2 + jt_up;         // top of the upper jaw

module lower_jaw()  translate([-cw/2, -c_tip-sp, -gap/2-jt_lo]) cube([cw, c_tip+sp+grip, jt_lo]);
module spine_low()  translate([-cw/2, -c_tip-sp, -gap/2-jt_lo]) cube([cw, sp, gap/2 + jt_lo + vis_v0]);
module flange()     translate([-cw/2, y_back, z_fl]) cube([cw, fl_d, f_t]);

// upper part, in flashing coordinates (u along the slope, v perpendicular)
module visor_local() {
  difference() {
    union() {
      translate([-vis_w/2, -vis_ext, vis_v0]) cube([vis_w, vis_ext + grip, vis_t]);           // visor
      translate([-cw/2, -c_tip-sp, vis_v0 + vis_t - 0.01]) cube([cw, c_tip+sp+grip, v_top - vis_v0 - vis_t]); // upper jaw
    }
    // drip groove on the underside, near the outer edge
    translate([-vis_w/2 - 1, -vis_ext + 1.5, vis_v0 - 0.1]) cube([vis_w + 2, 1.0, 0.8]);
    // M4 screw, captive nut and wide hole in the visor to insert the nut
    translate([0, bolt_u, vis_v0 - 1]) cylinder(d=4.4, h=v_top + 2);
    translate([0, bolt_u, vis_v0 + vis_t - 0.01]) cylinder(d=7.3/cos(30), h=3.4, $fn=6);
    translate([0, bolt_u, vis_v0 - 1]) cylinder(d=9, h=vis_t + 1);
    // M3 joining screws into the back
    for (s=[-1,1]) translate([s*scr_dx, -c_tip - sp/2, vis_v0 - 1]) cylinder(d=3.4, h=v_top + 2);
  }
}

module clamp() {
  difference() {
    union() {
      lipframe() { lower_jaw(); spine_low(); }
      hull() { lipframe() lower_jaw(); flange(); }
    }
    // M3 self-tapping pilot holes in the back (joins the visor)
    lipframe() for (s=[-1,1]) translate([s*scr_dx, -c_tip - sp/2, vis_v0 - 8]) cylinder(d=2.5, h=8.1);
    // M2 heat-set inserts (from below) to fix the box
    for (s=[-1,1]) translate([s*hole_dx, y_back + fl_d/2, z_fl - 1]) cylinder(d=3.2, h=5);
  }
}

// visor oriented for printing: bottom face on the bed
module visor() translate([0, 0, -vis_v0]) visor_local();

// ---------------- preview: board, PC817, wires ----------------
zb = floor_t + so_h + pcb_t + 1.0;     // wires above the board
zl = floor_t + 6.5;                    // PC817 leg tips
zf = floor_t + 1.5;                    // low wires in the cut-out

module wire(pts, c) color(c)
  for (i = [0:len(pts)-2]) hull() {
    translate(pts[i])   sphere(d=0.9, $fn=8);
    translate(pts[i+1]) sphere(d=0.9, $fn=8);
  }

module preview_inside_raw() {
  // remote board (L-shaped)
  color("green") translate([0,0,floor_t + so_h]) linear_extrude(pcb_t)
    polygon([B([0,0]), B([rem_w,0]), B([rem_w,cut_yr]), B([cut_xr,cut_yr]),
             B([cut_xr,rem_len]), B([0,rem_len])]);
  // antenna area
  color("gold", 0.5) translate([bx0, by0, floor_t + so_h + pcb_t]) cube([5, rem_w, 0.3]);
  // buttons
  for (b = [[7.6,7.8],[21.4,7.8]]) { p = B(b);
    color("silver") translate([p[0]-1.75, p[1]-3, floor_t+so_h+pcb_t]) cube([3.5, 6, 3.5]); }
  // PC817 upside down
  color("black") translate([pc_c[0]-2.3, pc_c[1]-3.25, floor_t]) cube([4.6, 6.5, 3.5]);
  for (dx=[-1.27,1.27], dy=[-3.81,3.81])
    color("silver") translate([pc_c[0]+dx, pc_c[1]+dy, floor_t+1.75]) cylinder(d=0.5, h=4.8);

  E   = [fit_x, wall + 0.4, fit_zc];         // cable entry from the socket
  P1  = [pc_c[0]-1.27, pc_c[1]-3.81, zl];   // LED anode
  P2  = [pc_c[0]+1.27, pc_c[1]-3.81, zl];   // LED cathode
  P4  = [pc_c[0]-1.27, pc_c[1]+3.81, zl];   // collector
  P3  = [pc_c[0]+1.27, pc_c[1]+3.81, zl];   // emitter
  pp = B(pad_plus); pg = B(pad_gnd); ph = B(btn_hi); pl = B(btn_lo);

  wire([E, [fit_x + 0.8, by0 + 9.7, zb], [pp[0], by0 + 9.7, zb], [pp[0], pp[1], zb-0.6]], "red");
  wire([E, [fit_x + 1.6, by0 + 10.5, zb], [pg[0], by0 + 10.5, zb], [pg[0], pg[1], zb-0.6]], "dimgray");
  wire([E, [fit_x - 1.0, by0 + 0.1, zf], [P1[0], by0 + 0.1, zf], P1], "orange");
  wire([E, [fit_x - 0.4, by0 + 1.1, zf-0.9], [P2[0], by0 + 1.1, zf-0.9], P2], "saddlebrown");
  wire([P4, [P4[0]-1, by0+18.2, zb+0.8], [ph[0]+2.4, by0+18.2, zb+0.8], [ph[0]+2.4, ph[1], zb+0.8],
        [ph[0], ph[1], zb-0.6]], "yellow");
  wire([P3, [P3[0]-1, by0+17.0, zb+0.8], [pl[0]+1.4, by0+17.0, zb+0.8], [pl[0], pl[1], zb-0.6]], "limegreen");
  // corrugated conduit and heat-shrink (reference)
  color("white") translate([fit_x, -1, fit_zc]) rotate([90,0,0]) cylinder(d=tube_od, h=40);
  color("black", 0.5) translate([fit_x, -sock_len + 7, fit_zc]) rotate([90,0,0])
    cylinder(d=sock_od + 0.6, h=14);
}

// ---------------- real-world orientation ----------------
// The *_raw modules are drawn with the antenna at X=0. To get, once mounted
// (lid facing out, drain side down), the antenna on the gate
// side, the mirrored version is needed: antenna at large X, cable at X=0.
// The board hole pattern is symmetric, so the board still fits.
module mirror_x() translate([L_ext, 0, 0]) mirror([1, 0, 0]) children();

module box()            mirror_x() box_raw();
module preview_inside() mirror_x() preview_inside_raw();

module lid() mirror_x() lid_raw();

module to_world() {
  multmatrix([[-1,0,0, L_ext/2],
              [0,0,1, y_back],
              [0,1,0, z_fl - H_ext],
              [0,0,0, 1]]) children();
}

module assembly() {
  color("teal") to_world() box();
  to_world() preview_inside();
  color("black") to_world() translate([0,0,D_base - gr_d + 8]) cord();     // exploded cord
  color("teal", 0.25) to_world() translate([0,0,D_base + 15]) lid();       // exploded lid
  color("orchid") clamp();
  color("plum") lipframe() visor_local();
  %lipframe() translate([-60, 0, -lip_t/2]) cube([120, lip_len, lip_t]);
  %translate([-60, -20, -90]) cube([120, 20, 90]);
}

if      (part == "box")    box();
else if (part == "lid")    { if (lid_flip) translate([0,0,lid_t]) rotate([180,0,0]) lid(); else lid(); }
else if (part == "clamp") clamp();
else if (part == "visor") visor();
else                      assembly();

// check: the socket must not exceed the box rim (the lid must close on the cord)
assert(sock_od <= D_base, "socket taller than the box: increase Di or reduce sock_wall");
