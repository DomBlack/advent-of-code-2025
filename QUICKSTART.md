# Quick Start Guide

## First Time Setup

1. **Install Zig 0.15.2**
   ```bash
   # Download from https://ziglang.org/download/
   # Or use your package manager of choice
   ```

2. **Verify Installation**
   ```bash
   zig version  # Should show 0.15.2
   ```

3. **Test the Build System**
   ```bash
   zig build
   ```

## Daily Workflow

### When a New Day is Released

1. **Add Your Personal Input**
   - Go to https://adventofcode.com/2025/day/N
   - Copy your personal input
   - Paste into `inputs/day-0N.txt`

2. **Add Example Input**
   - Copy the example input from the problem description
   - Paste into `inputs/day-0N-example-1.txt`
   - If there are multiple examples, create `day-0N-example-2.txt`, etc.

3. **Implement Your Solution**
   - Open `src/day-0N.zig`
   - Implement `part1()` function
   - Update the test with the expected result from the example
   - Run tests: `zig build test-day-0N`
   - Once tests pass, run with your input: `zig build run-day-0N`

4. **Implement Part 2**
   - Implement `part2()` function
   - Update the test with the expected result
   - Test and run as before

## Useful Commands

```bash
# Build everything
zig build

# Run a specific day with your input
zig build run-day-01

# Test a specific day with example inputs
zig build test-day-01

# Run all tests
zig build test

# Build in release mode (faster execution)
zig build -Doptimize=ReleaseFast

# Run in release mode
zig build run-day-01 -Doptimize=ReleaseFast
```

## Tips

- Tests use `@embedFile()` to compile the example inputs into the test binary
- The main function reads from a file path passed as a command-line argument
- Shared utilities are in `lib/utils.zig` - add your own helper functions there
- Each day is completely independent - you can work on any day in any order
