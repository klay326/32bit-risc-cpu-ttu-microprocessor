# Module-by-Module Guide

## Table of Contents
1. [CPU Module](#cpu-module)
2. [Instruction Decoder](#instruction-decoder)
3. [ALU](#alu)
4. [Register File](#register-file)
5. [Program Counter](#program-counter)
6. [Multiplexers](#multiplexers)
7. [Memory Modules](#memory-modules)

---

## CPU Module

**File**: `src/cpu.v`

This is the top-level module that integrates all submodules into a cohesive processor.

### Purpose
Serves as the system integrator, instantiating and connecting:
- Program Counter
- Instruction Decoder
- ALU
- Register File
- RAM and ROM
- Multiplexers

### Signals

#### Internal Wires (Data Paths)

```verilog
wire [48:0] romtodecode;        // Instruction from ROM to decoder
wire [4:0] alu_oper;            // ALU operation code
wire [4:0] registerdst_addr;    // Destination register address
wire [4:0] registerasrc_addr;   // Source A register address
wire [4:0] registerbsrc_addr;   // Source B register address
wire aluormem;                  // Mux control: ALU or Memory result
wire alusrc;                    // Mux control: Register or Immediate
wire register_load;             // Register file write enable
wire ram_wr;                    // RAM write enable
wire zflag;                     // Zero flag from ALU
wire [31:0] A, B;              // Register outputs
wire [31:0] b_bus;             // ALU B input (after mux)
wire [31:0] out_bus;           // ALU output
wire [31:0] regdatain;         // Data to register file
wire [31:0] ramwire;           // Data from RAM
wire [31:0] literal_value;     // Immediate value from instruction
```

### Data Flow

```
ROM → Instruction Decoder → Control Signals
                          ↓
                    Program Counter
                          ↓
Register File ← ALU ← Multiplexers ← Immediate/Register
      ↓                                      ↑
      RAM ←────────────────────────────────┘
```

### Clock and Reset

- **Clock (`clk`)**: Synchronous clock input
- **Reset (`rst`)**: Synchronous reset (active high)

---

## Instruction Decoder

**File**: `src/instructiondecoder.v`

The control unit of the CPU. Decodes 49-bit instructions and generates control signals for all modules.

### Purpose
- Parse instruction bits into opcode, addressing mode, and operand addresses
- Generate control signals for multiplexers, register file, ALU, and memory
- Handle multiple addressing modes (immediate, direct, register)

### Instruction Parsing

```verilog
assign opcode = instruction[48:44];           // 5-bit opcode
assign adressing_mode = instruction[43:42];   // 2-bit addressing mode
assign source = instruction[41:37];           // 5-bit source register
assign dest = instruction[36:32];             // 5-bit destination register
assign literal_source = instruction[31:0];    // 32-bit immediate value
```

### Output Control Signals

| Signal | Width | Purpose |
|--------|-------|---------|
| `alu_oper` | 5 | ALU operation code |
| `registerdst_addr` | 5 | Write destination register |
| `registerasrc_addr` | 5 | Read source A register |
| `registerbsrc_addr` | 5 | Read source B register |
| `aluormem` | 1 | 0: ALU result → Reg, 1: RAM result → Reg |
| `alusrc` | 1 | 0: Register B → ALU, 1: Immediate → ALU |
| `literal_value` | 32 | Extracted immediate value |
| `register_load` | 1 | Enable register write |
| `ram_wr` | 1 | Enable RAM write |

### Instruction Decoding Examples

#### Load Immediate
```
Opcode: LD (0x01)
Mode: Immediate (0x00)
Destination: r1 (0x01)
Immediate: 0x12345678

Control Signals Generated:
- alusrc = literalALUsrc (1)      // Route immediate to ALU
- register_load = loadreg (1)     // Enable register write
- registerdst_addr = 0x01         // Write to r1
- alu_oper = LD                   // ALU pass-through
- literal_value = 0x12345678      // Immediate value
```

#### Add Register
```
Opcode: ADD (0x03)
Mode: Register (0x10)
Source: r1 (0x01)
Destination: r2 (0x02)
Immediate field holds: r3 (0x03) [shifted to register address format]

Control Signals:
- registerasrc_addr = 0x01        // Read r1
- registerbsrc_addr = 0x03        // Read r3
- registerdst_addr = 0x02         // Write to r2
- alusrc = regALUsrc (0)          // Route register to ALU
- aluormem = selectalu (0)        // Route ALU result to register
- register_load = 1               // Enable write
- alu_oper = ADD                  // ADD operation
```

#### Store
```
Opcode: ST (0x02)
Source: r1 (address)
Data: r2 (value)
Address: 0x1000

Control Signals:
- registerbsrc_addr = r2          // Read data to write
- ram_wr = 1                      // Enable RAM write
- literal_value = 0x1000          // Address
- alusrc = literalALUsrc          // Route immediate (address) to ALU
```

### Addressing Modes Handled

Each arithmetic/logic instruction can operate in one of two modes:

1. **Immediate Mode (0x00)**
   - Second operand is a literal value in the instruction
   - Used for constants and quick operations
   - Example: `ADD r1, r2, 100`

2. **Register Mode (0x10)**
   - Second operand is in a register
   - Used for register-to-register operations
   - Example: `ADD r1, r2, r3`

### State Machine

The decoder uses combinational logic (no state machine) for speed. Reset condition zeros all control outputs.

---

## ALU (Arithmetic Logic Unit)

**File**: `src/alu.v`

Performs all arithmetic and logical operations on 32-bit operands.

### Operations Supported

| Opcode | Operation | Formula | Description |
|--------|-----------|---------|-------------|
| 0x01 | LD | B | Load/Pass through B |
| 0x02 | ST | B | Store (pass through) |
| 0x03 | ADD | A + B | Addition |
| 0x04 | SUB | A - B | Subtraction |
| 0x05 | AND | A & B | Bitwise AND |
| 0x06 | OR | A \| B | Bitwise OR |
| 0x07 | XOR | A ^ B | Bitwise XOR |
| 0x08 | NOT | ~A | Bitwise NOT |
| 0x09 | SL | A << B | Shift left (B is shift amount) |
| 0x0A | SR | A >> B | Shift right (B is shift amount) |

### Inputs

```verilog
input clk, reset
input [31:0] a_bus, b_bus           // 32-bit operands
input [4:0] opcode                  // 5-bit operation selector
```

### Outputs

```verilog
output reg [31:0] out_bus           // 32-bit result
output z                            // Zero flag (1 if out_bus == 0)
```

### Zero Flag

```verilog
assign z = (out_bus == 0);
```

This flag is critical for conditional branching in the Program Counter.

### Implementation Notes

- Uses combinational logic for operation selection (case statement)
- Combinational flag generation (no delay)
- Reset clears output to 0
- All operations complete in one clock cycle

---

## Register File

**File**: `src/registerfile.v`

The CPU's working memory: 32 registers, each 32 bits wide.

### Architecture

```
32 registers × 32 bits = 1024 bits total
regbank[0]  → 32 bits
regbank[1]  → 32 bits
...
regbank[31] → 32 bits
```

### Inputs

```verilog
input [4:0] AA                      // Address for read port A
input [4:0] BA                      // Address for read port B
input [4:0] DA                      // Address for write port
input [31:0] D                      // Data input for write
input RL                            // Register Load enable
input clk, reset
```

### Outputs

```verilog
output [31:0] A, B                  // Data outputs for read ports
output reg [31:0] test              // Debug output (always reads r31)
```

### Operation

**Combinational Reads:**
```verilog
assign A = regbank[AA];             // Read port A (asynchronous)
assign B = regbank[BA];             // Read port B (asynchronous)
```

**Synchronous Writes:**
```verilog
if(RL == 1)                         // When write enabled
    regbank[DA] <= D;               // Write data on clock edge
```

### Features

- **2-port read, 1-port write** design
- Simultaneous reads from two registers
- Synchronous write (samples on clock edge)
- Debug port always outputs register 31 for monitoring

### Reset Behavior

Currently commented out but could zero all registers on reset:
```verilog
// if(reset) 
//   for (integer i = 0; i < 32; i = i + 1) 
//     regbank[i] <= 0;
```

---

## Program Counter

**File**: `src/programcounter.v`

Manages instruction sequencing with support for conditional and unconditional branches.

### Inputs

```verilog
input clk, rst
input z                             // Zero flag from ALU
output [48:0] romout               // 49-bit instruction from ROM
```

### Internal Registers

```verilog
reg [5:0] pc                        // Program counter (6 bits → 64 instructions max)
reg [3:0] counter                   // Delay counter (0-15)
reg lastz                           // Latched zero flag from previous cycle
```

### Program Counter Increment Logic

The PC doesn't increment every clock. Instead:
1. A counter counts from 0 to 4 (5 cycles)
2. On the 5th cycle, the PC increments or branches
3. This creates intentional delay for instruction pipelining

```verilog
if (counter < 4)
    counter <= counter + 1;
else begin
    counter = 0;  // Reset counter
    // Check for branch conditions
    case (romout[48:44])
        BZ: ...
        BNZ: ...
        BRA: ...
        default: pc <= pc + 1;  // Normal increment
    endcase
end
```

### Branch Instructions

#### Branch If Zero (BZ - 0x10)

```verilog
if (lastz)                          // If PREVIOUS instruction result was 0
    pc <= romout[4:0];              // Jump to address in instruction
else
    pc <= pc + 1;                   // Normal increment
```

#### Branch If Not Zero (BNZ - 0x11)

```verilog
if (~lastz)                         // If PREVIOUS instruction was NOT zero
    pc <= romout[4:0];              // Jump to address
else
    pc <= pc + 1;                   // Normal increment
```

#### Unconditional Branch (BRA - 0x12)

```verilog
pc <= romout[4:0];                  // Always jump
```

### Zero Flag Tracking

```verilog
lastz <= z;  // Sample and hold the zero flag at each increment
```

The zero flag is latched from the previous instruction to avoid race conditions.

### Reset Behavior

```verilog
if (rst)
    pc <= 0;                        // Reset to instruction 0
```

---

## Multiplexers

### ALU Source Multiplexer (`alusrcmux.v`)

Routes either a register value or an immediate value to the ALU's B input.

```verilog
assign b_bus = alusrc ? literal : regbdata;

// When alusrc = 0 → Use register data
// When alusrc = 1 → Use immediate value
```

**Usage:** Selects between immediate and register operands for ALU operations.

### ALU/Memory Result Multiplexer (`aluormemmux.v`)

Routes either the ALU result or RAM data to the register file input.

```verilog
assign regdatain = aluormem ? ramout : aluout;

// When aluormem = 0 → Use ALU result
// When aluormem = 1 → Use RAM data
```

**Usage:** Selects destination for register writes (ALU operations vs. memory loads).

---

## Memory Modules

### ROM (Read-Only Memory)

**File**: `src/rom.v`

Stores the program (instructions). Uses Xilinx Block RAM IP core.

```verilog
module rom(
    input clka,                     // Clock
    input [3:0] addra,             // Address (4 bits = 16 instructions)
    output [48:0] douta            // 49-bit instruction
);

mem_gen_rom U1 (
    .clka(clka),
    .addra(addra),
    .douta(douta)
);
```

**Characteristics:**
- Read-only (no write capability)
- 49-bit instruction width
- Addressed by Program Counter
- Synchronous read (samples on clock edge)

**Initialization:**
- Use `.coe` (Coefficient) files in Vivado
- Place in `mem_init/` directory
- Load via Vivado IP core settings

### RAM (Random-Access Memory)

**File**: `src/ram.v`

Stores runtime data. Uses Xilinx Block RAM IP core.

```verilog
module ram(
    input clka,                     // Clock
    input wea,                      // Write enable
    input [31:0] addra,            // Address
    input [31:0] dina,             // Data input
    output [0:31] douta            // Data output
);

mem_gen_ram U1 (
    .clka(clka),
    .wea(wea),
    .addra(addra),
    .dina(dina),
    .douta(douta)
);
```

**Characteristics:**
- Readable and writable
- 32-bit data width
- Addressable memory cells
- Synchronous read/write

---

## Signal Summary Table

| Module | Input Signal | Output Signal | Width | Purpose |
|--------|--------------|---------------|-------|---------|
| **CPU** | clk, rst | — | 1 | Top-level control |
| **PC** | clk, rst, z | romout | 1, 49 | Instruction sequencing |
| **Decoder** | instruction | alu_oper, reg_dst, reg_asrc, reg_bsrc, aluormem, alusrc, literal, reg_load, ram_wr | 5, 5, 5, 5, 1, 1, 32, 1, 1 | Instruction parsing & control |
| **ALU** | a_bus, b_bus, opcode | out_bus, z | 32, 32, 5 | 32, 1 | Arithmetic/logic operations |
| **RegFile** | AA, BA, DA, D, RL | A, B, test | 5, 5, 5, 32, 1 | 32, 32, 32 | Register storage & access |
| **ROM** | clka, addra | douta | 1, 4 | 49 | Instruction storage |
| **RAM** | clka, wea, addra, dina | douta | 1, 1, 32, 32 | 32 | Data storage |

---

## Example: Executing "ADD r1, r2, 0x100"

```
1. FETCH Phase
   PC = 0
   ROM[0] → Instruction [0x03, 0x00, 0x02, 0x01, 0x00000100]
   
2. DECODE Phase
   Instruction Decoder sees:
   - Opcode: 0x03 (ADD)
   - Mode: 0x00 (Immediate)
   - Src: 0x02 (r2)
   - Dst: 0x01 (r1)
   - Immediate: 0x100
   
   Control signals generated:
   - alu_oper = ADD
   - registerasrc_addr = 0x02 → RegFile reads r2
   - registerbsrc_addr = 0x00 (ignored for immediate mode)
   - alusrc = 1 (select immediate)
   - aluormem = 0 (select ALU result)
   - register_load = 1
   - literal_value = 0x100
   
3. EXECUTE Phase
   RegisterFile outputs:
   - A = [value of r2]
   - (B value irrelevant due to immediate mode)
   
   ALU Source Mux selects:
   - a_bus = A (value from r2)
   - b_bus = literal_value = 0x100
   
   ALU performs:
   - out_bus = a_bus + b_bus = r2_value + 0x100
   - z = (out_bus == 0) ? 1 : 0
   
4. WRITEBACK Phase
   ALU/Mem Mux selects ALU result (aluormem = 0)
   RegFile writes:
   - regbank[0x01] ← out_bus
   
5. NEXT CYCLE
   PC increments after 5-cycle delay
   PC = 1 → ROM[1] fetched
```

---

## Datapath Diagram

```
                    ROM
                    │
                    │ [48:0] instruction
                    ↓
            ┌───────────────────┐
            │ Instruction       │
            │ Decoder           │
            └────────┬──────────┘
                     │ Control Signals
                     │
        ┌────────────┼────────────┐
        ↓            ↓            ↓
   RegFile      Multiplexers    ALU
        │           │ │           │
        ├─ a_bus ────┘│ ALU Src   │
        ├─ b_bus ─────┘           │
        │                ├─ ─────→ ALU
        │                │
        │           ALU/Mem Mux
        │                │
        │        ┌──────┴───────┐
        │        ↓              ↓
        │       ALU result    RAM data
        │        │              │
        ├────────┼──────────────┘
        │        │
        └────────┴─→ Write Port
                 │
              regbank
```

For more detailed explanations, refer to individual module comments in the source files.
