# SystemVerilog Mastery

## Introduction
Hi! I'm Satvik, an ECE student at UT Austin. This repository documents my transition from academic Verilog to industry-standard **SystemVerilog (IEEE 1800-2012)**. 

The curriculum focuses on four core pillars:
1. **Modern Design:** Synthesis-safe RTL using interfaces and packages.
2. **Professional Verification:** Self-checking testbenches, SystemVerilog Assertions (SVA), and functional coverage.
3. **Hardware Protocols:** Low-level controllers for UART, SPI, and I2C.
4. **System Integration:** Clock Domain Crossing (CDC) and asynchronous FIFOs.

## 🛠 Hardware & Tools
* **Board:** Xilinx Nexys A7-100T (Artix-7)
* **Linting/Sim:** Verilator
* **Synthesis:** Vivado ML

---

## 📅 Roadmap & Status

### Phase 1: RTL Foundations
- [X] **S01–S02:** 4-state logic and procedural block contracts.
- [X] **S03–S04:** Typedefs, packages, and parameterized arrays.
- [X] **S05–S06:** 3-always-block FSMs and Vivado synthesis lab.
- [X] **S07–S08:** Interfaces, modports, and Vivado Tcl flow.

### Phase 2: Verification Essentials
- [X] **S09–S10:** Task-based TBs and self-checking golden models.
- [X] **S11–S12:** SVA concurrent assertions and functional coverage.

### Phase 3: Protocols & Hardware
- [ ] **S13–S17:** UART TX/RX with 16x oversampling and hardware echo.
- [ ] **S18–S22:** SPI Master FSM, sensor BFMs, protocol verification, and timing analysis.

### Phase 4: CDC & System Integration
- [ ] **S23–S24:** I2C Open-drain physics and Master FSM.
- [ ] **S25–S27:** Metastability, 2-FF/Pulse synchronizers, and async FIFO with Gray-coded pointers.

---

## 📂 Repository Structure
All sessions and projects contain `/rtl` and `/tb`. Depending on complexity:

| Folder | Contents |
|--------|----------|
| `rtl/` | Synthesizable RTL source |
| `tb/` | Testbench stimulus modules |
| `sva/` | SVA bind files |
| `coverage/` | Coverage bind files |
| `vectors/` | Generated test vectors |
| `sim/` | Filelist (`rtl.f`)|
| `synth/` | XDC constraints and Vivado Tcl scripts |