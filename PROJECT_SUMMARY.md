# Project Summary: Advent of Code 2025 Zig Setup

This repository has been set up with a complete Zig 0.15.2 project structure for Advent of Code 2025.

## What Was Created

### Build System
- **build.zig** - Complete build configuration that:
  - Creates 12 separate binaries (day-01 through day-12)
  - Sets up a shared `utils` module for common code
  - Provides `zig build run-day-XX` commands for running with your input
  - Provides `zig build test-day-XX` commands for testing with example inputs
  - Provides `zig build test` to run all tests

- **build.zig.zon** - Package manifest for Zig 0.15.2

### Source Files
- **src/day-01.zig through src/day-12.zig** - Template files for each day containing:
  - `part1()` and `part2()` functions to implement
  - `main()` function that reads from a file path argument
  - Test cases that use `@embedFile()` to load example inputs
  - All ready to be filled in with your solutions

### Shared Libraries
- **lib/utils.zig** - Common utility functions:
  - `readInputFile()` - Read an entire file into a string
  - `splitLines()` - Split input by newlines
  - `parseInt()` - Parse integers from strings
  - Add your own helper functions here

### Input Files
- **inputs/day-XX.txt** - Placeholder for your personal puzzle inputs (12 files)
- **inputs/day-XX-example-N.txt** - Placeholders for example inputs (12 files)
- Support for multiple example inputs per day

### Documentation
- **README.md** - Comprehensive guide with:
  - Project structure overview
  - Setup instructions
  - Usage examples for all commands
  - Example day structure

- **QUICKSTART.md** - Quick reference guide for daily workflow

- **EXAMPLES.md** - Guide for handling multiple example inputs

### Tools
- **validate.sh** - Script to validate project structure
- **.gitignore** - Already configured for Zig build artifacts

## Key Features

### Running with Your Input
```bash
zig build run-day-01
```
This runs the day-01 binary with `inputs/day-01.txt` as input.

### Testing with Examples
```bash
zig build test-day-01
```
This runs tests that use `@embedFile()` to compile example inputs into the test binary.

### Independence
- Each day is completely independent
- Shared utilities available to all days via the `utils` module
- Can work on any day in any order

## Next Steps

1. Install Zig 0.15.2
2. Run `./validate.sh` to verify everything is set up
3. When day 1 is released:
   - Add your input to `inputs/day-01.txt`
   - Add the example to `inputs/day-01-example-1.txt`
   - Implement solutions in `src/day-01.zig`
   - Test with `zig build test-day-01`
   - Run with `zig build run-day-01`

## Pattern Established

The project demonstrates the pattern you requested:
- ✅ Each day is its own binary (day-01, day-02, etc.)
- ✅ Shared packages/libraries for common code
- ✅ Running a day uses YOUR input
- ✅ Testing a day uses EXAMPLE inputs
- ✅ 12 days total for 2025's Advent of Code
- ✅ Empty day-01 template ready to fill in

Happy coding! 🎄
