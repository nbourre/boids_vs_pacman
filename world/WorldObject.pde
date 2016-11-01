abstract class WorldObject{
  
  //draw attributes
  PVector location;
  PVector size;
  World world;
  
  abstract void update(long deltaTime);
  abstract void render();
}