state Main {
  int value;
  entry {
    int param = 1;
    simplefunction(param);
    exit(0);
  }
  fn simplefunction(int param) {
    Main.value = param;
    println("Hello function");
    println("param = {}", param);
    println("value = {}", value);
  }
}