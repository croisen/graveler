const std = @import("std");

const ATTEMPTS = 1_000_000_000;
const ROLLS = 231;

const Highest = struct {
    lock: std.Thread.RwLock = .{},
    count: u8 = 0,

    fn set(self: *Highest, c: u8) void {
        self.lock.lock();
        defer self.lock.unlock();

        self.count = c;
    }

    fn get(self: *Highest) u8 {
        self.lock.lockShared();
        defer self.lock.unlockShared();

        return self.count;
    }
};

pub fn main() !void {
    const start = try std.time.Instant.now();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // Initializing multithreading
    const cpu_count = try std.Thread.getCpuCount();

    // + 1 just in case that dividing the total attempt count doesn't really
    // work out to be an even number
    const attempts_per_thread = (ATTEMPTS / cpu_count) + 1;
    var handles = std.ArrayList(std.Thread).init(gpa.allocator());
    defer handles.deinit();

    var highest: Highest = .{};
    try print("Starting {} iterations of {} dice rolls to see how many lands on 1\r\n", .{ ATTEMPTS, ROLLS });
    try print("Now doing {} iterations per thread (total: {} threads)\r\n", .{ attempts_per_thread, cpu_count });

    for (0..cpu_count) |cpu|
        try handles.insert(cpu, try std.Thread.spawn(.{}, loop, .{ cpu, attempts_per_thread, &highest }));

    for (handles.items) |handle|
        handle.join();

    const end = try std.time.Instant.now();
    // It was in nano seconds soo
    const elapsed = @as(f128, @floatFromInt(end.since(start))) / @as(f128, @floatFromInt(1_000_000_000));
    try print("\nHighest count of rolls that landed on 1: {}\r\n", .{highest.get()});
    try print("Done! {d:9.5} seconds has elapsed\r\n", .{elapsed});
}

pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try bw.flush();
}

pub fn loop(thread_id: u64, attempt_count: u64, highest: *Highest) !void {
    const seed: u64 = @bitCast(std.time.timestamp());
    var prng = std.rand.DefaultPrng.init(seed * (thread_id + 1));

    var items: [4]u8 = undefined;
    for (1..attempt_count + 1) |attempt| {
        @memset(&items, 0);
        for (0..ROLLS) |_| {
            const idx = prng.next() % 4; // Limit it to 0-3
            items[idx] += 1;
        }

        if (attempt % 100_000 == 0) {
            try print("T{:03} - Attempt: {:12}\r", .{ thread_id, attempt });
        }

        if (items[0] > highest.get()) {
            highest.set(items[0]);
            try print("T{:03} - Attempt: {:12} | Rolls: {any:3}\r\n", .{ thread_id, attempt, items });
        }
    }
}
