//! Advent of Code 2025 - Build Configuration
//!
//! This build script implements automatic day discovery:
//! 1. Scans src/days/ for dayXX.zig files at build time
//! 2. Generates src/days.zig with imports and dispatch logic
//! 3. Creates per-day test steps (e.g., `zig build test-day1`)
//! 4. Wires up the utils module for shared functionality
//!
//! To add a new day:
//! - Just create src/days/dayXX.zig and add inputs/dayXX.txt
//! - The build system automatically detects and integrates it
//!
//! The Zig build system is declarative - we define steps and dependencies,
//! and the build runner executes them in the correct order with parallelization.

const std = @import("std");
const zlinter = @import("zlinter");

pub fn build(b: *std.Build) void {
    // ========================================================================
    // Build Configuration
    // ========================================================================

    // Standard target options allow `zig build` to support cross-compilation
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow choosing between Debug, ReleaseSafe,
    // ReleaseFast, and ReleaseSmall via `-Doptimize=<mode>`
    const optimize = b.standardOptimizeOption(.{});

    // ========================================================================
    // Utilities Module
    // ========================================================================

    // Create a module for shared utilities used across all days
    // This module lives in src/utils/root.zig and can be expanded with
    // additional focused files (parsing.zig, grid.zig, etc.)
    const utils = b.addModule("utils", .{
        .root_source_file = b.path("src/utils/root.zig"),
        .target = target,
    });

    // ========================================================================
    // Day Discovery and Code Generation
    // ========================================================================

    // Discover all implemented days by scanning src/days/ directory
    const discovered_days = discoverDays(b) catch &[_]u8{};

    // Generate src/days.zig with imports and dispatch logic for all days
    // This is a build-time code generation step
    generateDaysModule(b, discovered_days) catch |err| {
        std.debug.print("Warning: Failed to generate days module: {}\n", .{err});
    };

    // ========================================================================
    // Main Executable
    // ========================================================================

    // Create the main executable that dispatches to day solutions
    const exe = b.addExecutable(.{
        .name = "aoc2025",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                // Import the utils module
                .{ .name = "utils", .module = utils },
            },
        }),
    });

    // Install the executable to zig-out/bin/
    b.installArtifact(exe);

    // ========================================================================
    // Run Step
    // ========================================================================

    // Create a top-level "run" step that executes the compiled binary
    // Usage: zig build run -- <day> [part]
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);

    // Make run depend on install so it runs from zig-out/ not cache
    run_cmd.step.dependOn(b.getInstallStep());

    run_step.dependOn(&run_cmd.step);

    // Forward command-line arguments to the executable
    // This allows: zig build run -- 1 1
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // ========================================================================
    // Test Infrastructure
    // ========================================================================

    // Create main test step that runs ALL tests
    const test_step = b.step("test", "Run all tests");

    // Test the utils module
    const utils_tests = b.addTest(.{
        .root_module = utils,
    });
    const run_utils_tests = b.addRunArtifact(utils_tests);
    test_step.dependOn(&run_utils_tests.step);

    // Test the main module
    const main_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_main_tests = b.addRunArtifact(main_tests);
    test_step.dependOn(&run_main_tests.step);

    // Create per-day test steps for each discovered day
    // This allows running: zig build test-day1, test-day2, etc.
    for (discovered_days) |day| {
        addDayTests(b, day, utils, test_step);
    }

    // ========================================================================
    // Linting Step
    // ========================================================================

    const lint_cmd = b.step("lint", "Lint source code.");
    lint_cmd.dependOn(step: {
        // Swap in and out whatever rules you see fit from RULES.md
        var builder = zlinter.builder(b, .{});
        builder.addRule(.{ .builtin = .field_naming }, .{});
        builder.addRule(.{ .builtin = .declaration_naming }, .{});
        builder.addRule(.{ .builtin = .function_naming }, .{});
        builder.addRule(.{ .builtin = .file_naming }, .{});
        builder.addRule(.{ .builtin = .switch_case_ordering }, .{});
        builder.addRule(.{ .builtin = .no_unused }, .{});
        builder.addRule(.{ .builtin = .no_deprecated }, .{});
        builder.addRule(.{ .builtin = .no_orelse_unreachable }, .{});
        break :step builder.build();
    });
}

// ============================================================================
// Day Discovery
// ============================================================================

/// Scans the src/days/ directory and returns a list of implemented day numbers.
/// Files are expected to be named dayXX.zig (e.g., day01.zig, day02.zig, ..., day25.zig)
fn discoverDays(b: *std.Build) ![]const u8 {
    var days: std.ArrayList(u8) = .empty;
    errdefer days.deinit(b.allocator);

    // Open the src/days/ directory
    var dir = std.fs.cwd().openDir("src/days", .{ .iterate = true }) catch |err| {
        // If directory doesn't exist or can't be opened, return empty list
        std.debug.print("Note: Could not open src/days/ directory: {}\n", .{err});
        return &[_]u8{};
    };
    defer dir.close();

    // Iterate through all files in the directory
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        // Only process regular files
        if (entry.kind != .file) continue;

        // Check if filename matches dayXX.zig pattern
        if (entry.name.len >= 8 and
            std.mem.startsWith(u8, entry.name, "day") and
            std.mem.endsWith(u8, entry.name, ".zig"))
        {
            // Extract the day number (characters 3-4 for day01, day02, etc.)
            const day_str = entry.name[3 .. entry.name.len - 4];

            // Parse the day number
            const day = std.fmt.parseInt(u8, day_str, 10) catch continue;

            // Validate day is in range 1-25
            if (day >= 1 and day <= 25) {
                try days.append(b.allocator, day);
            }
        }
    }

    // Sort days in ascending order for consistent output
    const days_slice = try days.toOwnedSlice(b.allocator);
    std.mem.sort(u8, days_slice, {}, std.sort.asc(u8));

    // std.debug.print("Discovered {} day(s): ", .{days_slice.len});
    // for (days_slice, 0..) |day, i| {
    //     if (i > 0) std.debug.print(", ", .{});
    //     std.debug.print("{}", .{day});
    // }
    // std.debug.print("\n", .{});

    return days_slice;
}

// ============================================================================
// Code Generation
// ============================================================================

/// Generates src/days.zig with imports and dispatch logic for all discovered days.
/// This file is auto-generated and should not be edited manually.
fn generateDaysModule(b: *std.Build, days: []const u8) !void {
    var buffer: std.ArrayList(u8) = .empty;
    defer buffer.deinit(b.allocator);

    var writer = std.Io.Writer.Allocating.fromArrayList(b.allocator, &buffer);

    // File header
    try writer.writer.writeAll(
        \\// Auto-generated by build.zig - DO NOT EDIT MANUALLY
        \\//
        \\// This file is generated at build time based on the day files found in src/days/
        \\// To add a new day, just create src/days/dayXX.zig and rebuild
        \\
        \\const std = @import("std");
        \\
        \\
    );

    // Generate imports for each day
    try writer.writer.writeAll("// Day imports\n");
    for (days) |day| {
        try writer.writer.print("const day{d:0>2} = @import(\"days/day{d:0>2}.zig\");\n", .{ day, day });
    }
    try writer.writer.writeAll("\n");

    // Generate implemented_days array
    try writer.writer.writeAll("/// Array of all implemented day numbers\n");
    try writer.writer.writeAll("pub const implemented_days = [_]u8{ ");
    for (days, 0..) |day, i| {
        if (i > 0) try writer.writer.writeAll(", ");
        try writer.writer.print("{}", .{day});
    }
    try writer.writer.writeAll(" };\n\n");

    // Generate runDay dispatch function
    try writer.writer.writeAll(
        \\/// Dispatch to the appropriate day's solution
        \\pub fn runDay(
        \\    allocator: std.mem.Allocator,
        \\    day: u8,
        \\    part: ?u8,
        \\    input: []const u8,
        \\    name: []const u8,
        \\) !void {
        \\    switch (day) {
        \\
    );

    // Generate switch cases for each day
    for (days) |day| {
        try writer.writer.print(
            \\        {d} => try runDayImpl(allocator, name, day{d:0>2}, input, part),
            \\
        , .{ day, day });
    }

    try writer.writer.writeAll(
        \\        else => {
        \\            std.debug.print("Day {} not yet implemented\n", .{day});
        \\            return error.DayNotImplemented;
        \\        },
        \\    }
        \\}
        \\
        \\
    );

    // Generate runDayImpl helper function
    try writer.writer.writeAll(
        \\/// Helper function to run a day's solution with proper error handling
        \\fn runDayImpl(
        \\    allocator: std.mem.Allocator,
        \\    name: []const u8,
        \\    day_module: anytype,
        \\    input: []const u8,
        \\    part: ?u8,
        \\) !void {
        \\    // Run part 1 if no specific part requested or if part 1 requested
        \\    if (part == null or part.? == 1) {
        \\        const result = try day_module.part1(allocator, input);
        \\        std.debug.print("{s} Part 1: {}\n", .{ name, result });
        \\    }
        \\
        \\    // Run part 2 if no specific part requested or if part 2 requested
        \\    if (part == null or part.? == 2) {
        \\        const result = try day_module.part2(allocator, input);
        \\        std.debug.print("{s} Part 2: {}\n", .{ name, result });
        \\    }
        \\}
        \\
    );

    // Convert writer back to ArrayList to access the generated content
    buffer = writer.toArrayList();

    // Write the generated code to src/days.zig
    const file = try std.fs.cwd().createFile("src/days.zig", .{});
    defer file.close();

    // Allocate a write buffer large enough for all content
    const write_buffer = try b.allocator.alloc(u8, buffer.items.len);
    defer b.allocator.free(write_buffer);

    var file_writer = file.writer(write_buffer);
    try file_writer.interface.writeAll(buffer.items);
    try file_writer.end();
}

// ============================================================================
// Per-Day Test Steps
// ============================================================================

/// Creates a test step for a specific day
/// This allows running: zig build test-day1, test-day2, etc.
fn addDayTests(
    b: *std.Build,
    day: u8,
    utils: *std.Build.Module,
    test_step: *std.Build.Step,
) void {
    // Format the filename: src/days/day01.zig, day02.zig, etc.
    const day_file = std.fmt.allocPrint(
        b.allocator,
        "src/days/day{d:0>2}.zig",
        .{day},
    ) catch return;

    // Create a module for this day
    const day_module = b.createModule(.{
        .root_source_file = b.path(day_file),
        .target = utils.resolved_target.?,
    });

    // The day module needs access to utils
    day_module.addImport("utils", utils);

    // Create a test executable for this day
    const day_tests = b.addTest(.{
        .root_module = day_module,
    });

    // Create a run step for the test executable
    const run_day_tests = b.addRunArtifact(day_tests);

    // Create a named step: "test-day1", "test-day2", etc.
    const step_name = std.fmt.allocPrint(
        b.allocator,
        "test-day{}",
        .{day},
    ) catch return;

    const step_desc = std.fmt.allocPrint(
        b.allocator,
        "Run day {} tests",
        .{day},
    ) catch return;

    const day_test_step = b.step(step_name, step_desc);
    day_test_step.dependOn(&run_day_tests.step);

    // Also add this day's tests to the main "test" step
    test_step.dependOn(&run_day_tests.step);
}