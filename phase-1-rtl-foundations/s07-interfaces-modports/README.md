# Session 7: Interfaces & Modports

## Concepts Covered

### `interface` Construct
- File-scope bundle of related signals declared as raw `logic` (no direction)
- Module port type: `module foo (bus_if.master bus);` — accessed via dot notation
- Elaborates to plain wires — **no hierarchical block in the synthesized netlist**

### `modport` Directional Roles
- Declares per-signal direction from a role's perspective (master/slave, producer/consumer)
- Enforcement scoped to the module port that names the modport — raw outer-scope access (`assign bus.signal = ...`) bypasses checks
- One interface instance can be connected with different modports to different modules

### When NOT to Use Interfaces
- Threshold: 4+ related signals forming a protocol that travel together
- Plain ports preferred for clk/rst/single-bit enables — bundling clk/rst is stylistic, not architectural
- Real justification: bidirectional traffic, handshake protocols, status feedback paths

### `generate for` Unrolling
- Unrolls at elaboration time — N iterations produce N parallel hardware instances; `genvar` has no runtime existence
- `begin : label` required for instances; produces indexed names `label[i].inst_name`
- **N=1 still produces `label[0]`** — bracket indexing is intrinsic to `for` generate

### Interface + Generate Idiom
- Interface instance declared inside generate body → per-iteration bundle, distinct scope each iteration
- Outer-scope assigns drive interface signals (bypasses modport intentionally); submodule receives via modport view

### Synthesis & Resource Counting
- Every NBA target inside `always_ff` infers FFs — count single-bit registered outputs (e.g., `pulse`), not just multi-bit state
- `pulse_channel`: 16-bit `counter` + 1-bit registered `pulse` = **17 FFs/instance**; `multi_channel` w/ `NUM_CHANNELS=4` = **68 FFs total**

## Deliverables

| File | Description |
|------|-------------|
| `bus_pkg.sv` | FSM state enum `state_t` (IDLE/WRITE/READ/DONE) |
| `bus_if.sv` | 6-signal bus interface (`addr`, `wdata`, `rdata`, `write_en`, `read_en`, `ready`) with `master` and `slave` modports |
| `bus_master.sv` | 3-block FSM master driving bus combinationally; NBA `latched_rdata` captures read data one cycle after `READ` state entry |
| `bus_slave.sv` | 8-entry register array; combinational read via address slicing, synchronous write, `ready` tied high |
| `bus_if_tb.sv` | Sequential write 0–7 → read 0–7; `@(posedge clk); #1` stimulus convention |
| `channel_if.sv` | 3-signal interface (`enable`, `period`, `pulse`) with `producer` and `consumer` modports |
| `pulse_channel.sv` | 16-bit counter; registered 1-cycle pulse on `counter == period-1`|
| `multi_channel.sv` | Parameterized wrapper instantiating `NUM_CHANNELS` channels via `generate for`; per-iteration `channel_if` inside generate body |
| `multi_channel_tb.sv` | 4-channel test (periods 10/20/30/40)|

## Tools Used
- **Verilator**: `--lint-only -Wall` — modport direction violations and width mismatches
- **Icarus Verilog**: `-g2012` simulation
- **Surfer**: FST waveform inspection; verify per-iteration generate hierarchy (`gen_chan[0..3].channel`, `gen_chan[0..3].u_channel`)