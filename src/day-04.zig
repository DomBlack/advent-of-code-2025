const std = @import("std");
const utils = @import("utils");

fn part1(input: []const u8) !i64 {
    _ = input;
    // TODO: Implement part 1
    return 0;
}

fn part2(input: []const u8) !i64 {
    _ = input;
    // TODO: Implement part 2
    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <input_file>\n", .{args[0]});
        return error.MissingInputFile;
    }

    const input_file = args[1];
    const input = try utils.readInputFile(allocator, input_file);
    defer allocator.free(input);

    const result1 = try part1(input);
    const result2 = try part2(input);

    std.debug.print("Part 1: {d}\n", .{result1});
    std.debug.print("Part 2: {d}\n", .{result2});
}

// Tests run against example inputs
test "example 1 part 1" {
    const input = @embedFile("../inputs/day-04-example-1.txt");
    const result = try part1(input);
    
    // TODO: Update with expected result from the problem
    try std.testing.expectEqual(@as(i64, 0), result);
}

test "example 1 part 2" {
    const input = @embedFile("../inputs/day-04-example-1.txt");
    const result = try part2(input);
    
    // TODO: Update with expected result from the problem
    try std.testing.expectEqual(@as(i64, 0), result);
}
