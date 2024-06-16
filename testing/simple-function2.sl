state Main {
  entry {
    int param = 1;
    simplefunction(param);
    exit(0);
  }
  fn simplefunction(int param) {
    println("Hello function");
    println("param = {}", param);
  }
}