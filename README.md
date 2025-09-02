# FPGA RISCV CPU

## Overview

This project implements a **single-cycle CPU** on FPGA that supports the **RV32I instruction set** of RISC-V.  
It is designed to be a simple, CPU core. More features such as pipeline, branch prediction, Out-of-Order execution and caches can be added in the future. 

## Key Features

- **RV32I Base Instruction Set Support** (arithmetic, logical, branch, load/store, and system instructions)
- **Single-Cycle Execution** for all instructions
- **FPGA Hardware**: The complete design can be used on Digilent Nexys A7 board.
- **Hardware bootloader** A hardware designed bootloader that can transmit assembly file from PC through UART to the FPGA, and store the instructions in the CPU RAM. This feature is half-way done.

---

## **Project Structure**
```plaintext
├── RTL/           # Verilog source files (CPU core, ALU, register file, etc.)
├── rv32ui-tests/     # Assembly files for simulating CPU
├── Nexys_board_test/      # Compiled files for synthesizing design on Vivado for Nexys A7 board.
└── README.md      # This file 

```
## Running Simulation
Iverilog and gtkwave can be used for simple simulation and wave viewing for verifying the behavior of the CPU. 

For simulation:
```bash
cd RTL

iverilog -o rv32.vvp RV32ui_tb.v
vvp rv32.vvp
```
GTKwave viewer:
```bash
gtkwave rv32.vcd
```
If the test from rv32ui passed, the terminal will show the following:
<img width="991" height="222" alt="image" src="https://github.com/user-attachments/assets/64932bc8-a014-480a-bfa7-8b13d1c180ec" />


## Build with Vivado
