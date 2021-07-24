// class for the grass and road object

class Cell {
  // fields to deterimine what the cell is
  boolean isRoad = false;
  boolean isStart = false;
  boolean isExit = false;
  // its position, and x, y value, and fixed value size
  int row, col;
  float x, y;
  static final int size=225;
  // load the two images for grass and road
  PImage road = loadImage(dataPath("images/background/road.png"));
  PImage grass = loadImage(dataPath("images/background/grass.png"));

  Cell(String n, int r, int c) { // constructor
    if (n.equals("road")) { //set road
      isRoad = true;
    }
    if (n.equals("grass")) { //set grass
      isRoad = false;
    }
    // set position values
    row = r;
    col = c;
    x = c * size;
    y = r * size;
    // set the image
  }

  //setters
  void setStart() { // set the cell as the starting point
    isStart = true;
  }

  void setExit() { // set the cell as the exit point
    isExit = true;
  }

  //draw the cell
  void drawCell() {
    if (isRoad) {
      image(road, x, y);
    } else {
      image(grass, x, y);
    }
  }
  
  //getters
  float getR(){
    return row;
  }
  
  float getC(){
    return col;
  }
  
  // helper methods for debugging
  void highlight(){
    noFill();
    strokeWeight(10);
    stroke(255,0,0);
    rect(x,y,size,size);
  }
  
  String toString(){
    String line = ("This cell is on " + row +" row and " + col + " col.");
    return line;
  }
}
