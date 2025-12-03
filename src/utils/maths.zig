const std = @import("std");

/// Returns the number of digits in the given integer `n`.
pub fn numDigits(n: i64) i64 {
    if (n == 0) {
        return 1;
    }

    var count: i64 = 0;
    var value = n;
    if (value < 0) {
        value = -value;
    }

    while (value > 0) {
        value = @divTrunc(value, 10);
        count += 1;
    }

    return count;
}

// ============================================================================
// Tests
// ============================================================================

test "numDigits function" {
    try std.testing.expectEqual(@as(i64, 1), numDigits(0));
    try std.testing.expectEqual(@as(i64, 1), numDigits(5));
    try std.testing.expectEqual(@as(i64, 2), numDigits(42));
    try std.testing.expectEqual(@as(i64, 3), numDigits(123));
    try std.testing.expectEqual(@as(i64, 4), numDigits(9999));
    try std.testing.expectEqual(@as(i64, 5), numDigits(10000));
    try std.testing.expectEqual(@as(i64, 1), numDigits(-7));
    try std.testing.expectEqual(@as(i64, 3), numDigits(-456));
}
