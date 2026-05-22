# Session 12: Functional Coverage

## Concepts Covered

### Coverage vs. Checking
- Coverage = stimulus completeness; checking = response correctness. Neither implies the other
- 100% coverage proves only that **defined bins** were hit — bin authorship is itself graded against the spec
- Buggy golden model + 100% coverage = silent failure

### `covergroup` Syntax (no Verilator support)
- `bins x = {[0:9]}` → 1 bin (any value in range); `bins x[] = {[0:9]}` → 10 bins (one per value)
- `illegal_bins` → `$error` on hit; `ignore_bins` requires unreachability proof"
- Transition bins: `(A => B)` fires on two consecutive samples matching the pattern

### Cross Coverage
- Cross = joint distribution; individual coverpoints are marginals — only cross is honest evidence of stimulus space
- `binsof(cp) intersect {…}` filters bins; denominator must reflect filtered count, not `$bits()`

### Manual Coverage (Verilator-compatible)
- Bin = bit in a hit register; sample = OR-into bit; coverage % = `$countones(hits)/denom`
- Ranged bins require `classify()` returning category index
- Cross = N-D hit array indexed by `[op][classify(operand)]`
- Transitions = `prev_state` reg + 2D hit array `[prev][curr]`, gated by legal-arc matrix

### Sampling Alignment
- Standing `@(posedge clk); #1 signal = value;` rule applies to coverage TBs identically
- Gate during reset: `@(posedge clk iff !rst)` or `if (!rst)` guard inside the always_ff

### Constrained Random
- `$urandom()` cannot hit single-value bins: P(zero) = 2⁻³² → ~10⁹ samples per hit
- Corner injection: with probability *p* draw from corner pool, else uniform — knob controls bin hit rate

### FSM Transition Coverage
- Denominator = legal arc count from spec, not full Cartesian state² (12/64 here, not 64/64)
- Legal arcs as constant 2D matrix; illegal arcs `$error`, never increment counter → hits ≤ legal count is structurally enforced

## Deliverables
| File | Description |
|------|-------------|
| `alu_coverage.sv` | Hit registers `cp_op` (10), `cp_a_class`/`cp_b_class` (6 each), 2D crosses `cr_op_a`/`cr_op_b` (42 bins, AND/OR/XOR ignored); `final` block reports |
| `alu_tb.sv` | Corner-injection stimulus generator (40% corner pool, 60% `$urandom`) × 10000 iterations; 100% on all coverpoints and crosses |
| `traffic_light_coverage.sv` | 8-bin state hit register; 8×8 transition matrix gated by `const legal_trans` (12 legal arcs); illegal arcs `$error` |
| `traffic_light_tb.sv` | Multi-mode stimulus (NORMAL/FLASH/PED) closing transition coverage to 12/12 |

## Tools Used
- **Verilator**: No covergroup support → manual hit registers
- **Surfer**: FST inspection of hit register transitions to debug coverage gaps