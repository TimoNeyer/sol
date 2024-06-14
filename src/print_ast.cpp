#include "print_ast.hpp"

void print_node(Node *node, int depth) {
  for (int i = 0; i < depth; i++) {
    printf("| ");
  }
  printf("-> type %d, value %s", node->value.type, node->value.value.c_str());
  for (Node *item : node->subtree) {
    print_node(item, depth + 1);
  }
}

void print_ast(Parser *parser) {
  print_node(parser->head, 0);
}