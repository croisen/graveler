const std = @import("std");

const ATTEMPTS: u64 = 1_000_000_000;
const ROLLS: u64 = 231;

pub fn main() !void {
    const start = try std.time.Instant.now();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // Initializing multithreading
    const cpu_count: usize = @intCast(try std.Thread.getCpuCount());

    // + 1 just in case that dividing the total attempt count doesn't really
    // work out to be an even number
    const attempts_per_thread: u64 = (ATTEMPTS / cpu_count) + 1;
    var handles = std.ArrayList(std.Thread).init(gpa.allocator());
    defer handles.deinit();

    var highest = try std.ArrayList(u8).initCapacity(gpa.allocator(), cpu_count);
    highest.expandToCapacity();
    @memset(highest.items, 0);
    defer highest.deinit();

    try print(
        "Starting {} iterations of {} dice rolls to see how many lands on 1\r\n",
        .{
            ATTEMPTS,
            ROLLS,
        },
    );
    try print(
        "Now doing {} iterations per thread (total: {} threads)\r\n",
        .{
            attempts_per_thread,
            cpu_count,
        },
    );

    for (0..cpu_count) |cpu|
        try handles.insert(
            cpu,
            try std.Thread.spawn(
                .{},
                loop,
                .{ cpu, attempts_per_thread, &highest.items },
            ),
        );

    for (handles.items) |handle|
        handle.join();

    var highest_roll: u8 = 0;
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
    try print("\nHighest count of rolls that landed on 1: {}\r\n", .{highest_roll});
    try print("Done! {d:9.5} seconds has elapsed\r\n", .{elapsed});
}

pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try bw.flush();
}

pub fn loop(thread_id: usize, attempt_count: u64, highest: *[]u8) !void {
    const seed: u64 = @bitCast(std.time.timestamp());
    var prng = std.rand.DefaultPrng.init(seed * (thread_id + 1));

    var items: [4]u8 = undefined;
    var attempt: u64 = 1;
    while (attempt <= attempt_count) {
        @memset(&items, 0);
        for (0..ROLLS) |_| {
            const idx = prng.random().int(usize) % 4; // Limit it to 0-3
            items[idx] += 1;
        }

        if (attempt % (attempt_count / 1_000) == 0) {
            try print("T{:03} - Attempt: {:12}\r", .{ thread_id, attempt + 1 });
        }

        if (highest.*[thread_id] < items[0]) {
            highest.*[thread_id] = items[0];
            try print(
                "T{:03} - Attempt: {:12} | Rolls: {any:3}\r\n",
                .{
                    thread_id,
                    attempt + 1,
                    items,
                },
            );
        }

        attempt += 1;
    }
}
