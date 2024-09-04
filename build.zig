const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const graveler_rewrite = b.addExecutable(.{
        .name = "graveler-rewrite",
        .root_source_file = b.path("src/graveler_rewrite.zig"),
        .target = target,
        .optimize = optimize,
    });

    const graveler_rewrite_mt = b.addExecutable(.{
        .name = "graveler-rewrite-mt",
        .root_source_file = b.path("src/graveler_rewrite_multi_threading.zig"),
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
    b.installArtifact(graveler_rewrite_mt);
    b.installArtifact(straight_prz_procs);

    const rewrite_run_cmd = b.addRunArtifact(graveler_rewrite);
    rewrite_run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        rewrite_run_cmd.addArgs(args);
    }

    const rewrite_run_cmd_mt = b.addRunArtifact(graveler_rewrite_mt);
    rewrite_run_cmd_mt.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        rewrite_run_cmd_mt.addArgs(args);
    }

    const new_run_cmd = b.addRunArtifact(straight_prz_procs);
    new_run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        new_run_cmd.addArgs(args);
    }

    const rewrite_run_step = b.step("run-rewrite", "Run the rewrite from python to zig");
    rewrite_run_step.dependOn(&rewrite_run_cmd.step);

    const rewrite_run_step_mt = b.step("run-rewrite-mt", "Run the rewrite from python to zig (multi-threading ver)");
    rewrite_run_step_mt.dependOn(&rewrite_run_cmd_mt.step);

    const new_run_step = b.step("run-prz-procs", "Run the app with straight paralysis proc counts");
    new_run_step.dependOn(&new_run_cmd.step);
}
