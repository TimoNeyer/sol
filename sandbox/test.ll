@b = global i32 0
@a = global i32 0

define void @main() {
entry:
    %b_val = load i32, i32* @b
    %sum = add i32 %b_val, 2
    store i32 %sum, i32* @a
    ret void
}
