const std = @import("std");

const mutexType = enum {
    rw,
    r,
    none,
};

/// necessary
const Construct = struct {
    bytelen: usize,
    alignment: u7,
    mutex: mutexType,
};
