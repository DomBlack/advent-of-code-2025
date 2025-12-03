# Advent of Code 2025

Solutions to [Advent of Code 2025](https://adventofcode.com/2025) in Zig 0.15.2.

## Features

- **Automatic day discovery** - Just add `dayXX.zig` and it works, no manual registration needed
- **Per-day testing** - Run all tests or just a single day's tests
- **Flexible CLI** - Run all days, a specific day, or a specific part
- **Modular utilities** - Build out shared utilities as needed
- **Well-commented code** - Learn Zig while solving puzzles

## Setup

1. **Install Zig 0.15.2**
   - Download from [ziglang.org/download](https://ziglang.org/download/)
   - Ensure `zig version` shows 0.15.2

2. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd advent-of-code-2025
   ```

3. **Add your input files**
   - Download your puzzle inputs from [adventofcode.com/2025](https://adventofcode.com/2025)
   - Place them in `inputs/day01.txt`, `inputs/day02.txt`, etc.
   - Input files are gitignored (they're user-specific per AoC rules)

## Project Structure

```
advent-of-code-2025/
├── build.zig              # Build system with auto-discovery
├── build.zig.zon          # Package manifest
├── README.md              # This file
├── .gitignore             # Git ignore rules
├── inputs/
│   ├── .gitkeep           # Keeps directory in git
│   ├── day01.txt          # Your puzzle inputs (not in git)
│   ├── day02.txt
│   └── ...
└── src/
    ├── main.zig           # CLI entry point
    ├── days.zig           # Auto-generated (not in git)
    ├── utils/
    │   └── root.zig       # Shared utilities
    └── days/
        ├── day01.zig      # Day 1 solution
        ├── day02.zig      # Day 2 solution
        └── ...
```

## Usage

### Running Solutions

```bash
# Run a specific day and part
zig build run -- 1 1          # Day 1, Part 1
zig build run -- 1 2          # Day 1, Part 2

# Run both parts of a day
zig build run -- 1            # Day 1, both parts

# Run all implemented days
zig build run                 # No arguments
zig build run -- all          # Explicit
```

### Testing

```bash
# Run all tests (utils + all days)
zig build test

# Run tests for a specific day
zig build test-day1
zig build test-day2
```

### Linting

```bash
zig build lint
```

### Building

```bash
# Build the executable (output: zig-out/bin/aoc2025)
zig build

# Build with optimization
zig build -Doptimize=ReleaseFast

# Run the built executable directly
./zig-out/bin/aoc2025 1 1
```

## Adding a New Day

The beauty of this setup is that adding a new day is **completely automatic**. Here's how:

### Quick Steps

1. **Copy the template**
   ```bash
   cp src/days/day01.zig src/days/day02.zig
   ```

2. **Implement your solution**
   - Edit `src/days/day02.zig`
   - Update the doc comments with the problem description
   - Implement `part1()` and `part2()` functions
   - Add tests with the example data from the problem

3. **Add your input**
   ```bash
   # Download from adventofcode.com and save as:
   inputs/day02.txt
   ```

4. **Build and run**
   ```bash
   zig build test-day2       # Run your tests
   zig build run -- 2        # Run your solution
   ```

**That's it!** The build system automatically:
- Discovers the new `day02.zig` file
- Generates the dispatch code in `src/days.zig`
- Creates the `test-day2` build step
- Includes it in "run all" functionality

No manual registration in `build.zig` or `main.zig` required!

### Day Template Structure

Each day file should follow this structure:

```zig
//! Day X: [Problem Title]
//!
//! Part 1: [Brief description]
//! Part 2: [Brief description]

const std = @import("std");
const utils = @import("utils");

/// Solve Part 1
pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    // Your solution here
}

/// Solve Part 2
pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    // Your solution here
}

// Helper functions (private)
fn parseData(...) { ... }

// Tests
test "dayX part1 example" { ... }
test "dayX part2 example" { ... }
test "dayX helper functions" { ... }
test "dayX edge cases" { ... }
```

## Utilities

The `utils` module provides common functionality. Start with the minimal set and expand as needed.

### Available Now

```zig
const utils = @import("utils");

// Read input file
const input = try utils.readInputFile(allocator, day);
defer allocator.free(input);

// Iterate over lines
var line_iter = utils.lines(input);
while (line_iter.next()) |line| {
    // Process each line
}
```

### Expanding Utilities

As you encounter common patterns across days, add focused utility modules:

**1. Create a new utility file** (e.g., `src/utils/parsing.zig`):
```zig
const std = @import("std");

/// Parse a single integer
pub fn parseInt(comptime T: type, str: []const u8) !T {
    return try std.fmt.parseInt(T, str, 10);
}

/// Parse multiple integers from a string
pub fn parseInts(comptime T: type, allocator: std.mem.Allocator, str: []const u8, delimiter: []const u8) ![]T {
    // Implementation...
}
```

**2. Re-export from `src/utils/root.zig`**:
```zig
pub const parsing = @import("parsing.zig");
```

**3. Use in your days**:
```zig
const value = try utils.parsing.parseInt(i64, "123");
```

### Suggested Utility Organization

- **parsing.zig** - `parseInt`, `parseInts`, split helpers
- **grid.zig** - `Point`, `Direction`, `Grid2D` for 2D problems
- **math.zig** - `gcd`, `lcm`, modulo operations
- **data_structures.zig** - Counters, specialized collections
- **algorithms.zig** - Pathfinding, search algorithms, combinatorics

Create these incrementally as problems require them - no need to build everything upfront!

## Tips for Advent of Code in Zig

### Memory Management

- Always use the allocator passed to your functions
- Remember to free allocated memory
- Tests use `std.testing.allocator` which detects leaks

```zig
pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var list = std.ArrayList(i64).init(allocator);
    defer list.deinit();  // Don't forget this!

    // Use the list...
    return result;
}
```

### Testing

- Add tests with example data from the problem description
- Test helper functions independently
- Test edge cases (empty input, single line, etc.)
- Use descriptive test names

```zig
test "day01 part1 example" {
    const input = "example data from problem";
    const result = try part1(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 42), result);
}
```

### Common Patterns

**Parsing lines of integers:**
```zig
var list = std.ArrayList(i64).init(allocator);
defer list.deinit();

var line_iter = utils.lines(input);
while (line_iter.next()) |line| {
    if (line.len == 0) continue;
    const value = try std.fmt.parseInt(i64, line, 10);
    try list.append(value);
}
```

**String splitting:**
```zig
var parts = std.mem.split(u8, line, " ");
while (parts.next()) |part| {
    // Process each part
}
```

**HashMaps:**
```zig
var map = std.AutoHashMap(i64, i64).init(allocator);
defer map.deinit();

try map.put(key, value);
const value = map.get(key);
```

## Build System Magic

This project uses **automatic day discovery** - the build system scans `src/days/` at compile time and generates the necessary dispatch code.

### What happens when you run `zig build`:

1. **Discovery**: `build.zig` scans `src/days/` for `dayXX.zig` files
2. **Generation**: Creates `src/days.zig` with:
   - Imports for all discovered days
   - Array of implemented day numbers
   - Dispatch function that routes to the right day
3. **Compilation**: Builds the main executable with all modules wired up
4. **Testing**: Creates per-day test steps (`test-day1`, `test-day2`, etc.)

You can see the generated `src/days.zig` file after building (it's in `.gitignore` but created locally).

### Troubleshooting

**Error: "FileNotFound" when running**
- Make sure your input file exists: `inputs/day01.txt`
- Input files must be zero-padded: `day01.txt` not `day1.txt`

**Error: "Day X not yet implemented"**
- The day file wasn't discovered by the build system
- Ensure filename is exactly `dayXX.zig` (e.g., `day02.zig`)
- Run `zig build` to regenerate the dispatch code

**Tests failing with memory leaks**
- You forgot a `defer` statement to free memory
- Common: `defer list.deinit()` or `defer allocator.free(data)`

**Build errors after adding a day**
- Make sure your day exports `part1` and `part2` functions
- Check function signatures match: `fn(std.mem.Allocator, []const u8) !i64`

## License

MIT License - See LICENSE file (if you add one)

## Acknowledgments

- [Advent of Code](https://adventofcode.com/) by Eric Wastl
- [Zig Programming Language](https://ziglang.org/)
