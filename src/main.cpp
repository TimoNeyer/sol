#include <fstream>
#include <iostream>

#include "./errors.hpp"
#include "./lexer.hpp"
#include "./parser.hpp"
#include "print_ast.hpp"

int main(int argc, char *argv[]) {
  if (argc != 2) {
    throw BaseException(Token(), "Error, no file given");
  }
  std::ifstream file(argv[1]);
  if (file.bad())
    throw BaseException(Token(), "failed to open file");
  Lexer lexer(&file);
  lexer.parse();
  //print_lexer(&lexer);
  Parser parser = Parser();
  parser.parse(&lexer.container);
  print_ast(&parser);
  return 0;
}