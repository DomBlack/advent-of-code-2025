const std = @import("std");
const utils = @import("utils");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    _ = allocator;
    var ranges = parseRanges(input);

    var sum: i64 = 0;

    while (try ranges.next()) |range| {
        const length = utils.maths.numDigits(range.start);
        if (@mod(length, 2) != 0) {
            // skip ranges with odd number of digits as they can't have the mirror property
            // i.e. can't be ABCABC as the middle digit would be missing
            continue;
        }

        // Find the half value range (i.e. for 1234->5678, consider 12->56)
        const half_length = @divFloor(length, 2);
        const start_half_value = @divTrunc(range.start, try std.math.powi(i64, 10, @intCast(half_length)));
        const end_half_value = @divTrunc(range.end, try std.math.powi(i64, 10, @intCast(half_length)));
        const min_half_value = @max(try std.math.powi(i64, 10, @intCast(half_length - 1)), start_half_value);
        const max_half_value = @min(try std.math.powi(i64, 10, @intCast(half_length)) - 1, end_half_value);

        // For each option if the half range, generate the full value and test it
        // i.e. 12 becomes 1212, 45 becomes 4545, etc.
        var current_half_value = min_half_value;
        while (current_half_value <= max_half_value) : (current_half_value += 1) {
            const to_test = current_half_value * try std.math.powi(i64, 10, @intCast(half_length)) + current_half_value;
            if ((to_test >= range.start) and (to_test <= range.end)) {
                sum += to_test;
            }
        }
    }

    return sum;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var ranges = parseRanges(input);

    var sum: i64 = 0;
    var seen = std.AutoHashMap(i64, void).init(allocator);
    defer seen.deinit();

    while (try ranges.next()) |range| {
        const length = utils.maths.numDigits(range.start);

        // Find the half value range (i.e. for 1234->5678, consider 1->5, 12->56)
        const half_length = @divFloor(length, 2);
        var current_length: i64 = 1;
        while (current_length <= half_length) : (current_length += 1) {
            // const start_half_value = @divTrunc(range.start, try std.math.powi(i64, 10, @intCast(current_length)));
            const end_half_value = @divTrunc(range.end, try std.math.powi(i64, 10, @intCast(current_length)));
            // const min_half_value = @max(try std.math.powi(i64, 10, @intCast(current_length - 1)), start_half_value);
            const max_half_value = @min(try std.math.powi(i64, 10, @intCast(current_length)) - 1, end_half_value);

            // For each option in the pattern range, generate the full value by repeating
            // i.e. 12 with length=4 becomes 1212, 12 with length=6 becomes 121212
            var current_half_value: i64 = 1;
            while (current_half_value <= max_half_value) : (current_half_value += 1) {
                const pattern_length = utils.maths.numDigits(current_half_value);
                const num_repeats = @divFloor(length, pattern_length);
                const multiplier = try std.math.powi(i64, 10, @intCast(pattern_length));

                var to_test: i64 = 0;
                var repeat_count: i64 = 0;
                while (repeat_count < num_repeats) : (repeat_count += 1) {
                    to_test = to_test * multiplier + current_half_value;
                }

                if ((to_test >= range.start) and (to_test <= range.end)) {
                    // Use getOrPut to check if we've seen this number before
                    const gop = try seen.getOrPut(to_test);
                    if (!gop.found_existing) {
                        // First time seeing this number
                        sum += to_test;
                    }
                }
            }
        }
    }

    return sum;
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const Range = struct {
    start: i64,
    end: i64,

    pub fn fromString(s: []const u8) !Range {
        var it = std.mem.splitScalar(u8, s, '-');

        const start_str = it.next() orelse return error.InvalidRangeFormat;
        const end_str = it.next() orelse return error.InvalidRangeFormat;

        const start = try std.fmt.parseInt(i64, start_str, 10);
        const end = try std.fmt.parseInt(i64, end_str, 10);

        return Range{
            .start = start,
            .end = end,
        };
    }

    pub fn size(self: Range) i64 {
        return self.end - self.start + 1;
    }
};

fn parseRanges(input: []const u8) RangeIterator {
    return .{ .inner = utils.parsing.commas(input) };
}

const RangeIterator = struct {
    inner: utils.parsing.NotEmptyIterator,
    current_range: ?Range = null,
    start_digit_count: i64 = 0,
    current_digit_count: i64 = 0,
    end_digit_count: i64 = 0,

    pub fn next(self: *RangeIterator) !?Range {
        while (true) {
            // If we're currently processing a range, continue with it
            if (self.current_range) |range| {
                if (self.current_digit_count <= self.end_digit_count) {
                    // Generate sub-range for current digit count
                    const digit_count = self.current_digit_count;
                    self.current_digit_count += 1;

                    var sub_range_start: i64 = 0;
                    var sub_range_end: i64 = 0;

                    if (digit_count == self.start_digit_count) {
                        sub_range_start = range.start;
                    } else {
                        sub_range_start = try std.math.powi(i64, 10, @intCast(digit_count - 1));
                    }

                    if (digit_count == self.end_digit_count) {
                        sub_range_end = range.end;
                    } else {
                        sub_range_end = try std.math.powi(i64, 10, @intCast(digit_count)) - 1;
                    }

                    return Range{
                        .start = sub_range_start,
                        .end = sub_range_end,
                    };
                } else {
                    // Done with this range, clear it
                    self.current_range = null;
                }
            }

            // Get next range from input
            if (self.inner.next()) |range_str| {
                const range = try Range.fromString(range_str);
                const numDigits_start = utils.maths.numDigits(range.start);
                const numDigits_end = utils.maths.numDigits(range.end);

                self.current_range = range;
                self.start_digit_count = numDigits_start;
                self.current_digit_count = numDigits_start;
                self.end_digit_count = numDigits_end;
                // Continue loop to generate first sub-range
            } else {
                // No more ranges
                return null;
            }
        }
    }
};

// ============================================================================
// Tests
// ============================================================================

test "day02 part1 example" {
    const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

    const result = try part1(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 1227775554), result);
}

test "day02 part2 example" {
    const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 4174379265), result);
}
