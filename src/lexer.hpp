#pragma once
#include <fstream>
#include <iostream>
#include <vector>

#define CONTAINERBUFF 128

enum TokenType {
  Separators,

  LEFT_PAREN,   // (
  RIGHT_PAREN,  // )
  LEFT_BRACE,   // [ 
  RIGHT_BRACE,  // ]
  LEFT_BRACKET, // {
  RIGHT_BRACKET,// }
  SEMICOLON,    // ;
  LINECOMMENT,  // #
  BLOCKCOMMENT, // /*
  COMMA,        // ,

  ENDSEPARATORS,

  MODIFIERS,

  GETREF,          // & -> get reference
  DEREF,         // * -> dereference

  ENDMODIFIERS,

  MATH,         

  MINUS,        // operator minus
  PLUS,         // operator plus
  STAR,         // operator multiply   
  SLASH,        // operator divide
  DOUBLE_SLASH, // operator integer division 
  DOUBLE_STAR,  // operator integer square
  PERCENT,      // operator modulo

  ENDMATH,

  LOGIC,

  BANG,         // operator not
  DOUBLE_AND,   // operator and
  DOUBLE_PIPE,  // operator or
  AND,          // inline logical and
  PIPE,         // inline logical or
  CARET,        // inline logical xor

  ENDLOGIC,

  COMPARE,

  GREATER,      // >
  GREATER_EQ,   // >=
  LESS,         // <
  LESS_EQ,      // <=
  BANG_EQ,      // !=
  EQUAL_EQ,     // ==

  ENDCOMPARE,

  ASSIGNMENT,

  EQUAL,        // =  assign new value
  MINUS_EQ,     // -= assign the value itself minus the rvalue
  PLUS_EQ,      // += assign the value itself plus the rvalue
  STAR_EQ,      // *= assign the value itself times the rvalue 
  SLASH_EQ,     // /= assign the value itself divided by the rvalue
  PIPE_EQ,       // |= assign the value itself logical or the rvalue
  AND_EQ,        // &= assign the value itself logical and the rvalue
  CARET_EQ,      // ^= assign the value itself logical xor the rvalue
  TILDE_EQ,      // ~= assign the value logical not the rvalue
  DOUBLE_PLUS,  // ++ increment the value either before use or after
  DOUBLE_MINUS, // -- decrement the value either before use or after
  ASSIGN,       // := assign compilation time value
  NEW,

  ENDASSIGNMENT,

  ACCESS,

  ARROWLEFT,    // <- define incoming transition
  ARROWRIGHT,   // -> define outgoing transition
  DOT,          // .  access type values or functions
  DOUBLE_COLON, // :: define to lvalue without beeing in the necessary block

  ENDACCESS,

  MISC,

  COLON,        // :  Currently not used 
  DOUBLE_DOT,   // .. used for ranges

  ENDMISC,

  TYPES,

  REFERENCE,    // pointer to something
  INT,          // 64 bit integer
  BOOL,         // 8 bit boolean value
  ARRAY,        // a fixed time a predefined type
  BYTES,        // 64 bytes without any metadata or predefined functions
  EXPRESSION,
  DOUBLE,       // 64 bit IEEE 754 float
  STATE,        // state 
  ENTRY,        // entry function
  TRANSITION,   // transition to other state

  KEYWORDS,

  FN,           // fn function keyword

  ENDTYPES,

  ELSE,
  FALSE,
  IF,
  INULL,        // nullptr
  RETURN,
  STRUCT,
  TRUE,

  ENDKEYWORDS,

  LITERALS,

  IDENTIFIER,
  CHAR,
  STRING,
  NUMBER,
  FLOAT,

  ENDLITERALS,

  EMPTY
};

class Token {
public:
  std::string value;
  TokenType type;
  int line;
  int column;
  Token();
  Token(std::string str, TokenType type, int ln, int clmn);
  Token(int vl, TokenType type, int ln, int clmn);
  Token(double vl, TokenType type, int ln, int clmn);
  Token(char vl, TokenType type, int ln, int clmn);
};

class TokenArray {
public:
  std::vector<Token> values;
  TokenArray(int minsize);
  TokenArray();
  TokenArray(TokenArray &&other);
  TokenArray(TokenArray &other);
  TokenArray &operator=(const TokenArray &other);
  bool push(Token token);
  size_t size();
  Token at(size_t index);
};

class Lexer {
private:
  std::ifstream stream;
  int line;
  int column;
  void parseNum(char value);
  bool Identcheck(char next);
  void parseIdent(char value);
  char get_next();
  bool isComment(std::string current);
  char getClose(char start);
  void parseString(char start);
  TokenType isKeyword(std::string value);

public:
  TokenArray container;
  Lexer(std::ifstream *file);
  void parse();
};
