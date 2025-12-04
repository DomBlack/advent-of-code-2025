const std = @import("std");

/// Pos is a 2D position vector with helper functions
pub const Pos = @Vector(2, i64);

/// a generic 2D map structure which can hold any type of cell
pub fn Map(comptime TileType: type) type {
    return struct {
        width: i64,
        height: i64,

        // tiles are all the tile_type's that make up the map.
        //
        // The tiles are laid out by rows, such that
        // indexes 0 -> Width are row 1, and indexes
        // Width -> Width * 2 are row 2.
        tiles: []TileType,

        allocator: std.mem.Allocator,

        const Self = @This();

        /// init creates a new Map from the given input string and the a function which can convert a character to a TileType.
        pub fn init(gpa: std.mem.Allocator, input: []const u8, comptime charToTile: anytype) !Map(TileType) {
            // Create an array large enough to hold all tiles in one allocation
            var array: std.ArrayList(TileType) = try .initCapacity(gpa, input.len);
            errdefer array.deinit(gpa);

            var width: i64 = 0;
            var height: i64 = 1;
            var row_len: i64 = 0;

            // Parse the input string into tiles
            for (input) |c| {
                if (c == '\n') {
                    // on a new line, either set the map width, or verify it matches the existing width
                    if (width == 0) {
                        width = row_len;
                    } else if (row_len != width) {
                        return error.InvalidMapWidth;
                    }

                    // move to the next row
                    height += 1;
                    row_len = 0;
                } else {
                    // Otherwise try to convert the character to a tile and add it to the array
                    const tile: TileType = blk: {
                        const ReturnType = @TypeOf(charToTile(c));
                        if (@typeInfo(ReturnType) == .error_union) {
                            break :blk try charToTile(c);
                        } else {
                            break :blk charToTile(c);
                        }
                    };
                    try array.append(gpa, tile);
                    row_len += 1;
                }
            }

            // After parsing, verify the last row length matches the width (if width is set)
            if (width != 0 and row_len != width) {
                return error.InvalidMapWidth;
            }

            // then return the map with the parsed tiles as an owned slice
            return .{
                .width = width,
                .height = height,
                .tiles = try array.toOwnedSlice(gpa),
                .allocator = gpa,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.tiles);
        }

        // length returns the number of tiles in the map.
        pub inline fn len(self: Self) usize {
            return self.tiles.len;
        }

        /// positionOf returns the x, y position of the given index.
        pub fn positionOf(self: Self, idx: usize) Pos {
            const x: i64 = @intCast(idx % @as(usize, @intCast(self.width)));
            const y: i64 = @intCast(idx / @as(usize, @intCast(self.width)));
            return Pos{ x, y };
        }

        /// indexOf returns the index of the given x, y position, or null if out of bounds.
        pub fn indexOf(self: Self, pos: Pos) ?usize {
            if (!self.inBounds(pos)) {
                return null;
            }
            return @intCast(pos[1] * self.width + pos[0]);
        }

        /// inBounds returns true if the given position is within the map bounds.
        pub fn inBounds(self: Self, pos: Pos) bool {
            return (pos[0] >= 0) and (pos[0] < self.width) and (pos[1] >= 0) and (pos[1] < self.height);
        }

        // get returns the TileType at the given position, or null if out of bounds.
        pub fn get(self: Self, pos: Pos) ?TileType {
            return if (self.indexOf(pos)) |idx| self.tiles[idx] else null;
        }
    };
}

test "test map" {
    const MyMap = Map(bool);
    const parser = struct {
        fn parse(c: u8) bool {
            return switch (c) {
                'y' => true,
                'n' => false,
                else => false,
            };
        }
    };

    var map = try MyMap.init(std.testing.allocator, "ynyn\nyynn\nnnyn\nynyy\nnyny", parser.parse);
    defer map.deinit();

    try std.testing.expectEqual(@as(i64, 4), map.width);
    try std.testing.expectEqual(@as(i64, 5), map.height);
    try std.testing.expectEqual(@as(usize, 0), map.indexOf(.{0, 0}));
    try std.testing.expectEqual(@as(usize, 1), map.indexOf(.{1, 0}));
    try std.testing.expectEqual(@as(usize, 4), map.indexOf(.{0, 1}));
    try std.testing.expectEqual(@as(usize, 5), map.indexOf(.{1, 1}));
    try std.testing.expectEqual(@as(usize, 19), map.indexOf(.{3, 4}));

    try std.testing.expectEqual(true, map.get(.{0, 0}).?);
    try std.testing.expectEqual(false, map.get(.{1, 0}).?);
    try std.testing.expectEqual(true, map.get(.{2, 0}).?);
    try std.testing.expectEqual(null, map.get(.{43, 32}));
    try std.testing.expectEqual(null, map.get(.{-1, -3}));
}