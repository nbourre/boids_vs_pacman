class Boid extends Prey {

  
  float r; // Rayon du boid
  
  static final float MIN_RADIUS = 2;
  static final float MAX_RADIUS = 4;
  static final float DEF_RADIUS = 2;
  
  static final int MAX_ENERGY = 500;
  
  float topSpeed; // Vitesse maximum
  float topSteer; // Braquage maximum
  
  float cohesionRadius;
  float separationRadius;
  float alignmentRadius;
  float feedingRadius;
  
  float separationWeight;
  float cohesionWeight;
  float alignmentWeight;
  float feedingWeight;
  float escapeWeight;
  
  PVector size; 
  float mass = 1;
  
  PVector separation;
  PVector cohesion;
  PVector alignment;
  
  color c;
  
  boolean isMale = (int)random (9) % 2 == 1;
  
  Boolean debug;
  
  boolean hasMated = false;
  float matingRadius = 200;
  
  Delay matingDelay;
  
  
  Boid (World world) {
    super (world);
    this.location = new PVector (random (width), random (height));    
    
    float angle = random(TWO_PI);
    this.velocity = new PVector(cos(angle), sin(angle));
    
    initDefautValues();
  }
  
  Boid (PVector loc, World world) {
    super (world);
    this.location = loc;
    this.velocity = new PVector (0, 0);
    
    initDefautValues();
  }
  
  Boid (PVector loc, PVector vel, World world) {
    super (world);
    this.location = loc;
    this.velocity = vel;
    
    initDefautValues();
  }
  
  Boid (float m, float x, float y, World world) {
    super (world);
    mass = m;
    location = new PVector (x, y);
    
    velocity = new PVector(0, 0);
    
    initDefautValues();
  }
  
  Boid (float x, float y, World world) {
    super (world);
    acceleration = new PVector (0, 0);
    float angle = random (TWO_PI);
    velocity = new PVector (cos(angle), sin(angle));
    
    location = new PVector (x, y);
    
    r = DEF_RADIUS;
    topSpeed = 2;
    topSteer = 0.03;
  }
  
  private void initDefautValues() {
    cohesionRadius = 50;
    separationRadius = 25;
    alignmentRadius = 50;
    feedingRadius = 100;
    
    cohesionWeight = 1;
    separationWeight = 1.5;
    alignmentWeight = 1;
    escapeWeight = 0.5;
    feedingWeight = 0.25;
    
    updateSize();
    
    topSpeed = 2;
    topSteer = .03;
    
    this.acceleration = new PVector (0 , 0);
    this.size = new PVector (16, 16);
    
    setStateColor();
    
    //this.c = color(127, 127, 127, 127);
    
    escapeDistance = 100;
    
    matingDelay = new Delay (4000);
    
    debug = false;
  }
  
  void run (ArrayList <Boid> boids) {
    
    
    flock(boids);
    update();
    checkEdges();
  }  
  
  void applyForce (PVector force) {
    PVector f;
    
    if (force != null) {
      if (mass != 1)
        f = PVector.div (force, mass);
      else
        f = force;
     
      this.acceleration.add(f);
    }
  }
  
  void flock(ArrayList <Boid> boids) {

    
    wandering(boids);
    
    
    PVector esc = escape (world.getPredators());
    if (esc != null) {
      esc.mult (escapeWeight);
      applyForce (esc);
      state = State.ESCAPING;
    }
    
    
    PVector food = seekFood (world.foods);
    if (food != null) {
      if (state != State.ESCAPING) {
        food.mult (feedingWeight);
        applyForce (food);        
      }          
    }
        /*
    switch (state) {
      case WANDERING:
        
        break;
      case ESCAPING:
        
        break;
      case HUNTING:
      break;
      case FEEDING:
        if (food != null) {
          food.mult (feedingWeight);
          applyForce (food);
          
          if (esc != null) {
            state = State.ESCAPING;
          }          
        } else {
          state = energy > breedingEnergy ? State.RUT : State.WANDERING;
        }
        break;
      case RUT:
        wandering(boids);
        rut(boids);
        break;
      case MATING:
        mate();
      break;
      
      default:
      break;
    }
    */
    
    setStateColor();
    


  }
  
  void update () {
    velocity.add (acceleration);
    velocity.limit(topSpeed);
    
    location.add (velocity);

    acceleration.mult (0);
  }
  
  void breed(){
  }
  
  void mate() {
    
    if (!matingDelay.expired()) {
      matingDelay.update(world.getDeltaTime());
            
      angle += 0.01;
    } else {
      angle = 0;
      state = State.WANDERING;
    }
  }
  
  void wandering(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    
    // Pondérer chacune des forces
    sep.mult (separationWeight);
    ali.mult (alignmentWeight);
    coh.mult (cohesionWeight);
    
    // Ajouter chacune des forces
    applyForce (sep);
    applyForce (ali);
    applyForce (coh);
    
    if (debug) {
      this.separation = sep;
      this.cohesion = coh;
      this.alignment = ali;
    }
    
    if (hasPartner()) {
      stickToPartner();
    }
  }
  
  void stickToPartner() {
    applyForce (seek (partner.location));
    PVector ali = PVector.sub (partner.velocity, velocity);
    ali.mult (1.5);
    applyForce (ali.limit (topSteer));
    
    
  }
  
  void updateSize() {
    r = map (energy, 0, MAX_ENERGY, MIN_RADIUS, MAX_RADIUS);
  }

  // Méthode qui calcule et applique une force de rotation vers une cible
  // STEER = CIBLE moins VITESSE
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
  
  void rut(ArrayList<Boid> boids) {
    
    if (!hasPartner()) {
      findPartner(boids);
    } else {
      moveToPartner();
    }
  }
  
  void setStateColor () {
    switch (state) {
      case WANDERING :
        c = isMale ? #0000AA : #AA00AA;
        break;
      case RUT:
        c = isMale ? #0000FF : #FF00FF;
        break;
      default:
        c = isMale ? #0000AA : #AA00AA;
        break;
    }
  }
  
  void moveToPartner () {
    if (hasPartner()) {
      applyForce (seek (partner.location));
      
      float distanceToTarget = PVector.dist(target, location);
      if (distanceToTarget < atTarget) {
        state = State.WANDERING;
      }
    }
  }
  
  void findPartner(ArrayList<Boid> boids) {
    boolean found = false;
    for (int i = 0; i < boids.size() && !found; i++) {
      Boid other = boids.get(i);
      boolean otherInRut = other.getState() == State.RUT;
      boolean isOppositeSex = other.isMale != isMale;
      boolean isFree = !other.hasPartner();
      
      if (otherInRut && isOppositeSex && isFree) {
        float distanceToMate = PVector.dist (other.location, this.location);
        
        if (distanceToMate <= matingRadius) {
          found = true;
          setPartner(other);
          other.setPartner(this);
        }
      }
    }
  }
  
  void render () {
    //stroke (0);
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
    
    if (debug) {
      renderDebug();
    }
  }
  
  void checkEdges() {
    boolean changedSide = false;
    
    if (location.x < -r) {
      location.x = width + r;
      changedSide = true;
    }
    
    if (location.y < -r) {
      location.y = height + r;
      changedSide = true;
    }
    
    if (location.x > width + r) {
      location.x = -r;
      changedSide = true;
    }
    
    if (location.y > height + r) {
      location.y = -r;
      changedSide = true;
    }
    
    hasEscaped = changedSide;
    
  }
  
  
  Rectangle getRectangle() {
    Rectangle r = new Rectangle(location.x, location.y, size.x, size.y);
    
    return r;
  }
  
  void setXY(int x, int y) {
    this.location.x = x;
    this.location.y = y;
  }
  
  // REGARDE LES AGENTS DANS LE VOISINAGE ET CALCULE UNE FORCE DE RÉPULSION
  PVector separate (ArrayList<Boid> boids) {
    PVector steer = new PVector(0, 0, 0);
    
    int count = 0;
    
    for (Boid other : boids) {
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
      
    if (count > 0) {
      steer.div((float)count);
    }
    
    if (steer.mag() > 0) {
      steer.setMag(topSpeed);
      steer.sub(velocity);
      steer.limit(topSteer);
    }
    
    
    return steer;
  }
  
  // ALIGNEMENT DE L'AGENTS AVEC LE RESTANT DU GROUPE
  // MOYENNE DE VITESSE AVEC TOUS LES AGENTS DANS LE VOISINAGE
  PVector align (ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    
    int count = 0;
    
    for (Boid other : boids) {
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
  PVector cohesion(ArrayList<Boid> boids) {
    PVector sum = new PVector(0, 0);
    
    int count = 0;
    
    for (Boid other : boids) {
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
  
  PVector escape (ArrayList<Predator> preds) {
    PVector result = null;
    int count = 0;
    
    for (Predator p : preds) {
      float distanceToPredator = PVector.dist(location, p.location);
      
      if (distanceToPredator < escapeDistance) {
        if (result == null) {
          result = new PVector (0, 0);
        }
        result.add(PVector.sub(location, p.location));
        count++;
      }
    }
    
    if (result != null && count > 0) {
      result.div(count);
      //result.mult(-1);
      result.limit(topSpeed);
      
      state = State.ESCAPING;
    }
    
    return result;
  }
  
 
  void setColor (color c) {
    this.c = c;
  }
  
  void renderDebug() {
    //textByLine ("Sep : " + pvectorToString(separation), 1);
    //textByLine ("Coh : " + pvectorToString(cohesion), 2);
    //textByLine ("Ali : " + pvectorToString(alignment), 3);
    
    noFill();
    stroke(200, 0, 0);
    ellipse(location.x, location.y, cohesionRadius, cohesionRadius);
    
    switch (state) {
      case MATING: {
        
        break;
      }
        
        
      default:
        
    }
  }
  
  void textByLine (String msg, int line) {
    int tPoint = 16;
    textSize(tPoint);
    fill (0);
    text (msg, 10, 15 + ((line - 1) * tPoint));
  }
  
  String pvectorToString(PVector v) {
    if (v != null)
      return "(" + v.x + ", " + v.y + ")";
    return "null";
  }
  
  PVector seekFood (ArrayList<Food> foods) {
    PVector result = null;
    
    for (int i = 0; i < foods.size(); i++) {
      Food f = foods.get (i);
      
      float distanceToFood = PVector.dist (location, f.location);
      
      if (distanceToFood < feedingRadius) {
        result = new PVector();
            
        result = PVector.sub (f.location, location);
        
        result.normalize();
        
        if (distanceToFood < f.size.x) {
          state = State.FEEDING;
          f.energy--;
          this.energy++;
          updateSize();
          println (this.energy);
        } else {
          state = State.HUNTING;
        }
        
        break;
      }
    }
    
    
    return result;
  }
  
  PVector attractionForce(Mover m) {
    PVector force = PVector.sub(location, m.location);
    float distance = force.mag();
    distance = constrain (distance, 5.0, 25.0);
    
    force.normalize();
    float strength = 1 / (distance * distance);
    force.mult(strength);
    
    return force;
  }
  
  State getState() {
    return state;
  }
  
}