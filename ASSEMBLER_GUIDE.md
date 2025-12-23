# CPU Assembly & Assembler Guide

## Overview

The CPU Assembler converts human-readable assembly language into COE (Coefficient) files that can be loaded into Vivado's Block RAM for instruction memory.

## Quick Start

```bash
# Assemble a program
python3 assembler.py program.asm -o program.coe

# Show help
python3 assembler.py --help-asm
```

## Instruction Set

### Registers
- `r0` through `r31` - 32 general-purpose registers (32-bit each)

### Addressing Modes
- **IMM** - Immediate value encoded in instruction
- **REG** - Value from register
- **DIR** - Direct memory address

## Instruction Reference

### Load/Store (IMM or REG)

```assembly
LD dst, imm         # Load immediate value into register
LD dst, src         # Load from register
ST addr, src        # Store register to memory address
```

**Examples:**
```assembly
LD r1, 0x12345678   # r1 = 0x12345678
LD r2, r1           # r2 = r1
ST 0x1000, r3       # memory[0x1000] = r3
```

### Arithmetic (IMM or REG)

```assembly
ADD dst, src, imm   # dst = src + imm
ADD dst, src1, src2 # dst = src1 + src2

SUB dst, src, imm   # dst = src - imm
SUB dst, src1, src2 # dst = src1 - src2
```

**Examples:**
```assembly
ADD r1, r2, 100     # r1 = r2 + 100
ADD r1, r2, r3      # r1 = r2 + r3
SUB r4, r1, r2      # r4 = r1 - r2
```

### Bitwise Logic (IMM or REG)

```assembly
AND dst, src, imm   # dst = src & imm
OR  dst, src, imm   # dst = src | imm
XOR dst, src, imm   # dst = src ^ imm
NOT dst, src        # dst = ~src
```

**Examples:**
```assembly
AND r1, r2, 0xFF    # r1 = r2 & 0xFF
OR  r3, r4, 0x0F    # r3 = r4 | 0x0F
XOR r5, r6, r7      # r5 = r6 ^ r7
NOT r8, r9          # r8 = ~r9
```

### Bit Shifts (IMM or REG)

```assembly
SL dst, src, imm    # dst = src << imm (shift left)
SL dst, src1, src2  # dst = src1 << src2

SR dst, src, imm    # dst = src >> imm (shift right)
SR dst, src1, src2  # dst = src1 >> src2
```

**Examples:**
```assembly
SL r1, r2, 3        # r1 = r2 << 3
SR r3, r4, r5       # r3 = r4 >> r5
```

### Branching

Branches use the zero flag (set by previous arithmetic operations).

```assembly
BZ addr             # Branch if zero flag set (jump if last result was 0)
BNZ addr            # Branch if NOT zero (jump if last result was not 0)
BRA addr            # Unconditional branch (always jump)
```

**Examples:**
```assembly
BZ 10               # Jump to instruction 10 if zero
BNZ loop            # Jump to label 'loop' if not zero
BRA start           # Always jump to label 'start'
```

## Number Formats

The assembler supports multiple number formats:

```assembly
LD r1, 100          # Decimal
LD r1, 0x64         # Hexadecimal
LD r1, 0b01100100   # Binary
```

## Labels

Define labels for jump targets:

```assembly
start:
    ADD r1, r1, 1
    BNZ start       # Jump back to 'start' label
```

Labels are resolved automatically during assembly.

## Comments

Lines or parts of lines starting with `#` are comments:

```assembly
# This is a comment
ADD r1, r2, 100     # Add 100 to r2, store in r1
```

## Example Programs

### Example 1: Simple Counter

```assembly
# Initialize counter
LD r1, 0

# Loop: increment and check
loop:
    ADD r1, r1, 1           # Increment r1
    BNZ loop                # Jump back if not zero
    
# When r1 overflows to 0, we exit
end:
    BRA end                 # Infinite loop at end
```

### Example 2: Bitwise Operations

```assembly
# Load two values
LD r1, 0xAAAAAAAA
LD r2, 0x55555555

# Perform operations
AND r3, r1, r2      # Bitwise AND
OR  r4, r1, r2      # Bitwise OR
XOR r5, r1, r2      # Bitwise XOR

# Result in r3, r4, r5
end:
    BRA end
```

### Example 3: Shift Demo

```assembly
# Load a value
LD r1, 1

# Shift left 4 times to get 16
SL r2, r1, 4        # r2 = 1 << 4 = 16

# Shift right 2 times
SR r3, r2, 2        # r3 = 16 >> 2 = 4

end:
    BRA end
```

## Instruction Encoding

Instructions are 49 bits:

```
[OPCODE(5)] [MODE(2)] [SRC(5)] [DST(5)] [IMM(32)]
```

The assembler automatically encodes assembly into this format.

**Opcode Reference:**
```
0x01: LD     0x02: ST     0x03: ADD    0x04: SUB
0x05: AND    0x06: OR     0x07: XOR    0x08: NOT
0x09: SL     0x0A: SR     0x10: BZ     0x11: BNZ     0x12: BRA
```

## Using Generated COE Files

1. Generate COE file:
   ```bash
   python3 assembler.py myprogram.asm -o myprogram.coe
   ```

2. In Vivado:
   - Open your Vivado project
   - Right-click on the Block RAM IP core (mem_gen_rom)
   - Select "Customize IP"
   - Go to "Other Options"
   - Load COE file
   - Click "OK"

3. Resynthesize and run simulation

## Troubleshooting

### "Unknown opcode"
- Check spelling (opcodes are case-insensitive but spelled correctly)
- Valid opcodes: LD, ST, ADD, SUB, AND, OR, XOR, NOT, SL, SR, BZ, BNZ, BRA

### "Invalid register"
- Registers must be r0-r31
- Check format: `r1` not `r01` or `R1`

### "Invalid value"
- Values can be decimal, hex (0x...), or binary (0b...)
- Hex values must start with 0x, not just x

### "Branch label not found"
- Check label spelling matches exactly
- Labels are case-sensitive
- Labels must be defined before use (forward references not supported)

## Tips

1. **Start small** - Test basic arithmetic before complex programs
2. **Use comments** - Document your program logic
3. **Test jumps** - Verify branch destinations are correct addresses
4. **Initialize registers** - Use LD before using registers
5. **Know your operands** - Some instructions require immediate, others require registers

## Example Workflow

```bash
# 1. Write your program
nano myprogram.asm

# 2. Assemble it
python3 assembler.py myprogram.asm -o myprogram.coe

# 3. Check output (should show instruction count)
# Output: ✓ Assembly successful!
#         Instructions: 15
#         Output: myprogram.coe

# 4. Load into Vivado and test
# 5. Iterate and improve
```

## Advanced: Multi-File Support

To assemble multiple files, create a main file that includes others (future enhancement).

## Customization

To add new instructions:

1. Add opcode to `OPCODES` dict in `assembler.py`
2. Add parsing logic in `assemble_line()` method
3. Test with example program
4. Update this guide

## See Also

- [README.md](README.md) - Project overview
- [docs/MODULE_GUIDE.md](docs/MODULE_GUIDE.md) - CPU architecture details
- [example.asm](example.asm) - Example assembly program
- [example_output.coe](example_output.coe) - Generated COE from example
