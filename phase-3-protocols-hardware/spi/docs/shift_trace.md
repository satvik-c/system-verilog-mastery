# SPI Shift-Register Exchange Trace

Mode 0, MSB-first. Master = `0xD2`, Slave = `0x6E` (both non-palindrome → bit order is observable).
Each clock: master drives `M[7]` on MOSI, slave drives `S[7]` on MISO; both left-shift, sampled bit enters LSB.

| Clk  | MOSI = M[7] | MISO = S[7] | Master (post-shift) | Slave (post-shift) |
|:----:|:-----------:|:-----------:|:-------------------:|:------------------:|
| load | —           | —           | `1101_0010` (D2)    | `0110_1110` (6E)   |
| 1    | 1           | 0           | `1010_0100` (A4)    | `1101_1101` (DD)   |
| 2    | 1           | 1           | `0100_1001` (49)    | `1011_1011` (BB)   |
| 3    | 0           | 1           | `1001_0011` (93)    | `0111_0110` (76)   |
| 4    | 1           | 0           | `0010_0110` (26)    | `1110_1101` (ED)   |
| 5    | 0           | 1           | `0100_1101` (4D)    | `1101_1010` (DA)   |
| 6    | 0           | 1           | `1001_1011` (9B)    | `1011_0100` (B4)   |
| 7    | 1           | 1           | `0011_0111` (37)    | `0110_1001` (69)   |
| 8    | 0           | 0           | `0110_1110` (6E)    | `1101_0010` (D2)   |

- MOSI sequence = `1 1 0 1 0 0 1 0` = `0xD2` (master's byte, MSB-first)
- MISO sequence = `0 1 1 0 1 1 1 0` = `0x6E` (slave's byte, MSB-first)
- After 8 clocks the registers are fully swapped: Master ← `0x6E`, Slave ← `0xD2`