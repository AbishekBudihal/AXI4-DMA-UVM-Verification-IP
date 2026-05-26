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
## Simulation Waveforms

### 1. AXI4-Lite Write Transactions
Clean `AWVALID`/`AWREADY` and `WVALID`/`WREADY` handshakes across multiple addresses (`0x00000008`, `0x0000000c`), with `BVALID`/`BREADY` write responses — full AXI4-Lite write channel compliance demonstrated.

![AXI Write Transaction Waveform](waveforms/AXI_Write_Transaction_Waveform.png)

---

### 2. DMA BUSY → DONE Transition + Coverage
`dma_busy` goes high → `dma_done` asserts at transfer completion. All 6 coverage bins hit simultaneously.

![DMA BUSY-to-DONE Transition Waveform](waveforms/DMA_BUSY_to_DONE_Transition_Waveform.png)

---

### 3. DMA IRQ Assertion
`dma_irq` fires precisely when `dma_done` asserts — correct interrupt timing verified.

![DMA IRQ Assertion Waveform](waveforms/dma_irq_Assertion_Waveform.png)
---

## Validation Results

| Parameter | Result |
|---|---|
| AXI4-Lite Channels | All 5 implemented and verified |
| DMA Transfer Completion | `dma_done` assertion confirmed |
| IRQ Timing | Fires at `dma_done` — zero latency error |
| Functional Coverage | **100%** — all bins hit |
| Pass / Fail | 11 / 0 |
| Verification Methodology | UVM (Universal Verification Methodology) |
| Simulation Tool | GTKWave (VCD), Xilinx Vivado |

---


### Features
- All five AXI4-Lite channels: AW, W, B, AR, R  
- VALID/READY handshaking on every channel  
- 32-bit register file with address decoding  
- Byte-enable write strobes (WSTRB) for partial writes  
- DMA controller: IDLE → BUSY → DONE state machine  
- Configurable source address, destination address, transfer length  
- dma_irq interrupt output — asserts on transfer completion  
- Synchronous active-low reset  
- Clean RTL structure for direct SoC integration  

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
