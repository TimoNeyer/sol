state Main {
  global int param;
  entry {
    param = 1;
    exit(param);
  }
}