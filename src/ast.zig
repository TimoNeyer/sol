const std = @import("std");
const Allocator = std.mem.Allocator;
const MemoryPool = std.heap.MemoryPool;
const ArrayList = std.ArrayList;
const token = @import("token.zig");

const ParsingError = error{
    UnexpectedEOF,
};

const AST = struct {
    roots: []Node,
    buffer: []token.Token,
    allocator: Allocator,
    nodeAllocator: MemoryPool(Node),
    const Node = struct { parent: usize, children: []usize, token: token.Token };

    pub fn init(tokens: []token.Token, allocator: Allocator) !AST {
        return .{
            .roots = undefined,
            .buffer = tokens,
            .allocator = allocator,
            .nodeAllocator = try MemoryPool(Node).initPreheated(allocator, tokens.len),
        };
    }
};

const ASTGenerator = struct {
    ast: AST,
    context: ArrayList(Context),
    allocator: Allocator,
    errMsg: []u8 = undefined,
    const Context = struct {
        kind: Kind,
        restricions: []Scope,
        expansions: []Scope,

        const Kind = enum {
            start,
            function,
            state,
            machine,
            block,
            inTransition,
            outTransition,
            entry,
            @"error",
            @"struct",
            @"enum",
            @"union",
            @"switch",
            @"if",
            @"while",
            @"for",
        };
    };
    const Scope = struct {
        kind: Kind,
        const Kind = enum { control_flow, builtin, global };
        const Target = struct { scope: []token.Token.Tag };
    };

    pub fn init(allocator: Allocator, tokens: []token.Token) !ASTGenerator {
        return ASTGenerator{
            .ast = try AST.init(tokens, allocator),
            .context = ArrayList(Context).initCapacity(allocator, 8),
            .allocator = allocator,
        };
    }

    fn assertCtx(self: ASTGenerator, tag: token.Token.Tag) !bool {
        if (self.context.getLastOrNull()) |ctx| {
            switch (tag) {
                .eof => return ctx.kind == Context.Kind.start,
                .r_brace => return true,
                .l_brace => {
                    for (ctx.expansions) |exp| {
                        switch (exp.kind) {
                            .control_flow => continue,
                            .global => {},
                        }
                    }
                },
            }
        } else {
            return ParsingError.UnexpectedEOF;
        }
    }

    pub fn parse(self: *ASTGenerator) !void {
        for (self.ast.buffer) |t| {
            switch (t.tag) {
                .eof => {
                    if (!self.assertCtx(.eof)) {
                        self.errMsg = try std.fmt.allocPrint(self.allocator, "Unexpected EOF, last context was type: {s}", .{@tagName(ctx.kind)});
                        return ParsingError.UnexpectedEOF;
                    } else {
                        return;
                    }
                },
                .keyword_extern, .keyword_pub, .keyword_mut => {},
            }
        }
    }
};
