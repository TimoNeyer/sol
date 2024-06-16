state Main {
  entry {
    int param0 = 0;
    int param1 = param0++;
    int param2 = ++param0;
    int param3 = param0--;
    int param4 = --param0;
    exit(param0);
  }
  
}