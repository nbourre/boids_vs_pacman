class World {
  Boolean debug = false;

  int nbBoids = 200;
  
  Flock flock;
  
  Pacman pm;
  ArrayList<Food> foods;
  ArrayList<Predator> predators;
  
  int huntingAcc = 0;
  int huntingKeyDelay = 250;
  
  long deltaTime;
  
  World() {
    //size (600, 360);
    foods = new ArrayList<Food>();
    //foods.add (new Food (width / 2, height / 2, this));
    /** BEGIN : Flock management **/
    flock = new Flock();
    
    for (int i = 0; i < nbBoids; i++) {
      Boid b = new Boid(this);
      
      if (i % 2 == 0) {
        b.setXY (width / 2, height / 2);
      }
      
      flock.addBoid(b);
    }
    /** END : Flock management **/
    
    /** BEGIN : Predator management **/
    predators = new ArrayList<Predator>();
    
    pm = new Pacman(new PVector( random (width), random (height)), new PVector (50, 50), this);
    pm.setPreys(flock.getFlock());
    
    predators.add(pm);

    
    
    for (Predator p : predators) {
      p.poops = foods;
    }
    /** END : Predator management **/
  }
  
  
  
  void update(long delta) {
    deltaTime = delta;
    flock.run();
    
    manageInputs();
    
    huntingAcc += delta;
    if (keyPressed) {
      if (key == 'h') {
        if (huntingAcc > huntingKeyDelay) {
          huntingAcc = 0;
          pm.toggleHunting();
        }
      }
    }
    
    updateFood(delta);
    updatePredators(delta);
    
    //saveFrame("frames/####.png");
  }
  
  long getDeltaTime() {
    return deltaTime;    
  }
  
  void display () {
    background (255);
    
    for (Food f : foods){
      f.display();
    }
    
    flock.render();
    
    pm.display();
    
    showThanks();
    showData();
  }
  
  
  
  void showThanks() {
    fill(50);
    text ("Merci à Jimmy Béland-Bédard pour le PacMan", width - 275, height - 15);
  }
  
  void showData() {
    fill(50);
    text ("Mangé : " + pm.preysEaten, width - 275, 15);
  }
  
  void manageInputs () {
    if (mousePressed) {
      Boid b = new Boid(this);
      b.setXY (mouseX, mouseY);
      b.setColor (color(255, 0, 0, 255));
      flock.addBoid(b);
      
    }    
  }
  
  void updateFood(float delta) {
    for (Food f : foods){
      f.update(delta);
    }
    
    for (int i = 0; i < foods.size(); i++) {
      Food f = foods.get(i);
      if (!f.isAvailable) {
        foods.remove(f);
      }
    }
  }
  
  void updatePredators (float delta) {
    for (Predator p : predators) {
      p.update(delta);
    }
  }
  
  void keyPressed() {
    
    if (key == 'd') {
      flock.debug = !flock.debug;
      println("test");
    }
  }
  
  ArrayList<Predator> getPredators() {
    return predators;
  }
  
}