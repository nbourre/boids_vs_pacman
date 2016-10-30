class Fertilizer extends WorldObject{
  
  //config attributes
  final int sizeReferenceEnergy = 500;
  final PVector baseSize = new PVector(30,10);
  //attributes
  private int energy;
  PVector proportionSize = new PVector();
  float energySizeProportion;
  
  //constructors 
  Fertilizer(float x, float y, World world){
    this.world = world;
    location = new PVector (x, y);
    size = baseSize;
    fillColor = #8B4513;
    strokeColor = 0;
    angle = location.heading();
    energy = 500;
  }
  
  Fertilizer(float x, float y, World world,int energy){
    this.world = world;
    location = new PVector (x, y);
    size = baseSize;
    fillColor = #8B4513;
    strokeColor = 0;
    angle = location.heading();
    this.energy = energy;
  }
  
  //methods
  int deplete(int amount){

    if(energy >= amount){
      energy -= amount;
      return amount;
    }
    else if(energy > 0){
      int value = energy;
      energy = 0;
      return value;
    }
    return 0;
  }
  
  //inherited methods
  void update(long deltaTime){
    
    //Size management
    energySizeProportion = (float) energy / sizeReferenceEnergy;
    if(energySizeProportion < 0.3)
      energySizeProportion = 0.3;
    proportionSize.x = size.x * energySizeProportion;
    proportionSize.y = size.y * energySizeProportion;
    
    //life management
    if(energy <= 0)
      world.removeFertilizer(this);
  }
  
  void render(){
   
    pushMatrix();
    fill(fillColor);
    stroke(strokeColor);
    strokeWeight(1);
    translate(location.x, location.y);
    rotate(angle);
   
    ellipse (0, 0, proportionSize.x, proportionSize.y);
    
    rotate (-PI / 18);
    arc (energySizeProportion * 20, energySizeProportion* 4, proportionSize.x, proportionSize.y, QUARTER_PI + PI, TWO_PI + PI, OPEN);
    
    popMatrix();
  }
  
}