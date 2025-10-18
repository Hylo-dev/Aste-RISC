# RISKit

Lightweight, focused editor for RISC-V assembly, written in Swift.

RISKit is an editor project that aims to provide a clean, simple environment to write, view and test RISC-V assembly code on macOS.

The editor focuses on a readable user interface, assembly-aware core functionality, and an accessible code workspace implemented in Swift with the RISC-V architecture emulator written in C.

## Features

- Syntax-aware editing for RISC-V assembly (mnemonics, registers, comments).
- Line numbers and basic indentation helpers.
- Simple assembler integration.
- Fast, native UI built in Swift.

## Tech stack

- App language: Swift
- Emulator language: C
- Target: Xcode (macOS)

## Requirements

- macOS with Xcode (use macOS 26 version)
- Installed RISC-V toolchain if you want to assemble code

## Build & run

1. Clone the repo:
   ```bash
   git clone https://github.com/eliorodr2104/RISKit.git
   
   cd RISKit
   ```
2. Open the Xcode workspace/project:
   ```bash
   open RISKit.xcodeproj
   ```
3. Select the appropriate target (macOS) and run from Xcode.
   
## Usage

- Create a new project, which will create the folder and add `.s` file inside it. Alternatively, open a project with an existing RISC-V assembly file.
- The editor highlights assembly constructs and helps with indentation.

## Contributing

Contributions are welcome. If you want to add features or fix bugs:
- Fork the repo.
- Create a descriptive branch (feature/your-feature or fix/bug).
- Open a PR with a clear description of changes and motivation.

Please include small, focused commits and tests where applicable.

## Roadmap (ideas)

- Instruction hints and inline documentation.
- Improved formatting and macros support.
- Multi-file project support and examples.

## Acknowledgements

Built with Swift. The emulator for the RISC-V architecture is written in C to ensure performance where necessary.
