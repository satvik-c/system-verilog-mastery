# Session 8: Vivado Mastery

## Concepts Covered

### Full Vivado Flow
- `read_verilog` / `read_xdc` → `synth_design` → `opt_design` → `place_design` → `phys_opt_design` → `route_design` → `write_bitstream`
- Synthesis output (netlist) and post-synth reports are estimates; post-route reports are truth
- Checkpoints (`.dcp`) snapshot state per stage → retry implementation without re-synth

### Failure Mode Classification
- **Synthesis errors** → RTL bug (multi-driver, latch inference) → fix `.sv`
- **Implementation errors** → XDC or physical bug (pin conflict, unrouteable, timing fail) → fix `.xdc` or restructure RTL

### XDC Constraints
- Required per port: `PACKAGE_PIN`, `IOSTANDARD`, plus `create_clock` for clock inputs
- `create_clock` does NOT gate whether design runs — clock signal still propagates from pad to FFs
- Missing `create_clock` → bitstream works, but `report_timing_summary` reports unconstrained paths → zero timing validation
- Active polarity must match RTL: `CPU_RESETN` active-low (C12), `BTNC` active-high (N17)
- Nexys A7 banks 14/15/16/35 are LVCMOS33; SW[8:9] (bank 34) are LVCMOS18

### Timing Reports
- **WNS ≥ 0** → timing met
- **Fmax = 1 / (T_clk − WNS)** — but only meaningful at the tightest constraint where timing met
- Loose constraint gives lower-bound Fmax; tight constraint forces tool to optimize harder and reveals true Fmax

### Critical Path Diagnosis
- **Logic delay dominant** → restructure to balanced tree (preferred, no latency cost) or pipeline (adds cycles)
- **Net delay dominant** → high fanout / scattered placement → replicate driver or floorplan
- Pipelining halves both logic AND net delay per stage but adds latency

### WSL Bring-Up
- USB JTAG does not pass through WSL → run `hw_server.bat` on Windows, connect from WSL via `connect_hw_server -url localhost:3121`
- `get_hw_devices xc7a100t*` wildcard for portability

## Deliverables

| File | Description |
|------|-------------|
| `build.tcl` | Non-project flow: read s06 RTL, synth → impl → bitstream, dump post-route reports |
| `program.tcl` | Flash bitstream over WSL TCP bridge to Nexys A7 |
| `xdc/Nexys-A7-100T-Master.xdc` | Modified Digilent master: `clk` (E3), `mode[1:0]` (SW0/SW1), `rst` (BTNC), `ns_light[2:0]` and `ew_light[2:0]` mapped to RGB LEDs LD16/LD17 for color-accurate traffic light display |
| `build/util_impl.rpt`, `build/timing_impl.rpt` | Post-route utilization and timing |
| `build/traffic_light.bit` | Final bitstream verified on Nexys A7 |

## Tools Used

- **Vivado** (WSL): `vivado -mode batch -source build.tcl && vivado -mode batch -source program.tcl`
- **hw_server** (Windows): JTAG bridge on `localhost:3121`