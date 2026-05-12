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
* **Linting/Sim:** Verilator & Icarus Verilog
* **Waveforms:** GTKWave & Surfer
* **Synthesis:** Vivado ML

---

## 📅 Roadmap & Status

### Phase 1: RTL Foundations
- [X] **S01–S02:** 4-state logic and procedural block contracts.
- [X] **S03–S04:** Typedefs, packages, and parameterized arrays.
- [X] **S05–S06:** 3-always-block FSMs and Vivado synthesis lab.
- [ ] **S07–S08:** Interfaces, modports, and Vivado Tcl flow.
- [ ] **Milestone 1:** FSM Review & Synthesis Results.

### Phase 2: Verification Essentials
- [ ] **S09–S10:** Task-based TBs and self-checking golden models.
- [ ] **S11–S12:** SVA concurrent assertions and functional coverage.
- [ ] **Milestone 2:** Fully Verified Parameterized ALU.

### Phase 3: Protocols & Hardware
- [ ] **S13–S17:** UART TX/RX with 16x oversampling and hardware echo.
- [ ] **S18–S21:** SPI Master FSM, sensor BFMs, and protocol verification.
- [ ] **S22:** Timing Analysis (Setup/Hold, WNS, and Fmax).
- [ ] **Milestone 3:** Integrated UART System.

### Phase 4: CDC & System Integration
- [ ] **S23–S24:** I2C Open-drain physics and Master FSM.
- [ ] **S25:** Metastability and 2-FF/Pulse synchronizers.
- [ ] **S26–S27:** Async FIFO with Gray-coded pointers and verification.
- [ ] **Milestone 4:** Capstone Review & Final Synthesis.

---

## 📂 Repository Structure
* `phase-X-.../`: Curriculum phase containers.
    * `sXX-.../`: Individual sessions containing `/rtl`, `/tb`, and a technical `README.md`.
    * `z-milestone-X-.../`: Final designs, schematics, and timing results.
* `z-common/`: Shared `project_pkg.sv` for types and constants.