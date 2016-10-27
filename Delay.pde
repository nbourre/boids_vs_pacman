class Delay {
  int interval;
  int accumulator = 0;
  
  Delay (int time) {
    interval = time;
  }
  
  void update (float deltaTime) {
    accumulator+= deltaTime;
  }
  
  boolean expired () {
    boolean result = false;
    
    if (accumulator > interval) {
      accumulator = 0;
      result = true;
    }
    
    return result;
  }
}