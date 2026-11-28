// =====================================================================
//  remote_condo_gate - in-line COUPLER for two segments of the corrugated
//  conduit (same socket as the boxes: bore, snap rings, central stop).
//  Sealing and fixing: one piece of 3:1 ADHESIVE-lined heat-shrink across
//  conduit - coupler - conduit.
//  Parametric - OpenSCAD 2021+
//
//  Print: standing on one end (axis vertical), no supports, ASA,
//  4 walls (the wall is printed solid). All internal overhangs are 45 deg.
// =====================================================================

tube_od   = 10.5;          // conduit outer diameter (same value as the boxes; set 10.0 if yours is smaller)
tube_p    = 2.5;           // corrugation pitch
sock_bore = tube_od + 0.4; // bore
sock_wall = 1.6;           // wall around the bore
sock_len  = 14;            // insertion depth on each side
snap_n    = 2;             // snap rings per side (0 = none)
snap_d    = tube_od - 0.8; // ring inner diameter: between groove and crest
pass_d    = 7;             // central passage for the wires (4 x 24 AWG or a 4 x 0.22 cable)
stop_t    = 2;             // central stop thickness
lead      = 0.6;           // lead-in chamfer at both mouths

$fn = 96;

r_b  = sock_bore / 2;
r_o  = r_b + sock_wall;
r_sn = snap_d / 2;
r_p  = pass_d / 2;
ch   = r_b - r_p;                       // 45 degree chamfer under the stop (printable)
z_s  = sock_len + ch;                   // stop: bottom of the flat part
L    = sock_len + ch + stop_t + sock_len;

module coupler() {
  rotate_extrude() difference() {
    union() {
      // wall
      translate([r_b, 0]) square([sock_wall, L]);
      // central stop: 45 degree cone below, flat on top
      polygon([[r_b + 0.1, sock_len], [r_p, z_s], [r_p, z_s + stop_t], [r_b + 0.1, z_s + stop_t]]);
      // snap rings: symmetric 45 degree ridges, from each mouth every 2 pitches
      for (i = [1 : snap_n]) if (snap_n > 0)
        for (z = [i*tube_p*2, L - i*tube_p*2])
          polygon([[r_b + 0.1, z - (r_b - r_sn)], [r_sn, z], [r_b + 0.1, z + (r_b - r_sn)]]);
    }
    // lead-in chamfers at the mouths
    polygon([[r_b - 0.01, -0.01], [r_b + lead, -0.01], [r_b - 0.01, lead]]);
    polygon([[r_b - 0.01, L + 0.01], [r_b + lead, L + 0.01], [r_b - 0.01, L - lead]]);
  }
}

coupler();

echo(str("Coupler: OD ", 2*r_o, " mm, length ", L, " mm, insertion ", sock_len, " mm per side, passage ", pass_d, " mm"));
