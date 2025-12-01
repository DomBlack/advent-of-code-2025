const std = @import("std");

/// Read the entire contents of a file into a string
pub fn readInputFile(allocator: std.mem.Allocator, file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    const buffer = try allocator.alloc(u8, file_size);
    const bytes_read = try file.readAll(buffer);

    return buffer[0..bytes_read];
}

/// Split a string by newlines
pub fn splitLines(allocator: std.mem.Allocator, input: []const u8) ![][]const u8 {
    var lines = std.ArrayList([]const u8).init(allocator);
    errdefer lines.deinit();

    var iter = std.mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        try lines.append(line);
    }

    return lines.toOwnedSlice();
}

/// Parse an integer from a string
pub fn parseInt(comptime T: type, str: []const u8) !T {
    return std.fmt.parseInt(T, str, 10);
}

test "readInputFile" {
    // This is a placeholder test
    // Actual file reading tests would require test fixtures
}

test "splitLines" {
    const allocator = std.testing.allocator;
    const input = "line1\nline2\nline3";
    const lines = try splitLines(allocator, input);
    defer allocator.free(lines);

    try std.testing.expectEqual(@as(usize, 3), lines.len);
    try std.testing.expectEqualStrings("line1", lines[0]);
    try std.testing.expectEqualStrings("line2", lines[1]);
    try std.testing.expectEqualStrings("line3", lines[2]);
}

test "parseInt" {
    try std.testing.expectEqual(@as(i32, 42), try parseInt(i32, "42"));
    try std.testing.expectEqual(@as(i32, -42), try parseInt(i32, "-42"));
}
