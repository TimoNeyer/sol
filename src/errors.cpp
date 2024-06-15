#include <iostream>

#include "errors.hpp"

BaseException::BaseException(Token backtracked, const char *message) {
  this->msg = std::format(
      "ERROR: {}\nlast seen Token {} in line {} column {}\n"
      "value {}\n",
      message,
      (int)backtracked.type, backtracked.line, backtracked.column,
      backtracked.value);
  std::cerr << msg;
}
/*
BaseException::BaseException(Token backtracked, const char *message, const
size_t index) { printf("%s\nlast seen Token %lu in line %d column %d\n value:
%s\n", message, index, backtracked.line, backtracked.column,
backtracked.value.c_str());
}*/

const char *BaseException::what() const noexcept {
  // printf(this->msg.c_str());
  return this->msg.c_str();
}
