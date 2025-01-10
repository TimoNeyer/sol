const std = @import("std");
const Allocator = std.mem.Allocator;
const MemoryPool = std.heap.MemoryPool;
const token = @import("token.zig");

const AST = struct {
    roots: []Node,
    buffer: *[]token.Token,
    allocator: Allocator,
    nodeAllocator: MemoryPool(Node),
    const Node = struct { parent: usize, children: []usize, token: token.Token };

    pub fn init(tokens: *[]token.Token, allocator: Allocator) AST {
        return .{
            .roots = undefined,
            .buffer = tokens,
            .allocator = allocator,
            .nodeAllocator = try MemoryPool(Node).initPreheated(allocator, tokens.len),
        };
    }

    const State = union {
        start: void,
        state: enum {
            state,
            entry,
        },
        function: enum { @"pub", @"fn", @"extern" },
    };

    pub fn generate(self: *AST) !void {
        for (self.buffer) |t| {
            _ = t;
        }
    }
};
