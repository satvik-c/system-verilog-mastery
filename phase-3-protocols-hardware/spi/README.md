# SPI Project — Phase 3 Progress

Sessions 18–22. RTL accumulates across sessions; git commits mark session boundaries.

- [X] **S18: SPI Theory** — 4-wire topology, full-duplex shift mechanics, CPOL/CPHA and the four modes, CS framing, SPI-vs-UART tradeoffs.
  - `docs/spi_theory.md` — concept reference
  - `docs/spi_mode0_timing.png` — Mode 0 byte-exchange timing diagram
  - `docs/spi_mode3_timing.png` — Mode 3 byte-exchange timing diagram
  - `docs/shift_trace.md` — per-clock shift-register contents, full-duplex swap
- [X] **S19: SPI Master FSM** — Parameterized master: configurable clock divider, CPOL/CPHA-aware MOSI/MISO shift, CS setup/hold timing, multi-byte transactions.
  - `rtl/spi_master.sv` — parameterized master: FSM, clock divider, full-duplex shift datapath
  - `tb/spi_master_tb.sv` — behavioral slave, byte-exchange exercise, manual waveform check
  - `project_pkg.sv` — `spi_state_t` FSM state enum
- [X] **S20: Sensor Modeling** — Behavioral ADXL362 BFM: Mode-0 slave, 3-byte read/write command protocol, register file with address auto-increment.
  - `tb/adxl362_model.sv` — non-synth ADXL362 BFM: command/address decode, register memory, auto-increment, MISO tri-state on deselect
  - `tb/adxl362_model_tb.sv` — standalone BFM unit test: directed register read, manual waveform check
  - `tb/spi_master_tb.sv` — adxl362_model integration: streaming TX, directed register reads (single + auto-increment), write-readback, manual waveform check
- [X] **S21: SPI Verification** — Bound protocol assertions, transaction scoreboard, randomized access, functional coverage.
  - `sva/spi_master_sva.sv` — bound SVA suite: CS/SCLK legality, MOSI sample-edge stability, rx_valid pulse
  - `tb/spi_master_tb.sv` — scoreboard TB: read/write tasks, auto-increment self-check, randomized soak
  - `coverage/spi_master_coverage.sv` — covergroup: command/address/byte/data coverpoints, read/write crosses
- [ ] **S22: Timing Deep Dive.** Setup/hold analysis, critical-path identification, Vivado timing reports, SCLK frequency from ADXL362 datasheet.