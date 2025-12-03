const std = @import("std");
const utils = @import("utils");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var number_turns_to_zero: i64 = 0;
    var current_position: i64 = 50;

    const instructions = try parseData(allocator, input);
    defer allocator.free(instructions);

    for (instructions) |instruction| {
        current_position = instruction.turn(current_position);

        if (current_position == 0) {
            number_turns_to_zero += 1;
        }
    }

    return number_turns_to_zero;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var number_turns_to_zero: i64 = 0;
    var current_position: i64 = 50;

    const instructions = try parseData(allocator, input);
    defer allocator.free(instructions);

    for (instructions) |instruction| {
        switch (instruction.direction) {
            .left => {
                const reversed = @mod(100 - current_position, 100);
                number_turns_to_zero += @divTrunc(reversed + instruction.steps, 100);
            },
            .right => {
                number_turns_to_zero += @divTrunc(current_position + instruction.steps, 100);
            },
        }

        current_position = instruction.turn(current_position);
    }

    return number_turns_to_zero;
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const Direction = enum {
    left,
    right,

    pub fn fromChar(c: u8) !Direction {
        switch (c) {
            'L' => return .left,
            'R' => return .right,
            else => return error.InvalidDirection,
        }
    }

    pub fn turn(self: Direction, current: i64, amount: i64) i64 {
        switch (self) {
            .left => return @mod(current - amount, 100),
            .right => return @mod(current + amount, 100),
        }
    }
};

const Instruction = struct {
    direction: Direction,
    steps: i64,

    pub fn fromString(s: []const u8) !Instruction {
        if (s.len < 2) {
            return error.InvalidInstructionFormat;
        }
        const dir = try Direction.fromChar(s[0]);
        const steps = try std.fmt.parseInt(i64, s[1..], 10);
        return Instruction{
            .direction = dir,
            .steps = steps,
        };
    }

    pub fn turn(self: Instruction, current: i64) i64 {
        return self.direction.turn(current, self.steps);
    }
};

fn parseData(allocator: std.mem.Allocator, input: []const u8) ![]Instruction {
    var list: std.ArrayList(Instruction) = .empty;
    errdefer list.deinit(allocator);

    var line_iter = utils.parsing.lines(input);
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;

        const value = try Instruction.fromString(line);
        try list.append(allocator, value);
    }

    return try list.toOwnedSlice(allocator);
}

// ============================================================================
// Tests
// ============================================================================

test "day01 part1 example" {
    const input = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82";

    const result = try part1(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "day01 part2 example" {
    const input = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82";

    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 6), result);
}

test "day01 part2 edge case 1" {
    const input = "R1000";
    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 10), result);
}

test "day01 part2 edge - right 1.5 turns landing on zero" {
    const input = "R150";
    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 2), result);
}

test "day01 part2 edge - left 1.5 turns landing on zero" {
    const input = "L150";
    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 2), result);
}
