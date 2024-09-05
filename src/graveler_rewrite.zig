const std = @import("std");

const ATTEMPTS: u64 = 1_000_000_000;
const ROLLS: u64 = 231;

pub fn main() !void {
    const start = try std.time.Instant.now();

    const seed: u64 = @bitCast(std.time.timestamp());
    var prng = std.rand.DefaultPrng.init(seed);

    var highest: u8 = 0;
    var items: [4]u8 = undefined;

    try print(
        "Starting {} iterations of {} dice rolls to see how many lands on 1\n",
        .{
            ATTEMPTS,
            ROLLS,
        },
    );
    for (0..ATTEMPTS) |attempt| {
        @memset(&items, 0);
        for (0..ROLLS) |_| {
            const idx = prng.random().int(u8) % 4; // Limit it to 0-3
            items[idx] += 1;
        }

        if (attempt % (ATTEMPTS / 1_000) == 0) {
            try print("- Attempt: {:12}\r", .{attempt + 1});
        }

        if (items[0] > highest) {
            highest = items[0];
            try print(
                "- Attempt: {:12} | Rolls: {any:3}\r\n",
                .{
                    attempt + 1,
                    items,
                },
            );
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
    try print("\nHighest count of rolls that landed on 1: {}\r\n", .{highest});
    try print("Done! {d:9.5} seconds has elapsed\r\n", .{elapsed});
}

pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try bw.flush();
}
