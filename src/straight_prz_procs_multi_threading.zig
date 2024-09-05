const std = @import("std");

const ATTEMPTS: u64 = 1_000_000_000;

pub fn main() !void {
    const start = try std.time.Instant.now();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // Initializing multithreading
    const cpu_count: usize = try std.Thread.getCpuCount();

    // + 1 just in case that dividing the total attempt count doesn't really
    // work out to be an even number
    const attempts_per_thread: u64 = (ATTEMPTS / cpu_count) + 1;
    var handles = std.ArrayList(std.Thread).init(gpa.allocator());
    defer handles.deinit();

    var highest = try std.ArrayList(u64).initCapacity(gpa.allocator(), cpu_count);
    highest.expandToCapacity();
    @memset(highest.items, 0);
    defer highest.deinit();

    try print("Starting {} battles to see how many paralysis procs in a row we can get\r\n", .{ATTEMPTS});
    try print("Now doing {} iterations per thread (total: {} threads)\r\n", .{ attempts_per_thread, cpu_count });

    for (0..cpu_count) |cpu|
        try handles.insert(cpu, try std.Thread.spawn(.{}, loop, .{ cpu, attempts_per_thread, &highest.items }));

    for (handles.items) |handle|
        handle.join();

    var highest_roll: u64 = 0;
    for (highest.items) |h| {
        if (highest_roll < h) {
            highest_roll = h;
        }
    }

    const end = try std.time.Instant.now();
    // It was in nano seconds soo
    const elapsed = @as(
        f128,
        @floatFromInt(end.since(start)),
    ) / @as(
        f128,
        @floatFromInt(1_000_000_000),
    );
    try print("\nHighest straight paralysis proc count: {}\r\n", .{highest_roll});
    try print("Done! {d:9.5} seconds has elapsed\r\n", .{elapsed});
}

pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try bw.flush();
}

pub fn loop(thread_id: usize, attempt_count: u64, highest: *[]u64) !void {
    const seed: u64 = @bitCast(std.time.timestamp());
    var prng = std.rand.DefaultPrng.init(seed * (thread_id + 1));

    var attempt: u64 = 1;
    while (attempt <= attempt_count) {
        var straight_prz_procs: u64 = 0;

        // See if the random 0-3 (inclusive) lands on a 0
        // Simulating the 25% change of move paralysis
        var was_prz = (prng.random().int(usize) % 4 == 0);
        while (was_prz) {
            straight_prz_procs += 1;
            was_prz = (prng.random().int(usize) % 4 == 0);
        }

        if (attempt % (attempt_count / 1_000) == 0) {
            try print("T{:03} - Attempt: {:12}\r", .{ thread_id, attempt + 1 });
        }

        if (highest.*[thread_id] < straight_prz_procs) {
            highest.*[thread_id] = straight_prz_procs;
            try print(
                "T{:03} - Attempt: {:12} | Highest Straight Paralysis Procs: {}\r\n",
                .{
                    thread_id,
                    attempt + 1,
                    straight_prz_procs,
                },
            );
        }

        attempt += 1;
    }
}
