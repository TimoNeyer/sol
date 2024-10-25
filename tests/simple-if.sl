state Main {
  entry {
    int param = 1;
    if (param == 1) {
      exit(1);
    } else {
      exit(0);
    }
  }
}