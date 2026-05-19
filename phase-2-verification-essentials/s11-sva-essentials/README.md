# Session 11: SVA Essentials

## Concepts Covered

### Assertion Flavors
- **Immediate** (`assert (cond) else $error(...);`) — zero-cycle, lives inside `always_*`/tasks
- **Concurrent** (`assert property (@(posedge clk) ...);`) — module scope, evaluates every edge in parallel with RTL
- Concurrent assertions sample in the **preponed region** — operands read *before* RTL `always_ff` updates on the same edge

### Implication Operators
- `a |-> b` — overlapping: consequent must hold **this** cycle (use when consequent is combinational from antecedent)
- `a |=> b` — non-overlapping: consequent must hold **next** cycle (use when consequent is registered)
- Identity: `a |=> b` = `a |-> ##1 b`
- **Vacuous truth:** if antecedent never fires, property passes trivially — pair every implication with a `cover property` (Session 12)

### Sampled-Value Functions
- `$rose`, `$fell`, `$stable`, `$past(sig, N)`, `$isunknown`, `$onehot`, `$onehot0`

### Sequence Operators
- `##N` fixed delay, `##[M:N]` delay range, `[*N]` N consecutive cycles, `[*M:N]` consecutive range

### `disable iff` — Reset Discipline
- Required on every concurrent assertion: `disable iff (rst)`
- Aborts **in-flight** multi-cycle evaluation when `rst` asserts — not just skips current cycle
- Prevents X-propagation false-fires from unreset FFs

### `bind` Directive
- `bind <module> <sva_module> <inst> (...)` — instantiates SVA inside every instance of target; DUT source untouched
- Assertion module ports all `input` — passive observer
- **Zero synthesis cost** — concurrent assertions are simulation-only; bitstream is bit-identical with/without SVA

### Verification Stack Layering
- Self-checking TB catches output mismatches at check points; vulnerable to shared spec misreading
- SVA catches continuous invariants + internal-state bugs invisible at check points
- Coverage (Session 12) closes the vacuous-truth gap

## Deliverables

| File | Description |
|------|-------------|
| `alu_sva.sv` | 5 properties bound to `alu`: Z biconditional, N identity, C/V zero for non-ADD/SUB, no-X under legal opcode, SLL semantics |
| `traffic_light_sva.sv` | 4 properties bound to `traffic_light`: legal-state, mutual-exclusion safety, GO_NS→SLOW_NS transition, FSM stability while `!counter_done` |
| `alu_tb.sv` / `traffic_light_tb.sv` | Extended with module-level `bind` directives |

## Tools Used
- **Verilator**: `--binary --assert -j 0 -Wall` — `--assert` mandatory or properties are dead code
- **Surfer**: FST waveforms alongside assertion fire output