# UART Project — Phase 3 Progress

Sessions 13–17. RTL accumulates across sessions; git commits mark session boundaries.

- [X] **S13 — UART Theory** — 8N1 framing, baud rate math, 16× oversampling rationale, RX sample algorithm with checkpoint ticks, framing error sources.
  - `docs/uart_theory.md` — concept reference
  - `docs/divider_table.md` — baud dividers @ 100 MHz (9600–921600)
  - `docs/frame_0x55_115200.png` — TX frame waveform for `0x55`
  - `docs/rx_sample_timeline.png` — RX 16× sample tick timeline
- [X] **S14 — UART TX Design** — parameterized TX module, baud tick generator, FSM-driven shift register, configurable data width / parity / stop bits.
  - `rtl/project_pkg.sv` — FSM state enum
  - `rtl/baud_gen.sv` — parameterized baud tick generator with enable
  - `rtl/uart_tx.sv` — 5-state TX FSM with shift register and parity computation
  - `tb/baud_gen_tb.sv` — tick period verification across parameter sets
  - `tb/uart_tx_tb.sv` — TX testbench with behavioral UART decoder
- [ ] **S15 — UART RX Design.** 16× oversampling RX with start-bit detection, false-start rejection, mid-bit sampling, framing error flag.
- [ ] **S16 — UART Verification.** TX↔RX loopback testbench, protocol assertions, error injection, functional coverage.
- [ ] **S17 — UART on Hardware.** Vivado synthesis + implementation, XDC pin mapping to Nexys A7 USB-UART bridge, terminal echo demo.