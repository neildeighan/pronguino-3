/**
 * Pronguino - Praint
 *
 * Painting with Processing
 *
 * https://neildeighan.com/pronguino-3/
 *
 * @author  Neil Deighan
 *
 */

// Import the serial library
import processing.serial.*;

// Declare Serial Port
Serial usbPort;

// Declare Game Options
Options options;

// Declare Debug Options
Debug debug;

// Declare Game Objects
Surface surface;
Net net;
Ball ball;
Scoreboard[] scoreboards;
Player[] players;
Player player;


/**
 * Setup environment, load options, create game objects, initialise serial communications
 */
void setup() 
{
  // Set Window size in pixels, these are refered to throughout code as "width" and "height" respectively,
  // and all game objects have been coded to be displayed relative to these, so you can have a really short game at 100 x 100,
  // or a really long game at say 1280 x 640, size() can also be replace with fullScreen().
  //
  // Note: Now that a playingsurface has been added game objects are drawn relative to this, although the 
  //       surface as been drawn relative to "width" and "height".  
  size(800, 600);

  // "Load" Game Options
  options = new Options();

  // "Load" Debug options
  debug = new Debug();
  
  // Set Frame Per Second (FPS)
  frameRate(options.framesPerSecond);

  // Create Surface
  surface = new Surface(75, 100); 

  // Create Net
  net = new Net();
  
  // Create Ball  
  ball = new Ball();

  // Create Scoreboards 
  float fontSize = options.scoreboardFontSize;
  PFont font = createFont(options.scoreboardFont, fontSize);
  
  scoreboards = new Scoreboard[Constants.PLAYER_COUNT];
  scoreboards[Constants.PLAYER_ONE] = new Scoreboard(width/2-(fontSize*2), surface.y - fontSize*1.5, font); 
  scoreboards[Constants.PLAYER_TWO] = new Scoreboard(width/2+(fontSize*0.25), surface.y - fontSize*1.5, font);

  // Create Players, each player will create its own paddle and controller
  players = new Player[Constants.PLAYER_COUNT];
  for (int index=0; index < Constants.PLAYER_COUNT; index++) {
    players[index] = new Player(index);
  }

  // Get Serial Port name .. change in Options once identified 
  // println(Serial.list());

  // Connect to serial port, just show error message for now,
  // the game will just continue to use keyboard controls 
  try {
    usbPort = new Serial(this, options.serialPortName, options.serialBaudRate);
  } 
  catch (Exception e) {
    println(e.getMessage());
  }

  // A short delay to make sure, if connected, serial communications catch up
  delay(100);

  // Set each players starting position for paddles 
  for (Player player : players) {
    player.positionAtStart();
  }
  
  // Only set background the once, when debugging 
  if(options.debug) {   
    background(options.backgroundColour);
  }
  
}

/**
 * Called everytime a key is pressed 
 */
void keyPressed() {

  // Check if any players control keys pressed
  for (Player player : players) {
    player.checkKeyPressed(key);
  }
  
  // Check if space hit to restart game
  if(key == Constants.KEY_SPACE) {
    restart();
  }
  
}

/**
 * Called everytime a key is released
 */
void keyReleased() {

  // Check if any players control keys released
  for (Player player : players) {
    player.checkKeyReleased(key);
  }
}

/**
 * Called everytime data is received from the serial port
 */
void serialEvent(Serial usbPort) {

  // Is there any data available ?
  if (usbPort.available() > 0) {

    // Get the data from port and "split" value for each players controller
    byte data = (byte)usbPort.read();
    players[Constants.PLAYER_ONE].setController(Functions.getHighNibble(data));
    players[Constants.PLAYER_TWO].setController(Functions.getLowNibble(data));

    // Check the players controllers to determine how to move
    for (Player player : players) {
      player.checkController();
    }
  }
}


/**
 * The code within this function runs continuously in a loop
 */
void draw() 
{

  // Set background in draw() when not debugging, as it needs to be drawn every frame. 
  if(!options.debug) {   
    background(options.backgroundColour);
  }

  // Move the ball 
  ball.move();
  
  // Move Players / Paddles
  for (Player player : players) {
    player.move();
  }

  // Check if the ball hits the surface boundary
  if (ball.hitsBoundary()) {
    try {
      // This will only cause error if we provided an invalid parameter, try it
      ball.bounce(Constants.AXIS_VERTICAL);
    } 
    catch (Exception e) {
      // Just show error message for now
      // the game will continue, but you will see some strange movements
      println(e.getMessage());
    }
  }   

  // Check if player hits the surface boundary
  for (Player player : players) {
    if (player.hitsBoundary()) {
      // Reposition
      player.positionAtWall();
      // Stop
      player.stopMoving();
    }
  }

  // Check if player hits ball
  for (Player player : players) {
    if (player.hits(ball)) {

      // Debug
      if(options.debug && debug.playerHitsBall) {
        ball.display(true);
        saveFrame("debug/Player("+player.index+")-Paddle"+player.paddle.location+"-Hits-Ball"+ball.location);       
      }

      // Reposition
       ball.positionAtPlayer(player);

      // Debug
      if(options.debug && debug.ballPositionAtPlayerPaddle) {
        saveFrame("debug/Ball-Position"+ ball.location+"-At-Player("+player.index+")-Paddle"+player.paddle.location);       
      }

      // Bounce
      try {
        // This will only cause error if we provided an invalid parameter, try it.
        ball.bounce(Constants.AXIS_HORIZONTAL);
      } 
      catch (Exception e) {
        // Just show error message for now, the game will continue, but you will see some strange movements
        println(e.getMessage());
      }
    }
  }

  // Check if player misses ball
  for (Player player : players) {
    if (player.misses(ball)) {
      // Add point to other players score
      players[player.index^1].score++;
      // Move to ball to start position
      ball.positionAtStart();
      // Set direction of ball from start position, depending on who missed
      ball.directionAtStart(player);
    }
  }

  // Update scoreboards
  for( Player player: players) {
    scoreboards[player.index].update(player.score);
  }

  // Check for winner
  for (Player player: players) {
    if(player.score == Constants.SCORE_MAX) {    
      noLoop();
    }
  }

  // Display the game objects
  surface.display();
  net.display();
  ball.display(false);
  for (Player player : players) {
    scoreboards[player.index].display();
    player.display();
  }

  // Saves an image of screen every frame, which can be used to make a movie
  // saveFrame("movie/frame-######.tif");
  // WARNING: Remove or comment if not in use, can fill up disk space if forgotton about
}

void restart() {
  
  // Reset Scores & Player Positions
  for(Player player: players) {
    player.score = 0;
    player.positionAtStart();
  }
  
  // Restart Loop
  loop();
}
