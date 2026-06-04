# SPI Theory — Concept Reference

## Signals & Topology
- 4 wires: `SCLK` (master-driven), `MOSI` (M→S), `MISO` (S→M), `CS` (active-low select, one per slave)
- Shared clock → no timing recovery (contrast UART 16× oversample)
- Multi-slave: shared SCLK/MOSI/MISO, separate `CS` per slave
- Nexys A7 on-board slave: ADXL362 accelerometer (Mode 0)

## Full-Duplex Shift Mechanics
- Two N-bit shift registers exchange contents over N clocks; MSB-first typical
- MSB-first ⇒ register shifts **left** (`q <= {q[N-2:0], in_bit}`); MSB exits, sampled bit enters LSB
- Sampled bit fills the vacated LSB — never overwrites the MSB
- After N clocks the registers have fully swapped contents
- Pure read still clocks out a dummy byte — no clock, no shift

See [`shift_trace.md`](shift_trace.md).

## CPOL / CPHA — Four Modes
- CPOL = SCLK idle level (0 = idle low, 1 = idle high)
- CPHA = sample on leading (0) vs trailing (1) edge — resolved *through* CPOL, not absolute rising/falling
- Leading edge: low→high at CPOL=0, high→low at CPOL=1

| Mode | CPOL | CPHA | Idle | Sample | Drive |
|:----:|:----:|:----:|:----:|:-------|:------|
| 0 | 0 | 0 | Low | Rising (leading) | Falling (trailing) |
| 1 | 0 | 1 | Low | Falling (trailing) | Rising (leading) |
| 2 | 1 | 0 | High | Falling (leading) | Rising (trailing) |
| 3 | 1 | 1 | High | Rising (trailing) | Falling (leading) |

- [`Mode 0 diagram`](spi_mode0_timing.png): idle low, first bit on `CS` fall
- [`Mode 3 diagram`](spi_mode3_timing.png): idle high, first bit on first leading (falling) edge
- Modes 0 & 3 both sample rising / drive falling — differ only in idle polarity + first-bit launch
- CPHA mismatch → sample edge lands on data transition → deterministic half-bit phase error, not noise

## CS Framing
- Falling edge: select slave (+ first MOSI bit for CPHA=0)
- Held low for entire transaction (may span multiple bytes)
- No in-band delimiters — bit/byte boundaries set by counting SCLK pulses
- Rising edge: deselect; commits/latches received word in many slaves

## SPI vs UART
| Aspect | UART | SPI |
|--------|------|-----|
| Clocking | Async, 16× recovery | Sync, shared SCLK |
| Min wires | 2 | 4 |
| Framing | Start/stop/parity | CS + bit count |
| Speed | kbps–Mbps | MHz–tens of MHz |
| Duplex | Full, independent lines | Full, simultaneous shift |
| Error detect | Optional parity | None built-in |
| Multi-device | Point-to-point | Multi-slave via CS |