# remote_condo_gate

Open a condominium garage gate from Home Assistant **without touching the gate
installation**: an ESP32 "presses" the button of an original (cloned) 12 V gate
remote through an optocoupler. The remote sits in a small weatherproof box hung
under the balcony's copper flashing; the ESP32, the 230 V power supply and a
5 → 12 V step-up live in a second sealed box nearby.

```
230 V ─► [inner box]  HLK-5M05B 5 V ─► ESP32 (GPIO4) ─┐
                                    └► MT3608 12 V ─┐ │
                                                    │ │  4-wire cable in a
                                                    ▼ ▼  6 mm corrugated conduit
                          [outer box]  12 V gate remote ◄─ PC817 optocoupler
```

## Repository layout

| Path | Content |
|---|---|
| `docs/wiring.svg` / `.png` | Wiring diagram |
| `esphome/remote-condo-gate.yaml` | ESPHome configuration (one "Open gate" button) |
| `cad/outer_box.scad` | Outer box, lid, two-part flashing clamp + visor |
| `cad/inner_box.scad` | Inner box for PSU, ESP32 and step-up, lid |

## Electronics

![Wiring diagram](docs/wiring.svg)

**Wiring**

| From | To |
|---|---|
| ESP32 GPIO4 → 1 kΩ | PC817 pin 1 (anode) |
| ESP32 GND | PC817 pin 2 (cathode) |
| PC817 pin 4 (collector) | remote button pad on the ~11.5 V side |
| PC817 pin 3 (emitter) | other remote button pad (NOT ground) |
| MT3608 OUT+ (set to 12.0 V) | remote former battery + contact |
| MT3608 OUT− / GND | remote former battery − contact |

Cable between the boxes: 4 × 0.22 mm² (+12 V, GND, LED+, LED−) in a
"6 mm" PP corrugated conduit (measured OD ~10.5 mm, annular corrugation).

Notes:
- The remote used here is a self-learning fixed-code duplicator with an
  always-powered MCU; its button carries only ~0.3 mA, so a PC817C is plenty.
- Avoid ESP32 strapping pins (0, 2, 5, 12, 15) for the output.
- Set the MT3608 to 12.0 V **with no load** before connecting the remote.

**Main parts**

- ESP32 DevKit 30 pin (WROOM)
- Hi-Link HLK-5M05B on a 4 × 6 cm perfboard, with fuse, varistor and output capacitor
- MT3608 step-up module
- PC817C (DIP-4), 1 kΩ resistor
- Cloned 12 V gate remote (battery holder removed)
- 1.5 mm **solid** silicone O-ring cord (~60 cm for both boxes)
- M16 × 1.5 IP68 cable gland (230 V cable)
- 6 mm PP corrugated conduit + 3:1 adhesive-lined heat-shrink
- Nylon M3 × 10 screws and nuts, M2 / M3 self-tapping screws, M2 heat-set inserts, M4 stainless screw + nut
- EPDM foam weather strip (under the visor's upper edge)

## ESPHome

`esphome/remote-condo-gate.yaml` exposes a single **Open gate** button. Each
press drives GPIO4 high for 500 ms, followed by a 3 s lockout so that double
taps do not send two pulses. Wi-Fi, API, OTA and logging come from a shared
package (`packages: common: !include ...`): adjust the path to your own file.

## 3D printing (OpenSCAD)

Select the part with the `part` variable at the top of each file and export STL.

| File | Parts | Orientation |
|---|---|---|
| `outer_box.scad` | `box`, `lid`, `clamp`, `visor` | box: floor down · lid & visor: exported ready · clamp: lay on its side |
| `inner_box.scad` | `box`, `lid` | box: floor down · lid: exported ready |

Material: **ASA** in a light colour (UV resistant, stays cooler in the sun).
4 walls, 5 top/bottom layers; clamp 50–60 % gyroid, boxes 25–30 %.

**Optional private emblem:** both files `include <logo_local.scad>`. If that
file exists in `cad/` (it is git-ignored) it can engrave an emblem on the lids
or provide a `logo_mod` slicer modifier; without it OpenSCAD just warns about
the missing include and the lids stay plain.

## Assembly notes

- Heat-stake the remote board pins and the PSU board pins with the soldering iron (no metal near the antenna).
- Seal the conduit to its socket with adhesive heat-shrink; make a drip loop before every cable entry.
- Put a silica gel sachet in each box.
- Test the radio range with the remote already inside the closed box, in its final position.
