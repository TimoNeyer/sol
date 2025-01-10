const std = @import("std");
const token = @import("token.zig");

const State = struct {
    entry: Entry,
    transitions: []Transition,
    vars: []Variable,
};

const Instruction = struct {
    fp: *anyopaque,
    argc: u8,
    argv: []u8,
    args_bytelen: []usize,
};

const mutexType = enum {
    rw,
    r,
    none,
};

const Comparators = enum { boolean, truthy, optional, expression, errorunion };

const TypesEnum = enum { condition, boolean, array, byte, byte16, byte32, byte64, integer, float32, float64, fixed_point, reference, structure, enumeration, modifier };

const Types = union(TypesEnum) {
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
    enumeration: *Enum,
    modifier: *Modifier,
    custom: Type,
};

const Modifier = struct {
    tag: token.Token.Tag,
};

const Structure = struct {
    bitsize: usize,
    fields: std.StringHashMap(Types),
    values: std.StringHashMap(*align(8) anyopaque),
};

const Enum = struct {
    T: usize,
    values: std.StringHashMap(usize),
};

const Fixed_point = struct { value: u64, index: u64 };

const Array = struct { size: usize, T: Types };

const Reference = struct {
    ptr: usize,
    T: Types,
};

const Condition = struct {
    op: []Evaluation,
    value: *anyopaque,
    T: Types,
};

const Variable = struct {
    type: Types,
    alignment: u7,
    mutex: mutexType,
};

const Evaluation = struct {
    T: Types,
    evaluator: ?*anyopaque,
    fallback: *anyopaque,
};

const Type = struct {
    alignment: u7,
    length: usize,
};

const Block = struct {
    content: []Expression,
};

const Evaluator = struct {
    T: Types,
    pub fn geq(a: Types, b: Types) bool {
        _ = a;
        _ = b;
        return false;
    }
    pub fn leq(a: Types, b: Types) bool {
        _ = a;
        _ = b;
        return false;
    }
    pub fn eql(a: Types, b: Types) bool {
        _ = a;
        _ = b;
        return false;
    }
    pub fn invert(a: Types) Types {
        return a;
    }
};

const Error = struct {
    identifier: usize,
    name: []u8,
};

const ErrorUnion = struct {
    identifier: usize,
    name: []u8,
    errors: []Error,
};

const Expression = struct { tokens: []token.Token };

const Function = struct {
    argc: usize,
    argvTypes: []Types,
    returnType: Types,
    returnError: ?union { single: Error, set: ErrorUnion },
};

const Entry = struct {
    parent: *State,
    src: ?*State,
    content: Block,
};

const Transition = struct {
    src: *State,
    dst: *State,
};
