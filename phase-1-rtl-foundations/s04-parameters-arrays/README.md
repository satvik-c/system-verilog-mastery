# Session 4: Parameters & Arrays

## Concepts Covered

### `parameter` vs. `localparam`
- `parameter`: instance-overridable knob — exposes design variants via `#(.WIDTH(...))`
- `localparam`: derived constant fixed inside the module — prevents inconsistent override
- Both resolved at elaboration; different values produce different hardware

### `$clog2` Auto-Sizing
- Returns ⌈log₂(N)⌉ — minimum bits to represent `0..N-1`
- Pattern: `localparam ADDR_W = $clog2(DEPTH);` — pointers resize automatically with `DEPTH`
- Edge case: `$clog2(1) = 0` — guard if `DEPTH = 1` is legal
- `$clog2(MAX)` for `MAX` distinct values; `$clog2(MAX+1)` for `0..MAX` inclusive

### Packed Arrays
- `logic [3:0][7:0] bus` — single contiguous 32-bit field, sliceable in any dimension
- Synthesizes to plain wires; no memory primitive
- Use for: packed registers, byte-lane buses, sliceable replicated signals

### Unpacked Arrays & BRAM Inference
- `logic [7:0] mem [0:255]` — collection of independent storage entries; cannot slice across the unpacked dimension
- Synchronous read inside `always_ff` → infers `RAMB18`/`RAMB36` (dedicated tile, effectively free)
- Asynchronous read → falls back to LUTRAM (~32 SLICEM LUTs per 256×8)
- Read latency = 1 clock cycle for synchronous read

### `generate-for` Replication
- Elaboration-time textual replication; `genvar` is resolved away in the final netlist
- Required for module instantiation, per-instance parameter override, or per-instance clock domain
- Named begin label (`begin : g_name`) creates the hierarchical scope for waveform/constraint access
- `for` inside `always` replicates statements within one process; `generate-for` replicates entire structural blocks

## Deliverables
| File | Description |
|------|-------------|
| `param_counter.sv` / `param_counter_tb.sv` | Parameterized counter with `localparam WIDTH = $clog2(MAX_COUNT)`; single-cycle `tick` on wrap; TB instances with `MAX_COUNT = 10` and `100` verify override |
| `counter_array.sv` / `counter_array_tb.sv` | `generate-for` replication of `param_counter` across `N` instances; packed 2D `[N-1:0][WIDTH-1:0]` collected into flattened `count` output |
| `bram_sp.sv` / `bram_sp_tb.sv` | Single-port BRAM with synchronous read; Vivado confirms 1× RAMB18 inference; TB uses `#1`-after-`@(posedge clk)` to avoid active-region race |

## Tools Used
- **Verilator**: `--lint-only -Wall` for compile-time lint
- **Icarus Verilog**: `-g2012` for SystemVerilog simulation
- **Surfer**: FST waveform inspection — verified per-instance hierarchy at `g_count[i].u_count`
- **Vivado**: synthesis + `report_utilization` to confirm BRAM vs. LUTRAM inference