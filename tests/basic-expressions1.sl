state Main {
  entry {
    int param0 = 1;
    int param1 = param0 + 1;
    bool param2 = param0 < param1;
    int param3 = 2; 
    param0 -= param1;
    param1 += param0;
    param0 *= param1;
    param1 /= param0;
    param0 |= param1;
    param1 &= param0;
    param0 ^= param1;
    param1 ~= param0;
    param0 /%= param0;
    exit(0);
  }
  
}
