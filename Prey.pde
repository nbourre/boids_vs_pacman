class Prey extends Mover {
  float escapeDistance;
  boolean hasEscaped = false;
  int energy = 50;
  Prey partner;
  int breedingEnergy = 300;
  
  Prey (World world) {
    super (world);
  }
  
  void partnerReset() {
    partner = null;
  }
  
  void setPartner(Prey p) {
    partner = p;
  }
  
  Prey getPartner() {
    return partner;
  }
  
  boolean hasPartner() {
    return partner != null;
  }
  
  public int getEnergy () {
    return energy;
  }
}