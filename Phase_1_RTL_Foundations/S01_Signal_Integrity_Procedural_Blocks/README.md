# Session 1: The Logic Revolution

## Concepts Covered

### 4-State Logic (0, 1, X, Z)
- Every SV bit carries one of four values: `0` (low), `1` (high), `X` (unknown — simulation-only), `Z` (high-impedance — physically real)
- `X` at time 0 is expected from unreset flip-flops; `X` during normal operation indicates a design bug (undriven input, missing branch, uninitialized register)
- `Z` represents an electrically disconnected wire; used in shared-bus protocols (I2C) via tri-state buffers

### X Propagation Rules
- `X & 0 = 0`, `X | 1 = 1` — dominant values absorb `X`
- `X & 1 = X`, `X | 0 = X` — non-dominant inputs propagate `X`
- A single `X` source can infect an entire datapath through non-dominant paths

### `logic` vs. `reg` vs. `wire`
- `reg` is a simulation scheduling construct — does NOT imply a hardware register; inference depends on procedural context (`always_ff` → FF, `always_comb` → LUT)
- `wire` permits multiple drivers, silently resolving conflicts to `X` at runtime
- `logic` rejects multiple drivers at compile time — use it everywhere unless multi-driver resolution is intentional
- Undriven `wire` → `Z`; undriven `logic` → `X`

### Tri-State and Artix-7 Constraint
- Internal tri-state routing is **not supported** on Artix-7 — Vivado replaces internal `Z` with muxes
- Physical tri-state only exists at I/O pads via the **IOBUF** primitive
- Constraint is silicon-level, not a language limitation

## Deliverables

| File | Description |
|------|-------------|
| `multi_driver.sv` / `tb_multi_driver.sv` | Demonstrates compile-time rejection of multiple drivers on `logic` vs. silent `X` resolution on `wire` |
| `x_prop.sv` / `tb_x_prop.sv` | Traces `X` propagation through AND, OR, and chained logic with predicted vs. observed outputs |
| `float_demo.sv` / `tb_float_demo.sv` | Compares undriven `wire` (`Z`) vs. incomplete `always_comb` assignment (latch inference); Verilator warns on missing `else` |

## Tools Used
- **Verilator**: `--lint-only -Wall` for compile-time lint (multiple-driver detection, latch warnings)
- **Icarus Verilog**: `-g2012` for SystemVerilog simulation
- **Surfer**: VCD waveform inspection