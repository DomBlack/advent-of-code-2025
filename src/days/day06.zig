const std = @import("std");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var lines = std.mem.splitBackwardsScalar(u8, input, '\n');

    // First read the operators from the last line
    const operators = blk: {
        const next_line = lines.next() orelse return error.MissingOperatorLine;
        break :blk try parseOperators(allocator, next_line);
    };
    defer allocator.free(operators);
    var totals = try allocator.alloc(i64, operators.len);
    defer allocator.free(totals);
    for (totals) |*total| {
        total.* = 0;
    }

    // Now read each line of numbers and compute the total for each operator
    while (lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, ' ');
        var idx: usize = 0;

        while (numbers.next()) |num_str| {
            if (num_str.len == 0) continue;

            const num = try std.fmt.parseInt(i64, num_str, 10);

            switch (operators[idx]) {
                Operators.add => totals[idx] += num,
                Operators.multiply => {
                    if (totals[idx] == 0) {
                        // First time multiplying, initialize to the number
                        totals[idx] = num;
                    } else {
                        totals[idx] *= num;
                    }
                },
            }

            idx += 1;
        }
    }

    // Finally sum the totals and return
    var total_sum: i64 = 0;
    for (totals) |total| {
        total_sum += total;
    }
    return total_sum;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var lines = std.mem.splitBackwardsScalar(u8, input, '\n');

    // First read the operators from the last line
    const operators = blk: {
        const next_line = lines.next() orelse return error.MissingOperatorLine;
        break :blk try parseOperators(allocator, next_line);
    };
    defer allocator.free(operators);
    var totals = try allocator.alloc(i64, operators.len);
    defer allocator.free(totals);
    for (totals) |*total| {
        total.* = 0;
    }

    // Now read each line of numbers into a list of lists
    var digits: std.ArrayList([]const u8) = .empty;
    defer digits.deinit(allocator);

    var max_digits: usize = 0;
    while (lines.next()) |line| {
        if (line.len > max_digits) {
            max_digits = line.len;
        }
        try digits.insert(allocator, 0, line);
    }

    // Now process each digit position
    var op_idx: usize = 0;
    for (0..max_digits) |digit_pos| {
        // parse the digit top-down in the column
        var digit: i64 = 0;
        var found_anything = false;
        for (digits.items) |num_str| {
            if (digit_pos >= num_str.len) continue;

            const char = num_str[digit_pos];
            if (char < '0' or char > '9') continue;

            digit *= 10;
            digit += @as(i64, char - '0');
            found_anything = true;
        }

        if (!found_anything) {
            op_idx += 1;
            continue;
        }

        // Apply the operator and update it's totals
        switch (operators[op_idx]) {
            Operators.add => totals[op_idx] += digit,
            Operators.multiply => {
                if (totals[op_idx] == 0) {
                    // First time multiplying, initialize to the number
                    totals[op_idx] = digit;
                } else {
                    totals[op_idx] *= digit;
                }
            },
        }
    }

    // Finally sum the totals and return
    var total_sum: i64 = 0;
    for (totals) |total| {
        total_sum += total;
    }
    return total_sum;
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const Operators = enum {
    add,
    multiply,
};

fn parseOperators(allocator: std.mem.Allocator, line: []const u8) ![]Operators {
    var parts = std.mem.splitScalar(u8, line, ' ');
    var list: std.ArrayList(Operators) = .empty;
    errdefer list.deinit(allocator);

    while (parts.next()) |part| {
        if (part.len == 0) continue;

        const operator = switch (part[0]) {
            '+' => Operators.add,
            '*' => Operators.multiply,
            else => return error.InvalidOperator,
        };
        try list.append(allocator, operator);
    }

    return try list.toOwnedSlice(allocator);
}

// ============================================================================
// Tests
// ============================================================================

const example_input =
    \\123 328  51 64
    \\ 45 64  387 23
    \\  6 98  215 314
    \\*   +   *   +
;

test "day06 part1 example" {
    const result = try part1(std.testing.allocator, example_input);
    try std.testing.expectEqual(@as(i64, 4277556), result);
}

test "day06 part2 example" {
    const result = try part2(std.testing.allocator, example_input);
    try std.testing.expectEqual(@as(i64, 3263827), result);
}
