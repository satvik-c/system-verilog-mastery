# Session 10: Self-Checking Testbenches

## Concepts Covered

### Golden Model Pattern
- Software re-statement of the spec, run in parallel with DUT on shared stimulus
- Must use **algebraically independent** expressions from RTL — same answer, different path
- Catches: RTL ≠ golden disagreement
- Blind spot: spec misinterpretation shared by both implementations
- Mitigation: third independent source (hand-authored file vectors)

### 4-State Comparison
- `!==` / `===` distinguish `X`/`Z` from `0`/`1`; `!=` / `==` return `X` → falsy → silent miss
- Use `!==` in every self-check; `X` leaks from undriven outputs and missing case arms

### Self-Checking Task Structure
- `task automatic` — per-call stack frame; mandatory for parallel/recursive/re-entrant calls
- Static tasks share locals across calls — safe only under strict sequential invocation
- Standing rule applies inside tasks: `@(posedge clk); #1 signal = value;`
- Increment `check_count` unconditionally, `error_count` on mismatch

### Error Reporting
- `$error` — flags severity, nonzero exit; use for DUT mismatches
- `$fatal` — for TB-scaffolding failures (unknown opcode in golden); halts simulation
- `$display` — informational only, never pass/fail signaling
- End-of-test banner mandatory; silent exit indistinguishable from hang

### File-Based Stimulus (`$readmemh`)
- Packed struct vector; total width must be whole hex digits; underscores ignored within values
- Load inside stimulus `initial` block before consumption — avoids time-0 race between sibling initials

### Three-Way Convergence
- RTL = SV golden = file vectors → strongest posture without SVA or formal
- Lone dissenter: investigate, do not adjust to match the majority
- Vectors catch reasoned corner cases; golden catches volume

## Deliverables

| File | Description |
|------|-------------|
| `project_pkg.sv` | `opcode_t` enum (10 ops) + `flags_t` packed struct `{N,V,C,Z}` |
| `alu.sv` | Parameterized W-bit ALU with a single `always_comb` |
| `alu_tb.sv` | Self-checking TB with golden model + hex-vector cases |
| `vectors/alu_directed.hex` | 35 hand-authored vectors; signed/unsigned overflow, shift-amount masking, SLT/SLTU divergence |

## Hardware Mapping (Artix-7)
- Combinational only — no FFs inferred
- Add/sub → CARRY4 cascade (dedicated carry-chain routing)
- Shifts → LUT-mux structure, `W × $clog2(W)` complexity
- Default case arm prevents latch inference even with full enum coverage

## Tools Used
- **Verilator**: `--lint-only -Wall` for lint; `--binary --trace` for simulation
- **Surfer**: FST waveform inspection on TB-reported failure only

## Verification Status
- W=4: 2560 exhaustive checks PASSED
- W=32: 35 directed checks PASSED
- Parameterization validated across width boundary