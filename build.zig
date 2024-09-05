const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    //const optimize = b.standardOptimizeOption(
    //.{
    //.preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast,
    //},
    //);
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    const just_native = b.step("native", "Builds all the executables natively");
    try build_native(b, just_native, target, optimize);

    const all = b.step(
        "all",
        "Builds all the executables against other architectures and oses (+ native) (except 32 bits and below)",
    );
    try build_all(b, all, optimize);

    b.getInstallStep().dependOn(just_native);
}

pub fn build_native(
    b: *std.Build,
    s: *std.Build.Step,
    t: std.Build.ResolvedTarget,
    o: std.builtin.OptimizeMode,
) !void {
    const graveler_rewrite = b.addExecutable(.{
        .name = "st-graveler-rewrite",
        .root_source_file = b.path("src/graveler_rewrite.zig"),
        .target = t,
        .optimize = o,
    });

    const graveler_rewrite_mt = b.addExecutable(.{
        .name = "mt-graveler-rewrite",
        .root_source_file = b.path("src/graveler_rewrite_multi_threading.zig"),
        .target = t,
        .optimize = o,
    });

    const straight_prz_procs = b.addExecutable(.{
        .name = "st-graveler-prz-procs",
        .root_source_file = b.path("src/straight_prz_procs.zig"),
        .target = t,
        .optimize = o,
    });

    const straight_prz_procs_mt = b.addExecutable(.{
        .name = "mt-graveler-prz-procs",
        .root_source_file = b.path("src/straight_prz_procs_multi_threading.zig"),
        .target = t,
        .optimize = o,
    });

    var dest = std.ArrayList([]const u8).init(b.allocator);
    defer dest.deinit();
    try dest.append(try t.query.zigTriple(b.allocator));
    try dest.append("bin");

    const dest_dir = b.pathJoin(dest.items);
    const conf = std.Build.Step.InstallArtifact.Options{
        .dest_dir = .{
            .override = .{ .custom = dest_dir },
        },
    };

    const d1 = b.addInstallArtifact(graveler_rewrite, conf);
    const d2 = b.addInstallArtifact(graveler_rewrite_mt, conf);
    const d3 = b.addInstallArtifact(straight_prz_procs, conf);
    const d4 = b.addInstallArtifact(straight_prz_procs_mt, conf);

    const isd1 = b.addInstallArtifact(graveler_rewrite, .{});
    const isd2 = b.addInstallArtifact(graveler_rewrite_mt, .{});
    const isd3 = b.addInstallArtifact(straight_prz_procs, .{});
    const isd4 = b.addInstallArtifact(straight_prz_procs_mt, .{});

    s.dependOn(&d1.step);
    s.dependOn(&d2.step);
    s.dependOn(&d3.step);
    s.dependOn(&d4.step);

    s.dependOn(&isd1.step);
    s.dependOn(&isd2.step);
    s.dependOn(&isd3.step);
    s.dependOn(&isd4.step);
}

pub fn build_all(b: *std.Build, s: *std.Build.Step, o: std.builtin.OptimizeMode) !void {
    const targets: []const std.Target.Query = &.{
        //.{},
        .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .{ .cpu_arch = .x86_64, .os_tag = .macos },

        .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu },
        .{ .cpu_arch = .arm, .os_tag = .linux, .abi = .gnu },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
        .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .gnu },

        .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .arm, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .musl },

        .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .android },
        .{ .cpu_arch = .arm, .os_tag = .linux, .abi = .android },

        .{ .cpu_arch = .x86_64, .os_tag = .windows },
        .{ .cpu_arch = .x86, .os_tag = .windows },
    };

    for (targets) |target| {
        const graveler_rewrite = b.addExecutable(.{
            .name = "st-graveler-rewrite",
            .root_source_file = b.path("src/graveler_rewrite.zig"),
            .target = b.resolveTargetQuery(target),
            .optimize = o,
        });

        const graveler_rewrite_mt = b.addExecutable(.{
            .name = "mt-graveler-rewrite",
            .root_source_file = b.path("src/graveler_rewrite_multi_threading.zig"),
            .target = b.resolveTargetQuery(target),
            .optimize = o,
        });

        const straight_prz_procs = b.addExecutable(.{
            .name = "st-graveler-prz-procs",
            .root_source_file = b.path("src/straight_prz_procs.zig"),
            .target = b.resolveTargetQuery(target),
            .optimize = o,
        });

        const straight_prz_procs_mt = b.addExecutable(.{
            .name = "mt-graveler-prz-procs",
            .root_source_file = b.path("src/straight_prz_procs_multi_threading.zig"),
            .target = b.resolveTargetQuery(target),
            .optimize = o,
        });

        var dest = std.ArrayList([]const u8).init(b.allocator);
        defer dest.deinit();
        try dest.append(try target.zigTriple(b.allocator));
        try dest.append("bin");

        const dest_dir = b.pathJoin(dest.items);
        const conf = std.Build.Step.InstallArtifact.Options{
            .dest_dir = .{
                .override = .{ .custom = dest_dir },
            },
        };

        const d1 = b.addInstallArtifact(graveler_rewrite, conf);
        const d2 = b.addInstallArtifact(graveler_rewrite_mt, conf);
        const d3 = b.addInstallArtifact(straight_prz_procs, conf);
        const d4 = b.addInstallArtifact(straight_prz_procs_mt, conf);

        s.dependOn(&d1.step);
        s.dependOn(&d2.step);
        s.dependOn(&d3.step);
        s.dependOn(&d4.step);
    }
}
