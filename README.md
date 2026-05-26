# AXI4-Lite Configurable SoC Peripheral Subsystem

> AXI4-Lite Slave + DMA Controller with IRQ —  
> RTL Design & UVM Verification Environment  
> Constrained-random testbench with 100% functional coverage  

---

## Overview

This project implements a complete **AXI4-Lite compliant SoC peripheral subsystem** from scratch in Verilog RTL, verified using a SystemVerilog testbench with UVM-style methodology. The system consists of two hardware modules connected to a common AXI4-Lite bus, plus a structured verification environment.

| Module | Description |
|--------|-------------|
| `axi_lite_slave` | 4×32-bit memory-mapped register file peripheral |
| `axi_lite_dma` | DMA Controller Front-End matching AMD/Xilinx AXI DMA PG021 programming model |

The design was synthesized in **Xilinx Vivado 2025.2** targeting the **Artix-7 (xc7a35tftg256-1)** FPGA and verified with a self-checking scoreboard achieving **100% functional coverage closure**.

---

## Project Structure
```
axi-lite-peripheral/
├── rtl/
│   └── axi_lite_slave.v        # AXI4-Lite slave RTL
|   └── axi_lite_dma.v
├── tb/
│   └── tb_axi_lite.sv           # Testbench with assertions, scoreboard & coverage
│   └──tb_axi_lite_dma.sv
├── waveforms/
│   └── xsim_simulation_ss                 # Simulation waveform output
└── README.md
```

---

## AXI4-Lite Slave Peripheral

### Features
- Fully AXI4-Lite protocol compliant — correct VALID/READY handshake on all 5 channels
- 4 × 32-bit memory-mapped register file (parameterized)
- 3-state Write FSM: `W_IDLE → W_DATA → W_RESP`
- 2-state Read FSM: `R_IDLE → R_DATA`
- WSTRB byte-lane masking — each bit independently controls one byte lane
- Response codes: OKAY (2'b00), SLVERR (2'b10), DECERR (2'b11) for unmapped addresses

### Register Map

| Address | Register | Access |
|---------|----------|--------|
| 0x00 | REG0 | R/W |
| 0x04 | REG1 | R/W |
| 0x08 | REG2 | R/W |
| 0x0C | REG3 | R/W |
---

## AXI4-Lite DMA Controller Front-End

Replicates the programming model of **AMD/Xilinx AXI DMA IP (PG021)**.

### Register Map

| Address | Register | Access | Description |
|---------|----------|--------|-------------|
| 0x00 | SRC_ADDR | R/W* | DMA source address |
| 0x04 | DST_ADDR | R/W* | DMA destination address |
| 0x08 | XFER_LEN | R/W* | Transfer length in clock cycles |
| 0x0C | CTRL_STAT | R/W | Control and status register |

*Write-protected during active transfer (BUSY=1)

### CTRL_STAT Bits

| Bit | Name | Description |
|-----|------|-------------|
| 0 | START | Write 1 to initiate transfer |
| 1 | BUSY | Set by HW when transfer active |
| 2 | DONE | Set by HW when transfer complete |
| 3 | ERROR | Set on zero-length transfer attempt |
| 4 | IRQ_EN | Enable hardware interrupt output |
---

## How to Run

### EDA Playground (recommended)
1. Go to [edaplayground.com](https://edaplayground.com)
2. Paste RTL in Design box, testbench in Testbench box
3. Select Cadence Xcelium + UVM 1.2
4. Click Run

### Icarus Verilog (local)
```bash
git clone https://github.com/AbishekBudihal/axi-lite-peripheral
cd axi-lite-peripheral
iverilog -g2012 -o sim rtl/axi_lite_slave.v tb/tb_axi_lite_dma.sv
vvp sim
gtkwave dump.vcd
```

### Vivado
1. Create RTL project, add files from `rtl/` and `constraints/`
2. Set part: `xc7a35tftg256-1`
3. Run Synthesis → Implementation
4. Open Timing Summary and Utilization Report

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Xilinx Vivado 2025.2 | Synthesis, STA, schematic |
| EDA Playground (Xcelium) | UVM simulation |
| Icarus Verilog + GTKWave | Local simulation and waveforms |
| VS Code | HDL editing |
| Git / GitHub | Version control |

---

`Verilog` `AXI4-Lite` `AMBA Protocol` `RTL Design` `FSM`
`Functional Verification` `Assertion-Based Verification`
`Constrained-Random Stimulus` `Functional Coverage` `Scoreboard`
`Digital Design` `ASIC/FPGA`
