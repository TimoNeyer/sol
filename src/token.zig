const std = @import("std");
const io = std.io;

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize,
    };

    pub fn get_str(self: *Token, buffer: []u8) []u8 {
        return buffer[self.loc.start..self.loc.end];
    }

    pub const keywords = std.StaticStringMap(Tag).initComptime(.{
        .{ "break", .keyword_break },
        .{ "catch", .keyword_catch },
        .{ "const", .keyword_const },
        .{ "continue", .keyword_continue },
        .{ "defer", .keyword_defer },
        .{ "else", .keyword_else },
        .{ "enum", .keyword_enum },
        .{ "errdefer", .keyword_errdefer },
        .{ "error", .keyword_error },
        .{ "fn", .keyword_fn },
        .{ "for", .keyword_for },
        .{ "if", .keyword_if },
        .{ "orelse", .keyword_orelse },
        .{ "pub", .keyword_pub },
        .{ "return", .keyword_return },
        .{ "state", .keyword_state },
        .{ "struct", .keyword_struct },
        .{ "switch", .keyword_switch },
        .{ "try", .keyword_try },
        .{ "union", .keyword_union },
        .{ "var", .keyword_var },
        .{ "volatile", .keyword_volatile },
        .{ "while", .keyword_while },
        .{ "entry", .keyword_entry },
        .{ "interface", .keyword_interface },
    });

    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }

    pub const Tag = enum {
        invalid,
        invalid_periodasterisks,
        identifier,
        keyword_entry,
        keyword_interface,
        type,
        string_literal,
        multiline_string_literal_line,
        char_literal,
        eof,
        builtin,
        bang,
        pipe,
        pipe_pipe,
        pipe_equal,
        equal,
        equal_equal,
        equal_angle_bracket_right,
        bang_equal,
        l_paren,
        r_paren,
        semicolon,
        percent,
        percent_equal,
        l_brace,
        r_brace,
        l_bracket,
        r_bracket,
        period,
        period_asterisk,
        ellipsis2,
        ellipsis3,
        caret,
        caret_equal,
        caret_caret,
        plus,
        plus_plus,
        plus_equal,
        plus_percent,
        plus_percent_equal,
        plus_pipe,
        plus_pipe_equal,
        minus,
        minus_equal,
        minus_percent,
        minus_percent_equal,
        minus_pipe,
        minus_pipe_equal,
        asterisk,
        asterisk_equal,
        asterisk_asterisk,
        asterisk_percent,
        asterisk_percent_equal,
        asterisk_pipe,
        asterisk_pipe_equal,
        arrow,
        colon,
        slash,
        slash_equal,
        slash_percent,
        slash_precent_equal,
        comma,
        ampersand,
        ampersand_equal,
        ampersand_ampersand,
        question_mark,
        angle_bracket_left,
        angle_bracket_left_equal,
        angle_bracket_angle_bracket_left,
        angle_bracket_angle_bracket_left_equal,
        angle_bracket_angle_bracket_left_pipe,
        angle_bracket_angle_bracket_left_pipe_equal,
        angle_bracket_right,
        angle_bracket_right_equal,
        angle_bracket_angle_bracket_right,
        angle_bracket_angle_bracket_right_equal,
        tilde,
        number_literal,
        doc_comment,
        container_doc_comment,
        keyword_break,
        keyword_catch,
        keyword_const,
        keyword_continue,
        keyword_defer,
        keyword_else,
        keyword_enum,
        keyword_errdefer,
        keyword_error,
        keyword_fn,
        keyword_for,
        keyword_if,
        keyword_orelse,
        keyword_pub,
        keyword_return,
        keyword_state,
        keyword_struct,
        keyword_switch,
        keyword_test,
        keyword_try,
        keyword_union,
        keyword_var,
        keyword_volatile,
        keyword_while,

        pub fn lexeme(tag: Tag) ?[]const u8 {
            return switch (tag) {
                .invalid,
                .identifier,
                .string_literal,
                .multiline_string_literal_line,
                .char_literal,
                .eof,
                .builtin,
                .number_literal,
                .doc_comment,
                .container_doc_comment,
                => null,

                .invalid_periodasterisks => ".**",
                .bang => "!",
                .pipe => "|",
                .pipe_pipe => "||",
                .pipe_equal => "|=",
                .equal => "=",
                .equal_equal => "==",
                .equal_angle_bracket_right => "=>",
                .bang_equal => "!=",
                .l_paren => "(",
                .r_paren => ")",
                .semicolon => ";",
                .percent => "%",
                .percent_equal => "%=",
                .l_brace => "{",
                .r_brace => "}",
                .l_bracket => "[",
                .r_bracket => "]",
                .period => ".",
                .period_asterisk => ".*",
                .ellipsis2 => "..",
                .ellipsis3 => "...",
                .caret => "^",
                .caret_equal => "^=",
                .caret_caret => "^^",
                .plus => "+",
                .plus_plus => "++",
                .plus_equal => "+=",
                .plus_percent => "+%",
                .plus_percent_equal => "+%=",
                .plus_pipe => "+|",
                .plus_pipe_equal => "+|=",
                .minus => "-",
                .minus_equal => "-=",
                .minus_percent => "-%",
                .minus_percent_equal => "-%=",
                .minus_pipe => "-|",
                .minus_pipe_equal => "-|=",
                .asterisk => "*",
                .asterisk_equal => "*=",
                .asterisk_asterisk => "**",
                .asterisk_percent => "*%",
                .asterisk_percent_equal => "*%=",
                .asterisk_pipe => "*|",
                .asterisk_pipe_equal => "*|=",
                .arrow => "->",
                .colon => ":",
                .slash => "/",
                .slash_equal => "/=",
                .slash_percent => "/%",
                .slash_precent_equal => "/%=",
                .comma => ",",
                .ampersand => "&",
                .ampersand_equal => "&=",
                .ampersand_ampersand => "&&",
                .question_mark => "?",
                .angle_bracket_left => "<",
                .angle_bracket_left_equal => "<=",
                .angle_bracket_angle_bracket_left => "<<",
                .angle_bracket_angle_bracket_left_equal => "<<=",
                .angle_bracket_angle_bracket_left_pipe => "<<|",
                .angle_bracket_angle_bracket_left_pipe_equal => "<<|=",
                .angle_bracket_right => ">",
                .angle_bracket_right_equal => ">=",
                .angle_bracket_angle_bracket_right => ">>",
                .angle_bracket_angle_bracket_right_equal => ">>=",
                .tilde => "~",
                .keyword_break => "break",
                .keyword_catch => "catch",
                .keyword_const => "const",
                .keyword_continue => "continue",
                .keyword_defer => "defer",
                .keyword_else => "else",
                .keyword_enum => "enum",
                .keyword_errdefer => "errdefer",
                .keyword_error => "error",
                .keyword_fn => "fn",
                .keyword_for => "for",
                .keyword_if => "if",
                .keyword_orelse => "orelse",
                .keyword_pub => "pub",
                .keyword_return => "return",
                .keyword_state => "state",
                .keyword_struct => "struct",
                .keyword_switch => "switch",
                .keyword_test => "test",
                .keyword_try => "try",
                .keyword_union => "union",
                .keyword_var => "var",
                .keyword_volatile => "volatile",
                .keyword_while => "while",
            };
        }

        pub fn symbol(tag: Tag) []const u8 {
            return tag.lexeme() orelse switch (tag) {
                .invalid => "invalid token",
                .identifier => "an identifier",
                .string_literal, .multiline_string_literal_line => "a string literal",
                .char_literal => "a character literal",
                .eof => "EOF",
                .builtin => "a builtin function",
                .number_literal => "a number literal",
                .state => "a defined state",
                .doc_comment, .container_doc_comment => "a document comment",
                else => unreachable,
            };
        }
    };
};

pub const Tokenizer = struct {
    buffer: [:0]const u8,
    index: usize,

    /// For debugging purposes.
    pub fn dump(self: *Tokenizer, token: *const Token) void {
        std.debug.print("{s} \"{s}\"\n", .{ @tagName(token.tag), self.buffer[token.loc.start..token.loc.end] });
    }

    pub fn init(buffer: [:0]const u8) Tokenizer {
        // Skip the UTF-8 BOM if present.
        return .{
            .buffer = buffer,
            .index = if (std.mem.startsWith(u8, buffer, "\xEF\xBB\xBF")) 3 else 0,
        };
    }

    const State = enum {
        start,
        expect_newline,
        identifier,
        builtin,
        string_literal,
        string_literal_backslash,
        multiline_string_literal_line,
        char_literal,
        char_literal_backslash,
        backslash,
        equal,
        bang,
        pipe,
        minus,
        minus_percent,
        minus_pipe,
        asterisk,
        asterisk_percent,
        asterisk_pipe,
        slash,
        slash_percent,
        line_comment_start,
        line_comment,
        doc_comment_start,
        doc_comment,
        int,
        int_exponent,
        int_period,
        float,
        float_exponent,
        ampersand,
        caret,
        percent,
        plus,
        plus_percent,
        plus_pipe,
        angle_bracket_left,
        angle_bracket_angle_bracket_left,
        angle_bracket_angle_bracket_left_pipe,
        angle_bracket_right,
        angle_bracket_angle_bracket_right,
        period,
        period_2,
        period_asterisk,
        saw_at_sign,
        invalid,
    };

    /// After this returns invalid, it will reset on the next newline, returning tokens starting from there.
    /// An eof token will always be returned at the end.
    pub fn next(self: *Tokenizer) Token {
        var state: State = .start;
        var result: Token = .{
            .tag = undefined,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
        };
        while (true) : (self.index += 1) {
            const c = self.buffer[self.index];
            switch (state) {
                .start => switch (c) {
                    0 => {
                        if (self.index == self.buffer.len) return .{
                            .tag = .eof,
                            .loc = .{
                                .start = self.index,
                                .end = self.index,
                            },
                        };
                        state = .invalid;
                    },
                    ' ', '\n', '\t', '\r' => {
                        result.loc.start = self.index + 1;
                    },
                    '"' => {
                        state = .string_literal;
                        result.tag = .string_literal;
                    },
                    '\'' => {
                        state = .char_literal;
                        result.tag = .char_literal;
                    },
                    'a'...'z', 'A'...'Z', '_' => {
                        state = .identifier;
                        result.tag = .identifier;
                    },
                    '@' => {
                        state = .saw_at_sign;
                    },
                    '=' => {
                        state = .equal;
                    },
                    '!' => {
                        state = .bang;
                    },
                    '|' => {
                        state = .pipe;
                    },
                    '(' => {
                        result.tag = .l_paren;
                        self.index += 1;
                        break;
                    },
                    ')' => {
                        result.tag = .r_paren;
                        self.index += 1;
                        break;
                    },
                    '[' => {
                        result.tag = .l_bracket;
                        self.index += 1;
                        break;
                    },
                    ']' => {
                        result.tag = .r_bracket;
                        self.index += 1;
                        break;
                    },
                    ';' => {
                        result.tag = .semicolon;
                        self.index += 1;
                        break;
                    },
                    ',' => {
                        result.tag = .comma;
                        self.index += 1;
                        break;
                    },
                    '?' => {
                        result.tag = .question_mark;
                        self.index += 1;
                        break;
                    },
                    ':' => {
                        result.tag = .colon;
                        self.index += 1;
                        break;
                    },
                    '%' => {
                        state = .percent;
                    },
                    '*' => {
                        state = .asterisk;
                    },
                    '+' => {
                        state = .plus;
                    },
                    '<' => {
                        state = .angle_bracket_left;
                    },
                    '>' => {
                        state = .angle_bracket_right;
                    },
                    '^' => {
                        state = .caret;
                    },
                    '\\' => {
                        state = .backslash;
                        result.tag = .multiline_string_literal_line;
                    },
                    '{' => {
                        result.tag = .l_brace;
                        self.index += 1;
                        break;
                    },
                    '}' => {
                        result.tag = .r_brace;
                        self.index += 1;
                        break;
                    },
                    '~' => {
                        result.tag = .tilde;
                        self.index += 1;
                        break;
                    },
                    '.' => {
                        state = .period;
                    },
                    '-' => {
                        state = .minus;
                    },
                    '/' => {
                        state = .slash;
                    },
                    '&' => {
                        state = .ampersand;
                    },
                    '0'...'9' => {
                        state = .int;
                        result.tag = .number_literal;
                    },
                    else => {
                        state = .invalid;
                    },
                },

                .expect_newline => switch (c) {
                    0 => {
                        if (self.index == self.buffer.len) {
                            result.tag = .invalid;
                            break;
                        }
                        state = .invalid;
                    },
                    '\n' => {
                        result.loc.start = self.index + 1;
                        state = .start;
                    },
                    else => {
                        state = .invalid;
                    },
                },

                .invalid => switch (c) {
                    0 => if (self.index == self.buffer.len) {
                        result.tag = .invalid;
                        break;
                    },
                    '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    else => continue,
                },

                .saw_at_sign => switch (c) {
                    0, '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    '"' => {
                        result.tag = .identifier;
                        state = .string_literal;
                    },
                    'a'...'z', 'A'...'Z', '_' => {
                        state = .builtin;
                        result.tag = .builtin;
                    },
                    else => {
                        state = .invalid;
                    },
                },

                .ampersand => switch (c) {
                    '=' => {
                        result.tag = .ampersand_equal;
                        self.index += 1;
                        break;
                    },
                    '&' => {
                        result.tag = .ampersand_ampersand;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .ampersand;
                        break;
                    },
                },

                .asterisk => switch (c) {
                    '=' => {
                        result.tag = .asterisk_equal;
                        self.index += 1;
                        break;
                    },
                    '*' => {
                        result.tag = .asterisk_asterisk;
                        self.index += 1;
                        break;
                    },
                    '%' => {
                        state = .asterisk_percent;
                    },
                    '|' => {
                        state = .asterisk_pipe;
                    },
                    else => {
                        result.tag = .asterisk;
                        break;
                    },
                },

                .asterisk_percent => switch (c) {
                    '=' => {
                        result.tag = .asterisk_percent_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .asterisk_percent;
                        break;
                    },
                },

                .asterisk_pipe => switch (c) {
                    '=' => {
                        result.tag = .asterisk_pipe_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .asterisk_pipe;
                        break;
                    },
                },

                .percent => switch (c) {
                    '=' => {
                        result.tag = .percent_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .percent;
                        break;
                    },
                },

                .plus => switch (c) {
                    '=' => {
                        result.tag = .plus_equal;
                        self.index += 1;
                        break;
                    },
                    '+' => {
                        result.tag = .plus_plus;
                        self.index += 1;
                        break;
                    },
                    '%' => {
                        state = .plus_percent;
                    },
                    '|' => {
                        state = .plus_pipe;
                    },
                    else => {
                        result.tag = .plus;
                        break;
                    },
                },

                .plus_percent => switch (c) {
                    '=' => {
                        result.tag = .plus_percent_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .plus_percent;
                        break;
                    },
                },

                .plus_pipe => switch (c) {
                    '=' => {
                        result.tag = .plus_pipe_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .plus_pipe;
                        break;
                    },
                },

                .caret => switch (c) {
                    '=' => {
                        result.tag = .caret_equal;
                        self.index += 1;
                        break;
                    },
                    '^' => {
                        result.tag = .caret_caret;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .caret;
                        break;
                    },
                },

                .identifier => switch (c) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => continue,
                    else => {
                        if (Token.getKeyword(self.buffer[result.loc.start..self.index])) |tag| {
                            result.tag = tag;
                        }
                        break;
                    },
                },
                .builtin => switch (c) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => continue,
                    else => break,
                },
                .backslash => switch (c) {
                    0 => {
                        result.tag = .invalid;
                        break;
                    },
                    '\\' => {
                        state = .multiline_string_literal_line;
                    },
                    '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    else => {
                        state = .invalid;
                    },
                },
                .string_literal => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            state = .invalid;
                            continue;
                        }
                        result.tag = .invalid;
                        break;
                    },
                    '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    '\\' => {
                        state = .string_literal_backslash;
                    },
                    '"' => {
                        self.index += 1;
                        break;
                    },
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => continue,
                },

                .string_literal_backslash => switch (c) {
                    0, '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    else => {
                        state = .string_literal;
                    },
                },

                .char_literal => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            state = .invalid;
                            continue;
                        }
                        result.tag = .invalid;
                        break;
                    },
                    '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    '\\' => {
                        state = .char_literal_backslash;
                    },
                    '\'' => {
                        self.index += 1;
                        break;
                    },
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => continue,
                },

                .char_literal_backslash => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            state = .invalid;
                            continue;
                        }
                        result.tag = .invalid;
                        break;
                    },
                    '\n' => {
                        result.tag = .invalid;
                        break;
                    },
                    0x01...0x09, 0x0b...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => {
                        state = .char_literal;
                    },
                },

                .multiline_string_literal_line => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            state = .invalid;
                            continue;
                        }
                        break;
                    },
                    '\n' => {
                        self.index += 1;
                        break;
                    },
                    '\r' => {
                        if (self.buffer[self.index + 1] == '\n') {
                            self.index += 2;
                            break;
                        } else {
                            state = .invalid;
                        }
                    },
                    0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => continue,
                },

                .bang => switch (c) {
                    '=' => {
                        result.tag = .bang_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .bang;
                        break;
                    },
                },

                .pipe => switch (c) {
                    '=' => {
                        result.tag = .pipe_equal;
                        self.index += 1;
                        break;
                    },
                    '|' => {
                        result.tag = .pipe_pipe;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .pipe;
                        break;
                    },
                },

                .equal => switch (c) {
                    '=' => {
                        result.tag = .equal_equal;
                        self.index += 1;
                        break;
                    },
                    '>' => {
                        result.tag = .equal_angle_bracket_right;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .equal;
                        break;
                    },
                },

                .minus => switch (c) {
                    '>' => {
                        result.tag = .arrow;
                        self.index += 1;
                        break;
                    },
                    '=' => {
                        result.tag = .minus_equal;
                        self.index += 1;
                        break;
                    },
                    '%' => {
                        state = .minus_percent;
                    },
                    '|' => {
                        state = .minus_pipe;
                    },
                    else => {
                        result.tag = .minus;
                        break;
                    },
                },

                .minus_percent => switch (c) {
                    '=' => {
                        result.tag = .minus_percent_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .minus_percent;
                        break;
                    },
                },
                .minus_pipe => switch (c) {
                    '=' => {
                        result.tag = .minus_pipe_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .minus_pipe;
                        break;
                    },
                },

                .angle_bracket_left => switch (c) {
                    '<' => {
                        state = .angle_bracket_angle_bracket_left;
                    },
                    '=' => {
                        result.tag = .angle_bracket_left_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .angle_bracket_left;
                        break;
                    },
                },

                .angle_bracket_angle_bracket_left => switch (c) {
                    '=' => {
                        result.tag = .angle_bracket_angle_bracket_left_equal;
                        self.index += 1;
                        break;
                    },
                    '|' => {
                        state = .angle_bracket_angle_bracket_left_pipe;
                    },
                    else => {
                        result.tag = .angle_bracket_angle_bracket_left;
                        break;
                    },
                },

                .angle_bracket_angle_bracket_left_pipe => switch (c) {
                    '=' => {
                        result.tag = .angle_bracket_angle_bracket_left_pipe_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .angle_bracket_angle_bracket_left_pipe;
                        break;
                    },
                },

                .angle_bracket_right => switch (c) {
                    '>' => {
                        state = .angle_bracket_angle_bracket_right;
                    },
                    '=' => {
                        result.tag = .angle_bracket_right_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .angle_bracket_right;
                        break;
                    },
                },

                .angle_bracket_angle_bracket_right => switch (c) {
                    '=' => {
                        result.tag = .angle_bracket_angle_bracket_right_equal;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .angle_bracket_angle_bracket_right;
                        break;
                    },
                },

                .period => switch (c) {
                    '.' => {
                        state = .period_2;
                    },
                    '*' => {
                        state = .period_asterisk;
                    },
                    else => {
                        result.tag = .period;
                        break;
                    },
                },

                .period_2 => switch (c) {
                    '.' => {
                        result.tag = .ellipsis3;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.tag = .ellipsis2;
                        break;
                    },
                },

                .period_asterisk => switch (c) {
                    '*' => {
                        result.tag = .invalid_periodasterisks;
                        break;
                    },
                    else => {
                        result.tag = .period_asterisk;
                        break;
                    },
                },

                .slash => switch (c) {
                    '/' => {
                        state = .line_comment_start;
                    },
                    '=' => {
                        result.tag = .slash_equal;
                        self.index += 1;
                        break;
                    },
                    '%' => {
                        state = .slash_percent;
                    },
                    else => {
                        result.tag = .slash;
                        break;
                    },
                },
                .slash_percent => switch (c) {
                    '=' => {
                        result.tag = .slash_precent_equal;
                        break;
                    },
                    else => {
                        result.tag = .slash_percent;
                        break;
                    },
                },
                .line_comment_start => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            state = .invalid;
                            continue;
                        }
                        return .{
                            .tag = .eof,
                            .loc = .{
                                .start = self.index,
                                .end = self.index,
                            },
                        };
                    },
                    '/' => {
                        state = .doc_comment_start;
                    },
                    '!' => {
                        result.tag = .container_doc_comment;
                        state = .doc_comment;
                    },
                    '\r' => {
                        state = .expect_newline;
                    },
                    '\n' => {
                        state = .start;
                        result.loc.start = self.index + 1;
                    },
                    0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => {
                        state = .line_comment;
                    },
                },
                .doc_comment_start => switch (c) {
                    0, '\n' => {
                        result.tag = .doc_comment;
                        break;
                    },
                    '\r' => {
                        if (self.buffer[self.index + 1] == '\n') {
                            self.index += 1;
                            result.tag = .doc_comment;
                            break;
                        } else {
                            state = .invalid;
                        }
                    },
                    '/' => {
                        state = .line_comment;
                    },
                    0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => {
                        state = .doc_comment;
                        result.tag = .doc_comment;
                    },
                },
                .line_comment => switch (c) {
                    0 => {
                        if (self.index != self.buffer.len) {
                            state = .invalid;
                            continue;
                        }
                        return .{
                            .tag = .eof,
                            .loc = .{
                                .start = self.index,
                                .end = self.index,
                            },
                        };
                    },
                    '\r' => {
                        state = .expect_newline;
                    },
                    '\n' => {
                        state = .start;
                        result.loc.start = self.index + 1;
                    },
                    0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => continue,
                },
                .doc_comment => switch (c) {
                    0, '\n' => {
                        break;
                    },
                    '\r' => {
                        if (self.buffer[self.index + 1] == '\n') {
                            self.index += 1;
                            break;
                        } else {
                            state = .invalid;
                        }
                    },
                    0x01...0x09, 0x0b...0x0c, 0x0e...0x1f, 0x7f => {
                        state = .invalid;
                    },
                    else => continue,
                },
                .int => switch (c) {
                    '.' => state = .int_period,
                    '_', 'a'...'d', 'f'...'o', 'q'...'z', 'A'...'D', 'F'...'O', 'Q'...'Z', '0'...'9' => continue,
                    'e', 'E', 'p', 'P' => state = .int_exponent,
                    else => break,
                },
                .int_exponent => switch (c) {
                    '-', '+' => {
                        state = .float;
                    },
                    else => {
                        self.index -= 1;
                        state = .int;
                    },
                },
                .int_period => switch (c) {
                    '_', 'a'...'d', 'f'...'o', 'q'...'z', 'A'...'D', 'F'...'O', 'Q'...'Z', '0'...'9' => {
                        state = .float;
                    },
                    'e', 'E', 'p', 'P' => state = .float_exponent,
                    else => {
                        self.index -= 1;
                        break;
                    },
                },
                .float => switch (c) {
                    '_', 'a'...'d', 'f'...'o', 'q'...'z', 'A'...'D', 'F'...'O', 'Q'...'Z', '0'...'9' => continue,
                    'e', 'E', 'p', 'P' => state = .float_exponent,
                    else => break,
                },
                .float_exponent => switch (c) {
                    '-', '+' => state = .float,
                    else => {
                        self.index -= 1;
                        state = .float;
                    },
                },
            }
        }

        result.loc.end = self.index;
        return result;
    }
};

test "tokenizer" {
    var tokenizer = Tokenizer.init("state main { entry {print(\"hello world\");}}");
    const types = [_]Token.Tag{ .keyword_state, .identifier, .l_brace, .identifier, .l_brace, .identifier, .l_paren, .string_literal, .r_paren, .semicolon, .r_brace, .r_brace };
    var i: usize = 0;
    while (i < tokenizer.buffer.len) : (i += 1) {
        const t = tokenizer.next();
        if (t.tag == .eof) break else try std.testing.expect(t.tag == types[i]);
    }
}

test "basic-expressions1" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/basic-expressions1.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "hello-world" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/hello-world.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "import" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/import.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "inc-dec-operators" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/inc-dec-operatos.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "simple-function1" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/simple-function1.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "simple-function2" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/simple-function2.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "simple-function3" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/simple-function3.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "simple-if" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/simple-if.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "simple-transition" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/simple-transition.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "state-global-param" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/state-global-param.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "state-param" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/state-param.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}

test "two-states" {
    const buffer: [:0]u8 = undefined;
    const f = try std.fs.cwd().openFile("tests/two-states.sl", .{});
    defer f.close();
    _ = try f.readAll(buffer);
    var tokenizer = Tokenizer.init(buffer);
    while (true) {
        if (tokenizer.next().tag == .eof) break;
    }
}
