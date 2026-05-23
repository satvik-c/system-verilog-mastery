# UART Baud Rate Dividers @ 100 MHz

`CLKS_PER_BIT = F_sys / B`, integer rounded. `CLKS_PER_SAMPLE = F_sys / (B × 16)` must also be a clean integer for 16× oversample.

| Baud   | Ideal Cycles | Integer | Actual Baud | % Error  | 10-Bit Phase Drift |
|--------|--------------|---------|-------------|----------|--------------------|
| 9600   | 10416.67     | 10417   | 9599.69     | −0.0032% | 0.032%             |
| 19200  | 5208.33      | 5208    | 19201.23    | +0.0064% | 0.064%             |
| 57600  | 1736.11      | 1736    | 57603.69    | +0.0064% | 0.064%             |
| 115200 | 868.06       | 868     | 115207.37   | +0.0064% | 0.064%             |
| 921600 | 108.51       | 109     | 917431.19   | −0.4520% | 4.520%             |

## Notes

- **115200 is the sweet spot at 100 MHz**: large divisor (868), trivial error, clean 16× divide (54.25 → 54)
- **921600 is risky**: divisor of 109 amplifies jitter; 16× rate doesn't divide cleanly (6.78 → 7), accumulating error