public enum State {
  WANDERING, HUNTING, SLEEPING, POOPING, ESCAPING, MATING, FEEDING, RUT
}
  
class Mover {
  State state = State.WANDERING;
  
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector size = new PVector();
  
  World world;
  
  float angle = 0;
  
  float topSpeed = 3;
  
  PVector target = new PVector();
  float atTarget = 2;
  
  Mover (World world) {
    this.world = world;
  }
  
  boolean moveToTarget() {
    float distanceToTarget = PVector.dist(target, location);
    PVector desired = PVector.sub(target, location);
    
    if (distanceToTarget > atTarget) {
      
      angle = velocity.heading();      
      
      velocity = desired;
      velocity.normalize();
      velocity.mult(topSpeed);
      
      location.add (velocity);
      return false;
    } else {
      return true;
    }
  }
}