class Food extends Mover {
  
  color fillColor = #8B4513;
  color strokeColor = 0;
  int energy = 15000;
  
  Delay decayTime = new Delay(energy);
  
  boolean isAvailable = true;
  int alpha = 255;

  Food (float x, float y, World world) {
    super (world);
    location = new PVector (x, y);
    size.x = 30;
    size.y = 10;
  }
  
  void deplete() {
    if (energy > 0)
      energy--;
  }
  
  void update(float deltaTime) {
    if (isAvailable) {

      if (!decayTime.expired()){
        float decayRatio = (float)(decayTime.accumulator) / decayTime.interval;
        
        alpha = 255 - (int)(decayRatio * 255);
        
       
        fillColor = color (red (fillColor), green (fillColor), blue (fillColor), alpha);
        strokeColor = color (0, 0, 0, alpha);
        decayTime.update(deltaTime);
        
        if (energy < 0) {
          isAvailable = false;
        }
        
      } else {
        isAvailable = false;
      }
    }
    
  }

  void display() {
    if (isAvailable) {
      pushMatrix();
      fill(fillColor);
      stroke(strokeColor);
      translate(location.x, location.y);
      rotate(angle);
      
      ellipse (0, 0, size.x, size.y);
      
      rotate (-PI / 18);
      arc (20, 4, size.x, size.y, QUARTER_PI + PI, TWO_PI + PI, OPEN);
      
      popMatrix();
    }
  }
}