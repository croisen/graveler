const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast,
    });

    const graveler_rewrite = b.addExecutable(.{
        .name = "graveler-rewrite",
        .root_source_file = b.path("src/graveler_rewrite.zig"),
        .target = target,
        .optimize = optimize,
    });

    const straight_prz_procs = b.addExecutable(.{
        .name = "graveler-prz-procs",
        .root_source_file = b.path("src/straight_prz_procs.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(graveler_rewrite);
    b.installArtifact(straight_prz_procs);

    const new_run_cmd = b.addRunArtifact(straight_prz_procs);
    new_run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        new_run_cmd.addArgs(args);
    }

    const rewrite_run_cmd = b.addRunArtifact(graveler_rewrite);
    rewrite_run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        rewrite_run_cmd.addArgs(args);
    }

    const rewrite_run_step = b.step("run-rewrite", "Run the rewrite from python to zig");
    rewrite_run_step.dependOn(&rewrite_run_cmd.step);

    const new_run_step = b.step("run-prz-procs", "Run the app with straight paralysis proc counts");
    new_run_step.dependOn(&new_run_cmd.step);
}
