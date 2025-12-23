# 32-bit CPU Architecture for FPGA

A complete 32-bit CPU design implemented in Verilog for Xilinx FPGA development. This project implements a simple but functional processor with an instruction set supporting arithmetic, logic, memory, and branching operations.

## Overview

This CPU is a **32-bit RISC-like processor** designed and implemented for educational purposes on Xilinx FPGAs. It features:

- **32 General-Purpose Registers** (32-bit each)
- **ALU** supporting 10+ operations (ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, LD, ST)
- **Instruction Memory (ROM)** - 49-bit instruction width
- **Data Memory (RAM)** - 32-bit wide with addressable storage
- **Program Counter** with conditional and unconditional branching
- **Control Unit** with multiple addressing modes

## Instruction Set Architecture (ISA)

### Instruction Format

All instructions are **49 bits** wide:

```
[48:44] Opcode       (5 bits)
[43:42] Addressing Mode (2 bits)
[41:37] Source Register (5 bits)
[36:32] Destination Register (5 bits)
[31:0]  Immediate/Literal Value (32 bits)
```

### Supported Opcodes

| Opcode | Mnemonic | Operation | Addressing Modes |
|--------|----------|-----------|-----------------|
| 0x01 | LD | Load | Immediate, Direct |
| 0x02 | ST | Store | N/A |
| 0x03 | ADD | Add | Immediate, Register |
| 0x04 | SUB | Subtract | Immediate, Register |
| 0x05 | AND | Bitwise AND | Immediate, Register |
| 0x06 | OR | Bitwise OR | Immediate, Register |
| 0x07 | XOR | Bitwise XOR | Immediate, Register |
| 0x08 | NOT | Bitwise NOT | N/A |
| 0x09 | SL | Shift Left | Immediate, Register |
| 0x0A | SR | Shift Right | Immediate, Register |
| 0x10 | BZ | Branch if Zero | N/A |
| 0x11 | BNZ | Branch if Not Zero | N/A |
| 0x12 | BRA | Unconditional Branch | N/A |

### Addressing Modes

- **Immediate (0x00)**: Operand is encoded in the instruction
- **Direct (0x01)**: Operand comes from memory
- **Register (0x10)**: Operand is in a register

## Project Architecture

### Directory Structure

```
src/
  ├── cpu.v                    # Top-level CPU module
  ├── alu.v                    # Arithmetic Logic Unit
  ├── registerfile.v           # 32x32-bit Register Bank
  ├── instructiondecoder.v     # Instruction Decoder & Control Unit
  ├── programcounter.v         # Program Counter with Branch Logic
  ├── alusrcmux.v             # Multiplexer for ALU source selection
  ├── aluormemmux.v           # Multiplexer for result selection
  ├── rom.v                    # Read-Only Memory (Instruction Storage)
  └── ram.v                    # Random-Access Memory (Data Storage)

test/
  └── cpu_tb.v                 # Testbench

mem_init/
  └── *.coe                    # Memory initialization files for Vivado

docs/
  └── MODULE_GUIDE.md          # Detailed module documentation
```

## Module Descriptions

### `cpu.v` - Top-Level Module
The main CPU module that instantiates and connects all submodules. Acts as the system integrator.

**Inputs:**
- `clk`: System clock
- `rst`: Synchronous reset

### `alu.v` - Arithmetic Logic Unit
Performs all arithmetic and logical operations on 32-bit operands.

**Inputs:**
- `a_bus`, `b_bus`: 32-bit operands
- `opcode`: Operation selector (5 bits)
- `reset`: Reset signal
- `clk`: Clock

**Outputs:**
- `out_bus`: 32-bit result
- `z`: Zero flag (set when result is 0)

### `registerfile.v` - Register File
Stores 32 general-purpose 32-bit registers with read and write capabilities.

**Inputs:**
- `AA`, `BA`, `DA`: Address buses for operand A, B, and destination
- `D`: Data input for writes
- `RL`: Register Load enable
- `reset`: Reset signal
- `clk`: Clock

**Outputs:**
- `A`, `B`: Data outputs for operands A and B
- `test`: Debug output (register 31)

### `instructiondecoder.v` - Instruction Decoder & Control Unit
Decodes 49-bit instructions and generates control signals for all modules. Handles multiple addressing modes and operation types.

**Inputs:**
- `instruction`: 49-bit instruction from ROM
- `clk`, `rst`: Clock and reset

**Outputs:**
- `alu_oper`: ALU operation code
- `registerdst_addr`, `registerasrc_addr`, `registerbsrc_addr`: Register addresses
- `aluormem`: Multiplexer control for result selection
- `alusrc`: Multiplexer control for ALU source
- `literal_value`: Immediate value extracted from instruction
- `register_load`: Register write enable
- `ram_wr`: RAM write enable

### `programcounter.v` - Program Counter
Manages instruction sequencing with support for conditional and unconditional branches. Includes delay counter for instruction pipelining.

**Inputs:**
- `clk`, `rst`: Clock and reset
- `z`: Zero flag from ALU (for conditional branches)

**Outputs:**
- `romout`: 49-bit instruction from ROM

**Branch Instructions:**
- **BZ (0x10)**: Branch if zero flag is set
- **BNZ (0x11)**: Branch if zero flag is NOT set
- **BRA (0x12)**: Unconditional branch

### `alusrcmux.v` & `aluormemmux.v` - Multiplexers
Route data to the ALU and select between ALU and memory results for register writes.

### `rom.v` & `ram.v` - Memory Modules
Wrapper modules for Xilinx Block RAM IP cores.
- **ROM**: Read-only instruction storage (49-bit width)
- **RAM**: Read-write data storage (32-bit width)

## Data Flow

1. **Fetch**: Program Counter outputs instruction address → ROM retrieves instruction
2. **Decode**: Instruction Decoder parses opcode, addressing mode, and registers
3. **Execute**: 
   - Registers read operands from Register File
   - ALU performs operation based on opcode
   - Multiplexers route data appropriately
4. **Memory**: If needed, RAM performs read/write at specified address
5. **Writeback**: Result stored in destination register

## Clock and Control Signals

- **Clock (`clk`)**: Drives all sequential operations
- **Reset (`rst`)**: Asynchronous reset signal
- **Zero Flag (`z`)**: Set by ALU when result equals zero; used for conditional branches

## Using with Vivado

### Memory Initialization

The CPU uses Xilinx Block RAM IP cores for ROM and RAM. Memory can be initialized with `.coe` (Coefficient) files:

1. Place `.coe` files in the `mem_init/` directory
2. In Vivado, add the `.coe` file path to the ROM/RAM IP core settings
3. Resynthesize and implement

### Example COE Format

```
memory_initialization_radix = 16;
memory_initialization_vector =
12340001,  // Instruction 0: LD r1, 0x12340001
...
;
```

## Testing

Run the simulation testbench (`cpu_tb.v`) to verify functionality:

```bash
vivado -mode batch -source sim_script.tcl
```

The testbench applies a clock with 5ns period and pulse reset for 20ns.

## Files Needed for Vivado (Vivado-Specific)

**❌ DO NOT include on GitHub:**
- `*.xpr` - Vivado project file
- `*.xise` - Project settings
- `.gen/` - Generated IP cores
- `.hw/` - Hardware files
- `.ip_user_files/` - Vivado IP configuration
- `.runs/` - Build artifacts
- `.sim/` - Simulation artifacts
- `.backup.jou`, `.jou` - Vivado journal files
- `.str` - Vivado string files
- `*.pb`, `*.dcp`, `*.tcl` - Build files
- `vivado_*.backup.jou` - Vivado backup logs

**✅ DO include on GitHub:**
- `src/*.v` - Verilog source files
- `test/*.v` - Testbench files
- `mem_init/*.coe` - Memory initialization files
- `.gitignore` - Exclude Vivado files
- `README.md` - Project documentation
- `ARCHITECTURE.md` - Detailed architecture guide

## Assembly Language Example

To create programs for this CPU, generate `.coe` files with 49-bit instructions. Example operations:

```
// Load immediate: LD r1, 0x12345678
// Opcode=0x01, Mode=0x00 (immediate), Dst=r1 (0x01), Literal=0x12345678
// Instruction: [0x01<<44] | [0x00<<42] | [0x01<<32] | 0x12345678

// Add with immediate: ADD r2, r1, 100
// Opcode=0x03, Mode=0x00, Src=r1 (0x01), Dst=r2 (0x02), Literal=100
```

## Ports and Signals Summary

### Top-Level (cpu.v)

| Signal | Width | Direction | Purpose |
|--------|-------|-----------|---------|
| clk | 1 | Input | System clock |
| rst | 1 | Input | Synchronous reset |

## Performance Characteristics

- **Word Width**: 32 bits (data bus)
- **Instruction Width**: 49 bits
- **Register Count**: 32
- **Max Address Space**: 64KB (16-bit program counter)
- **Clock Domain**: Single clock domain
- **Pipeline Depth**: 4 stages (instruction delay)

## Future Enhancements

- [ ] Pipeline stages for improved throughput
- [ ] Cache implementation
- [ ] Interrupt handling
- [ ] Stack operations (PUSH, POP)
- [ ] Subroutine calls (CALL, RET)
- [ ] Conditional execution without branching
- [ ] Additional data widths (16-bit, 8-bit operations)

## Author

Klay Adams (R11679660)

## License

Educational use. Please credit original author if reused.

---

For detailed module-by-module documentation, see [MODULE_GUIDE.md](docs/MODULE_GUIDE.md)
