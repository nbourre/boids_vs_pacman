class Flock {
  ArrayList<Boid> boids;
  
  Boolean debug = false;
  
  Flock() {
    boids = new ArrayList<Boid>();
  }
  
  void run () {
    for (Boid b : boids) {
      b.run(boids);
      
      b.debug = debug;
    }
  }
  
 
  void addBoid(Boid b){
    boids.add(b);
  }
  
  void render() {
    for (Boid b : boids) {
      b.render();
    }
  }
  
  ArrayList<Boid> getFlock() {
    return boids;
  }
  
  
  

}