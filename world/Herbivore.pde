public enum HerbivoreState {WANDERING, EATING,MATING, BREEDING}

class Herbivore extends WorldObject {
  
//config attributes
  //wandering state attributes
  final static int wanderingDelay = 40000;
  //EATING state attributes
  final static float eatRadius = 5;
  final static int eatDelay = 100;
  final static int eatAmount = 3;
  final static int feedingDelay = 5000;
  final static float feedingRadius = 25;
  //mating state attributes
  final static int matingDelay = 20000;
  final static int sexDelay = 2000;
  final static int matingEnergyRequired = 150;
  final static float sexRadius = 5;
  final static float matingRadius = 200;
  //escape attributes
  final static float escapeRadius = 75;
  final static float escapeWeight = 50;
  //breeding state attributes
  final static int breedingDelay = 5000;
  //herbivore attributes
  static final int defaultRayon = 3;
  static final float energySizeMultiplicator = 0.03;//used to calcul sizeModifier
  static final int defaultEnergy = 100; 
  final static float defaultSpeed = 2;
  final static float geneticSpeedVariance = 1.00; // represent % of variance of speed inbetween agent
  final static int poopDelay = 120000;
  //Flock movement attributes
  final static float separationRadius = 25;
  final static float alignmentRadius = 50;
  final static float cohesionRadius = 50;
  final static float separationWeight = 1.5;
  final static float cohesionWeight = 1;
  final static float alignmentWeight = 1;
  final static float topSteer = .03;

  //attributes
  int energy;
  HerbivoreState state;
  HerbivoreState beforeEscapeState;
  ArrayList<Plant> plants;
  ArrayList<Herbivore> herbivores;
  ArrayList<Carnivore> carnivores;
  float r; // Rayon du boid
  color c;
  Boolean isMale;
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float speed;
  PVector separation;
  PVector alignment;
  PVector cohesion;
  PVector food;
  PVector escape;
  PVector mate;
  PVector sexLocation;
  
  Delay eatTimer = new Delay(eatDelay);
  Delay wanderingTimer = new Delay(wanderingDelay);
  Delay feedingTimer = new Delay(feedingDelay);
  Delay poopTimer = new Delay(poopDelay);
  Delay matingTimer= new Delay(matingDelay);
  Delay breedingTimer = new Delay(breedingDelay);
  Delay sexTimer = new Delay(sexDelay);
  Boolean hasPartner = false;
  Herbivore partner = null;
//CONSTRUCTOR
  Herbivore(float x,float y, World world){
  //WorldObject attributes
    this.location = new PVector(x,y);
    this.world = world;
    //herbivore attributes
    this.carnivores = world.carnivores;
    this.herbivores = world.herbivores;
    this.plants = world.plants;
    this.state = HerbivoreState.WANDERING;
    this.energy = defaultEnergy;
    this.isMale = (int)random (9) % 2 == 1;
    poopTimer.update(random(0,poopDelay));
    wanderingTimer.update(random(0,wanderingDelay));
    velocity.set(random(10),random(10));
    velocity.limit(speed);
    updateSize();//set r in proportion with current energy
    speed = defaultSpeed;
    speed += random(-geneticSpeedVariance,geneticSpeedVariance);
  }
  //apply 50% inherite genetic to geneticSpeedModifier
  void setGeneticInheriteSpeedModifier(float modifier){
    float currentGeneticVariance = speed - defaultSpeed;
    currentGeneticVariance = currentGeneticVariance/2 + modifier;
    speed = defaultSpeed + currentGeneticVariance;
  }
  
//INHERITE METHODS
  void update(long deltaTime){
    switch(state){
      case WANDERING:
        wanderingUpdate(deltaTime);
        break;
      case EATING:
        eatingUpdate(deltaTime);
        break;
      case MATING:
        matingUpdate(deltaTime);
        break;
      case BREEDING:
        breedingUpdate(deltaTime);
        break;

    }
    
    velocity.add (acceleration);
    velocity.limit(speed);
    location.add (velocity);
    acceleration.set(0,0);
    
    checkEdges();
    updateSize();
    setColor();
    //life management
    if(energy <= 0)
      world.removeHerbivore(this);
  }
  void render(){
    noStroke();
    fill (c);
    
    float theta = velocity.heading() + radians(90);
    pushMatrix();
    translate(location.x, location.y);

    rotate (theta);
    beginShape(TRIANGLES);
    vertex(0, -r * 2);
    vertex(-r, r * 2);
    vertex(r, r * 2);
    endShape();
    
    popMatrix();
  }
  
//state methods

  void wanderingUpdate(long deltaTime){
    
    applyFlockForces();
    applyEscapeForce();
    poopTimer.update(deltaTime);
    if(poopTimer.expired())
    poop();
   
    wanderingTimer.update(deltaTime);
    if(wanderingTimer.expired())
      this.state = HerbivoreState.EATING;
    
    if(energy >= matingEnergyRequired)
      this.state = HerbivoreState.MATING;
  }
  
  void eatingUpdate(long deltaTime){
    applyEscapeForce();
    food = calculFood();
    this.acceleration.add(food);
    
    eatTimer.update(deltaTime);
    if(eatTimer.expired())
      eat();
      
    feedingTimer.update(deltaTime);
    if(feedingTimer.expired())
      this.state = HerbivoreState.WANDERING;
  }
  
  void matingUpdate(long deltaTime){
    matingTimer.update(deltaTime);
    applyEscapeForce();
    applyFlockForces();
    if(matingTimer.expired()){
      this.state = HerbivoreState.WANDERING;
      hasPartner = false;
    }
    else{
      if(!hasPartner){
        findPartner();
      }else{
         //go towards partner
         if(partner != null){
           mate = PVector.sub (sexLocation, location);
           mate.limit(speed);
           this.acceleration.add(mate);
           //if partner close enuff and you male put baby in it
           if(isMale && PVector.dist(location,partner.location) <= sexRadius){
             sexTimer.update(deltaTime);
             matingTimer.accumulator = 0;
             
             //BABY CREATION
             if(sexTimer.expired()){
               partner.energy += 50;
               this.energy -= 50;
               this.state = HerbivoreState.WANDERING;
               partner.state = HerbivoreState.BREEDING;
               hasPartner = false;
               partner.hasPartner = false;
               partner.partner = null;
               partner = null;
             }  
             
           }
         }else{
           findPartner();
         }  
      }
    }
  }

  void breedingUpdate(long deltaTime){
    
    applyFlockForces();
    applyEscapeForce();
    breedingTimer.update(deltaTime);
    if(breedingTimer.expired()){
      Herbivore newHerbivore = new Herbivore(location.x,location.y,world);
      newHerbivore.setGeneticInheriteSpeedModifier((float)(speed - defaultSpeed)/2);
      world.addHerbivore(newHerbivore);
      this.energy -= defaultEnergy;
      this.state = HerbivoreState.WANDERING;
    }
  }

  
//METHODS
 
  void findPartner() {
     for(Herbivore h:herbivores){
       //si le candidat est sexe opposer et en rut et sans partner
       if(h.state == HerbivoreState.MATING && h.isMale != this.isMale && !h.hasPartner){
         float d = PVector.dist (this.location, h.location);
         if(d <= matingRadius){
           this.partner = h;
           h.partner = this;
           this.hasPartner = true;
           h.hasPartner = true;
         
           sexLocation = new PVector(location.x,location.y);
           partner.sexLocation = sexLocation;
         }
       }
     }
  }
  // REGARDE LES AGENTS DANS LE VOISINAGE ET CALCULE UNE FORCE DE RÉPULSION
  PVector calculSeparation () {
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    
    for (Herbivore other : herbivores) {
      float d = PVector.dist (this.location, other.location);
      
      if ((d > 0) && (d < separationRadius)) {
        // Calculer le vecteur qui pointe contre le voisin
        PVector diff = PVector.sub (this.location, other.location);
        
        diff.normalize();
        diff.div(d);
        
        steer.add(diff);
        count++;
      }
    }
 
    if (count > 0) 
      steer.div((float)count);
    
    if (steer.mag() > 0) {
      steer.setMag(speed);
      steer.sub(velocity);
      steer.limit(topSteer);
    }
    
    return steer;
  }
  
  // ALIGNEMENT DE L'AGENTS AVEC LE RESTANT DU GROUPE
  // MOYENNE DE VITESSE AVEC TOUS LES AGENTS DANS LE VOISINAGE
  PVector calculAlignment () {
    PVector sum = new PVector(0, 0);
    int count = 0;
    
    for (Herbivore other : herbivores) {
      float d = PVector.dist (this.location, other.location);
      
      if (d > 0 && d < alignmentRadius) {
        sum.add (other.velocity);
        count++;
      }
    }
    
    if (count > 0) {
      sum.div((float)count);
      sum.setMag(speed);
      
      PVector steer = PVector.sub (sum, this.velocity);
      steer.limit (topSteer);
      
      return steer;
    }
    else {
      return new PVector(0, 0);
    }
  }
  
  // REGARDE LE GROUPE ET S'Y COLLE
  PVector calculCohesion() {
    PVector sum = new PVector(0, 0); 
    int count = 0;
    
    for (Herbivore other : herbivores) {
      float d = PVector.dist(this.location, other.location);
      if (d > 0 && d < cohesionRadius) {
        sum.add(other.location);
        count++;
      }
    }
    
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    
    }
    else {
      return new PVector(0, 0);
    }
  }
  //look for Carnivore and calcul PVector for escape
  PVector calculEscape() {
    
    PVector result = new PVector(0,0);
    int count = 0;
    
    for (Carnivore c:carnivores) {
      float distanceToPredator = PVector.dist(location, c.location);
      
      if (distanceToPredator < escapeRadius) {
        result.add(PVector.sub(location, c.location));
        count++;
      }
    }
    
    if (count > 0) {
      result.div(count);
      result.limit(speed);
    }
    return result;
  }
  //look for plant around and calcul forces on the closest one
  PVector calculFood () {
    PVector result = new PVector(0,0);
    Plant closestPlant = null;
    float bestDistance = 9999999;
    for (Plant p:plants){
      if(p.state != PlantState.SEED){
        float distanceToPlant = PVector.dist(location, p.location);
        if(distanceToPlant <= feedingRadius && distanceToPlant <= bestDistance){
          bestDistance = distanceToPlant;
          closestPlant = p;
        }
      }
    }
    
    if(closestPlant != null){
      result = PVector.sub(closestPlant.location, location);
      result.limit(speed);
    }
    
    return result;
  }
  
  
  void updateSize(){
    r = energySizeMultiplicator * energy;
  }
  void checkEdges() { 
    if (location.x < -r) 
      location.x = width + r;
    if (location.y < -r) 
      location.y = height + r;
    if (location.x > width + r) 
      location.x = -r;
    if (location.y > height + r) 
      location.y = -r;
  }
  void setColor(){
    switch(state){
      case WANDERING :
          c = isMale ? #000044 : #440044;
          break;
      case EATING:
          c = isMale ? #000044 : #440044;
          break;
      case BREEDING:
          c = #00FFFF;
          break;
      case MATING:
          c = isMale ? #0000bb : #bb00FF;
          break;
    }
  }
  
   PVector seek (PVector target) {
    // Vecteur différentiel vers la cible
    PVector desired = PVector.sub (target, this.location);
    
    // VITESSE MAXIMALE VERS LA CIBLE
    desired.setMag(speed);
    
    // Braquage
    PVector steer = PVector.sub (desired, velocity);
    steer.limit(topSteer);
    
    return steer;    
  }
  
  void eat(){
    for (Plant p : plants) {
      if(p.state != PlantState.SEED){
        float d = PVector.dist (this.location, p.location);
        if(d <= eatRadius)
          this.energy += p.deplete(eatAmount);          
      }
    }
  }
  
  void poop(){
    
    if(energy > 50){
      world.addFertilizer(new Fertilizer(location.x,location.y,world,30));
      this.energy -= 30;
      if(random(5) < 2){
        this.energy -= 20;
        world.addPlant(new Plant(location.x,location.y,world));
      }
      
    }else{
      world.addFertilizer(new Fertilizer(location.x,location.y,world,this.energy));
      energy = 0;
    } 
  }
  
  void applyFlockForces(){
    separation = calculSeparation();
    cohesion = calculCohesion();
    alignment = calculAlignment();
    
    separation.mult (separationWeight);
    alignment.mult (alignmentWeight);
    cohesion.mult (cohesionWeight);
    
    this.acceleration.add(separation);
    this.acceleration.add(alignment);
    this.acceleration.add(cohesion);
  }
  void applyEscapeForce(){
    escape = calculEscape();
    escape.mult(escapeWeight);
    acceleration.add(escape);
  }
}