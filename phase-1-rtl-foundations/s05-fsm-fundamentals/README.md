# Session 5: FSM Fundamentals

## Concepts Covered

### Moore vs. Mealy
- Moore: output = f(current state) — changes only on clock edge, stable for the full cycle
- Mealy: output = f(current state, current input) — combinational, follows the input mid-cycle
- Mealy creates a primary-input-to-primary-output combinational path; downstream FFs risk setup/hold violation → metastability
- Default to Moore for inter-module signals; reserve Mealy for top-level outputs or where one-cycle latency matters

### The 3-Always-Block Pattern
- **Block 1 (`always_ff`)**: `state <= next_state` plus reset — the sole sequential block
- **Block 2 (`always_comb`)**: next-state case; assign a default at top to prevent latch on a missing path
- **Block 3 (`always_comb`)**: output case; same default-at-top rule
- Separation gives the synthesizer unambiguous FF vs. LUT cones and confines Moore ↔ Mealy swaps to block 3

### State Encoding & Artix-7 Slice Economics
- Slice = 4 LUT6 + 8 FFs → FFs are 2× more abundant than LUTs
- **Binary** — `$clog2(N)` FFs but dense multi-bit-compare LUT cost for next-state
- **One-hot** — N FFs but each next-state bit is typically a 2–4 input OR in a single LUT6
- Vivado defaults to one-hot for FSMs under ~16 states; binary takes over above ~16–32 (FF cost + fanout dominate)
- Force with `(* fsm_encoding = "one_hot" *)` / `"sequential"` attribute

### Enum Pattern
- `typedef enum logic [N:0] {S_A, S_B, ...} state_t;` in `project_pkg.sv` — explicit width required
- Surfer renders `state.name()` instead of hex — essential for FSM debugging
- Always include `default:` even with enums (guards X-state from power-up glitches or SEUs)

### State vs. Register
- **State** = "which phase of control flow am I in?" — enumerable, bounded
- **Register** = "what value am I tracking?" — its derived predicates (`counter == MAX`) may gate transitions; the value itself is data
- Heuristic: if folding the info into the state creates a bounded count → state; if it scales with a parameter or data width → register

## Deliverables

| File | Description |
|------|-------------|
| `project_pkg.sv` | Typed enums: `moore_state_t` (5-state, 3-bit), `mealy_state_t` (Mealy, 4-state, 2-bit), `btn_state_t` (4-state, 2-bit) |
| `seq_detect_moore.sv` / `seq_detect_moore_tb.sv` | 5-state Moore "1101" detector with overlap; `detected = (CS == MO_DONE)`|
| `seq_detect_mealy.sv` / `seq_detect_mealy_tb.sv` | 4-state Mealy "1101" detector; `detected` combinational in `ZERO_1` when `in == 1`|
| `button_debouncer.sv` / `button_debouncer_tb.sv` | 4-state Moore debouncer + parameterized counter (`CLK_HZ`, `DEBOUNCE_MS`, `$clog2`-sized)|

## Tools Used
- **Verilator**: `--lint-only -Wall` — all three modules clean
- **Icarus Verilog**: `-g2012` for SystemVerilog simulation
- **Surfer**: FST waveform inspection with typed-enum state labels