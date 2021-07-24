// map feilds
Map map;
int rows, cols;
boolean moveLeft, moveRight, moveUp, moveDown;
boolean faceLeft, faceRight, faceUp = true, faceDown;
float mapCoff, mapRoff;
int playerC, playerR;

// player fields
Role player;
float fireFlicker = 0;
boolean fireOn = true;

// monster fields
ArrayList<Role> monsters = new ArrayList<Role>();
int monsterSum;

//game play fields
String mapFile;
boolean startGame = false, isRunning = false, drawLoad = false, isPaused = false, gameOver = false;
boolean hasWon, hasLost, dash = false; // helper boolean for draw method, and dash
float speed = 0.02;
float monsterSpeed = 0.021;

// screen fields
float timeCount = 0, fireCount = 0, dashCount = 0, lastDash = 0;// counter variable for looping
PImage bg, easyDark, easyLight, hardDark, hardLight, titleDark, titleLight; // image elements for starting title
PImage pausebg, conDark, conLight, restartDark, restartLight, btmenuDark, btmenuLight, quitDark, quitLight, button; // image elements for pausing screen
PImage won, lost; // image elements for win and lose screen
ArrayList<PImage> fires = new ArrayList<PImage>(); // the arraylist for fire images
PImage light, leftHand, rightHand, downHand; // the light image in the gameplay, and their hand images
float ratio = 1.5;


// set up to set the size of the screen
void setup() {
  size(1920, 1080);
  loadImages();
  frameRate(60);
  noSmooth();
} 

// startGame - whether the game is chosen by the user
// drawLoad - whether to draw the load screen or not
// isRunning - whether the map is loaded and running
// isPaused - whether the gameplay is paused
// gameOver - a game is finished, could be win or lose
void draw() {
  if (!startGame && !isRunning && !drawLoad && !isPaused && !gameOver) { // display opening game menu, reset status for winning and losing
    drawStartScreen();
  } else if (drawLoad && !startGame && !isPaused && !gameOver) { // if only drawLoad is true, others are false, draw the load screen and set startGame to true 
    drawLoadingScreen();
    startGame = true;
  } else if (startGame && !isRunning && !isPaused && !gameOver) { // game is running, loading map
    setMap(); // call the helper method to set up the map
    loadMonsters(); // set up the monster and their initial position
    setCharacter(); // set up the player and monster character
    if (map.finishedLoading()) {
      isRunning = true;
    }
  } else if (isRunning && !isPaused && !gameOver) { // finished loading the map, running the game
    tint(80);
    map.drawMap(mapRoff, mapCoff);
    drawMonsters();    
    tint(255, 65);
    if (fireOn) {
      image(light, 100*ratio, 130*ratio);
    }
    noTint();
    if (moveLeft || moveRight || moveUp || moveDown ) {
      player.drawPlayerWalk(2, 2);
    } else {
      player.drawPlayer(2, 2);
    }
    drawTorch(); //draw the torch
    moveCharacter();
    image(button, 1210*ratio, 10*ratio); // the pause button
    if (hasWon()) { // if the player won, show the won screen, reset the four core booleans 
      isRunning = false;
      gameOver = true;
      hasWon = true;
    } 
    if (isCaught()) { // if the player lost, show the lost screen
      isRunning = false;
      gameOver = true;
      hasLost = true;
    }
  } else if (!isRunning && isPaused) {
    drawPauseScreen();
  } else if (!isRunning && hasWon) {
    drawWonScreen();
  } else if (!isRunning && hasLost) {
    drawLostScreen();
  }
}

// draw the monsters in the map, moving along their chosen path
void drawMonsters() {
  push();
  translate(-mapCoff*225, -mapRoff*225); // translate so that the monsters will be drawn in the same coordinate system as the map
  for (int i = 0; i < monsterSum; i++) { 
    if (i == 4 || i == 5) { // make the final two monster in the hard gameplay faster 
      monsterSpeed = 0.023;
    } else {
      monsterSpeed = 0.021;
    }
    Role m = monsters.get(i);
    // booleans to check its path direction, and changing its(row, col) to move
    if (m.destRight()) { //moving right
      m.moveCharacter(0, monsterSpeed);
    } else if (m.destLeft()) { // moving left
      m.moveCharacter(0, -monsterSpeed);
    } else if (m.destDown()) { // moving down
      m.moveCharacter(monsterSpeed, 0);
    } else if (m.destUp()) { // moving up
      m.moveCharacter(-monsterSpeed, 0);
    }
    m.drawMonser();
    if (m.reachedDest()) { // if the monster reached the destination, swap the destination with start
      m.swapPath();
    }
  }
  pop();
}

// draw the torch, with three directions, facing up doesn't matter
void drawTorch() {
  if (fireOn) {
    if (faceLeft) {
      image(leftHand, 2.06*Cell.size, 2.38*Cell.size);
      drawFire(2.2, 2.09);
    } else if (faceRight) {
      image(rightHand, 2.62*Cell.size, 2.38*Cell.size);
      drawFire(2.2, 2.74);
    } else if (faceDown) {
      image(downHand, 2.43*Cell.size, 2.32*Cell.size);
      drawFire(2.3, 2.45);
    }
  }
}

// helper method to draw the torch, loop around the arraylist
void drawFire(float r, float c) {
  if (fireCount > 5.9) {
    fireCount = 0;
  }
  image(fires.get(floor(fireCount)), c*Cell.size, r*Cell.size);
  fireCount += 0.1;
}

// dectect whether the character is caught by the monter
boolean isCaught() {
  for (int i = 0; i < monsterSum; i++) { 
    if (player.hasCollide(monsters.get(i))) {
      return true;
    } else if (fireOn && player.closeTo(monsters.get(i))){
      return true;
    }
  }
  return false;
}

// detect whether the character has reached the exit
boolean hasWon() {
  float subR = abs(player.getR() - map.getExitR());
  float subC = abs(player.getC() - map.getExitC());
  if (subR <= 0.3 && subC <= 0.3) {
    return true;
  }
  return false;
}

// move the character up, down, left and right according to the boolean
void moveCharacter() {
  if (moveLeft) {
    goLeft();
  }
  if (moveRight) {
    goRight();
  }
  if (moveUp) {
    goUp();
  }
  if (moveDown) {
    goDown();
  }
}

// let the character move left with the speed given, mostly same for the four directions
// character is at (2,2), so offset will add 2 to find the player position
void goLeft() {
  playerR = round(mapRoff+2.3); // calculate the row count for the player position
  playerC = ceil(mapCoff+2); // calculate the col count for the player position
  if (mapCoff > speed) { // make sure the x translation isn't below minimum
    if (map.getCellAt(playerR, playerC-1).isRoad) { // check if the cell to the left is road
      doDash();
      mapCoff -= speed;
      player.moveCharacter(0, -speed);
      //println("X offset: " + mapCoff);
      player.setLeft(); // set the player image to left
      faceLeft = true;
      faceRight = false;
      faceDown = false;
    }
  } else {
    mapCoff = 0; // make sure x offset won't be negative
  }
}

// move the character to the right
void goRight() {
  playerR = round(mapRoff+2.3);
  playerC = floor(mapCoff+2);  // floor the col count
  if (mapCoff < cols-8) { // make sure the x offset isn't greater than maximum 
    if (map.getCellAt(playerR, playerC+1).isRoad) { 
      doDash();
      mapCoff += speed;
      player.moveCharacter(0, speed);
      //println("X offset: " + mapCoff);
      player.setRight();
      faceLeft = false;
      faceRight = true;
      faceDown = false;
    }
  } else {
    mapCoff = cols-8; // reset if it is greater than maximum
  }
}

//move the character up
void goUp() {
  playerR = round(mapRoff+2.8); // round up using extra calculation
  playerC = round(mapCoff+2.1);
  if (mapRoff > speed) { 
    if (map.getCellAt(playerR-1, playerC).isRoad) {
      doDash();
      mapRoff -= speed;
      player.moveCharacter(-speed, 0);
      //println("Y offset: " + mapRoff);
      player.setBack();
      faceLeft = false;
      faceRight = false;
      faceDown = false;
    }
  } else {
    mapRoff = 0;
  }
}

// move the character down
void goDown() {
  playerR = round(mapRoff+1.5);
  playerC = round(mapCoff+2.1);
  if (mapRoff < rows-5) {
    if ( map.getCellAt(playerR+1, playerC).isRoad) {
      doDash();
      mapRoff += speed;  
      player.moveCharacter(speed, 0);
      //println("Y offset: " + mapRoff);
      player.setFront();
      faceLeft = false;
      faceRight = false;
      faceDown = true;
    }
  } else {
    mapRoff = rows-5;
  }
}

// dash, the player can only dash for a while, then dash will be set to false
void doDash() {
  if (dash) {
    if (dashCount == 100) {
      speed = 0.02;
      dashCount = 0;
      dash = false;
    } else {
      speed = 0.04;
    }
    dashCount++;
  } else {
    speed = 0.02;
    dashCount = 0;
  }
}

// if key is pressed, set moving booleans true
void keyPressed() {
  if (isRunning && !isPaused) {
    if (key == 'w' || key == 'W') { // go up
      moveUp = true;
    }
    if (key == 's' || key == 'S') { // go down
      moveDown = true;
    }
    if (key == 'a' || key == 'A') { // go left
      moveLeft = true;
    }
    if (key == 'd' || key == 'D') { // go right
      moveRight = true;
    }
    if (key == 'f' || key == 'F') { // turn on the torch
      if (fireOn) {
        fireOn = false;
      } else if (!fireOn) {
        fireOn = true;
      }
    }
    if (key==CODED) { // dash
      if (keyCode == SHIFT) {
        float thisDash = millis();
        if (lastDash == 0 || thisDash - lastDash > 5000 ) { // player cannot repeatly do dash, there has to be a time gap
          dash = true;
          lastDash = thisDash;
        }
      }
    }
  }
}

// if key is released, set moving booleans false
void keyReleased() {
  if (isRunning && !isPaused) { 
    if (key == 'w' || key == 'W') {
      moveUp = false;
    }
    if (key == 's' || key == 'S') {
      moveDown = false;
    }
    if (key == 'a' || key == 'A') {
      moveLeft = false;
    }
    if (key == 'd' || key == 'D') {
      moveRight = false;
    }
    if (key==CODED) {
      if (keyCode == SHIFT) {
        dash = false;
      }
    }
  }
}

// mouse event for starting screens and ending screens
void mousePressed() {
  if (!startGame && !isRunning && !drawLoad) { // for starter screen detection
    if (mouseX > 270*ratio && mouseX < 464*ratio && mouseY > 550*ratio && mouseY < 697*ratio) { // "easy"
      mapFile = "maze1";
      drawLoad = true;
    }
    if (mouseX > 870*ratio && mouseX < 1064*ratio && mouseY > 550*ratio && mouseY < 697*ratio) { // "hard"
      mapFile = "maze2";
      drawLoad = true;
    }
  } else if (isRunning && !isPaused) {
    if (mouseX > 1210*ratio && mouseX < 1270*ratio && mouseY > 10*ratio && mouseY < 71*ratio) { // the pause button
      isRunning = false;
      isPaused = true;
      pause();
    }
  } else if (!isRunning && isPaused) {
    if (mouseX > 550*ratio && mouseX < 758*ratio && mouseY > 320*ratio && mouseY < 402*ratio) { // continue 
      isRunning = true;
      isPaused = false;
    }    
    clickedOptions();
  } else if (!isRunning && !isPaused && gameOver) {
    clickedOptions();
  }
}

// draw the start screen
void drawStartScreen() {
  image(bg, 0, 0); // background
  if (timeCount == 14) { // title
    image(titleDark, 500*ratio, 25*ratio);
    timeCount = 0;
  } else {
    image(titleLight, 500*ratio, 25*ratio);
    timeCount++;
  }
  if (mouseX > 270*ratio && mouseX < 464*ratio && mouseY > 550*ratio && mouseY < 697*ratio) { // easy
    image(easyLight, 270*ratio, 550*ratio);
  } else {
    image(easyDark, 270*ratio, 550*ratio);
  }
  if (mouseX > 870*ratio && mouseX < 1064*ratio && mouseY > 550*ratio && mouseY < 697*ratio) { // hard
    image(hardLight, 870*ratio, 550*ratio);
  } else {
    image(hardDark, 870*ratio, 550*ratio);
  }
  if (mouseX > 1170*ratio && mouseX < 1280*ratio && mouseY > 630*ratio && mouseY < 720*ratio) { // quit
    image(quitLight, 1170*ratio, 630*ratio);
  } else {
    image(quitDark, 1170*ratio, 630*ratio);
  }
}

// a loading screen for loading the map
void drawLoadingScreen() {
  background(0);
  textAlign(CENTER);
  textSize(20);
  text("w/a/s/d to move, SHIFT to dash, 'f' to turn on and off the torch", 640*ratio, 620*ratio);
  text("loading...", 640*ratio, 650*ratio);
}

// a screen to indicate the player has won the game
// the player can restart or go back to title screen
void drawWonScreen() {
  image(won, 0, 0);
  drawOptions(); // draw restart, back to menu and quit options
}

// a screen to indicate the player has lost the game
// the player can restart or go back to title screen
void drawLostScreen() {
  image(lost, 0, 0);
  drawOptions(); // draw restart, back to menu and quit options
}

// a screen to indicate the player has pause the game
// the player can continue, restart or go back to title screen
void drawPauseScreen() {
  image(pausebg, 0, 0);
  if (mouseX > 550*ratio && mouseX < 758*ratio && mouseY > 320*ratio && mouseY < 402*ratio) { // continue option
    image(conLight, 550*ratio, 300*ratio);
  } else {
    image(conDark, 550*ratio, 300*ratio);
  }
  drawOptions(); // draw restart, back to menu and quit options
}

// set the map from the player's selection
void setMap() {
  map = new Map(mapFile); // create the map object
  map.loadMap(); 
  rows = map.getRows();
  cols = map.getCols();
  mapCoff = 0; 
  mapRoff = map.getStartR()-2; //the (0,0) of the screen will be two rows above the starting cell
}

// set the playable character
void setCharacter() {
  player = new Role("player");
  player.setCharacterPos(map.startR, map.startC);
}

// load the monsters from the map, set their position and destination into Role object
void loadMonsters() {
  monsters = new ArrayList<Role>();
  monsterSum = map.getMonsterSum();
  for (int i = 0; i < monsterSum; i++) {
    Role m = new Role("monster");
    // starting position
    float r = map.getPathAt(i, 0).getR();
    float c = map.getPathAt(i, 0).getC();
    // destination position
    float dr = map.getPathAt(i, 1).getR();
    float dc = map.getPathAt(i, 1).getC();
    m.setCharacterPos(r, c);
    m.setMonsterDest(dr, dc);
    monsters.add(m); // add the monster into the arraylist
  }
}

// helper method to draw button for restart, back to menu and quit
void drawOptions() {
  if (mouseX > 560*ratio && mouseX < 751*ratio && mouseY > 420*ratio && mouseY < 502*ratio) { // restart option
    image(restartLight, 560*ratio, 400*ratio);
  } else {
    image(restartDark, 560*ratio, 400*ratio);
  }    
  if (mouseX > 510*ratio && mouseX < 808*ratio && mouseY > 495*ratio && mouseY < 597*ratio) { // back to menu option
    image(btmenuLight, 510*ratio, 495*ratio);
  } else {
    image(btmenuDark, 510*ratio, 495*ratio);
  }    
  if (mouseX > 595*ratio && mouseX < 714*ratio && mouseY > 590*ratio && mouseY < 692*ratio) { // quit option
    image(quitLight, 595*ratio, 590*ratio);
  } else {
    image(quitDark, 595*ratio, 590*ratio);
  }
}

// helper method for three option's mouse action
void clickedOptions() {
  if (mouseX > 560*ratio && mouseX < 751*ratio && mouseY > 420*ratio && mouseY < 502*ratio) { // restart, using the same map
    drawLoad = true;
    reset();
  }    
  if (mouseX > 510*ratio && mouseX < 808*ratio && mouseY > 495*ratio && mouseY < 597*ratio) { // back to menu
    drawLoad = false;
    reset();
  }    
  if (mouseX > 595*ratio && mouseX < 714*ratio && mouseY > 590*ratio && mouseY < 692*ratio) { // quit 
    exit();
  }
}

// load all the images in setUp
void loadImages() {
  bg = loadImage(dataPath("images/title/title_bg.png"));
  easyDark = loadImage(dataPath("images/title/easyDark.png"));
  easyLight = loadImage(dataPath("images/title/easyLight.png"));
  hardDark = loadImage(dataPath("images/title/hardDark.png"));
  hardLight = loadImage(dataPath("images/title/hardLight.png"));
  titleDark = loadImage(dataPath("images/title/titleDark.png"));
  titleLight = loadImage(dataPath("images/title/titleLight.png"));
  pausebg = loadImage(dataPath("images/pause/pause_bg.png"));
  conDark = loadImage(dataPath("images/pause/ContinueDark.png"));
  conLight = loadImage(dataPath("images/pause/ContinueLight.png"));
  restartDark = loadImage(dataPath("images/pause/RestartDark.png"));
  restartLight = loadImage(dataPath("images/pause/RestartLight.png"));
  btmenuDark = loadImage(dataPath("images/pause/MenuDark.png")); 
  btmenuLight = loadImage(dataPath("images/pause/MenuLight.png")); 
  quitDark = loadImage(dataPath("images/pause/QuitDark.png")); 
  quitLight = loadImage(dataPath("images/pause/QuitLight.png"));
  button = loadImage(dataPath("images/pause/button.png"));
  won = loadImage(dataPath("images/after/win.png"));
  lost = loadImage(dataPath("images/after/lost.png"));
  light = loadImage(dataPath("images/fire/light.png"));
  leftHand = loadImage(dataPath("images/fire/fireLeftHand.png"));
  rightHand = loadImage(dataPath("images/fire/fireRightHand.png"));
  downHand = loadImage(dataPath("images/fire/fireFrontHand.png"));
  for (int i = 0; i < 6; i++) {
    fires.add(loadImage(dataPath("images/fire/fire"+i+".png")));
  }
}

// helper method to clear out the moving while paused
void pause() {
  moveLeft =false;
  moveRight = false;
  moveUp = false;
  moveDown = false;
  dash = false;
}

// reset everything but drawLoad for menus
void reset() {
  startGame = false;
  isRunning = false;
  isPaused = false;
  gameOver = false;
  hasLost = false;
  hasWon = false;
  moveLeft =false;
  moveRight = false;
  moveUp = false;
  moveDown = false;
  faceLeft = false;
  faceRight = false;
  faceUp = true;
  faceDown = false;
  dash = false;
}
