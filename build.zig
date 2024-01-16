// SPDX-FileCopyrightText: 2024 Caleb Depatie
//
// SPDX-License-Identifier: 0BSD

const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const out = b.addExecutable(.{
        .name = "zold",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(out);

    const run = b.addRunArtifact(out);

    if (b.args) |args| {
        run.addArgs(args);
    }

    const run_step = b.step("run", "Run the linker");
    run_step.dependOn(&run.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
