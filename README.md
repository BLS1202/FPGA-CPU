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
```bash
cd RTL

```
