# I2C Theory — Concept Reference

## Signals & Topology
- 2 wires: SCL (clock), SDA (data) — both bidirectional, open-drain, external pull-ups
- Idle HIGH; any device pulls LOW, none drives HIGH
- Multi-drop: all devices share SCL/SDA; selection by in-band 7-bit address, not a select line (contrast SPI CS)
- Bus level = wired-AND of all drivers: LOW if any device pulls, HIGH only if all release

## Open-Drain & Z State
- Output drives `0` (pull) or `Z` (release) only — never `1`
- Idiom: `assign sda = sda_drive ? 1'b0 : 1'bz;`
- HIGH = pull-up restoring a released line, not an active drive
- Push-pull `1` vs another device's `0` → VDD–GND short; open-drain prevents this by construction
- Line read-back = wired-AND result → exposes ACK and clock-stretch from other devices
- Slave holding SCL LOW = clock stretching (direct consequence of open-drain SCL)

## IOBUF — Pad-Level Tri-State (Artix-7)
- Internal tri-state not synthesizable on Artix-7; `Z` exists only at the I/O pad
- `.IO` → bidirectional pad (XDC pin)
- `.I` → tied `1'b0` (drives 0 only)
- `.T` → active-HIGH tri-state: `1` = high-Z/released, `0` = drive `.I`; wired `.T = ~sda_drive`
- `.O` → pad read-back = wired-AND bus level → `sda_in`
- One IOBUF per bidirectional line (SDA; SCL if stretch supported)

## Protocol Primitives
- Validity rule: SDA changes only while SCL LOW; an SDA transition under SCL HIGH is reserved
- START (S): SDA 1→0 while SCL HIGH
- STOP (P): SDA 0→1 while SCL HIGH
- Repeated START (Sr): START reissued with no intervening STOP — electrically identical to S
- START/STOP unambiguous vs data because they deliberately violate the validity rule

## Byte Transfer & ACK/NACK
- 9 SCL pulses/byte: 8 data bits MSB-first + 1 ACK slot; data sampled on SCL rising edge
- ACK slot: transmitter releases SDA (Z); receiver pulls `0` = ACK, releases (Z→HIGH) = NACK
- Master reading final byte → NACK → slave releases bus, master issues STOP

## Addressing
- First byte after START = `[A6..A0][R/W]`, MSB-first; R/W = 0 write, 1 read
- Addressed slave drives the ACK slot; no ACK = no device / busy
- Example: addr `0x48`, W=0 → wire byte `0x90` (`1001 0000`)

See [Timing Diagram](i2c_write_0x48_timing.png).

## I2C vs SPI
| Aspect | I2C | SPI |
|--------|-----|-----|
| Wires | 2 (SCL, SDA) | 4 (SCLK, MOSI, MISO, CS) |
| Electrical | Open-drain + pull-ups, wired-AND | Push-pull, point-driven |
| Device select | In-band 7-bit address | Dedicated CS per slave |
| Duplex | Half (single shared SDA) | Full (separate MOSI/MISO) |
| Clock | Master-driven, slave may stretch | Master-driven, no stretch |
| Framing | START/STOP + per-byte ACK | CS + SCLK bit count |
| Speed | 100k / 400k / 1M+ | MHz–tens of MHz |
| Flow control | Per-byte ACK/NACK | None built-in |