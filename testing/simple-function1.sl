state Main {
  entry {
    int param = 1;
    simplefunction();
    exit(0);
  }
  fn simplefunction() {
    println("Hello function");
  }
}