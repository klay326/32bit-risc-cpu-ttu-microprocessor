# Example CPU Assembly Program
# This demonstrates all instruction types

# Load a value into r1
LD r1, 0x12345678

# Add with immediate
ADD r2, r1, 100

# Add with register
ADD r3, r1, r2

# Subtract
SUB r4, r3, r2

# Bitwise operations
AND r5, r3, 0xFF
OR  r6, r4, 0x0F
XOR r7, r5, r6

# Bitwise NOT
NOT r8, r5

# Shift operations
SL r9, r3, 2        # Shift left by 2
SR r10, r4, 3       # Shift right by 3

# Store value to memory
ST 0x1000, r2

# Branching example
loop:
    ADD r1, r1, 1
    BNZ loop        # Branch if not zero
    BRA end

end:
    BRA end         # Infinite loop at end
