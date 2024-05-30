#include <fstream>
#include <iostream>

#include "./errors.hpp"
#include "./lexer.hpp"
#include "./parser.hpp"

int main(int argc, char *argv[]) {
  try {
    if (argc != 2) {
      throw BaseException(Token(), "Error, no file given", 0);
    }
    std::ifstream file(argv[1]);
    if (file.bad())
      throw BaseException(Token(), "failed to open file", 0);
    Lexer lexer(&file);
    lexer.parse();
    for (unsigned long int i = 0; i < lexer.container.values.size(); i++) {
    if (lexer.container.values.at(i).type == EMPTY)
      continue;
    std::cout << "Token " << lexer.container.values.at(i).value;
    std::cout << " is Type " << lexer.container.values.at(i).type;
    std::cout << "\n";
  }
    Parser parser = Parser();
    parser.parse(&lexer.container);
  } catch (BaseException e) {
    std::cout << e.what() << std::endl;
  }
  return 0;
}