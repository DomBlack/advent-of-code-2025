const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for shared utilities
    const utils = b.addModule("utils", .{
        .root_source_file = b.path("lib/utils.zig"),
    });

    // Helper function to create a day executable
    const createDay = struct {
        fn create(
            builder: *std.Build,
            day_num: u8,
            t: std.Build.ResolvedTarget,
            opt: std.builtin.OptimizeMode,
            utils_mod: *std.Build.Module,
        ) void {
            const day_str = builder.fmt("day-{d:0>2}", .{day_num});
            const src_path = builder.fmt("src/{s}.zig", .{day_str});

            // Create the executable
            const exe = builder.addExecutable(.{
                .name = day_str,
                .root_source_file = builder.path(src_path),
                .target = t,
                .optimize = opt,
            });

            // Add the utils module
            exe.root_module.addImport("utils", utils_mod);

            builder.installArtifact(exe);

            // Create run step
            const run_cmd = builder.addRunArtifact(exe);
            run_cmd.step.dependOn(builder.getInstallStep());

            // Pass the user's input file as argument
            const input_path = builder.fmt("inputs/{s}.txt", .{day_str});
            run_cmd.addArg(input_path);

            // Allow extra args from command line
            if (builder.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_step_name = builder.fmt("run-{s}", .{day_str});
            const run_step_desc = builder.fmt("Run {s} with user input", .{day_str});
            const run_step = builder.step(run_step_name, run_step_desc);
            run_step.dependOn(&run_cmd.step);

            // Create test step that runs against example inputs
            const test_exe = builder.addTest(.{
                .root_source_file = builder.path(src_path),
                .target = t,
                .optimize = opt,
            });
            test_exe.root_module.addImport("utils", utils_mod);

            const run_test = builder.addRunArtifact(test_exe);

            const test_step_name = builder.fmt("test-{s}", .{day_str});
            const test_step_desc = builder.fmt("Run tests for {s} with example inputs", .{day_str});
            const test_step = builder.step(test_step_name, test_step_desc);
            test_step.dependOn(&run_test.step);
        }
    }.create;

    // Create all 12 days for Advent of Code 2025
    inline for (1..13) |day| {
        createDay(b, @intCast(day), target, optimize, utils);
    }

    // Create a test step that runs all tests
    const test_step = b.step("test", "Run all tests");
    inline for (1..13) |day| {
        const day_str = b.fmt("day-{d:0>2}", .{day});
        const src_path = b.fmt("src/{s}.zig", .{day_str});
        const test_exe = b.addTest(.{
            .root_source_file = b.path(src_path),
            .target = target,
            .optimize = optimize,
        });
        test_exe.root_module.addImport("utils", utils);
        const run_test = b.addRunArtifact(test_exe);
        test_step.dependOn(&run_test.step);
    }
}
