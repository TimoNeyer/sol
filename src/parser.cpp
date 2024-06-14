#include "parser.hpp"
#include "errors.hpp"
#include "lexer.hpp"
#include <cstddef>
#include <fmt/format.h>

Node::Node() {
  this->value = Token();
  this->subtree = std::vector<Node *>();
  this->parent = nullptr;
}

Node::Node(Token token, const Node *parent) {
  this->subtree = std::vector<Node *>();
  this->value = token;
  this->parent = parent;
}

Node::Node(Node &other, Node *parent) {
  this->subtree = other.subtree;
  this->value = other.value;
}

void Node::push_node(Node *node) { this->subtree.push_back(node); }

Node::~Node() {
  for (Node *ptr : this->subtree) {
    if (!ptr->subtree.empty())
      delete ptr;
  }
}

Parser::Parser() {
  this->head = new Node();
  this->backtrack = std::stack<Node *>();
  this->backtrack.push(this->head);
}

/*
void : testExpression(TokenArray *value, size_t *index, TokenType delim) {
  Node *exp = new Node(value->at(*index), this->backtrack.top());
  exp->value.value = "";
  TokenArray buffer(4);
  TokenType next;

  for (size_t i = *index; i < MAXEXP && value->at(i).type != delim;
       next = value->at(i++).type) {
    if (delim != SEMICOLON && value->at(*index + i).type == DOUBLE_PIPE) {
      this->testExpression(value, &i, DOUBLE_PIPE);
      this->testExpression(value, &i, delim);
    }
    switch (value->at(*index).type) {
    case PLUS:
    case MINUS:
      if (next != INT || next != FLOAT)
        throw BaseException(value->at(*index),
                            "Can not convert non int or float to minus",
                            *index);
    case IDENTIFIER:
      if (next > MATH && next < ENDACCESS || next == LEFT_PAREN ||
          next == SEMICOLON) {
        // parse Exp
      } else {
        std::cout << next << std::endl;
        throw BaseException(value->at(*index), "Wrong Expression", *index);
      }
      break;
    case LEFT_PAREN:
      this->testExpression(value, index, RIGHT_PAREN);
      break;
    case DOUBLE_PLUS:
    case DOUBLE_MINUS:
      break;
    default:
      break;
    }
  }
}*/

void Parser::parseArray(TokenArray *value, size_t *index) {
  TokenType current = value->at(++*index).type;
  TokenType next = value->at(++*index).type;
  while (next != EMPTY && next != RIGHT_BRACKET) {
    if (current > ENDLITERALS && current < LITERALS)
      throw BaseException(value->at(*index), "unexpected value in array",
                          *index);
    if (next != COMMA)
      throw BaseException(value->at(*index),
                          "Expected Comma as separator in array", *index);
    current = next;
    next = value->at(++*index).type;
  }
}

void Parser::testExpression(TokenArray *value, size_t index, TokenType delim) {
  Token current = value->at(index);
  if (current.type == delim)
    return;
  switch (current.type) {
  case LEFT_PAREN:
    return this->testExpression(value, index, RIGHT_PAREN);
  case SEMICOLON:
  case ARROWRIGHT:
  case ARROWLEFT:
  case COLON:
  case DOUBLE_COLON:
    throw BaseException(current, "unexpected separator in expression", index);
  case EMPTY:
    throw BaseException(current, "Unexpected end of file", index);
  default:
    Token next = value->at(index + 1);
    if (current.type > MATH && current.type < ENDMATH) {
      if (next.type != INT && next.type != NUMBER && next.type != FLOAT &&
          next.type != DOUBLE && next.type != IDENTIFIER)
        throw BaseException(
            next, "Unable to parse Expression, expected int, float or ident",
            index);
    } else if (current.type > LOGIC && current.type < ENDLOGIC) {
      if (next.type != BOOL && next.type != IDENTIFIER && next.type != INT &&
          next.type != NUMBER && next.type != FLOAT && next.type != DOUBLE)
        throw BaseException(next,
                            "Unable to parse Expression, expected bool, "
                            "numeric value or Identifier",
                            index);
    } else if (current.type == IDENTIFIER && next.type == EQUAL &&
               value->at(index + 2).type == LEFT_BRACKET) {
      index += 2;
      this->parseArray(value, &index);
    } else if (next.type == EMPTY) {
      throw BaseException(next, "Unexpected end of file", index);
    } else {
      this->testExpression(value, ++index, delim);
    }
  }
}

void Parser::parseFn(TokenArray *value, size_t *index) {
  Node *fn = new Node(value->at(*index), this->backtrack.top());
  this->backtrack.push(fn);
  Node *name = new Node(value->at((++*index)), fn);
  Node *params = new Node(
      Token("", EXPRESSION, value->at(*index).line, value->at(*index).column),
      fn);
  this->testExpression(value, *index, RIGHT_PAREN);
  for (int i = 0; i < MAXARGS && i + *index < value->size() &&
                  value->at(++*index).type != RIGHT_PAREN;
       i++) {
    Node *arg = new Node(value->at(*index), params);
    params->push_node(arg);
  }
  Node *content = new Node(Token(), fn);
  this->backtrack.pop();
  this->backtrack.push(content);
}

void Parser::parseIf(TokenArray *value, size_t *index) {
  Node *iif = new Node(value->at((*index)++), this->backtrack.top());
  Node *exp = new Node(value->at(*index), iif);
  this->backtrack.push(exp);
  this->testExpression(value, *index, RIGHT_PAREN);
  unsigned int trace = 1;
  for (int i = 0; i < MAXEXP && trace; i++) {
    if (value->at((*index)++).type == RIGHT_PAREN)
      trace--;
    else if (value->at((*index)++).type == LEFT_PAREN)
      trace++;
    else
      exp->push_node(new Node(value->at((*index)++), exp));
  }
  this->backtrack.pop();
  this->backtrack.push(iif);
}

void Parser::parseState(TokenArray *value, size_t *index) {
  Node *state = new Node(value->at((*index)++), this->backtrack.top());
  Node *name = new Node(value->at((*index)++), state);
  this->backtrack.push(state);
}

void Parser::parse(TokenArray *lexerout) {
  this->head = new Node();
  this->backtrack.push(this->head);
  size_t *i = new size_t;
  for (*i = 0; *i < lexerout->size(); (*i)++) {
    switch (lexerout->at(*i).type) {
    case IF:
      this->parseIf(lexerout, i);
      break;
    case FN:
      this->parseFn(lexerout, i);
      break;
    case STRUCT:
      this->parseStruct(lexerout);
      break;
    case STATE:
      this->parseState(lexerout, i);
      break;
    case TRANSITION:
      this->parseTransition(lexerout, i);
      break;
    case RIGHT_BRACE:
      if (this->backtrack.size() == 0)
        throw BaseException(lexerout->at(*i),
                            "call stack ambiguous, probably missing '{' or '}'",
                            *i);
      this->backtrack.pop();
      break;
    default:
      this->testExpression(lexerout, *i, SEMICOLON);
      Node *current = new Node(
          Token("", EXPRESSION, lexerout->at(*i).line, lexerout->at(*i).column),
          this->backtrack.top());
      for (int h = 0; h < MAXARGS && *i < lexerout->size() &&
                      lexerout->at((*i)++).type != RIGHT_PAREN;
           h++) {
        Node *arg = new Node(lexerout->at(*i), this->backtrack.top());
        this->backtrack.top()->push_node(arg);
      }
      break;
    }
  }
  if (this->backtrack.top() != this->head)
    throw BaseException(lexerout->at(*i),
                        "Unexpected continuation, too many '{'?", *i);
}