World world;

//time management variables
long previousTime = 0;
long currentTime = 0;
long deltaTime;

//key management variable
Boolean newWorldPress = false;
Boolean newFertilizerPress = false;
Boolean newPlantPress = false;
Boolean newHerbivorePress = false;
Boolean newCarnivorePress = false;

void setup () {
  
  fullScreen(1);
  //size (680, 384);
  world = new World();
 
}

void draw() {
  currentTime = millis();
  deltaTime = currentTime - previousTime;
  
  background (255);
  
  world.update(deltaTime);
  world.display();
  world.showData();
  
  showThanks();
  
  //assure la loop no matter what
  if(world.carnivores.size() == 0)
    world = new World();
  previousTime = currentTime; 
}

void showThanks() {
  fill(50);
  text ("Merci à Jimmy Béland-Bédard pour le PacMan", width - 275, height - 15);
}

void keyPressed() {
  if (key == 'w' && !newWorldPress){ 
    newWorldPress = true;
    world = new World();
  }
  if (key == 'f' && !newFertilizerPress){ 
    newFertilizerPress = true;
    world.addFertilizer(new Fertilizer(random (width), random (height),world));
  }
  if (key == 'p' && !newPlantPress){
    newPlantPress = true;
    world.addPlant(new Plant(random (width), random (height),world));
  }
  if (key == 'h' && !newHerbivorePress){
    newHerbivorePress = true;
    world.addHerbivore(new Herbivore(random (width), random (height),world));
  }
  if (key == 'c' && !newCarnivorePress){
    newCarnivorePress = true;
    world.addCarnivore(new Carnivore(random (width), random (height), world));
  }
}

void keyReleased() {
  if (key == 'w') 
    newWorldPress = false;
  if (key == 'f') 
    newFertilizerPress = false;
  if (key == 'p') 
    newPlantPress = false;
  if (key == 'h') 
    newHerbivorePress = false;
  if (key == 'c') 
    newCarnivorePress = false;
}
/**
  this class contains 4 types of components : fertilizer,herbivore,carnivore,plant
  those components interact with each other. The main idea is to represent world
  simulation with energy.Nothing is lost, nothing is created apply to this energy
  system.
**/
class World {
  
//config attributes
  final Boolean debug = false;
  final int startingHerbivore = 100;
  final int startingFertilizer = 30;
  final int startingPlant = 200;
  final int startingCarnivore = 2;
  
//world components
  ArrayList<Carnivore> carnivores;
  ArrayList<Fertilizer> fertilizers;
  ArrayList<Herbivore> herbivores;
  ArrayList<Plant> plants;
  ArrayList<Carnivore> deadCarnivores;
  ArrayList<Fertilizer> deadFertilizers;
  ArrayList<Herbivore> deadHerbivores;
  ArrayList<Plant> deadPlants;
  ArrayList<Carnivore> newCarnivores;
  ArrayList<Fertilizer> newFertilizers;
  ArrayList<Herbivore> newHerbivores;
  ArrayList<Plant> newPlants;
  
  float herbivoreAverageStartSpeed;
  float herbivoreAverageCurrentSpeed;
//constructor
  World() {
    
    carnivores = new ArrayList<Carnivore>();
    fertilizers = new ArrayList<Fertilizer>();
    herbivores = new ArrayList<Herbivore>();
    plants = new ArrayList<Plant>();
    deadCarnivores = new ArrayList<Carnivore>();
    deadFertilizers = new ArrayList<Fertilizer>();
    deadHerbivores = new ArrayList<Herbivore>();
    deadPlants = new ArrayList<Plant>();
    newCarnivores = new ArrayList<Carnivore>();
    newFertilizers = new ArrayList<Fertilizer>();
    newHerbivores = new ArrayList<Herbivore>();
    newPlants = new ArrayList<Plant>();
    
  //adding component
    float speedSum = 0;
    for (int i = 0; i < startingHerbivore; i++)
      herbivores.add(new Herbivore(random (width), random (height),this));
    for(Herbivore h : herbivores)
      speedSum += h.speed;
    herbivoreAverageStartSpeed = speedSum / startingHerbivore;
      
    for (int i = 0; i < startingFertilizer; i++) 
      fertilizers.add(new Fertilizer(random (width), random (height),this));
      
    for (int i = 0; i < startingPlant; i++) 
      plants.add(new Plant(random (width), random (height),this));
      
    for (int i = 0; i < startingCarnivore; i++) 
      carnivores.add(new Carnivore(random (width), random (height), this));
  }
  
  void update(long delta) {
    
  //update component
    for(Herbivore h : herbivores)
      h.update(delta);
      
    for(Plant p : plants)
      p.update(delta);
      
    for(Fertilizer f : fertilizers)
      f.update(delta);
    
    for(Carnivore c : carnivores)
      c.update(delta);
   
   //kill component
     fertilizers.removeAll(deadFertilizers);
     carnivores.removeAll(deadCarnivores);
     plants.removeAll(deadPlants);
     herbivores.removeAll(deadHerbivores);
     deadFertilizers.clear();
     deadCarnivores.clear();
     deadPlants.clear();
     deadHerbivores.clear();
     
   //add new component
     fertilizers.addAll(newFertilizers);
     carnivores.addAll(newCarnivores);
     plants.addAll(newPlants);
     herbivores.addAll(newHerbivores);
     newFertilizers.clear();
     newCarnivores.clear();
     newPlants.clear();
     newHerbivores.clear();
     
  }
  
  void display () {
    
    //render component
    for(Fertilizer f : fertilizers)
      f.render();
      
    for(Plant p : plants)
      p.render();
      
    for(Herbivore h : herbivores)
      h.render();
      
    for(Carnivore c : carnivores)
      c.render();
  }
  
  void showData() {
    fill(50);
    int fertilizerEnergy = getFertilizerEnergy();
    int plantEnergy = getPlantEnergy();
    int herbivoreEnergy = getHerbivoreEnergy();
    int carnivoreEnergy = getCarnivoreEnergy();
    int worldEnergy = herbivoreEnergy + plantEnergy + fertilizerEnergy + carnivoreEnergy;
    
    float speedSum = 0;
    for(Herbivore h : herbivores)
      speedSum += h.speed;
    herbivoreAverageCurrentSpeed = speedSum / herbivores.size();
    text ("Fertilizer count: " + fertilizers.size(), width - 275, 15);
    text ("total energy: " + fertilizerEnergy, width - 150, 15);
    
    text ("Plant count: " + plants.size(), width - 275, 25);
    text ("total energy: " + plantEnergy, width - 150, 25);
    
    text ("Herbivore count: " + herbivores.size(), width - 275, 35);
    text ("total energy: " + herbivoreEnergy, width - 150, 35);
    
    text ("Carnivore count: " + carnivores.size(), width - 275, 45);
    text ("total energy: " + carnivoreEnergy, width - 150, 45);
    
    text ("total world energy: " + worldEnergy, width - 150, 55);
    
    text ("Herbivore startSpeed average " + herbivoreAverageStartSpeed, width - 275, 85);
    text ("herbivore Average Current Speed :  " + herbivoreAverageCurrentSpeed, width - 275, 95);
  }

//Components management methods
  //Fertilizer
  void addFertilizer(Fertilizer fertilizer){
    newFertilizers.add(fertilizer);
  }
  
  void removeFertilizer(Fertilizer fertilizer){
    deadFertilizers.add(fertilizer);
  }
  
  int getFertilizerEnergy(){
    int sum = 0;
    for(Fertilizer f:fertilizers)
      sum += f.energy;
    return sum;
  }
  
  //Plant
  void addPlant(Plant plant){
    newPlants.add(plant);
  }
  
  void removePlant(Plant plant){
    deadPlants.add(plant);
  }
  
  int getPlantEnergy(){
    int sum = 0;
    for(Plant p:plants)
      sum += p.energy;
    return sum;
  }
  
  //Herbivore
  void addHerbivore(Herbivore herbivore){
    newHerbivores.add(herbivore);
  }
  
  void removeHerbivore(Herbivore herbivore){
    deadHerbivores.add(herbivore);
  }
  
  int getHerbivoreEnergy(){
    int sum = 0;
    for(Herbivore h:herbivores)
      sum += h.energy;
    return sum;
  }
  
  //Carnivore
  void addCarnivore(Carnivore carnivore){
    newCarnivores.add(carnivore);
  }
  
  void removeCarnivore(Carnivore carnivore){
    deadCarnivores.add(carnivore);
  }
  
  int getCarnivoreEnergy(){
    int sum = 0;
    for(Carnivore c:carnivores)
      sum += c.energy;
    return sum;
  }
  
}