state Main {
  int param;
  entry {
    param = 1;
    -> Secondary(param);
  }
  -> Secondary (int value) {
    Secondary.param = value;
    println("switching to state Secondary");
  }
}

state Secondary {
  int param;
  entry {
    println("Hello Secondary");
    println("param: {}", param);
    exit(param)
  }
}