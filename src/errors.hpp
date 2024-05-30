#include <exception>
#include <string>
#include <fmt/format.h>

#include "lexer.hpp"

class BaseException : std::exception {
  std::string msg;
  Token * last_seen;
  Token * block;

public:
  BaseException(Token backtracked, const char * message, size_t index);
  virtual const char * what() const throw(); 
};

class SyntaxError : BaseException {
};