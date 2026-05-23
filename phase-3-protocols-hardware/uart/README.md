# UART Project — Phase 3 Progress

Sessions 13–17. RTL accumulates across sessions; git commits mark session boundaries.

- [X] **S13 — UART Theory** — 8N1 framing, baud rate math, 16× oversampling rationale, RX sample algorithm with checkpoint ticks, framing error sources.
  - `docs/uart_theory.md` — concept reference
  - `docs/divider_table.md` — baud dividers @ 100 MHz (9600–921600)
  - `docs/frame_0x55_115200.png` — TX frame waveform for `0x55`
  - `docs/rx_sample_timeline.png` — RX 16× sample tick timeline
- [ ] **S14 — UART TX Design.** Parameterized TX module: baud generator, shift register FSM, configurable data width / stop bits / parity.
- [ ] **S15 — UART RX Design.** 16× oversampling RX with start-bit detection, false-start rejection, mid-bit sampling, framing error flag.
- [ ] **S16 — UART Verification.** TX↔RX loopback testbench, protocol assertions, error injection, functional coverage.
- [ ] **S17 — UART on Hardware.** Vivado synthesis + implementation, XDC pin mapping to Nexys A7 USB-UART bridge, terminal echo demo.