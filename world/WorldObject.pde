abstract class WorldObject{
  
  //draw attributes
  PVector location;
  PVector size;
  color fillColor;
  color strokeColor;
  float angle;
  World world;

  abstract void update(long deltaTime);
  abstract void render();
}