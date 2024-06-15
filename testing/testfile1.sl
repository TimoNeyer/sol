state Main {
  global int st;
  entry {
    int a;
    print("ehlo");
    print(st);
    exit(0);
  }
}