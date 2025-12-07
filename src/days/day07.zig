const std = @import("std");
const utils = @import("utils");

// ============================================================================
// Public Interface (called by main.zig)
// ============================================================================

pub fn part1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var map: utils.maps.Map(Tile) = try .init(allocator, input, Tile.fromChar);
    defer map.deinit();

    var num_splitters_hit: i64 = 0;
    for (map.tiles, 0..) |item, idx| {
        switch (item) {
            Tile.start_position, Tile.beam => {
                const pos = map.positionOf(idx);
                const below_pos = pos + down;

                if (map.inBounds(below_pos)) {
                    const below_tile = map.get(below_pos).?;
                    if (below_tile == Tile.empty) {
                        try map.set(below_pos, Tile.beam);
                    } else if (below_tile == Tile.splitter) {
                        // Beam hits splitter, create new beams
                        num_splitters_hit += 1;
                        map.set(pos + down_left, Tile.beam) catch {};
                        map.set(pos + down_right, Tile.beam) catch {};
                    }
                }
            },
            else => {},
        }
    }

    return num_splitters_hit;
}

pub fn part2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var map: utils.maps.Map(Tile) = try .init(allocator, input, Tile.fromChar);
    defer map.deinit();

    const start_pos = blk: {
        for (map.tiles, 0..) |tile, idx| {
            if (tile == Tile.start_position) break :blk map.positionOf(idx);
        }
        return error.MissingStartPosition;
    };

    var memorised_positions: MemorisedMap = .init(allocator);
    defer memorised_positions.deinit();

    return runBeam(&map, &memorised_positions, start_pos);
}

// ============================================================================
// Helper Functions (private to this module)
// ============================================================================

const down = utils.maps.Pos{ 0, 1 };
const down_left = utils.maps.Pos{ -1, 1 };
const down_right = utils.maps.Pos{ 1, 1 };

const Tile = enum {
    empty,
    start_position,
    splitter,
    beam,

    pub fn fromChar(c: u8) !Tile {
        return switch (c) {
            '.' => Tile.empty,
            'S' => Tile.start_position,
            '^' => Tile.splitter,
            '|' => Tile.beam,
            else => error.UnexpectedCharacter,
        };
    }
};

const MemorisedMap = std.AutoHashMap(utils.maps.Pos, i64);

fn runBeam(map: *utils.maps.Map(Tile), cache: *MemorisedMap, pos: utils.maps.Pos) !i64 {
    const below_pos = pos + down;

    const cached = cache.get(below_pos);
    if (cached != null) {
        return cached.?;
    }

    if (map.inBounds(below_pos)) {
        const below_tile = map.get(below_pos).?;
        switch (below_tile) {
            Tile.start_position, Tile.beam => {
                return error.InvalidBeamPath;
            },
            Tile.empty => {
                return runBeam(map, cache, below_pos);
            },
            Tile.splitter => {
                // Beam hits splitter, create new beams
                const left_count = try runBeam(map, cache, pos + down_left);
                const right_count = try runBeam(map, cache, pos + down_right);

                const total_count = left_count + right_count;
                try cache.put(below_pos, total_count);
                return total_count;
            },
        }
    } else {
        // Reached the bottom of the map, count as a possible path
        return 1;
    }
}

// ============================================================================
// Tests
// ============================================================================

const example_input =
    \\.......S.......
    \\...............
    \\.......^.......
    \\...............
    \\......^.^......
    \\...............
    \\.....^.^.^.....
    \\...............
    \\....^.^...^....
    \\...............
    \\...^.^...^.^...
    \\...............
    \\..^...^.....^..
    \\...............
    \\.^.^.^.^.^...^.
    \\...............
;

test "day07 part1 example" {
    const result = try part1(std.testing.allocator, example_input);
    try std.testing.expectEqual(@as(i64, 21), result);
}

test "day07 part2 example" {
    const result = try part2(std.testing.allocator, example_input);
    try std.testing.expectEqual(@as(i64, 40), result);
}
