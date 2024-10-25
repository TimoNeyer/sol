use ./simple-function1.simplefunction as sf;

state Main {
  entry {
    int param = 1;
    sf();
    exit(0)
  }
}