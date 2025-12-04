const std = @import("std");
const utils = @import("utils");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    const map = try utils.maps.Map(Cell).init(allocator, input, Cell.fromChar);
    defer map.deinit();

    const accessible = try getAccessibleRolls(allocator, map);
    defer allocator.free(accessible);

    return @intCast(accessible.len);
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    const map = try utils.maps.Map(Cell).init(allocator, input, Cell.fromChar);
    defer map.deinit();

    var count_of_removed_rolls: i64 = 0;

    while (true) {
        const accessible = try getAccessibleRolls(allocator, map);
        defer allocator.free(accessible);

        if (accessible.len == 0) {
            break;
        }

        // Remove the accessible rolls from the map
        for (accessible) |pos| {
            const idx = map.indexOf(pos) orelse continue;
            map.tiles[idx] = .empty;
        }

        count_of_removed_rolls += @intCast(accessible.len);
    }

    return count_of_removed_rolls;
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const Cell = enum {
    empty,
    roll_of_paper,

    pub fn fromChar(c: u8) !Cell {
        return switch (c) {
            '.' => Cell.empty,
            '@' => Cell.roll_of_paper,
            else => error.UnexpectedCharacter,
        };
    }
};

const adjacent_positions = [_]utils.maps.Pos {
    .{ -1, -1 }, // top-left
    .{ 0, -1 },  // top
    .{ 1, -1 }, // top-right
    .{ 1, 0 },  // right
    .{ 1, 1 },  // bottom-right
    .{ 0, 1 },  // bottom
    .{ -1, 1 }, // bottom-left
    .{ -1, 0 }, // left
};

fn getAccessibleRolls(allocator: std.mem.Allocator, map: utils.maps.Map(Cell)) ![]utils.maps.Pos {
    var list: std.ArrayList(utils.maps.Pos) = .empty;
    errdefer list.deinit(allocator);

    // Find all accessible rolls of paper
    for (map.tiles, 0..) |cell, idx| {
        if (cell == .roll_of_paper) {
            const this_pos = map.positionOf(idx);

            // It's only accessible if it has less than 4 adjacent rolls of paper
            var count_of_adjacent_rolls: i64 = 0;
            for (adjacent_positions) |offset| {
                const adjacent_pos = this_pos + offset;

                if (map.get(adjacent_pos) == .roll_of_paper) {
                    count_of_adjacent_rolls += 1;
                }
            }

            if (count_of_adjacent_rolls < 4) {
                try list.append(allocator, this_pos);
            }
        }
    }

    return list.toOwnedSlice(allocator);
}

// ============================================================================
// Tests
// ============================================================================

test "day04 part1 example" {
    const input = "..@@.@@@@.\n@@@.@.@.@@\n@@@@@.@.@@\n@.@@@@..@.\n@@.@@@@.@@\n.@@@@@@@.@\n.@.@.@.@@@\n@.@@@.@@@@\n.@@@@@@@@.\n@.@.@@@.@.";

    const result = try part1(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 13), result);
}

test "day04 part2 example" {
    const input = "..@@.@@@@.\n@@@.@.@.@@\n@@@@@.@.@@\n@.@@@@..@.\n@@.@@@@.@@\n.@@@@@@@.@\n.@.@.@.@@@\n@.@@@.@@@@\n.@@@@@@@@.\n@.@.@@@.@.";

    const result = try part2(std.testing.allocator, input);
    try std.testing.expectEqual(@as(i64, 43), result);
}
