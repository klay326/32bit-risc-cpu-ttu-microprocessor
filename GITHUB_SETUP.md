# GitHub Repository Setup Guide

## What to Include vs Exclude

### ✅ FILES TO INCLUDE ON GITHUB

These are the essential files for the CPU project:

#### Source Code
```
src/
  ├── cpu.v                    # Top-level CPU module
  ├── alu.v                    # ALU implementation  
  ├── registerfile.v           # 32-register bank
  ├── instructiondecoder.v     # Control unit
  ├── programcounter.v         # PC with branch logic
  ├── alusrcmux.v             # ALU source multiplexer
  ├── aluormemmux.v           # Result multiplexer
  ├── rom.v                    # Instruction memory wrapper
  └── ram.v                    # Data memory wrapper
```

#### Simulation & Testing
```
test/
  └── cpu_tb.v                 # Testbench for simulation
```

#### Memory Initialization
```
mem_init/
  ├── test.coe                 # Example program 1
  ├── shortprogram.coe         # Example program 2
  ├── instructiontest.coe      # Example program 3
  └── klaycputest.coe          # Example program 4
```

#### Documentation
```
README.md                       # Main project documentation
docs/
  └── MODULE_GUIDE.md           # Detailed module reference
```

#### Configuration
```
.gitignore                      # Tells Git what to ignore
LICENSE                         # (Optional) License file
```

---

### ❌ FILES TO EXCLUDE (Vivado-Specific)

**NEVER commit these to GitHub** - they're Vivado project/build artifacts:

#### Project Files
```
*.xpr                           # Vivado project file (large, user-specific)
*.xise                          # Project settings
*.xps                           # Project settings
```

#### Generated IP Cores
```
KlayAdams-Project6.gen/         # Generated IP files
.ip_user_files/                 # IP configuration
```

#### Build Output
```
KlayAdams-Project6.runs/        # Synthesis/implementation artifacts
KlayAdams-Project6.hw/          # Hardware design files
KlayAdams-Project6.sim/         # Simulation artifacts
```

#### Vivado Cache
```
.cache/                         # Vivado internal cache
.Xil/                          # Xilinx internal files
webtalk_*.jou                  # Vivado web telemetry
webtalk_*.log
vivado*.jou                    # Vivado journal files
vivado*.log                    # Vivado logs
vivado_pid*.str
htr.txt
```

#### Build Artifacts
```
*.bit                           # Bitstream file
*.mcs                           # Memory configuration
*.dcp                           # Checkpoint files
*.pb                            # Protocol buffer files
*.tcl                           # Vivado TCL scripts
*.vdi                           # Design information
*.vds                           # Design summary
```

#### Simulation Output
```
*.wdb                           # Waveform database
*.vcd                           # Value change dump
*.ghw                           # GHDL waveform
```

#### Report Files
```
*.rpt                           # Report files
*.rpx                           # Report XML
```

#### Build Scripts
```
runme.bat                       # Platform-specific build scripts
runme.sh
ISEWrap.js
ISEWrap.sh
rundef.js
gen_run.xml
project.wdf
```

---

## How to Create GitHub Repository

### Step 1: Verify Your GitHub-Ready Folder

The folder `/Users/klay/Documents/KlayAdams-Project6/github_repo/` now contains:

```
github_repo/
├── src/                        # ✅ All Verilog modules
├── test/                       # ✅ Testbench
├── mem_init/                   # ✅ Memory initialization files
├── docs/                       # ✅ Documentation
├── README.md                   # ✅ Main documentation
└── .gitignore                  # ✅ Exclusion rules
```

### Step 2: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `fpga-cpu-32bit` (or your choice)
3. Description: "32-bit CPU FPGA implementation in Verilog for Xilinx FPGAs"
4. Make it **Public** (so others can see your work)
5. Check "Add a README file" (optional - you already have one)
6. Skip adding `.gitignore` (you already have one)
7. Click "Create repository"

### Step 3: Push to GitHub Locally

From your terminal:

```bash
# Navigate to the GitHub-ready folder
cd /Users/klay/Documents/KlayAdams-Project6/github_repo

# Initialize git repository (if not already done)
git init

# Add all files (respects .gitignore automatically)
git add .

# Create initial commit
git commit -m "Initial commit: CPU design with ALU, registers, and control unit"

# Add remote (replace USERNAME and REPO with your GitHub details)
git remote add origin https://github.com/USERNAME/fpga-cpu-32bit.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 4: Verify on GitHub

Visit `https://github.com/USERNAME/fpga-cpu-32bit` to confirm everything uploaded correctly.

---

## Files Explained

### Verilog Modules

| File | Lines | Purpose |
|------|-------|---------|
| `cpu.v` | 20 | Top-level instantiation of all modules |
| `alu.v` | 50 | Arithmetic/logic operations |
| `registerfile.v` | 27 | 32-register storage bank |
| `instructiondecoder.v` | 254 | Instruction parsing and control signals |
| `programcounter.v` | 60 | Instruction sequencing & branching |
| `alusrcmux.v` | 12 | Selects ALU input source |
| `aluormemmux.v` | 12 | Selects register write source |
| `rom.v` | 18 | Instruction memory (Xilinx IP wrapper) |
| `ram.v` | 22 | Data memory (Xilinx IP wrapper) |
| **Total** | ~455 | **Core implementation** |

### Memory Files

| File | Purpose |
|------|---------|
| `test.coe` | Basic test program instructions (hex format) |
| `shortprogram.coe` | Longer test program with loops/branches |
| `instructiontest.coe` | Instruction decoder test program |
| `klaycputest.coe` | Full CPU functionality test |

**COE Format:** Hexadecimal instruction definitions loadable into Xilinx Block RAM

### Documentation

| File | Purpose |
|------|---------|
| `README.md` | Project overview, ISA, architecture, usage |
| `docs/MODULE_GUIDE.md` | Detailed module-by-module explanation |
| `.gitignore` | Git exclusion rules (keeps repo clean) |

---

## Key Facts About Your CPU

### What This CPU Does
- ✅ Executes 13 different instructions
- ✅ Performs 32-bit arithmetic and logic
- ✅ Has conditional branching (BZ, BNZ)
- ✅ Supports immediate and register addressing
- ✅ Reads/writes to instruction and data memory

### What This CPU Doesn't Have (Yet)
- ❌ Pipelined execution (sequential only)
- ❌ Interrupts/exceptions
- ❌ Stack operations
- ❌ Subroutine calls (CALL/RET)
- ❌ Virtual memory/caching
- ❌ Floating-point operations

---

## Sharing Your Work

### Repository Description for GitHub

Copy-paste this into your GitHub repo description:

```
32-bit RISC-like CPU implementation in Verilog for Xilinx FPGAs. 
Features ALU, 32 registers, instruction/data memory, and conditional branching.
Fully documented with testbench.

Includes:
- 9 Verilog modules (2000+ lines of HDL)
- Instruction set with 13 operations
- Complete testbench
- Memory initialization examples
- Detailed architecture documentation
```

### Topics to Add
- `fpga`
- `verilog`
- `cpu`
- `alu`
- `xilinx`
- `vivado`
- `fpga-design`
- `education`

---

## About Your Vivado Project Files

### Vivado Project Structure

Your original project has:

```
KlayAdams-Project6.xpr          # Main Vivado project file (~50KB)
KlayAdams-Project6.gen/          # Generated IP cores
KlayAdams-Project6.runs/         # Synthesis/implementation (~500MB+ total)
KlayAdams-Project6.ip_user_files/# IP configuration
```

**Why Exclude Them?**
1. **Size**: Vivado projects + generated files = hundreds of MB
2. **Machine-specific**: `.xpr` files are user-dependent
3. **Reproducible**: Others can generate from `.v` files
4. **Repository bloat**: Git will slow down with massive files

**If You Need to Share the Project Later:**
- Share as a `.zip` of the entire Vivado folder
- OR provide Vivado TCL script to recreate it
- NOT via GitHub (use Google Drive, OneDrive, etc.)

---

## Tips for Continued Development

### Before Each Commit
```bash
# Check what will be committed
git status

# Review changes
git diff

# Verify .gitignore is working (no .xpr, .runs, etc.)
git ls-files | grep -E '\.(xpr|pb|dcp)$'  # Should be empty
```

### Adding New Features
1. Update `.v` files in `src/`
2. Update testbench in `test/`
3. Commit with descriptive message: `git commit -m "Add stack operations"`
4. Push to GitHub: `git push`

### Documentation
- Update `README.md` when changing instruction set
- Update `docs/MODULE_GUIDE.md` when modifying modules
- Keep comments in Verilog code

---

## Final Checklist

- [ ] Verify all `.v` files are in `src/`
- [ ] Verify testbench is in `test/`
- [ ] Verify `.coe` files are in `mem_init/`
- [ ] Verify `README.md` and `docs/MODULE_GUIDE.md` exist
- [ ] Verify `.gitignore` exists with Vivado patterns
- [ ] Test git: `cd github_repo && git status`
- [ ] Create GitHub repository
- [ ] Push all files: `git push -u origin main`
- [ ] Verify on GitHub website

---

You're now ready to share your CPU design on GitHub! 🎉
