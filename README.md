# MyOS

A simple operating system written in C++.

## Prerequisites

- NASM (Netwide Assembler)
- GCC Cross-Compiler for i686-elf
- QEMU for system emulation
- Make (or MinGW for Windows)

## Project Structure

```
.
├── src/
│   ├── boot/       # Bootloader code
│   ├── kernel/     # Kernel source files
│   └── drivers/    # Hardware drivers
├── include/        # Header files
└── build/         # Build output directory
```

## Setting Up the Development Environment

### Windows Setup
1. Install NASM from: https://www.nasm.us/
2. Install QEMU from: https://www.qemu.org/download/
3. Install MinGW for Make utilities
4. Set up the cross-compiler (detailed instructions below)

### Cross-Compiler Setup
Follow these steps to set up your cross-compiler:
1. Download and build binutils
2. Download and build GCC
3. Add the cross-compiler to your PATH

## Building

1. Make sure you have all prerequisites installed
2. Run `make` to build the OS
3. Run `make run` to start the OS in QEMU

## Features (Planned)

- [ ] Bootloader
- [ ] Basic kernel initialization
- [ ] Memory management
- [ ] Interrupt handling
- [ ] Basic device drivers
- [ ] Simple file system
- [ ] Basic shell

## Development Status

This OS is currently in early development stages.

## License

This project is open source and available under the MIT License. 