const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    //const optimize = b.standardOptimizeOption(
    //.{
    //.preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast,
    //},
    //);
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    const native = b.step("native", "Builds all the executables natively");
    var native_dest = std.ArrayList([]const u8).init(b.allocator);
    defer native_dest.deinit();
    try native_dest.append(try target.query.zigTriple(b.allocator));
    try native_dest.append("bin");
    const native_dest_dir = b.pathJoin(native_dest.items);
    const native_conf = std.Build.Step.InstallArtifact.Options{
        .dest_dir = .{
            .override = .{ .custom = native_dest_dir },
        },
    };
    main_build(b, native, optimize, target, native_conf);
    main_build(b, b.getInstallStep(), optimize, target, .{});

    const all = b.step("all", "Builds all the executables against other cpus & OSes");
    const all_targets: []const std.Target.Query = &.{
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

    var all_dest = std.ArrayList([]const u8).init(b.allocator);
    defer all_dest.deinit();
    for (all_targets) |all_target| {
        all_dest.clearAndFree();
        try all_dest.append(try all_target.zigTriple(b.allocator));
        try all_dest.append("bin");

        const all_dest_dir = b.pathJoin(all_dest.items);
        const all_conf = std.Build.Step.InstallArtifact.Options{
            .dest_dir = .{
                .override = .{ .custom = all_dest_dir },
            },
        };

        main_build(b, all, optimize, b.resolveTargetQuery(all_target), all_conf);
    }

    native.dependOn(b.getInstallStep());
    all.dependOn(native);
}

pub fn main_build(
    b: *std.Build,
    s: *std.Build.Step,
    o: std.builtin.OptimizeMode,
    t: std.Build.ResolvedTarget,
    c: std.Build.Step.InstallArtifact.Options,
) void {
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

    const d1 = b.addInstallArtifact(graveler_rewrite, c);
    const d2 = b.addInstallArtifact(graveler_rewrite_mt, c);
    const d3 = b.addInstallArtifact(straight_prz_procs, c);
    const d4 = b.addInstallArtifact(straight_prz_procs_mt, c);

    s.dependOn(&d1.step);
    s.dependOn(&d2.step);
    s.dependOn(&d3.step);
    s.dependOn(&d4.step);
}
