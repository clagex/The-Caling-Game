// a map object, which contains the total rows and cols count, has the starting and ending position,  //<>// //<>//
// has 2d arrays for cells and path to draw the map
class Map { 

  //fields
  BufferedReader reader;
  int rows = 0, cols = 0; // total rows and cols
  int startR, startC, exitR, exitC, monsterSum; 
  String line = null, name; // line and name for reading the maze file
  boolean loaded = false; // loading status
  Cell[][] cells;
  Cell[][] path;

  //constructor
  Map(String n) {
    name = n;
    reader = createReader(dataPath(name + ".txt")); // assign the reader to the correct file
    if (name.equals("maze1")) { // using the existing numbers to assign rows, cols and monter count
      rows = 20; 
      cols = 34;
      cells = new Cell[rows][cols];
      monsterSum = 3;
      path = new Cell[3][2];
    } else if (name.equals("maze2")) {
      rows = 31; 
      cols = 51;
      cells = new Cell[rows][cols];
      monsterSum = 6;
      path = new Cell[6][2];
    }
  }

  // draw the map at the given row, col offset
  // translate the given row and col as 0,0 point
  void drawMap(float r, float c) {
    push();
    translate(-c*225, -r*225);
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        float xPos = (col-c)*225;
        float yPos = (row-r)*225;
        if (xPos > -Cell.size && xPos < width + Cell.size && yPos > -Cell.size && yPos < height+Cell.size) {
          cells[row][col].drawCell();
        }
      }
    }
    pop();
  }

  // load the map and save every cell as an Cell object in a 2d array
  // takes about 3-5 seconds to load
  void loadMap() {
    int r = 0;
    try {
      while ((line = reader.readLine())!=null) {
        for (int i = 0; i < cols; i++) {
          if (line.charAt(i)=='#') { // if the cell is grass
            cells[r][i] = new Cell("grass", r, i);
          } else { // the others are all road
            cells[r][i] = new Cell("road", r, i);
            if (line.charAt(i)=='s') { // "s" is starting position
              cells[r][i].setStart();
              startR = r;
              startC = i;
            } else if (line.charAt(i)=='e') { // "e" is exit
              cells[r][i].setExit();
              exitR = r;
              exitC = i;
            } else if (Character.isDigit(line.charAt(i))) { // if it is a number
              int num = Character.getNumericValue(line.charAt(i)); // get the number
              if (path[num][0] == null) { // add the cell into its array, [path number][start/end]
                path[num][0] = new Cell("road", r, i);
              } else {
                path[num][1] = new Cell("road", r, i);
              }
            }
          }
        }
        r++;
      }
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    loaded = true;
  }
  // getters
  Cell getCellAt(int row, int col) {
    return cells[row][col];
  }

  Cell getPathAt(int p, int n) {
    return path[p][n];
  }

  int getSigns(float n1, float n2) { // comparator
    if (n2-n1 > 0) {
      return 1;
    } else if (n2-n1 == 0) {
      return 0;
    } else {
      return -1;
    }
  }

  Cell getPathfor(int p, int n) { // for monster to get their path
    return path[p][n];
  }

  int getRows() {
    return rows;
  }

  int getCols() {
    return cols;
  }

  int getStartR() {
    return startR;
  }

  int getStartC() {
    return startC;
  }
  
  int getExitR(){
    return exitR;
  }
  
  int getExitC(){
    return exitC;
  }

  int getMonsterSum() {
    return monsterSum;
  }

  boolean finishedLoading() {
    return loaded;
  }
}
