# Session 3: Types & Packages

## Concepts Covered

### `typedef enum logic [N:0]`

- Named values for FSM states; underlying type is a fixed-width `logic` vector — zero hardware cost beyond the vector itself
- Width MUST be explicit (`logic [N:0]`); omitting it defaults to 32-bit `int`
- Encoding auto-assigned by synthesizer unless literals are specified; FSM encoding attribute (`fsm_encoding`) covered later
- Waveform viewers render enum names instead of raw bits — primary debugging benefit
- `case (state)` over an enum requires a `default` clause: underlying vector has more representable values than named members (e.g., 2-bit vector, 3 named states → 1 illegal encoding); an SEU or reset bug landing on the illegal value without `default` infers a latch
- Always reset and compare using enum names (`state <= IDLE`), never raw literals (`state <= 2'b00`) — decouples module code from package width changes

### `struct packed`

- Fields concatenated into a contiguous bit vector; total width = sum of field widths
- First field declared occupies the highest bits (MSB-first ordering)
- Implicitly castable to/from `logic [N-1:0]` of equal width — assignable as a flat vector, sliceable by bit range, passable across module ports
- Synthesizes to plain wires — zero hardware cost beyond the bits themselves
- Unpacked structs (`struct {...}` without `packed`) have simulator-defined layout, may have padding, do not synthesize predictably — verification-only

### `package` and `import`

- Single source of truth for shared types, constants, and (later) functions; convention: one `project_pkg.sv` per project
- `import project_pkg::*;` at top of each module pulls all symbols into scope
- Width or constant change in the package propagates to every importing module — eliminates width drift across files
- Use `localparam` inside packages, not `parameter` — packages are imported (not instantiated), so override syntax has no application site
- Zero hardware cost — purely a compile-time namespace mechanism

### Hardware Cost Model

- Type *definitions* (enum, struct packed, package) → zero cost
- Signals *declared* with those types cost identically to raw `logic` vectors of equal width
- The abstractions are free; the bits are not

## Deliverables

| File | Description |
|------|-------------|
| `project_pkg.sv` | Project-wide package: `SYS_CLK_HZ` constant, `light_state_t` enum (`RED`/`GREEN`/`YELLOW`, 2-bit), `light_outputs_t` and `spi_cmd_t` packed structs |
| `traffic_light.sv` / `traffic_light_tb.sv` | Sequential FSM cycling `RED → GREEN → YELLOW` on `tick` pulse; `always_ff` state register, `always_comb` output decode with `default` clause; outputs a `light_outputs_t` struct; verified enum names render in Surfer |
| `reg_packer.sv` / `reg_packer_tb.sv` | Combinational packing of `addr` (8b) / `rw` (1b) / `reserved` (7b) into a 16-bit `spi_cmd_t`; verifies `[15:8]=addr`, `[7]=rw`, `[6:0]=reserved` via flat `logic [15:0]` cast and field round-trip |

## Tools Used

- **Verilator**: `--lint-only -Wall` for compile-time lint; package compiled before importing modules
- **Icarus Verilog**: `-g2012` for SystemVerilog simulation
- **Surfer**: VCD inspection — verified enum state names render as labels and packed struct fields expand into individual signals