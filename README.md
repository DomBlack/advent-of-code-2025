# Advent of Code 2025

My solutions for [Advent of Code 2025](https://adventofcode.com/2025) written in Zig 0.15.2.

## Project Structure

This project has a separate binary for each day (day-01 through day-12), with shared utility libraries for common functionality.

```
.
├── build.zig              # Build configuration
├── build.zig.zon          # Package manifest
├── src/                   # Source files for each day
│   ├── day-01.zig
│   ├── day-02.zig
│   └── ...
├── lib/                   # Shared libraries
│   └── utils.zig          # Common utility functions
└── inputs/                # Input files
    ├── day-01.txt         # Your personal input
    ├── day-01-example-1.txt  # Example input for testing
    └── ...
```

## Requirements

- Zig 0.15.2 (or compatible version)

## Setup

1. Install Zig 0.15.2 from [ziglang.org/download](https://ziglang.org/download/)
2. Clone this repository
3. Add your personal puzzle inputs to `inputs/day-XX.txt`
4. Add example inputs from the problem descriptions to `inputs/day-XX-example-N.txt`

## Usage

### Running a Day with Your Input

To run a specific day with your personal input:

```bash
zig build run-day-01
```

This will run day 01 using `inputs/day-01.txt` as the input file.

### Testing a Day with Example Inputs

To run tests for a specific day using the example inputs:

```bash
zig build test-day-01
```

This will run the tests in `src/day-01.zig` which use the example input files via `@embedFile`.

### Running All Tests

To run all tests for all days:

```bash
zig build test
```

### Building All Binaries

To build all day binaries:

```bash
zig build
```

The compiled binaries will be in `zig-out/bin/`.

## Adding a New Day

Each day follows the same pattern:

1. The source file in `src/day-XX.zig` contains:
   - `part1()` and `part2()` functions that solve each part
   - A `main()` function that reads from a file passed as a command-line argument
   - Test cases that use `@embedFile` to load example inputs

2. Input files:
   - `inputs/day-XX.txt` - Your personal puzzle input
   - `inputs/day-XX-example-N.txt` - Example inputs from the problem (can have multiple)

3. The build system automatically:
   - Creates a binary for the day
   - Sets up a run command that passes your input file
   - Sets up tests that use the example inputs

## Shared Utilities

Common functions are in `lib/utils.zig` and can be imported with:

```zig
const utils = @import("utils");
```

Current utilities include:
- `readInputFile()` - Read an entire file into a string
- `splitLines()` - Split input by newlines
- `parseInt()` - Parse integers from strings

## Example Day Structure

```zig
const std = @import("std");
const utils = @import("utils");

fn part1(input: []const u8) !i64 {
    // Solve part 1
    return 0;
}

fn part2(input: []const u8) !i64 {
    // Solve part 2
    return 0;
}

pub fn main() !void {
    // Reads input file from command line and runs both parts
}

test "day-01 example 1 part 1" {
    const input = @embedFile("../inputs/day-01-example-1.txt");
    const result = try part1(input);
    try std.testing.expectEqual(@as(i64, 42), result);
}
```
