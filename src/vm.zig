
const internal_type = union {
    condition: *Condition,
    boolean: bool,
    array: *Array,
    byte: u8,
    bytes16: u16,
    bytes32: u32,
    integer: u64,
    float32: f32,
    float64: f64,
    fixed_point: *Fixed_point,
    reference: *anyopaque,
    structure: type,
    enumeration: *Internal_enum,
};

const Internal_enum = struct {
    T: usize,
    values: std.StringHashMap(usize),
};

const Fixed_point = struct { value: usize, index: @bitSizeOf(usize) };

const Array = struct { size: usize, cap: usize, T: internal_type };

const Condition = struct {
    op: low_level_instruction,
    flags: u2,
    value1: *anyopaque,
    value2: *anyopaque,
    type1: internal_type,
    type2: internal_type,
};

const math_flags = enum(u2) {
    wrap = 1,
    saturate = 2,
};

fn add(T: type, a: T, b: T, flags: u2) T {
    switch (flags) {
        0 => return a + b,
        1 => return a +% b,
        2 => return a +| b,
        3 => unreachable,
    }
}

fn mul(T: type, a: T, b: T, flags: u2) T {
    switch (flags) {
        0 => return a * b,
        1 => return a *% b,
        2 => return a *| b,
        3 => unreachable,
    }
}

fn div(T: type, a: T, b: T) T {
    return a / b;
}

fn floor_div(T: type, a: T, b: T) T {
    var i: T = a;
    var c = 0;
    while (i > 0) : (i -= b) {
        c += 1;
    }
    return c;
}

fn mod(T: type, a: T, b: T) T {
    return a % b;
}

fn shift(T: type, a: T, b: T, flags: u2) T {
    switch (flags) {
        0 => return blk: {
            if (b > 0) {
                break :blk a << b;
            } else {
                break :blk a >> b;
            }
        },
        1 => return blk: {
            if (b > 0) {
                break :blk ((a << b) | (a >> (-b & @bitSizeOf(T))));
            } else {
                break :blk ((a >> b) | (a << (-b & @bitSizeOf(T))));
            }
        },
        2 => return blk: {
            if (b > 0) {
                break :blk a <<| b;
            } else {
                break :blk @max(a >> b, 1);
            }
        },
        3 => unreachable,
    }
}

fn b_and(T: type, a: T, b: T) T {
    return a & b;
}

fn b_or(T: type, a: T, b: T) T {
    return a | b;
}

fn b_xor(T: type, a: T, b: T) T {
    return a ^ b;
}

fn b_not(T: type, a: T) T {
    return ~a;
}

fn l_and(a: bool, b: bool) bool {
    return a and b;
}

fn l_or(a: bool, b: bool) bool {
    return a or b;
}

fn l_xor(a: bool, b: bool) bool {
    return a ^ b;
}

fn l_not(a: bool) bool {
    return !a;
}

fn eql(T: type, a: T, b: T) bool {
    return a == b;
}

fn leq(T: type, a: T, b: T) bool {
    return a <= b;
}

fn geq(T: type, a: T, b: T) bool {
    return a >= b;
}
