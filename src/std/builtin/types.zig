const std = @import("std");
const ir = @import("../../intermediate2.zig");

const int = struct {
    alignment: u7 = 8,
    length: usize = @bitSizeOf(usize),

    pub fn @"type"(self: *int) ir.Type {
        return .{
            .alignment = self.alignment,
            .length = self.length,
        };
    }

    pub fn evaluator(self: *int) ir.Evaluator {
        _ = self;
        return .{
            .T = .integer,
        };
    }

    fn geq(a: ir.Types, b: ir.Types) bool {}
};
