<h1 align="center">Aste-RISC</h1>

<div align="center">
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/hylo-dev/Aste-RISC?style=for-the-badge&labelColor=101418&color=9ccbfb">
<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/hylo-dev/Aste-RISC?style=for-the-badge&labelColor=101418&color=b9c8da">
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/hylo-dev/Aste-RISC?style=for-the-badge&labelColor=101418&color=d3bfe6">
<img alt="GitHub issues" src="https://img.shields.io/github/issues/hylo-dev/Aste-RISC?style=for-the-badge&labelColor=101418&color=ffb4a2">

</div>

> [!WARNING]
> This project is in a very early, embryonic stage. Many features are planned or partially implemented. All help and contributions are welcome!

---

A modern, native macOS IDE for RISC-V Assembly, built with SwiftUI and designed for education. Aste-RISC provides a powerful step-by-step debugger that visualizes register state and stack frames, all wrapped in the new macOS Tahoe (26.0) design language.

This project's core emulation logic is derived from a [TUI-based RISC-V emulator](https://github.com/hylo-dev/RISC-V-Emulator) written in C with ncurses.

## Overview

Aste-RISC is designed to be an educational tool for students at the University of Turin (and beyond) studying computer architecture.

It aims to:
* Provide a seamless, Mac-native code editing experience.
* Offer a powerful visual debugger to see instructions execute one by one.
* Visualize complex concepts like the stack, stack frames, and register file.
* Focus on the RV32I instruction set for foundational learning.

## Features

### Implemented
- [x] **Native Code Editor:** A simple, built-in text editor for writing assembly.
- [x] **Step-by-Step Execution:** Run your code instruction by instruction.
- [x] **Register Visualization:** See the state of all 32 general-purpose registers update in real-time.
- [x] **Stack Visualization:** A visual representation of the stack, including stack frames.
- [x] **SwiftUI Native UI:** A modern interface built using the latest macOS Tahoe (26.0) design principles.
- [x] **C-Based Emulation Core:** The performance-critical emulation logic is handled in C.
- [x] **Some Project Management features:** Project templates and drag-and-drop file support.

### Roadmap
- [ ] **Multi-Editor Support:** Integrate support for using Helix, Vim, and Neovim as the backend editor.
- [ ] **LSP Integration:** Implement the [asm-lsp (Rust)](https://github.com/bergercookie/asm-lsp) for features like auto-completion, diagnostics, and go-to-definition.
- [ ] **Keyboard Shortcuts:** Full keyboard-driven navigation and operation.
- [ ] **Instruction Set:** Full support for the RV32I base ISA.

## Getting Started

### Prerequisites

* macOS 15.0 (Tahoe) or later
* Xcode 16 or later
* RISC-V GCC Toolchain (e.g., `riscv-software-src/riscv/riscv-gnu-toolchain` via Homebrew)

### Installation

Later a .dmg file will be available (and it will contain the used binaries such as the compiler and the lsp).
For now you can download and run the project from xcode.

#### 1. Clone the repository
```bash
# Clone the repository
git clone https://github.com/hylo-dev/Aste-RISC.git

# Navigate to the project directory
cd Aste-RISC
```

#### 2. Build the project

The simplest method is to open the `Aste-RISC.xcodeproj` (or `.xcworkspace`) in Xcode and run the project.

## Usage

1.  Open the `Aste-RISC` application.
2.  Create or open a Aste-RISC project.
3.  Write your RISC-V (RV32I) assembly code.
4.  Use the build/run button (TBD) to compile.
    * **Behind the scenes:** Aste-RISC calls the `riscv64-unknown-elf-gcc` toolchain to assemble your code into an ELF binary.
5.  The IDE will load the binary, and you can use the "Step" button to walk through the instructions, observing the register and stack changes.

## Project Status

This project is currently in early development. It began as an educational experiment for a university course at the University of Turin.

## Contributing

Contributions are highly welcome! This is a learning project, so feel free to open issues, suggest features, or submit pull requests.

## Stats

<a href="https://www.star-history.com/hylo-dev/Aste-RISC&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=hylo-dev/Aste-RISC&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=hylo-dev/Aste-RISC&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=hylo-dev/Aste-RISC&type=Date" />
 </picture>
</a>
