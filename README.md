RISC-V Single-Cycle Processor Implementation

Project Overview:
This repository contains a Verilog implementation of a 32-bit single-cycle RISC-V CPU core. The design follows the RV32I ISA subset, focusing on the core execution stages: Fetch, Decode, Execute, Memory, and Write-back.
The processor is designed for modularity, with separate units for ALU control, immediate generation, and register management.

The current implementation supports the following instruction types:

R-type: Arithmetic operations between registers (e.g., ADD).

I-type: Operations with immediate values (e.g., ADDI).

S-type: Memory store operations (e.g., SW).

B-type: Conditional branching (e.g., BEQ).

Architecture and Design:

Control Unit: Decodes the 7-bit opcode to manage control signals for the ALU, Register File, and Data Memory.

ALU: 32-bit arithmetic logic unit providing results and a zero flag used for conditional branches.

Branching Mechanism: Target addresses are calculated using a 1-bit left shift on the immediate value to ensure proper half-word alignment, as per RISC-V specifications.

Memory Architecture: Implements a Harvard-style architecture with separate instruction and data memory modules.

Simulation and Verification:
Verification was performed using the Vivado Simulator environment.

Branch Execution Analysis
The execution of the BEQ instruction was verified by monitoring the Program Counter (PC). In the provided test case, when the comparison evaluates to true, the pc_current correctly transitions from 0x8 to 0x10 (16 bytes), effectively skipping the subsequent instruction at address 0xc.

Data Memory Verification
Memory store operations (sw) were verified by inspecting the data_memory internal array, ensuring that register values are correctly committed to the specified memory addresses during the write cycle.
