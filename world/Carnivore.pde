/**
  this class represent carnivore. Carnivore eat herbivore the more hungry the carnivore is the faster he is
**/
class Carnivore extends WorldObject{
//config attributes
  final static int baseEnergy = 2000;
  final static int animationDelay = 500;
  final static float upperLipClosed = PI / 180;
  final static float lowerLipClosed = TWO_PI - (PI / 180);
  final static float lowerLipOpen = 7 * QUARTER_PI;
  final static float upperLipOpen = QUARTER_PI;
  final static float eatRadius = 5;
  final static float chaseRadius = 200;
  final static float huntingRadius = 100;
  final static int poopDelay = 30000;
  final static int poopAmount = 400;
  final static float defaultSpeed = 3.5;
  final static float energySpeedMultiplicator = -0.0005;
  final static float defaultRayon = 30;
  final static float energySizeMultiplicator = 0.02;
//attributes
  ArrayList<Herbivore> herbivores;
  Boolean lipOpen = false;
  color c = color (255, 100, 0);
  float currentSpeed;
  Delay animationTimer = new Delay(animationDelay);
  Delay poopTimer = new Delay(poopDelay);
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  PVector targetLocation = new PVector();
  Boolean hasTarget = false;
  Herbivore target;
  int energy;
  float angle;
  float rayon;
//constructor
  Carnivore(float x, float y, World world){
    //WorldObject attributes
    this.location = new PVector(x,y);
    this.world = world;
    this.size = new PVector(defaultRayon,defaultRayon);
    this.velocity = new PVector (defaultSpeed,defaultSpeed);
    angle = velocity.heading();
    //herbivore attributes
    this.herbivores = world.herbivores;
    this.energy = baseEnergy;
    speedUpdate();
    sizeUpdate();
    targetLocation = new PVector(random (width - (2 * size.x)), random(height - (2* size.y)));
  }
  
//inherited methods
  void update(long deltaTime){
    
    if(!hasTarget){
      findTarget();
      if(PVector.dist(this.location,targetLocation) < 10)
        targetLocation = new PVector(random (width - (2 * size.x)), random(height - (2* size.y)));
    }
    else{
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
    speedUpdate();
    sizeUpdate();
    moveToTarget();
    
    
    poopTimer.update(deltaTime);
    if(poopTimer.expired())
      poop();
      
    animationTimer.update(deltaTime);
    if(animationTimer.expired())
      lipOpen = !lipOpen;
       
    if(energy < 0)
      world.removeCarnivore(this);
  }
  
  
  void render(){
    pushMatrix();
    
    stroke(0);
    translate(location.x, location.y);
    rotate(angle);
    fill(c);
    if(lipOpen)
      arc(0, 0, rayon, rayon, upperLipOpen, lowerLipOpen, PIE);
    else
      arc(0, 0, rayon, rayon, upperLipClosed, lowerLipClosed, PIE);
    popMatrix();
    
  }

//methods
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
  
  void speedUpdate(){
    currentSpeed = (float)defaultSpeed + (float)energy * energySpeedMultiplicator;
  }
  
  void sizeUpdate(){
    rayon = energySizeMultiplicator * energy;
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
  
  void poop(){
    int poopSize;
    if(poopAmount < energy)
      poopSize = poopAmount;
    else
      poopSize = energy;
      
    world.addFertilizer(new Fertilizer(location.x,location.y,world,poopSize));
    energy -= poopSize;
  }
}