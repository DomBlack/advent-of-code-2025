# Adding Multiple Example Inputs

Some Advent of Code problems have multiple example inputs. Here's how to handle them:

## Structure

```
inputs/
├── day-01.txt              # Your personal input
├── day-01-example-1.txt    # First example
├── day-01-example-2.txt    # Second example (optional)
└── day-01-example-3.txt    # Third example (optional)
```

## In Your Code

Add additional test cases in `src/day-01.zig`:

```zig
test "day-01 example 1 part 1" {
    const input = @embedFile("../inputs/day-01-example-1.txt");
    const result = try part1(input);
    try std.testing.expectEqual(@as(i64, 42), result);
}

test "day-01 example 2 part 1" {
    const input = @embedFile("../inputs/day-01-example-2.txt");
    const result = try part1(input);
    try std.testing.expectEqual(@as(i64, 100), result);
}

test "day-01 example 1 part 2" {
    const input = @embedFile("../inputs/day-01-example-1.txt");
    const result = try part2(input);
    try std.testing.expectEqual(@as(i64, 84), result);
}
```

## Running Tests

All tests for a day will run with:

```bash
zig build test-day-01
```

Or run all tests:

```bash
zig build test
```
