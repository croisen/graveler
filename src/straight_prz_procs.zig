const std = @import("std");

const ATTEMPTS = 1_000_000_000;

pub fn main() !void {
    const start = try std.time.Instant.now();

    const seed: u64 = @bitCast(std.time.timestamp());
    var prng = std.rand.DefaultPrng.init(seed);

    var highest: u64 = 0;

    try print("Starting {} battles to see how many paralysis procs in a row we can get\n", .{ATTEMPTS});
    for (1..ATTEMPTS + 1) |attempt| {
        var straight_prz_procs: u64 = 0;

        // See if the random 0-3 (inclusive) lands on a 0
        // Simulating the 25% change of move paralysis
        var was_prz = (prng.random().int(u64) % 4 == 0);
        while (was_prz) {
            straight_prz_procs += 1;
            was_prz = (prng.random().int(u64) % 4 == 0);
        }

        if (attempt % (ATTEMPTS / 1_000) == 0) {
            try print("- Attempt: {:12}\r", .{attempt});
        }

        if (highest < straight_prz_procs) {
            highest = straight_prz_procs;
            try print("- Attempt: {:12} | Highest Straight Paralysis Procs: {}\r\n", .{ attempt, straight_prz_procs });
        }
    }

    const end = try std.time.Instant.now();
    // It was in nano seconds soo
    const elapsed = @as(f128, @floatFromInt(end.since(start))) / @as(f128, @floatFromInt(1_000_000_000));
    try print("\nHighest straight paralysis proc count: {}\r\n", .{highest});
    try print("Done! {d:9.5} seconds has elapsed\r\n", .{elapsed});
}

pub fn print(comptime format: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(format, args);
    try bw.flush();
}
