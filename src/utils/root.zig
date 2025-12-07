const std = @import("std");

pub const parsing = @import("parsing.zig");
pub const maths = @import("maths.zig");
pub const maps = @import("maps.zig");

// Force test discovery for imported modules
test {
    std.testing.refAllDecls(@This());
}

// ============================================================================
// File I/O Utilities
// ============================================================================

/// Read the input file for a given day.
/// Returns the file contents as a string (caller owns memory and must free it).
///
/// Input files are expected to be in the `inputs/` directory with the format
/// `dayXX.txt` (zero-padded, e.g., day01.txt, day02.txt, ..., day25.txt).
///
/// Example:
/// ```zig
/// const input = try utils.readInputFile(allocator, 1);
/// defer allocator.free(input);
/// ```
pub fn readInputFile(allocator: std.mem.Allocator, day: u8) ![]u8 {
    // Format the filename with zero-padding (day01, day02, etc.)
    const filename = try std.fmt.allocPrint(
        allocator,
        "inputs/day{d:0>2}.txt",
        .{day},
    );
    defer allocator.free(filename);

    // Open the file
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // Read the entire file into memory
    // Use a reasonable max size (10MB should be plenty for AoC inputs)
    const max_size = 10 * 1024 * 1024;

    var read_buffer: [4096]u8 = undefined;
    var file_reader = file.reader(&read_buffer);
    const contents = try file_reader.interface.allocRemaining(allocator, std.Io.Limit.limited(max_size));

    return contents;
}
