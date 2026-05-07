# Session 2: Intentional Blocks

## Concepts Covered

### The Three Procedural Blocks
- `always_comb` — combinational contract: every output assigned on every path, complete sensitivity inferred automatically; maps to **LUT6** network on Artix-7
- `always_ff` — sequential contract: must contain a clock edge (`posedge`/`negedge`), uses `<=` (non-blocking); maps to **FDRE/FDCE** flip-flop primitives
- `always_latch` — intentional latch declaration; Artix-7 has no latch primitive — implemented via LUT feedback loop (wastes resources, breaks static timing analysis)

### Latch Inference — The #1 RTL Bug
- Missing `else`, incomplete `case`, or partial multi-output assignment in `always_comb` → latch inferred to hold previous value
- **Fix pattern:** assign defaults at the top of every `always_comb` block before any conditional logic — synthesizer optimizes away unreachable defaults
- `default` case protects against 4-state inputs (X/Z in simulation) that binary-exhaustive branches do not cover
- Verilator `--lint-only -Wall` catches all latch inference at compile time

### Synchronous vs. Asynchronous Reset
- **Sync reset** (`always_ff @(posedge clk)` + `if(rst)`): reset is data on the D pin, evaluated only on clock edges; maps to **FDRE** primitive
- **Async reset** (`always_ff @(posedge clk or posedge rst)` + `if(rst)`): FF clears immediately on `rst` assertion regardless of clock; maps to **FDCE** primitive (dedicated async clear pin)
- Async reset leaves the clock domain momentarily on release — if `rst` deasserts near a clock edge, setup/hold violation → metastability
- **Default to sync reset on Artix-7** — avoids reset-release metastability, keeps all timing within the clock domain

### `initial` Blocks
- Non-synthesizable on Artix-7 — no hardware mechanism for "run once at power-up"
- Artix-7 FFs default to 0 after bitstream load (`INIT` attribute), but relying on this is fragile and invisible in simulation
- Correct habit: every FF gets an explicit reset in `always_ff`

## Deliverables

| File | Description |
|------|-------------|
| `latch_lab.sv` / `latch_lab_tb.sv` | Three `always_comb` blocks with deliberate latch inference (missing `else`, incomplete `case`, partial multi-output); Verilator warnings captured; fixed with defaults-at-top pattern |
| `reset_compare.sv` / `reset_compare_tb.sv` | Two 8-bit FFs (sync/async reset) on shared clock and data; mid-cycle reset assertion demonstrates `q_async` clearing immediately vs. `q_sync` waiting for next `posedge clk` |

## Tools Used
- **Verilator**: `--lint-only -Wall` for latch inference detection
- **Icarus Verilog**: `-g2012` for SystemVerilog simulation
- **Surfer**: VCD waveform inspection (mid-cycle reset timing, latch hold behavior)