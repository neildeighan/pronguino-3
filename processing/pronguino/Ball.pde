/**
 * Ball
 *
 * Encapsulates the ball
 *
 * @author  Neil Deighan
 */
class Ball {
  PVector location;
  PVector velocity;
  float radius;
  float speed; 
  color colour;

  /**
   * Class Constructor 
   */
  Ball() {
    this.location = new PVector();
    this.velocity = new PVector();    
    this.radius = options.ballRadius;
    this.speed = options.ballSpeed;
    this.colour = options.ballColour;    
    
    this.positionAtStart();
    this.directionAtStart();
  }

  /**
   * Generates a random direction of -1 or +1, but not 0
   *
   * @return  -1 or +1
   */
  int getRandomDirection() {
    int r;

    do {
     // The random functions parameters are non-inclusive so -2 and 2
     // are not returned, also returns float type, i.e. 1.85428, 0.76158786 or -1.1046469,
     // so we cast to (int) to "round" to 1, 0 or -1
     r = (int)random(-2, 2);
    } while (r == 0);
    
    return r;
  }

  /**
   * Positions the ball in front of the players paddle
   *
   * @param  player  Player where ball needs to be positioned
   */
  void positionAtPlayer(Player player) {
    this.location.x = (player.index==Constants.PLAYER_ONE) 
      ? player.paddle.location.x + (player.paddle.w/2 + this.radius) 
      : player.paddle.location.x - (player.paddle.w/2 + this.radius);
  }

  /**
   * Positions the ball in the centre of the surface.
   */
  void positionAtStart() {
    this.location.set(surface.x+(surface.w/2), surface.y+(surface.h/2)); 
  }

  /**
   * Sets the initial direction of the ball at random, before it starts moving at beginning of game
   */
  void directionAtStart() {
    this.velocity.set(this.getRandomDirection(), this.getRandomDirection());
  }

  /**
   * Sets the horizontal direction of the ball based on the player who missed ball
   *
   * @param  player  Player that missed the ball
   */
  void directionAtStart(Player player) {
    this.directionAtStart();
    this.velocity.x = (player.index == Constants.PLAYER_ONE) 
      ? Constants.DIRECTION_RIGHT 
      : Constants.DIRECTION_LEFT;
  }

  /**
   * Move the ball by adding velocity * speed to location 
   */
  void move() {
    this.location.add(PVector.mult(this.velocity, this.speed));
  }

  /**
   * Changes the direction of the ball on the given axis.
   *
   * @param  axis  
   *
   * @throws Exception if invalid axis value given
   */
  void bounce(int axis) throws Exception {

    switch(axis) {
      case Constants.AXIS_HORIZONTAL:
        this.velocity.x *= Constants.DIRECTION_OPPOSITE;
        break;
      case Constants.AXIS_VERTICAL:
        this.velocity.y *= Constants.DIRECTION_OPPOSITE;
        break;
      default:
        // Have added simple parameter checking which raises 
        // error if invalid, this protects the game from the developer
        throw new Exception("axis parameter must be AXIS_HORIZONTAL or AXIS_VERTICAL");
    }
  }

  /**
   * Checks if the y co-ord of the ball is outside of the top/bottom surface boundaries
   *
   * @return true, if outside of the boundaries 
   */
  boolean hitsBoundary() {
    return ( ( this.location.y - this.radius < surface.y+surface.lineWidth) || 
             ( this.location.y + this.radius > surface.y+surface.h-surface.lineWidth) ) &&
             ( this.location.x > surface.x && this.location.x < surface.x + surface.w);  
  }

  /**
   * Draws the ball
   */
  void display(boolean snapshot) {

    // x, y = centre, r = radius
    ellipseMode(RADIUS);
    
    // Colour
    if(snapshot) {
      noFill();
      stroke(#000000);
    } else {
     fill(this.colour);
     stroke(this.colour);
    }
    
    // Draw
    circle(this.location.x, this.location.y, this.radius);
    
    // Debug
    if(options.debug && (debug.playerHitsBall || debug.paddleHitsBoundary)) {
      strokeWeight(1);
      stroke(#000000);
      point(this.location.x, this.location.y);  
    }
  } 
}
