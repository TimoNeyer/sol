#include <exception>
#include <string>
#include <format>

#include "lexer.hpp"

class BaseException : std::exception {
  std::string msg;

public:
  BaseException(Token backtracked, const char * message);
  const char * what() const throw(); 
};

class SyntaxError : BaseException {
};