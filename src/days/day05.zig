const std = @import("std");
const utils = @import("utils");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    const  rtn = try parseInput(allocator, input);
    defer allocator.free(rtn.ranges);
    defer allocator.free(rtn.ingredients);

    var range_idx: usize = 0;
    var ing_idx: usize = 0;
    var num_fresh_ingredients: i64 = 0;

    while (range_idx < rtn.ranges.len and ing_idx < rtn.ingredients.len) {
        const current_range = rtn.ranges[range_idx];
        const current_ingredient = rtn.ingredients[ing_idx];

        if (current_range.contains(current_ingredient)) {
            // Found a fresh ingredient
            num_fresh_ingredients += 1;

            ing_idx += 1;
        } else if (current_ingredient > current_range.end) {
            // Move to the next range
            range_idx += 1;
        } else {
            ing_idx += 1;
        }
    }

    return num_fresh_ingredients;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    const ranges = blk:  {
        const  rtn = try parseInput(allocator, input);
        defer allocator.free(rtn.ingredients);
        break :blk rtn.ranges;
    };
    defer allocator.free(ranges);

    var current_range = ranges[0];
    var i: usize = 1;
    var num_fresh_ingredients: i64 = 0;

    while (i < ranges.len) {
        const next_range = ranges[i];
        if (current_range.overlaps(next_range)) {
            current_range = current_range.merge(next_range);
        } else {
            // No overlap, calculate gap
            num_fresh_ingredients += current_range.length();
            current_range = next_range;
        }
        i += 1;
    }

    num_fresh_ingredients += current_range.length();

    return num_fresh_ingredients;
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const Range = struct {
    start: i64,
    end: i64,

    pub fn contains(self: Range, value: i64) bool {
        return value >= self.start and value <= self.end;
    }

    pub fn overlaps(self: Range, other: Range) bool {
        return self.start <= other.end and other.start <= self.end;
    }

    pub fn lessThan(_: void, a: Range, b: Range) bool {
        return a.start < b.start or (a.start == b.start and a.end < b.end);
    }

    pub fn merge(self: Range, other: Range) Range {
        return Range{
            .start = @min(self.start, other.start),
            .end = @max(self.end, other.end),
        };
    }

    pub fn length(self: Range) i64 {
        return self.end - self.start + 1;
    }
};

// parseInput returns the sorted ranges and sorted ingredient values from the input
fn parseInput(allocator: std.mem.Allocator, input: []const u8) !struct{ ranges: []Range, ingredients: []i64 } {
    var ranges: std.ArrayList(Range) = .empty;
    errdefer ranges.deinit(allocator);

    // First parse all the ranges, which are in the format "start-end" per line
    // and are separated by newlines. The ranges end when an empty line is encountered.
    var line_iter = std.mem.splitScalar(u8,input, '\n');
    while (line_iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) break;

        const dash_index = std.mem.indexOf(u8, trimmed, "-");
        if (dash_index == null) {
            return error.InvalidInput;
        }

        const start_str = trimmed[0..dash_index.?];
        const end_str = trimmed[dash_index.? + 1 ..];

        const start = std.fmt.parseInt(i64, start_str, 10) catch return error.InvalidInput;
        const end = std.fmt.parseInt(i64, end_str, 10) catch return error.InvalidInput;

        try ranges.append(allocator, Range{
            .start = start,
            .end = end,
        });
    }
    std.mem.sort(Range, ranges.items, {}, Range.lessThan);

    var ingredients: std.ArrayList(i64) = .empty;
    errdefer ingredients.deinit(allocator);

    // Now parse the ingredient values, which are just integers per line
    while (line_iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;
        const value = std.fmt.parseInt(i64, trimmed, 10) catch return error.InvalidInput;
        try ingredients.append(allocator, value);
    }
    std.mem.sort(i64, ingredients.items, {}, std.sort.asc(i64));

    return .{
        .ranges = try ranges.toOwnedSlice(allocator),
        .ingredients =  try ingredients.toOwnedSlice(allocator),
    };
}

// ============================================================================
// Tests
// ============================================================================

const example_input =
    \\ 3-5
    \\ 10-14
    \\ 16-20
    \\ 12-18
    \\
    \\ 1
    \\ 5
    \\ 8
    \\ 11
    \\ 17
    \\ 32
;

test "day05 part1 example" {
    const result = try part1(std.testing.allocator, example_input);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "day05 part2 example" {
    const result = try part2(std.testing.allocator, example_input);
    try std.testing.expectEqual(@as(i64, 14), result);
}
