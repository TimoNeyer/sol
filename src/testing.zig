const std = @import("std");

pub fn main() !void {
    const d01 = 10;
    std.debug.print("{b}: {b}", .{ d01, @sizeOf(usize) });
}
