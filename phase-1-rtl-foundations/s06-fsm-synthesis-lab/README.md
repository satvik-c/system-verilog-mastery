# Session 6: FSM Synthesis Lab

## Concepts Covered

### Vivado Synthesis Flow

- Stages: `synth_design` → `opt_design` → `place_design` → `route_design` → `write_bitstream`
- Synthesis errors = RTL bugs (latches, multi-driver); implementation errors = physical (pins, congestion, timing)
- Synthesis alone sufficient for encoding comparison; full P&R required for board-accurate timing

### FSM Encoding Attribute

- `(* fsm_encoding = "one_hot" | "sequential" | "gray" | "auto" | "none" *)` attached to state register declaration
- Synthesis-only directive; enum semantics and simulation behavior unchanged
- Vivado default for FSMs <16 states is one-hot

### One-Hot vs. Binary Trade-offs

- One-hot: N FFs, per-bit next-state ≈ OR of (predecessor AND transition_cond) — fits LUT4/LUT5 regardless of N
- Binary: ⌈log₂N⌉ FFs, per-bit next-state is wider function of all state bits + inputs
- One-hot's LUT advantage emerges at >~16 states or FSMs with many input-conditional transitions
- One-hot implements "stay in state" via FF clock-enable (CE) on FDRE/FDSE; binary muxes current state back through D
- Artix-7 favors one-hot: 8 FFs/slice abundant, LUT6 capacity is the scarce resource

### Utilization Reports

- "Slice LUTs" = post-combining count (multiple logical LUTs may pack into one LUT6 site)
- "Slice Registers" = FF count, subdivided by Reset/Set, sync/async, CE
- Primitives section lists raw logical LUT counts (LUT2–LUT6) before combining

### Timing Reports & WNS

- WNS = smallest setup-side margin across all paths; WNS ≥ 0 → timing met
- Fmax = 1 / (T_clk_declared − WNS)
- THS / WHS = hold side; hold violations are physical and cannot be fixed by slowing the clock
- Critical path = source FF clock-to-Q + LUT delays + net delays + destination FF setup
- `report_timing -max_paths 1 -path_type full` walks worst path cell-by-cell

### Critical Path Pipelining

- High-fanout combinational signals on critical paths can be cut by registering them
- Cost: +1 cycle latency; FSM must compensate (e.g., adjust terminal count)
- Canonical timing-closure move when WNS is negative on clean RTL

## Deliverables

| File | Description |
|------|-------------|
| `project_pkg.sv` | `fsm_state_t` (8-state enum), `light_t` (4-value), `mode_t` (3-value) typedefs |
| `traffic_light.sv` | 3-always-block multi-mode controller (NORMAL / FLASH / PED), parameterized `COUNT_MAX` |
| `traffic_light_tb.sv` | Stimulus across all three modes; manual FST waveform inspection |
| `traffic_light.xdc` | 100 MHz `create_clock` on `clk` |
| `util_onehot.rpt` / `util_binary.rpt` | Synthesis utilization reports per encoding |
| `timing_onehot.png` / `timing_binary.png` | WNS / THS / WPWS summary captures |
| `critical_path_onehot.png` / `critical_path_binary.png` | Per-segment critical path delay breakdown |

## Encoding Comparison

| Metric | One-Hot | Binary |
|---|---|---|
| State register FFs | 8 | 3 |
| Counter FFs | 3 | 3 |
| Total Slice Registers | 11 | 6 |
| Slice LUTs (post-combining) | 10 | 9 |
| WNS on 10 ns clock | +7.496 ns | +7.483 ns |
| Critical path delay | 2.504 ns | 2.517 ns |
| Logic levels on critical path | 1 LUT5 | 1 LUT6 + 1 LUT4 |
| Implied Fmax | ~399 MHz | ~397 MHz |
| Critical path source → sink | `FSM_onehot_CS_reg[0]/C` → `FSM_onehot_CS_reg[0]/CE` | `FSM_sequential_CS_reg[1]/C` → `counter_reg[1]/D` |

**Note:** `counter_done` sits on the critical path in both encodings since its a high-fanout combinational signal computed from state, consumed by next-state logic and counter reset.

## Tools Used

- **Vivado 2025.2**: `synth_design`, `report_utilization`, `report_timing_summary` on `xc7a100tcsg324-1`
- **Verilator**: SystemVerilog compilation and simulation
- **Surfer**: FST waveform inspection across mode transitions