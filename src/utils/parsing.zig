const std = @import("std");

/// Iterator that filters out empty values after trimming whitespace.
/// Trims spaces, tabs, carriage returns, and newlines from each value.
pub const NotEmptyIterator = struct {
    inner: std.mem.SplitIterator(u8, .scalar),

    pub fn next(self: *NotEmptyIterator) ?[]const u8 {
        while (self.inner.next()) |value| {
            const trimmed = std.mem.trim(u8, value, " \t\r\n");
            if (trimmed.len > 0) return trimmed;
        }
        return null;
    }
};

/// Returns an iterator over lines in the input string.
///
/// Empty lines are excluded from the iteration.
/// Leading and trailing whitespace is trimmed from each line.
///
/// Example:
/// ```zig
/// var iter = utils.lines(input);
/// while (iter.next()) |line| {
///     // Process each line
/// }
/// ```
pub fn lines(input: []const u8) NotEmptyIterator {
    return .{ .inner = std.mem.splitScalar(u8, input, '\n') };
}

/// Returns an iterator over comma-separated values in the input string.
///
/// Empty values are excluded from the iteration.
/// Leading and trailing whitespace is trimmed from each value.
pub fn commas(input: []const u8) NotEmptyIterator {
    return .{ .inner = std.mem.splitScalar(u8, input, ',') };
}

// ============================================================================
// Tests
// ============================================================================

test "lines iterator" {
    const input = "line1\nline2\nline3";

    var iter = lines(input);
    try std.testing.expectEqualStrings("line1", iter.next().?);
    try std.testing.expectEqualStrings("line2", iter.next().?);
    try std.testing.expectEqualStrings("line3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "lines iterator with empty lines" {
    const input = "line1\n\nline3";

    var iter = lines(input);
    try std.testing.expectEqualStrings("line1", iter.next().?);
    try std.testing.expectEqualStrings("line3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "lines iterator with trailing newline" {
    const input = "line1\nline2\n";

    var iter = lines(input);
    try std.testing.expectEqualStrings("line1", iter.next().?);
    try std.testing.expectEqualStrings("line2", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "lines iterator trims whitespace" {
    const input = "  line1  \n\t line2\t\n  line3";

    var iter = lines(input);
    try std.testing.expectEqualStrings("line1", iter.next().?);
    try std.testing.expectEqualStrings("line2", iter.next().?);
    try std.testing.expectEqualStrings("line3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "commas iterator" {
    const input = "value1,value2,value3";

    var iter = commas(input);
    try std.testing.expectEqualStrings("value1", iter.next().?);
    try std.testing.expectEqualStrings("value2", iter.next().?);
    try std.testing.expectEqualStrings("value3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "commas iterator with empty values" {
    const input = "value1,,value3";

    var iter = commas(input);
    try std.testing.expectEqualStrings("value1", iter.next().?);
    try std.testing.expectEqualStrings("value3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "commas iterator with trailing comma" {
    const input = "value1,value2,";

    var iter = commas(input);
    try std.testing.expectEqualStrings("value1", iter.next().?);
    try std.testing.expectEqualStrings("value2", iter.next().?);
    try std.testing.expect(iter.next() == null);
}

test "commas iterator trims whitespace" {
    const input = "  value1  , \t value2\t , value3 ";

    var iter = commas(input);
    try std.testing.expectEqualStrings("value1", iter.next().?);
    try std.testing.expectEqualStrings("value2", iter.next().?);
    try std.testing.expectEqualStrings("value3", iter.next().?);
    try std.testing.expect(iter.next() == null);
}
