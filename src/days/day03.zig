const std = @import("std");
const utils = @import("utils");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    const banks = try parseBatteryBanks(allocator, input);
    defer freeBatteryBanks(allocator, banks);

    var sum: i64 = 0;

    for (banks) |bank| {
        const capacity = bank.largestCapacityFor(2);
        sum += capacity;
    }

    return sum;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    const banks = try parseBatteryBanks(allocator, input);
    defer freeBatteryBanks(allocator, banks);

    var sum: i64 = 0;

    for (banks) |bank| {
        const capacity = bank.largestCapacityFor(12);
        sum += capacity;
    }

    return sum;
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const BatteryBank = struct {
    batteries: []i64,

    pub fn deinit(self: BatteryBank, allocator: std.mem.Allocator) void {
        allocator.free(self.batteries);
    }

    pub fn largestCapacityFor(self: BatteryBank, n: usize) i64 {
        var sum: i64 = 0;

        var start_idx: usize = 0;
        for (0..n) |battery_i| {
            var largest_cell: i64 = 0;
            var largest_cell_idx: usize = 0;
            for (start_idx..(self.batteries.len - (n - (battery_i + 1)))) |i| {
                if (self.batteries[i] > largest_cell) {
                    largest_cell = self.batteries[i];
                    largest_cell_idx = i;
                }
            }
            sum *= 10;
            sum += largest_cell;
            start_idx = largest_cell_idx + 1;
        }

        return sum;
    }

    pub fn fromString(allocator: std.mem.Allocator, line: []const u8) !BatteryBank {
        var battery_list: std.ArrayList(i64) = .empty;
        errdefer battery_list.deinit(allocator);

        var i: usize = 0;
        while (i < line.len) {
            const c = line[i];
            if (c >= '0' and c <= '9') {
                const digit = @as(i64, c - '0');
                try battery_list.append(allocator, digit);
            } else {
                return error.InvalidBatteryCharacter;
            }
            i += 1;
        }

        return BatteryBank{
            .batteries = try battery_list.toOwnedSlice(allocator),
        };
    }
};

pub fn parseBatteryBanks(allocator: std.mem.Allocator, input: []const u8) ![]BatteryBank {
    var battery_list: std.ArrayList(BatteryBank) = .empty;
    errdefer battery_list.deinit(allocator);

    var line_iter = utils.parsing.lines(input);
    while (line_iter.next()) |line| {
        const battery_bank = try BatteryBank.fromString(allocator, line);
        try battery_list.append(allocator, battery_bank);
    }

    return battery_list.toOwnedSlice(allocator);
}

fn freeBatteryBanks(allocator: std.mem.Allocator, banks: []BatteryBank) void {
    for (banks) |bank| {
        bank.deinit(allocator);
    }
    allocator.free(banks);
}

// ============================================================================
// Tests
// ============================================================================

test "day03 part1 example" {
    const input = "987654321111111\n811111111111119\n234234234234278\n818181911112111";

    const result = try part1(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 357), result);
}

test "day03 part2 example" {
    const input = "987654321111111\n811111111111119\n234234234234278\n818181911112111";

    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 3121910778619), result);
}
