public enum HerbivoreState {WANDERING, HUNGRY ,MATING, BREEDING}

class Herbivore extends WorldObject {
  
  //config attributes
  final static float mass = 1;
  static final float MIN_RADIUS = 2;
  static final float MAX_RADIUS = 4;
  static final int MAX_ENERGY = 500;
  final static float eatRadius = 5;
  final static int eatTime = 100;
  final static int wanderingTime = 40000;
  final static int feedingTime = 5000;
  final static int poopTime = 80000;
  final static int breedingTime = 20000;
  final static int matingTime = 20000;
  final static int sexTime = 5000;
  final static float separationRadius = 25;
  final static float alignmentRadius = 50;
  final static float cohesionRadius = 50;
  final static float feedingRadius = 25;
  final static float matingRadius = 200;
  final static float sexRadius = 5;
  final static float escapeRadius = 75;
  
  final static float separationWeight = 1.5;
  final static float cohesionWeight = 1;
  final static float alignmentWeight = 1;
  final static float feedingWeight = 0.25;
  final static float matingWeight = 200;
  final static float escapeWeight = 0.5;
  
  final static float topSteer = .03;
  final static float topSpeed = 2;
  
  final static int matingEnergyRequired = 200;
  //attributes
  int energy;
  HerbivoreState state;
  ArrayList<Plant> plants;
  ArrayList<Herbivore> herbivores;
  ArrayList<Carnivore> carnivores;
  float r; // Rayon du boid
  color c;
  Boolean isMale;
  PVector velocity = new PVector();
  PVector acceleration = new PVector();

  PVector separation;
  PVector alignment;
  PVector cohesion;
  PVector food;
  PVector escape;
  PVector mate;
  PVector sexLocation;
  
  Delay eatTimer;
  Delay wanderingTimer;
  Delay feedingTimer;
  Delay poopTimer;
  Delay matingTimer= new Delay(matingTime);
  Delay breedingTimer = new Delay(breedingTime);
  Delay sexTimer = new Delay(sexTime);
  Boolean hasPartner = false;
  Herbivore partner = null;
//CONSTRUCTOR
  Herbivore(float x,float y, World world){
    //WorldObject attributes
    this.location = new PVector(x,y);
    this.world = world;
    this.size = new PVector (16, 16);
    angle = size.heading();
    //herbivore attributes
    this.carnivores = world.carnivores;
    this.herbivores = world.herbivores;
    this.plants = world.plants;
    this.state = HerbivoreState.WANDERING;
    this.energy = 100;
    this.isMale = (int)random (9) % 2 == 1;
    eatTimer = new Delay(eatTime);
    poopTimer = new Delay(poopTime);
    poopTimer.update(random(0,poopTime));
    wanderingTimer = new Delay(wanderingTime);
    wanderingTimer.update(random(0,wanderingTime));
    feedingTimer = new Delay(feedingTime);
    updateSize();//set r in proportion with current energy
    
  }
  
  
//INHERITE METHODS
  void update(long deltaTime){
    
    switch(state){
      case WANDERING:
        wanderingUpdate(deltaTime);
        break;
      case HUNGRY:
        hungryUpdate(deltaTime);
        break;
      case MATING:
        matingUpdate(deltaTime);
        break;
      case BREEDING:
        breedingUpdate(deltaTime);
        break;
    }
    velocity.add (acceleration);
    velocity.limit(topSpeed);
    location.add (velocity);
    acceleration.mult (0);
    
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
  
  
//STATE METHODS
  void wanderingUpdate(long deltaTime){
    
    separation = calculSeparation();
    cohesion = calculCohesion();
    alignment = calculAlignment();
    escape = calculEscape();
    
    
    separation.mult (separationWeight);
    alignment.mult (alignmentWeight);
    cohesion.mult (cohesionWeight);
    escape.mult(escapeWeight);
    
    
    this.acceleration.add(separation);
    this.acceleration.add(alignment);
    this.acceleration.add(cohesion);
    this.acceleration.add(escape);
    
    poopTimer.update(deltaTime);
    if(poopTimer.expired())
      poop();
    
    
    wanderingTimer.update(deltaTime);
    if(wanderingTimer.expired())
      this.state = HerbivoreState.HUNGRY;
    
    if(energy >= matingEnergyRequired)
      this.state = HerbivoreState.MATING;
    
  }
  void hungryUpdate(long deltaTime){
    food = calculFood();
    food.mult(feedingWeight);
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
    
    if(!matingTimer.expired()){
      if(!hasPartner){
        findPartner();
      }else{
         //go towards partner
         if(partner != null){
           mate = PVector.sub (sexLocation, location);
           mate.mult(matingWeight);
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
    }else{
      this.state = HerbivoreState.WANDERING;
    }
    
    
    //
  }
  void breedingUpdate(long deltaTime){
    breedingTimer.update(deltaTime);
    if(breedingTimer.expired()){
      world.addHerbivore(new Herbivore(location.x,location.y,world));
      this.energy -= 100;
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
           sexLocation.add(PVector.sub(this.location,h.location));
           partner.sexLocation = sexLocation;
           println("findPartner");
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
      steer.setMag(topSpeed);
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
      sum.setMag(topSpeed);
      
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
  PVector calculEscape () {
    PVector result = new PVector(0,0);
    int count = 0;
    
    for (Carnivore c:carnivores) {
      float distanceToPredator = PVector.dist(location, c.location);
      
      if (distanceToPredator < escapeRadius) {
        if (result == null) {
          result = new PVector (0, 0);
        }
        result.add(PVector.sub(location, c.location));
        count++;
      }
    }
    
    if (result != null && count > 0) {
      result.div(count);
      //result.mult(-1);
      result.limit(topSpeed);

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
    
    if(closestPlant != null)
      return PVector.sub (closestPlant.location, location);
    
    return result;
  }
  
  void updateSize() {
    r = map (energy, 0, MAX_ENERGY, MIN_RADIUS, MAX_RADIUS);
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
          c = isMale ? #0000AA : #AA00AA;
          break;
      case HUNGRY:
          c = isMale ? #0000FF : #FF00FF;
          break;
      case BREEDING:
          c = isMale ? #0000FF : #FFFFFF;
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
    desired.setMag(topSpeed);
    
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
          this.energy += p.deplete(1);          
      }
    }
  }
  
  void poop(){
    
    if(energy > 50){
      world.addFertilizer(new Fertilizer(location.x,location.y,world,30));
      world.addPlant(new Plant(location.x,location.y,world,20));
      this.energy -= 50;
    }else{
      world.addFertilizer(new Fertilizer(location.x,location.y,world,this.energy));
      energy = 0;
    } 
  }
  
}