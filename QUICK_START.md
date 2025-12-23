# Quick Start Guide

## What You Have

A **32-bit CPU** you designed for FPGA that can:
- Perform arithmetic (ADD, SUB)
- Do logic operations (AND, OR, XOR, NOT)
- Shift bits left/right (SL, SR)
- Load/store data from memory (LD, ST)
- Branch conditionally (BZ, BNZ) or unconditionally (BRA)

---

## Project Organization

### `src/` - Core CPU Modules

```
cpu.v              ← Connects everything together (20 lines)
├── programcounter.v   ← Counts through instructions, handles jumps
├── instructiondecoder.v ← Decodes instructions, generates control signals
├── registerfile.v  ← Stores 32 variables (registers)
├── alu.v           ← Does math/logic operations
├── alusrcmux.v     ← Picks immediate or register for ALU
├── aluormemmux.v   ← Picks ALU result or memory for registers
├── rom.v           ← Reads instructions from memory
└── ram.v           ← Reads/writes data from memory
```

**Key Insight:** `cpu.v` is tiny—it just wires the modules together. Most complexity is in the instruction decoder and ALU.

### `test/` - How to Test

```
cpu_tb.v           ← Simulation testbench
                     (Clocks the CPU, resets it, checks output)
```

### `mem_init/` - Example Programs

```
test.coe           ← Example instructions in hexadecimal
shortprogram.coe   ← Longer program example
```

### `docs/` - Understanding It

```
MODULE_GUIDE.md    ← Deep dive into each module
```

---

## The CPU Works Like This

### 1️⃣ **FETCH** → Get instruction from memory
```
Program Counter → ROM → Instruction [e.g., "ADD r1, r2, 100"]
```

### 2️⃣ **DECODE** → Understand what to do
```
Instruction Decoder reads:
- What operation? (ADD, SUB, LD, etc.)
- What registers? (r1, r2, etc.)
- What immediate value? (100)
```

### 3️⃣ **EXECUTE** → Do the math
```
ALU performs: r2 + 100
Result: (output)
```

### 4️⃣ **STORE** → Save result
```
Register File writes result into r1
```

### 5️⃣ **REPEAT** → Next instruction
```
Program Counter increments
Back to FETCH
```

---

## Instruction Format

Every instruction is **49 bits**:

```
[OPCODE] [MODE] [SRC] [DST] [VALUE/ADDRESS]
  5b      2b     5b    5b      32b
```

### Example: Load the number 0x12345678 into register 1

```
Instruction breakdown:
- Opcode: 0x01 (LD = Load)
- Mode: 0x00 (Immediate = the value is in the instruction)
- Src: ignored for LD
- Dst: 0x01 (register 1)
- Value: 0x12345678

In hex (49-bit instruction):
[01][00][00001][00001][00000000000000000000000000012345678]
→ 0x10400004D2D78 (roughly)
```

---

## Key Modules Explained (Simple Version)

### ALU
**Does math:**
```
Input A: 10
Input B: 5
Operation: ADD
Output: 15

Input A: 10
Input B: 5
Operation: SUB
Output: 5

Input A: 10
Input B: 0
Operation: ADD
Output: 10
Zero Flag: Not set (result ≠ 0)
```

### Register File
**Stores values:**
```
32 registers (r0-r31), each holds 32 bits

Register 1 ← value
Register 2 ← value
...
Register 31 ← value
```

### Instruction Decoder
**Reads instruction, sets switches:**
```
Instruction: "ADD r1, r2, 100"

Decoder output:
- Tell ALU to add
- Tell registers to read r2
- Tell mux to use immediate (100)
- Tell register file to write to r1
```

### Program Counter
**Tracks position, handles jumps:**
```
Start: PC = 0 (instruction 0)
Normal: PC = 1 (instruction 1)
Branch: PC = 10 (jump to instruction 10)
```

---

## Important Vivado-Specific Stuff (What NOT to Put on GitHub)

These are Vivado project files—**they're machine-specific and massive**:

```
❌ *.xpr (project file - 50KB)
❌ .gen/ (generated files - 100MB+)
❌ .runs/ (build artifacts - 200MB+)
❌ *.pb, *.dcp, *.tcl (Vivado internals)
```

**Why?** Your coworkers don't need them. They can open the `.v` files in any HDL editor or recreate the Vivado project.

✅ **DO include:**
- `.v` files (pure Verilog, no Vivado)
- `.coe` files (memory init)
- `.md` files (documentation)

---

## How Signals Flow

```
┌─────────────────────────────────────────────────────────┐
│                        CPU                              │
│                                                         │
│  ROM (Instructions)                                    │
│     ↓                                                   │
│  Instruction Decoder (Understand instruction)          │
│     ↓ ↓ ↓ ↓ ↓ ↓ ↓ (Control signals)                   │
│                                                         │
│  ┌─→ Program Counter (Which instruction)               │
│  │        ↓                                             │
│  │   Program Counter (handles jumps)                    │
│  │        ↓                                             │
│  │   Back to ROM (fetch next)                          │
│  │                                                     │
│  ├─→ Register File (r0-r31)                           │
│  │    ↓ (read A, read B)                              │
│  │   Mux (immediate or register?)                      │
│  │    ↓                                                │
│  │   ALU (math/logic)                                  │
│  │    ↓                                                │
│  │   Mux (ALU result or RAM data?)                     │
│  │    ↓                                                │
│  └─→ Register File (write result)                     │
│       ↓ (to RAM if storing)                            │
│      RAM (Data storage)                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Reading the Code

### Start Here: `src/cpu.v`

```verilog
module cpu(
    input clk, rst       // Clock and reset
);
    // Wires connecting modules
    wire [48:0] instruction;
    wire [31:0] alu_result;
    // ... more wires
    
    // Instantiate (create instances of) all submodules
    programcounter pc(...);      // Module 1
    instructiondecoder id(...);  // Module 2
    alu alu(...);                // Module 3
    registerfile rf(...);        // Module 4
    // ... etc
endmodule
```

**What this shows:** The CPU is just modules plugged together. The real work happens in each module.

### Then Look: `src/alu.v`

```verilog
always @(*) begin
    case(opcode)
        ADD: out_bus <= a_bus + b_bus;      // Do addition
        SUB: out_bus <= a_bus - b_bus;      // Do subtraction
        AND: out_bus <= a_bus & b_bus;      // Do AND
        // ... more operations
    endcase
end
```

**What this shows:** The ALU is just a big switch statement—"if ADD, then add."

---

## Memory Files (`.coe` Format)

Example from `mem_init/test.coe`:

```
memory_initialization_radix=16;
memory_initialization_vector=
1001ABCDEF12   // Instruction 0
391F0000000A   // Instruction 1
304100000001   // Instruction 2
...
;
```

Each value is one 49-bit instruction in hexadecimal.

**To decode one:** Use the instruction decoder module to understand what each hex means.

---

## What to Know Before Sharing on GitHub

### The Good 📦
- ✅ You have working Verilog code
- ✅ It's well-organized (src/, test/, docs/)
- ✅ You have documentation
- ✅ Others can learn from it

### Vivado-Specific Stuff 🚫
- ❌ .xpr files are huge and user-specific
- ❌ Generated files can be recreated
- ❌ No one needs your build artifacts
- ❌ Use `.gitignore` to exclude them

### Best Practice
- **Share pure Verilog** (language-agnostic)
- **Include documentation** (help people understand)
- **Provide test files** (prove it works)
- **Exclude tool-specific files** (they clutter repos)

---

## Next Steps

1. **Understand each module** (read `docs/MODULE_GUIDE.md`)
2. **Study the testbench** (`test/cpu_tb.v`)
3. **Create GitHub repo** (follow `GITHUB_SETUP.md`)
4. **Add features** (e.g., stack operations, interrupts)
5. **Write more documentation** (comments in code, guides for users)

---

## Common Questions

**Q: Why 49-bit instructions?**
A: Opcode(5) + Mode(2) + Src(5) + Dst(5) + Immediate(32) = 49 bits

**Q: Why 32 registers?**
A: Common design choice. 5 bits can address 32 values (2^5 = 32).

**Q: Can I extend this CPU?**
A: Yes! Add more opcodes, more registers, pipelining, caching, etc.

**Q: Should I upload the Vivado project?**
A: No. Upload just the `.v` files. People can recreate the Vivado project from them.

**Q: Is this a real CPU?**
A: It's a simplified educational CPU. Real CPUs have pipelining, caching, interrupts, etc.

---

## Resources

- **Verilog Guide**: See comments in `.v` files
- **ISA Reference**: See README.md
- **Module Details**: See docs/MODULE_GUIDE.md
- **GitHub Setup**: See GITHUB_SETUP.md

**You're ready to share!** 🚀
