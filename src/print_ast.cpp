#include "print_ast.hpp"
#include "lexer.hpp"

void print_node(Node *node, int depth) {
  for (int i = 0; i < depth; i++) {
    printf("| ");
  }
  printf("-> type %d, value %s\n", node->value.type, node->value.value.c_str());
  for (Node *item : node->subtree) {
    print_node(item, depth + 1);
  }
}

void print_ast(Parser *parser) { print_node(const_cast<Node*>(parser->head), 0); }

void print_lexer(Lexer *lexer) {
  for (Token item : lexer->container.values) {
    printf("Token %s is type %d\n", item.value.c_str(), item.type);
  }
}