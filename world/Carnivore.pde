
public enum CarnivoreState {WANDERING, HUNTING, SLEEPING}

class Carnivore extends WorldObject{

  //config attributes
  final static int baseEnergy = 200;
  final static int sleepingDelay = 5000;
  final static int huntingDelay = 10000;
  final static int wanderingDelay = 10000;
  final static int animationDelay = 500;
  
  final static float eatRadius = 5;
  final static float chaseRadius = 100;
  final static float huntingRadius = 50;
  final static float wanderingSpeed = 2;
  final static float huntingSpeed = 3;
   //attributes
  ArrayList<Herbivore> herbivores;
  
  
  float upperLipClosed = PI / 180;
  float lowerLipClosed = TWO_PI - (PI / 180);
  float lowerLipOpen = 7 * QUARTER_PI;
  float upperLipOpen = QUARTER_PI;
  color normalColor = color (255, 238, 0);
  color huntingColor = color (255, 100, 0);
  color c = normalColor;
  float upperLip = upperLipClosed , lowerLip = lowerLipClosed;
  Boolean lipOpen = false;



  
  float currentSpeed;
  float topSteer = 0.3;

  
  Delay sleepingTimer = new Delay (sleepingDelay);
  Delay huntingTimer = new Delay (huntingDelay);
  Delay wanderingTimer = new Delay (wanderingDelay);
  Delay animationTimer = new Delay(animationDelay);

  PVector velocity;
  PVector acceleration = new PVector();
  PVector targetLocation;
  
  Boolean hasTarget = false;
  Herbivore target;
  int energy;
  CarnivoreState state;
//CONSTRUCTOR
  Carnivore(float x, float y, World world){
    //WorldObject attributes
    this.location = new PVector(x,y);
    this.world = world;
    this.size = new PVector(30,30);
    this.velocity = new PVector (3, 3);
    angle = size.heading();
    //herbivore attributes

    this.herbivores = world.herbivores;
    this.state = CarnivoreState.WANDERING;
    currentSpeed = wanderingSpeed;
    this.energy = baseEnergy;
    targetLocation = new PVector(random (width - (2 * size.x)), random(height - (2* size.y)));
    
  }
//INHERITE METHODS
  void update(long deltaTime){
    
    switch(state){
      case WANDERING:
        currentSpeed = wanderingSpeed;
        wanderingUpdate(deltaTime);
        break;
      case HUNTING:
        currentSpeed = huntingSpeed;
        huntingUpdate(deltaTime);
        break;
      case SLEEPING:
        sleepingUpdate(deltaTime);
        break;
    }
    
    setColor();
    moveToTarget();
  }
  
  
  void render(){
    pushMatrix();
    
    stroke(0);
    translate(location.x, location.y);
    
    if (this.state == CarnivoreState.SLEEPING) {
      fill (50);
      text ("Zzzz...", size.x / 2, -size.y / 2);
      noFill();
      ellipse (size.x - 10, -size.y / 2 - 3, size.x, size.y / 2);
    } else {
      rotate(angle);
    }
    
    fill(c);
    if(lipOpen)
      arc(0, 0, size.x, size.y, upperLipOpen, lowerLipOpen, PIE);
    else
      arc(0, 0, size.x, size.y, upperLipClosed, lowerLipClosed, PIE);
    popMatrix();
    
  }
//STATE METHODS
  void wanderingUpdate(long deltaTime){
    wanderingTimer.update(deltaTime);
    if(wanderingTimer.expired())
      this.state = CarnivoreState.HUNTING;
      
    if(PVector.dist(this.location,targetLocation) < 10)
      targetLocation = new PVector(random (width - (2 * size.x)), random(height - (2* size.y)));
  }
  
  void huntingUpdate(long deltaTime){
    
      
    if(!hasTarget){
      findTarget();
      if(PVector.dist(this.location,targetLocation) < 10)
        targetLocation = new PVector(random (width - (2 * size.x)), random(height - (2* size.y)));
    }else{
      targetLocation = target.location;
      if(PVector.dist(location,target.location) < eatRadius){
        energy += target.energy;
        target.energy = 0;
        world.removeHerbivore(target);
        hasTarget = false;
      }else if(PVector.dist(location,target.location) > chaseRadius){
        hasTarget = false;
      }
    }
    
    animationTimer.update(deltaTime);
    if(animationTimer.expired())
      lipOpen = !lipOpen;
    
    huntingTimer.update(deltaTime);
    if(huntingTimer.expired()){
      this.state = CarnivoreState.SLEEPING;
      targetLocation.x = location.x;
      targetLocation.y = location.y;
      lipOpen = false;
    }
      
  }
  
  void sleepingUpdate(long deltaTime){
    targetLocation.x = location.x;
    targetLocation.y = location.y;
    sleepingTimer.update(deltaTime);
    if(sleepingTimer.expired()){
      this.state = CarnivoreState.WANDERING;
      world.addFertilizer(new Fertilizer(location.x,location.y,world,energy - baseEnergy));
      this.energy = baseEnergy;
    }
  }
  
  
//METHODS
  //look for plant around and calcul forces on the closest one
  void findTarget () {
    Herbivore closestHerbivore = null;
    float bestDistance = 9999999;
    for (Herbivore h:herbivores){
      float distanceToHerbivore = PVector.dist(location, h.location);
      if(distanceToHerbivore <= huntingRadius && distanceToHerbivore <= bestDistance){
        bestDistance = distanceToHerbivore;
        closestHerbivore = h;
      }
    }
    if(closestHerbivore != null){
      target = closestHerbivore ; 
      hasTarget = true;
    }
  }
  void setColor(){
    
    switch(state){
      case WANDERING:
        c = color (255, 238, 0);
        break;
      case HUNTING:
        c = color (255, 100, 0);
        break;
      case SLEEPING:
       c = color (200, 200, 200);
        break;
    }
  }
  
  boolean moveToTarget() {
    float distanceToTarget = PVector.dist(targetLocation, location);
    PVector desired = PVector.sub(targetLocation, location);
    
    if (distanceToTarget >= 2) {
      
      angle = velocity.heading();      
      
      velocity = desired;
      velocity.normalize();
      velocity.mult(currentSpeed);
      
      location.add (velocity);
      return false;
    } else {
      return true;
    }
  }
}