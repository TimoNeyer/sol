#pragma once

#include <exception>
#include <stack>
#include <unordered_map>
#include <format>

#include "lexer.hpp"

// define max lengths
#define MAXFILESIZE 10000000
#define STDMAXS 128

#define MAXPREPROC STDMAXS
#define MAXTYPELEN STDMAXS
#define MAXARGS STDMAXS
#define MAXEXP MAXTYPELEN * 4

#define BLOCKBUFFER 4

struct Node {
  Token value;
  const Node *parent;
  std::vector<Node *> subtree;
  Node();
  Node(Token token, const Node *parent);
  Node(Node &other, Node *parent);
  void push_node(Node *node);
  ~Node();
};

class Parser {
  const Node *head;

  void testExpression(TokenArray *value, size_t * index, TokenType delim);
  void parseIf(TokenArray *value, size_t *index);
  void parseFn(TokenArray *value, size_t *index);
  void parseStruct(TokenArray *value);
  void parseState(TokenArray * value, size_t * index);
  void parseTransition(TokenArray * value, size_t * index);
  void parseArray(TokenArray * value,size_t * index);

public:
  std::stack<const Node *> backtrack;
  void parse(TokenArray *value);
  Parser();
  ~Parser();
};

