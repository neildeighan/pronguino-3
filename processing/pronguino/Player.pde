/**
 * Player
 *
 * Encapsulates the player
 *
 * @author  Neil Deighan
 */
class Player {

  int index;
  int score;
  char upKey;
  char downKey;

  Controller controller;
  Paddle paddle;

  /**
   * Class Constructor
   *
   * @param  index  array index of the player being created
   */
  Player(int index) {
    this.index = index;
    this.score = 0;

    // Sets the control keys for the player
    this.upKey = options.keys[index].up;
    this.downKey = options.keys[index].down;

    //Create Controller
    this.controller = new Controller(this);

    //Create Paddle
    this.paddle = new Paddle(this);
  }

  /**
   * Checks which key has been pressed to determine direction of players paddle
   *
   * @param  pressedKey  
   */
  void checkKeyPressed(char pressedKey) {
    if (pressedKey == this.downKey) {
      this.paddle.updateDirection(Constants.DIRECTION_DOWN);
    } else {
      if (pressedKey == this.upKey) {
        this.paddle.updateDirection(Constants.DIRECTION_UP);
      }
    }
  }

  /**
   * Checks which key has been released stop movement of players paddle
   *
   * @param  releasedKey  
   */
  void checkKeyReleased(char releasedKey) {
    if (releasedKey == this.downKey || releasedKey == this.upKey) {
      this.paddle.updateDirection(Constants.DIRECTION_NONE);
    }
  }

  /**
   * Sets the value of the controller
   *
   * @param  value
   */
  void setController(int value) {
    this.controller.currentValue = value;
  }

  /**
   * Checks if value has changed, and updates direction/speed of paddle 
   */
  void checkController() {
    if (this.controller.valueChanged()) {
      
      // If the difference is negative, we want to move up .. down if positive ..
      this.paddle.updateDirection( this.controller.valueDifference() < 0 ? Constants.DIRECTION_UP : Constants.DIRECTION_DOWN);
      
      // unlike the keys, the controller can be turned at different speeds ..
      // if turned really slow, the absolute difference at a minimum will be 1 ..
      // so to keep the speed same as option ... i.e. (1 + 6.0 - 1) = 6.0
      // if turned faster, the absolute difference,say 7, has jumped from one value to another very quickly ..
      // so we need the paddle to move a bit quicker to catch up i.e.(7 + 6.0 - 1) = 12.0  
      this.paddle.updateSpeed( abs(this.controller.valueDifference()) + options.paddleSpeed-1 );
      
      // Set the previous value, so we can determine changes next time round ...
      this.controller.previousValue = this.controller.currentValue;
    } else {
      // If the value hasnt change, just stay still
      this.paddle.updateDirection(Constants.DIRECTION_NONE);
    }
  }

  /**
   * Checks if players paddle hits surface boundary
   *
   * @return  true, if players paddle hits surface boudary
   */
  boolean hitsBoundary() {
    return this.paddle.hitsBoundary();
  }

  /**
   * Checks if players paddle hits ball
   *
   * @param  ball  
   *
   * @return  true, if players paddle hits ball
   */
  boolean hits(Ball ball) {
    return this.paddle.hits(ball);
  }

  /**
   * Checks if players paddle misses ball
   *
   * @param  ball  
   *
   * @return  true, if players paddle misses ball
   */
  boolean misses(Ball ball) {
    return this.paddle.misses(ball);
  }

  /**
   * Sets start position of players paddle
   */
  void positionAtStart() {
    this.paddle.positionAtStart();
  }  

  /**
   * Sets position of players paddle at surface boundary
   */
  void positionAtWall() {
    this.paddle.positionAtBoundary();
  }

  /**
   * Stop players paddle moving
   */
  void stopMoving() {
    this.paddle.stopMoving();
  }

  /**
   * Move the players paddle
   */
  void move() {
    this.paddle.move();
  }

  /**
   * Draw the players paddle
   */
  void display() {
    this.paddle.display();
  }
}
