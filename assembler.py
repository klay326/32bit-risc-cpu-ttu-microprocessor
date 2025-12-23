#!/usr/bin/env python3
"""
32-bit RISC CPU Assembly to COE Assembler
Converts assembly language to Vivado COE (Coefficient) files
"""

import re
import sys
from typing import List, Tuple, Dict

class CPUAssembler:
    """Assembles CPU instructions to COE format"""
    
    # Opcode definitions
    OPCODES = {
        'LD':   0x01,
        'ST':   0x02,
        'ADD':  0x03,
        'SUB':  0x04,
        'AND':  0x05,
        'OR':   0x06,
        'XOR':  0x07,
        'NOT':  0x08,
        'SL':   0x09,
        'SR':   0x0A,
        'BZ':   0x10,
        'BNZ':  0x11,
        'BRA':  0x12,
    }
    
    # Addressing modes
    MODES = {
        'IMM': 0,  # Immediate
        'DIR': 1,  # Direct (memory)
        'REG': 2,  # Register
    }
    
    def __init__(self):
        self.instructions = []
        self.labels = {}
        self.current_addr = 0
    
    def parse_register(self, reg_str: str) -> int:
        """Parse register reference (r0-r31)"""
        match = re.match(r'r(\d+)', reg_str.lower())
        if not match:
            raise ValueError(f"Invalid register: {reg_str}")
        reg_num = int(match.group(1))
        if not (0 <= reg_num <= 31):
            raise ValueError(f"Register out of range: r{reg_num}")
        return reg_num
    
    def parse_value(self, val_str: str) -> int:
        """Parse decimal, hex (0x...), or binary (0b...) values"""
        val_str = val_str.strip()
        try:
            if val_str.startswith('0x') or val_str.startswith('0X'):
                return int(val_str, 16)
            elif val_str.startswith('0b') or val_str.startswith('0B'):
                return int(val_str, 2)
            else:
                return int(val_str)
        except ValueError:
            raise ValueError(f"Invalid value: {val_str}")
    
    def encode_instruction(self, opcode: int, mode: int, src: int, 
                          dst: int, imm: int) -> int:
        """Encode instruction into 49-bit format
        [OPCODE(5)][MODE(2)][SRC(5)][DST(5)][IMM(32)]
        """
        # Validate inputs
        if not (0 <= opcode <= 31):
            raise ValueError(f"Opcode out of range: {opcode}")
        if not (0 <= mode <= 3):
            raise ValueError(f"Mode out of range: {mode}")
        if not (0 <= src <= 31):
            raise ValueError(f"Source register out of range: {src}")
        if not (0 <= dst <= 31):
            raise ValueError(f"Dest register out of range: {dst}")
        if not (0 <= imm <= 0xFFFFFFFF):
            raise ValueError(f"Immediate out of range: 0x{imm:X}")
        
        # Build 49-bit instruction
        instruction = (opcode << 44) | (mode << 42) | (src << 37) | (dst << 32) | imm
        return instruction
    
    def assemble_line(self, line: str) -> Tuple[bool, str]:
        """
        Assemble a single instruction line
        Returns: (success, message)
        
        Instruction formats:
        - LD dst, imm              (Load immediate)
        - LD dst, [addr]           (Load from memory)
        - ST [addr], src           (Store to memory)
        - ADD dst, src, imm        (Add with immediate)
        - ADD dst, src1, src2      (Add with register)
        - SUB/AND/OR/XOR dst, src, imm/reg
        - NOT dst, src
        - SL/SR dst, src, imm/reg
        - BZ addr                  (Branch if zero)
        - BNZ addr                 (Branch if not zero)
        - BRA addr                 (Unconditional branch)
        """
        # Remove comments
        line = line.split('#')[0].strip()
        if not line:
            return True, "Empty line (skipped)"
        
        # Parse label
        if ':' in line:
            parts = line.split(':', 1)
            label = parts[0].strip()
            self.labels[label] = self.current_addr
            if len(parts) > 1:
                line = parts[1].strip()
            else:
                return True, f"Label '{label}' at address {self.current_addr}"
        
        if not line:
            return True, "Label only"
        
        # Parse instruction
        tokens = re.split(r'[,\s\[\]]+', line.strip())
        tokens = [t for t in tokens if t]  # Remove empty tokens
        
        if not tokens:
            return True, "Empty instruction"
        
        mnemonic = tokens[0].upper()
        
        if mnemonic not in self.OPCODES:
            return False, f"Unknown opcode: {mnemonic}"
        
        opcode = self.OPCODES[mnemonic]
        
        try:
            # Parse instruction based on type
            if mnemonic in ['LD']:
                if len(tokens) < 3:
                    return False, f"{mnemonic} requires at least 2 operands"
                dst = self.parse_register(tokens[1])
                # Check if operand 2 is register (REG mode) or value (IMM mode)
                if tokens[2].lower().startswith('r'):
                    mode = self.MODES['REG']
                    src = self.parse_register(tokens[2])
                    imm = 0
                else:
                    mode = self.MODES['IMM']
                    src = 0
                    imm = self.parse_value(tokens[2])
                instruction = self.encode_instruction(opcode, mode, src, dst, imm)
            
            elif mnemonic in ['ST']:
                if len(tokens) < 3:
                    return False, f"{mnemonic} requires at least 2 operands"
                # ST [addr], src
                imm = self.parse_value(tokens[1])
                src = self.parse_register(tokens[2])
                mode = self.MODES['IMM']
                dst = 0
                instruction = self.encode_instruction(opcode, mode, src, dst, imm)
            
            elif mnemonic in ['ADD', 'SUB', 'AND', 'OR', 'XOR']:
                if len(tokens) < 4:
                    return False, f"{mnemonic} requires 3 operands"
                dst = self.parse_register(tokens[1])
                src = self.parse_register(tokens[2])
                
                # Check if 3rd operand is register or immediate
                if tokens[3].lower().startswith('r'):
                    mode = self.MODES['REG']
                    imm = self.parse_register(tokens[3])
                else:
                    mode = self.MODES['IMM']
                    imm = self.parse_value(tokens[3])
                
                instruction = self.encode_instruction(opcode, mode, src, dst, imm)
            
            elif mnemonic in ['NOT']:
                if len(tokens) < 3:
                    return False, f"{mnemonic} requires 2 operands"
                dst = self.parse_register(tokens[1])
                src = self.parse_register(tokens[2])
                mode = self.MODES['REG']
                imm = 0
                instruction = self.encode_instruction(opcode, mode, src, dst, imm)
            
            elif mnemonic in ['SL', 'SR']:
                if len(tokens) < 4:
                    return False, f"{mnemonic} requires 3 operands"
                dst = self.parse_register(tokens[1])
                src = self.parse_register(tokens[2])
                
                # Check if shift amount is register or immediate
                if tokens[3].lower().startswith('r'):
                    mode = self.MODES['REG']
                    imm = self.parse_register(tokens[3])
                else:
                    mode = self.MODES['IMM']
                    imm = self.parse_value(tokens[3])
                
                instruction = self.encode_instruction(opcode, mode, src, dst, imm)
            
            elif mnemonic in ['BZ', 'BNZ', 'BRA']:
                if len(tokens) < 2:
                    return False, f"{mnemonic} requires an address"
                mode = 0
                src = 0
                dst = 0
                
                # Try to resolve label, or parse as value
                addr_str = tokens[1]
                if addr_str in self.labels:
                    imm = self.labels[addr_str]
                else:
                    imm = self.parse_value(addr_str)
                
                instruction = self.encode_instruction(opcode, mode, src, dst, imm)
            
            else:
                return False, f"Unhandled opcode: {mnemonic}"
            
            self.instructions.append(instruction)
            self.current_addr += 1
            return True, f"{mnemonic}: 0x{instruction:012X}"
        
        except Exception as e:
            return False, f"Parse error: {str(e)}"
    
    def assemble(self, code: str) -> Tuple[bool, List[int], List[str]]:
        """
        Assemble complete program (two-pass)
        Pass 1: Collect labels
        Pass 2: Assemble instructions with label resolution
        Returns: (success, instructions, messages)
        """
        messages = []
        
        # Pass 1: Collect labels
        self.instructions = []
        self.labels = {}
        self.current_addr = 0
        
        for line in code.split('\n'):
            line = line.split('#')[0].strip()
            if not line:
                continue
            
            if ':' in line:
                parts = line.split(':', 1)
                label = parts[0].strip()
                self.labels[label] = self.current_addr
            
            # Count instructions (skip labels)
            if ':' in line:
                remainder = line.split(':', 1)[1].strip()
                if remainder:
                    tokens = re.split(r'[,\s\[\]]+', remainder.strip())
                    tokens = [t for t in tokens if t]
                    if tokens and tokens[0].upper() in self.OPCODES:
                        self.current_addr += 1
            else:
                tokens = re.split(r'[,\s\[\]]+', line.strip())
                tokens = [t for t in tokens if t]
                if tokens and tokens[0].upper() in self.OPCODES:
                    self.current_addr += 1
        
        # Pass 2: Assemble instructions
        self.instructions = []
        self.current_addr = 0
        
        for line_num, line in enumerate(code.split('\n'), 1):
            success, message = self.assemble_line(line)
            messages.append(f"Line {line_num}: {message}")
            if not success:
                return False, [], messages
        
        return True, self.instructions, messages
    
    def to_coe(self, instructions: List[int]) -> str:
        """Convert instructions to COE format"""
        hex_values = [f"{instr:012X}" for instr in instructions]
        coe = "memory_initialization_radix=16;\n"
        coe += "memory_initialization_vector="
        coe += " ".join(hex_values)
        coe += ";\n"
        return coe
    
    def to_mif(self, instructions: List[int]) -> str:
        """Convert instructions to MIF format (alternative)"""
        mif = "DEPTH = " + str(len(instructions)) + ";\n"
        mif += "WIDTH = 49;\n"
        mif += "ADDRESS_RADIX = HEX;\n"
        mif += "DATA_RADIX = HEX;\n"
        mif += "CONTENT\n"
        mif += "BEGIN\n"
        
        for addr, instr in enumerate(instructions):
            mif += f"  {addr:X} : {instr:012X};\n"
        
        mif += "END;\n"
        return mif


def main():
    """Command-line interface"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="32-bit RISC CPU Assembly to COE Assembler",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Assemble a file
  python3 assembler.py program.asm -o program.coe
  
  # Show help for instruction format
  python3 assembler.py --help-asm
        """)
    
    parser.add_argument('input', nargs='?', help='Input assembly file')
    parser.add_argument('-o', '--output', help='Output COE file (default: input.coe)')
    parser.add_argument('--mif', action='store_true', help='Output MIF format instead of COE')
    parser.add_argument('--help-asm', action='store_true', help='Show instruction format help')
    
    args = parser.parse_args()
    
    if args.help_asm:
        print_instruction_help()
        return
    
    if not args.input:
        print("Error: Input file required")
        print("Use: python3 assembler.py input.asm -o output.coe")
        sys.exit(1)
    
    # Read input file
    try:
        with open(args.input, 'r') as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {args.input}")
        sys.exit(1)
    
    # Assemble
    assembler = CPUAssembler()
    success, instructions, messages = assembler.assemble(code)
    
    # Print messages
    for message in messages:
        print(message)
    
    if not success:
        print("\nAssembly failed!")
        sys.exit(1)
    
    # Generate output
    if args.mif:
        output_code = assembler.to_mif(instructions)
        output_file = args.output or args.input.replace('.asm', '.mif')
    else:
        output_code = assembler.to_coe(instructions)
        output_file = args.output or args.input.replace('.asm', '.coe')
    
    # Write output
    try:
        with open(output_file, 'w') as f:
            f.write(output_code)
        print(f"\n✓ Assembly successful!")
        print(f"  Instructions: {len(instructions)}")
        print(f"  Output: {output_file}")
    except Exception as e:
        print(f"Error writing output: {e}")
        sys.exit(1)


def print_instruction_help():
    """Print instruction format help"""
    help_text = """
32-bit RISC CPU Instruction Set

ADDRESSING MODES:
  IMM - Immediate (value encoded in instruction)
  DIR - Direct (memory address)
  REG - Register

INSTRUCTION FORMATS:

Load/Store:
  LD dst, imm              Load immediate into dst
  LD dst, src              Load from src register
  ST imm, src              Store src to memory address

Arithmetic (ADD, SUB):
  ADD dst, src, imm        Add immediate to src, store in dst
  ADD dst, src1, src2      Add src2 to src1, store in dst
  SUB dst, src, imm        Subtract immediate from src
  SUB dst, src1, src2      Subtract src2 from src1

Logic (AND, OR, XOR):
  AND dst, src, imm        Bitwise AND
  OR dst, src, imm         Bitwise OR
  XOR dst, src, imm        Bitwise XOR

Other:
  NOT dst, src             Bitwise NOT
  SL dst, src, imm         Shift left by imm
  SL dst, src, src2        Shift left by src2
  SR dst, src, imm         Shift right by imm
  SR dst, src, src2        Shift right by src2

Branching:
  BZ addr                  Branch if zero flag set
  BNZ addr                 Branch if zero flag not set
  BRA addr                 Unconditional branch

EXAMPLES:

  # Load a value
  LD r1, 0x12345678

  # Add two numbers
  ADD r1, r2, 100          # r1 = r2 + 100
  ADD r3, r4, r5           # r3 = r4 + r5

  # Shift operations
  SL r1, r2, 3             # r1 = r2 << 3
  SR r1, r2, r3            # r1 = r2 >> r3

  # Branching
  BZ 10                    # Jump to instruction 10 if zero
  BRA 0                    # Jump to instruction 0

COMMENTS:
  # This is a comment

LABELS:
  start:  LD r1, 100
          ADD r1, r1, r2
          BRA start
    """
    print(help_text)


if __name__ == '__main__':
    main()
