const std = @import("std");
const token = @import("token.zig");

const CompileError = error{
    UnexpectedEOF,
    SyntaxError,
};

const high_level_instruction = enum {
    transition,
    execute,
    assign,
    evaluate,
    throw_error,
    _switch,
    _if,
    _for,
    _while,
    allocate,
    type_check,
    import,
    eval_optional,
    dereference,
    get_reference,
    get_struct_field,
    capture,
};

const low_level_instruction = enum {
    add,
    mul,
    div,
    floor_div,
    mod,
    shift,
    b_and,
    b_or,
    b_xor,
    b_not,
    l_and,
    l_or,
    l_xor,
    l_not,
    eql,
    leq,
    geq,
    _if,
    jump,
    call,
    _return,
    load,
    store,
    move,
    get_field_offset,
    alloc,
    dealloc,
    cast,
    throw,
    handle_err,
    loop,
    _break,
    _continue,
};

const comparators = enum { boolean, truthy, optional, expression, errorunion };

const type_enum = enum { null, str, condition, boolean, array, byte, byte16, byte32, byte64, integer, float32, float64, fixed_point, reference, structure, enumeration, modifier };

const internal_type = union {
    condition: *Condition,
    boolean: bool,
    array: *Array,
    byte: u8,
    byte16: u16,
    byte32: u32,
    byte64: u64,
    integer: i64,
    float32: f32,
    float64: f64,
    fixed_point: *Fixed_point,
    reference: *Reference,
    structure: *Structure,
    enumeration: *Internal_enum,
    modifier: *Modifier,
};

const Modifier = struct {
    tag: token.Token.Tag,
};

const Structure = struct {
    bitsize: usize,
    fields: std.StringHashMap(internal_type),
    values: std.StringHashMap(*align(8) anyopaque),
};

const Internal_enum = struct {
    T: usize,
    values: std.StringHashMap(usize),
};

const Fixed_point = struct { value: u64, index: u8 };

const Array = struct { size: usize, cap: usize, T: internal_type };

const Reference = struct {
    ptr: usize,
    T: internal_type,
};

const Condition = struct {
    op: low_level_instruction,
    value: *anyopaque,
    T: internal_type,
};

const Context_type = enum { state, function };

const Context_flags = struct {
    map: std.HashMap(token.Token.Tag, void, struct {
        const Self = @This();
        pub fn hash(self: *Self, t: token.Token.Tag) u64 {
            _ = self;
            return @intFromEnum(t);
        }
        pub fn eql(self: *Self, a: token.Token.Tag, b: token.Token.Tag) bool {
            _ = self;
            return a == b;
        }
    }, 80),
    pub fn get(self: *Context_flags, t: token.Token.Tag) bool {
        if (self.map.get(t)) |_| {
            return true;
        } else {
            return false;
        }
    }
    pub fn set(self: *Context_flags, t: token.Token.Tag) !void {
        try self.map.put(t, {});
    }
};

const Context = struct {
    T: Context_type,
    allocator: *std.mem.Allocator,
    fields: std.StringHashMap(internal_type),
    values: std.StringHashMap(*align(8) anyopaque),
    flags: Context_flags,

    pub fn addField(self: *Context, name: []u8, T: type_enum, value: *align(8) ?anyopaque) !void {
        try self.fields.put(name, T);
        try self.fields.put(name, value);
    }
};

const flag_ctx = struct {
    pub fn hash(self: *flag_ctx, t: token.Token.Tag) u64 {
        _ = self;
        return @intFromEnum(t);
    }
    pub fn eql(self: *flag_ctx, a: token.Token.Tag, b: token.Token.Tag) bool {
        _ = self;
        return a == b;
    }
};

const ctx_lookup_ctx = struct {
    pub fn hash(self: *ctx_lookup_ctx, a: u64) u64 {
        _ = self;
        return a;
    }
    pub fn eql(self: *ctx_lookup_ctx, a: u64, b: u64) bool {
        _ = self;
        return a == b;
    }
};

fn gen_ctx(t: Context_type, allocator: *std.mem.Allocator) Context {
    return Context{
        .T = t,
        .allocator = allocator,
        .fields = std.StringHashMap(internal_type).init(allocator.*),
        .values = std.StringHashMap(*align(8) anyopaque).init(allocator.*),
        .flags = std.HashMap(token.Token.Tag, void, flag_ctx, 80).init(allocator),
    };
}


fn parse_type(self: *AST) !type_enum {
    var current = try self.get();
    const state = enum {
        start,
        type,
        @"struct",
        array,
        string
    };
    switch (current.tag) {
        .identifier => {
            switch (current.get_str(self.s_buffer)) {

            }
        }
    }
    return .null;
}

const AST = struct {
    allocator: std.mem.Allocator,
    root: *AST_Node,
    ctx_lookup: std.HashMap(u64, u64, ctx_lookup_ctx, 80),
    contexts: std.ArrayList(Context),
    ctx_stack: std.ArrayList(*Context),
    current_ctx: *Context,
    state: State = .start,
    index: usize = 0,
    t_buffer: []token.Token,
    s_buffer: []u8,
    Errmsg: [:0]u8 = "",

    const AST_Node = struct {
        T: internal_type,
        value: *align(8) anyopaque,
        children: []AST_Node,
        parent: *AST_Node,
        ctx: *Context,
    };

    const State = enum {
        start,
        keyword_state,
        state,
        keyword_pub,
        keyword_export,
        keyword_fn,
        function,
    };

    pub fn init(allocator: std.mem.Allocator, buffer: []token.Token) !AST {
        const base_ctx = try allocator.create(Context);
        base_ctx.* = gen_ctx(.base, allocator);
        const root = try allocator.create(AST_Node);
        root.* = AST_Node{ .T = .eof, .value = null, .children = []AST_Node{}, .parent = root, .ctx = base_ctx };
        return AST{ .allocator = allocator, .root = root, .ctx_stack = try std.ArrayList(*Context).init(allocator), .ctx_lookup = try std.HashMap(u64, []u8, ctx_lookup_ctx, 80).init(allocator), .current_ctx = base_ctx, .t_buffer = buffer };
    }

    fn get(self: *AST) !token.Token {
        if (self.t_buffer.len == self.index + 1) {
            return CompileError.UnexpectedEOF;
        } else {
            self.index += 1;
            return self.t_buffer[self.index];
        }
    }

    fn seek(self: *AST) !token.Token {
        if (self.t_buffer.len >= self.index + 1) {
            return CompileError.UnexpectedEOF;
        } else {
            return self.t_buffer[self.index + 1];
        }
    }

    fn add_ctx(self: *AST, t: Context_type, tok: token.Token) !void {
        self.current_ctx = try self.contexts.addOne(gen_ctx(t, self.allocator));
        self.index += 1;
        try self.ctx_lookup.put(self.index + 1, tok.get_str(self.s_buffer));
        try self.ctx_stack.append(self.current_ctx);
    }

    fn parse_function(self: *AST) !void {
        const name = try self.get();
        if (name.tag != .identifier) {
            self.Errmsg = "after fn write the name of the function";
            return CompileError.SyntaxError;
        }
        self.add_ctx(.function, name);
        if ((try self.get()).tag != .l_paren) {
            self.Errmsg = "after function name use parentheses to define the input parameters";
            return CompileError.SyntaxError;
        }
        var current = try self.get();
        const state = enum { name, type, start };
        var cstate: state = .start;
        var ctype: type_enum = .null;
        while (current.tag != .eof) {
            switch (current.tag) {
                .r_paren => break,
                .comma => cstate = .type,
                else => switch (cstate) {
                    .name => {
                        if (current.tag != .identifier) {
                            self.Errmsg = "Unable to parse function parameters";
                            return CompileError.SyntaxError;
                        }
                        const str = current.get_str(self.s_buffer);
                        const ptr = try self.allocator.create([str.len]u8);
                        ptr.* = str;
                        if (ctype) |t| {
                            try self.current_ctx.addField(str, t, null);
                        } else {
                            self.Errmsg = "unable to get type of parameter";
                            return CompileError.SyntaxError;
                        }
                        current = try self.get();
                    },
                    .type => {
                        ctype = try parse_type();
                    },
                    .start => {
                        cstate = .name;
                        current = try self.get();
                    },
                },
            }
        }
    }


    pub fn generate(self: *AST) !usize {
        while ((try self.seek()).tag != .eof) {
            switch (self.state) {
                .keyword_state => {},
                .keyword_fn => {},
                .keyword_pub => {
                    switch (try self.seek().tag) {
                        .keyword_fn => {
                            self.state = .keyword_fn;
                            try self.current_ctx.flags.set(.keyword_pub);
                        },
                        .keyword_export => {
                            self.state = .keyword_export;
                            if (self.current_ctx.T != .function) {
                                self.current_ctx = try self.contexts.addOne(gen_ctx(.function, self.allocator));
                            }
                            try self.current_ctx.flags.set(.keyword_export);
                        },
                    }
                },
            }
        }
    }
};
