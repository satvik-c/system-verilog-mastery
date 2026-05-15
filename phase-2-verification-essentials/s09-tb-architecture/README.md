# Session 9: TB Architecture

## Concepts Covered

### Testbench Structure
- TB is a `module` with no ports — instantiates DUT internally, non-synthesizable
- Naming convention: `<dut>_tb`
- Clock: `initial clk = 1'b0;` + `always #5 clk = ~clk;` — must initialize, else `~X = X` stalls forever
- Reset: hold ≥ 5 cycles, release synchronous to a clock edge with `#1`

### Standing TB Timing Convention
- Pattern: `@(posedge clk); #1 signal = value;` for every stimulus assignment, reset included
- Active-region race: TB's blocking assignment and DUT's `always_ff` both trigger at the same edge; ordering not language-defined
- `#1` shifts the assignment past the NBA region → DUT samples old value at *this* edge, new value at *next* edge → deterministic

### Tasks vs. Functions
- `function`: zero simulation time, returns value, no `#`/`@`/`wait` — pure computation only
- `task`: consumes simulation time, can suspend on events — multi-cycle stimulus
- `automatic` on both → each call gets its own local storage

### Simulation Control & Waveform Dumping
- `$display`, `$time`, `$finish`, `$fatal` for console output and termination
- `$dumpfile("name.fst")` + `$dumpvars(0, tb_module)` → full hierarchy (depth 0 = recursive)
- Timing operators: `#N`, `@(posedge clk)`, `repeat(N) @(posedge clk);`, `wait(expr)`

## Common Bugs
- Missing `initial clk = 0;` → clock stays `X` forever
- Missing `#1` after `@(posedge clk)` → Active-region race
- Uninitialized stimulus inputs → X-propagation on first post-reset edge
- `function` containing `#`/`@` → compile error
- Missing `$finish` → simulator hangs

## Deliverables
| File | Description |
|------|-------------|
| `counter_tb.sv` | TB skeleton applied to `param_counter`; task for enable bursts, function for predicted count, `$display` observation |
| `traffic_light_tb.sv` | Skeleton applied to `traffic_light` FSM; per-mode stimulus tasks, state transition logger via `.name()` on enum |

## Tools Used
- **Verilator**: lint and simulation (`--lint-only -Wall`, `--trace-fst` for FST output)
- **Surfer**: FST waveform inspection; auto-decodes enums to symbolic names