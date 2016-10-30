public enum PlantState {SEED, SPROUT, MATURE, FLOWERING}
class Plant extends WorldObject{
  
  //config attributes
  final static int fertilizerRayon = 50;//represent how far the seed can get the fertilizer
  final static int matureStateEnergy = 100;//represent how much energy required to enter mature state
  final static int floweringStateEnergy = 200;//represent how much energy required to enter flowering state
  final static int floweringTime = 5000;//represent how long it take to generate new seeds and then go dyingstate
  final static int nbFlowerSeed = 5;//represent how much new Plant is generated after flowering
  final static int flowerSeedRadius = 40;//represent how far the new Plant can be generated 
  final PVector maturePlantSize = new PVector(5,30);//represents the maximun size of the plant used to calcule size while growing
  final static color sproutColor = #458B00;
  final static color matureColor = #c4c431;
  final static color floweringColor = #ba390e;
  final static color dyingColor = #6d3f06;
  final static int eatTime = 500;
  //attributes
  ArrayList<Fertilizer> fertilizers;
  Fertilizer fertilizer;
  private int energy;
  private PlantState state;
  Delay floweringTimer;
  Delay eatTimer;
  
  //constructors 
  Plant(float x, float y ,World world,int energy){
    //WorldObject attributes
    this.world = world;
    location = new PVector (x, y);
    fillColor = sproutColor;
    strokeColor = sproutColor;
    this.size = new PVector(1,1);//size.y represent plant height and size.x represent plant width
    angle = size.heading();
    
    //Plant attributes
    state = PlantState.SEED;
    floweringTimer = new Delay(floweringTime);
    eatTimer = new Delay(eatTime);
    this.energy = energy;
    this.fertilizers = world.fertilizers;
    
  }
  

  //inherited methods
  void update(long deltaTime){
    
    switch(state){
      case SEED:
        seedUpdate();
        break;
      case SPROUT:
        sproutUpdate(deltaTime);
        break;
      case MATURE:
        matureUpdate(deltaTime);
        break;
      case FLOWERING:
        floweringUpdate(deltaTime);
        break;
    }
    
    //life management
    if(energy <= 0)
      world.removePlant(this);
    
  }
  
  void render(){
    pushMatrix();
    switch(state){
      case SEED:
        seedRender();
        break;
      case SPROUT:
        sproutRender();
        break;
      case MATURE:
        matureRender();
        break;
      case FLOWERING:
        floweringRender();
        break;
    }
    popMatrix();
  }
  
  
  //state methods
  
  //SEED
  void seedUpdate(){
    if(findFertilizer())
      this.state = PlantState.SPROUT;
  }
  void seedRender(){
    fill(fillColor);
    stroke(fillColor);
    strokeWeight(1);
    line(location.x, location.y, location.x+1 ,location.y+1);
  }
  
  
  //SPROUT
  void sproutUpdate(long deltaTime){
    eatTimer.update(deltaTime);
    if(eatTimer.expired()){
      if(fertilizer != null){
        int newEnergy = fertilizer.deplete(1);
        energy += newEnergy;
        if(newEnergy == 0)
          this.fertilizer = null;
      }else
        findFertilizer();
    }
    if(energy >= matureStateEnergy)
      this.state = PlantState.MATURE;

    sizeUpdate();
  }
  void sproutRender(){
    fill(sproutColor);
    stroke(sproutColor);
    strokeWeight(size.x);
    line(location.x, location.y, location.x+size.x ,location.y+size.y);
  }
  
  
  //MATURE
  void matureUpdate(long deltaTime){
    
    
    if(energy >= matureStateEnergy){
      eatTimer.update(deltaTime);
      if(eatTimer.expired()){
        if(fertilizer != null){
          int newEnergy = fertilizer.deplete(1);
          energy += newEnergy;
          if(newEnergy == 0)
            this.fertilizer = null;
        }else
          findFertilizer();
          
        if(energy >= floweringStateEnergy)
          this.state = PlantState.FLOWERING;
      }
    }else
      this.state = PlantState.SPROUT;
      
  }
  void matureRender(){
    fill(matureColor);
    stroke(matureColor);
    strokeWeight(size.x);
    line(location.x, location.y, location.x+size.x ,location.y+size.y);
  }
  
  
  //FLOWERING
  void floweringUpdate(long deltaTime){
    
    if(energy == floweringStateEnergy){ 
      floweringTimer.update(deltaTime);
      if(floweringTimer.expired()){
        int energyPerSeed = ((floweringStateEnergy - matureStateEnergy) / nbFlowerSeed); 
        for(int i = 0 ; i < nbFlowerSeed ; i++){
          PVector newLocation = new PVector(this.location.x+random(-flowerSeedRadius,flowerSeedRadius),this.location.y + random(-flowerSeedRadius,flowerSeedRadius));
          Plant newPlant = new Plant(newLocation.x,newLocation.y,world,energyPerSeed);
          this.energy -= energyPerSeed;
          world.addPlant(newPlant);
        }
        this.state = PlantState.MATURE;
      }
    }else
      this.state = PlantState.MATURE;  
      
  }
  
  void floweringRender(){
    fill(floweringColor);
    stroke(floweringColor);
    strokeWeight(size.x);
    line(location.x, location.y, location.x+size.x ,location.y+size.y);
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
  
  void sizeUpdate(){
    float proportion = (float) energy/matureStateEnergy;
    if(proportion > 1)
      proportion = 1;
    size.x = proportion * maturePlantSize.x;
    size.y = -(proportion * maturePlantSize.y);
  }
  
  Boolean findFertilizer(){
    for(Fertilizer f:fertilizers){
      if(PVector.dist(f.location,this.location) < fertilizerRayon){
        fertilizer = f;
        return true;
      }
    }
    return false;
  }
}