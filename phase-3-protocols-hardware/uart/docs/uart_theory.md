# UART Theory Reference

## Frame Structure (8N1)

- Asynchronous; no shared clock between TX and RX; one wire per direction
- Frame: idle (H) → start (1 bit L) → 8 data bits (LSB first) → stop (1 bit H) = 10 bit periods
- LSB first: TX shifts right out; RX shifts into MSB → byte oriented correctly after 8 shifts

See [`frame_0x55_115200.png`](frame_0x55_115200.png).

## Baud Rate Math

- `CLKS_PER_BIT = F_sys / B`, integer rounding mandatory
- `CLKS_PER_SAMPLE = F_sys / (B × 16)` must also divide cleanly for clean 16× oversample
- **Baud rate error** ≠ **accumulated phase error over a frame** — phase error = baud error × frame length

See [`divider_table.md`](divider_table.md).

## 16× Oversampling

- RX recovers timing from the start-bit falling edge alone — no shared clock
- 16 phase positions per bit → ±6.25% resolution → ~3–5% accumulated drift tolerance per frame
- 4× insufficient: drift tolerance ≤12.5%, FS validation point too close to edge
- 32× or more has diminishing returns; standard 16550 UART uses 16×

## RX Sample Algorithm

- **Tick 0**: falling edge on RX → exit IDLE, reset sample counter
- **Tick 8**: re-check line LOW → valid start; HIGH → glitch, return IDLE (false-start rejection)
- **Ticks 24, 40, 56, 72, 88, 104, 120, 136**: mid-bit sample of D0–D7, shift into RX register
- **Tick 152**: line HIGH → valid stop; LOW → framing error

See [`rx_sample_timeline.png`](rx_sample_timeline.png).

## Mid-Bit Sampling Rationale

- Maximum margin to both bit edges → drift tolerance
- Bit transitions are electrically unsettled (slew rate, RC settling, possible ringing); mid-bit sits at rail voltage

## Framing Error Sources

- Severe baud mismatch (>~5% accumulated)
- Frame config mismatch (e.g., RX 7N1, TX 8N1 — 8th data bit lands at stop position)
- RX synced on a noise glitch — now sampling out of phase