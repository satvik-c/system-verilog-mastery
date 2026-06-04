# SPI Project — Phase 3 Progress

Sessions 18–22. RTL accumulates across sessions; git commits mark session boundaries.

- [X] **S18: SPI Theory** — 4-wire topology, full-duplex shift mechanics, CPOL/CPHA and the four modes, CS framing, SPI-vs-UART tradeoffs.
  - `docs/spi_theory.md` — concept reference
  - `docs/spi_mode0_timing.png` — Mode 0 byte-exchange timing diagram
  - `docs/spi_mode3_timing.png` — Mode 3 byte-exchange timing diagram
  - `docs/shift_trace.md` — per-clock shift-register contents, full-duplex swap
- [ ] **S19: SPI Master FSM.** Parameterized master: configurable clock divider, CPOL/CPHA-aware MOSI/MISO shift, CS setup/hold timing, multi-byte transactions.
- [ ] **S20: Sensor Modeling.** Behavioral ADXL362 SPI slave BFM with register read/write protocol and configurable register contents.
- [ ] **S21: SPI Verification.** Protocol assertions (CPOL/CPHA, CS timing), transaction-level checking against BFM, randomized access, coverage.
- [ ] **S22: Timing Deep Dive.** Setup/hold analysis, critical-path identification, Vivado timing reports, SCLK frequency from ADXL362 datasheet.