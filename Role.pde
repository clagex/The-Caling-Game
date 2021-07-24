// a class for the playable character and monster object
class Role {
  // fields for values
  boolean isPlayer = false;
  boolean faceF, faceL, faceR, faceB=true;
  float row, col;
  float ROW, COL, DESTR, DESTC;
  float destR, destC;
  int size = 225;
  float monsterCount = 0, playerCount = 0; // counting the frames that's drawn
  // fields for images
  ArrayList<PImage> monsters = new ArrayList<PImage>();
  ArrayList<PImage> backs = new ArrayList<PImage>();
  ArrayList<PImage> fronts = new ArrayList<PImage>();
  ArrayList<PImage> rights = new ArrayList<PImage>();
  ArrayList<PImage> lefts = new ArrayList<PImage>();

  // constructor
  Role(String n) {
    if (n.equals("player")) {
      isPlayer=true;
      for (int i = 0; i < 4; i++) {
        backs.add(loadImage(dataPath("images/character/back"+i+".png")));
        fronts.add(loadImage(dataPath("images/character/front"+i+".png")));
        rights.add(loadImage(dataPath("images/character/right"+i+".png")));
        lefts.add(loadImage(dataPath("images/character/left"+i+".png")));
      }
    } else if (n.equals("monster")) {
      isPlayer = false;
      for (int i = 0; i < 4; i++) {
        monsters.add(loadImage(dataPath("images/monster/monster"+i+".png")));
      }
    }
  }

  // draw the player without changing its row and col field
  void drawPlayer(float r, float c) {
    if (isPlayer) {
      if (faceF) { // front
        image(fronts.get(1), c*size, r*size);
      } else if (faceL) { // left
        image(lefts.get(1), c*size, r*size);
      } else if (faceR) { // right
        image(rights.get(1), c*size, r*size);
      } else if (faceB) { // back
        image(backs.get(1), c*size, r*size);
      }
    } else {
      return;
    }
  }

  // draw the player walking with looking array
  void drawPlayerWalk(float r, float c) {
    if (isPlayer) {
      if (playerCount > 3.9) {
        playerCount = 0;
      }
      if (faceF) {
        image(fronts.get(floor(playerCount)), c*size, r*size);
      } else if (faceL) {
        image(lefts.get(floor(playerCount)), c*size, r*size);
      } else if (faceR) {
        image(rights.get(floor(playerCount)), c*size, r*size);
      } else if (faceB) {
        image(backs.get(floor(playerCount)), c*size, r*size);
      }
      playerCount+=0.1;
    } else {
      return;
    }
  }

  // draw monster with the col and row field value, without parameters
  void drawMonser() {
    if (monsterCount > 3.9) {
      monsterCount =0;
    }
    image(monsters.get(floor(monsterCount)), col*size, row*size);
    monsterCount+=0.1;
  }

  // move the character r row, and c col, and change the field value
  void moveCharacter(float r, float c) {
    row += r;
    col += c;
    //drawCharacter(row, col);
  }

  // swap the starting and destination position, swap the changable values to the opposite final values
  void swapPath() {
    if (destR == DESTR && destC == DESTC) {
      destR = ROW;
      destC = COL;
    } else {
      destR = DESTR;
      destC = DESTC;
    }
  }

  //getters
  boolean destRight() {
    return (row == destR && destC > col);
  }

  boolean destLeft() {
    return (row == destR && destC < col);
  }

  boolean destUp() {
    return (row > destR && destC == col);
  }

  boolean destDown() {
    return (row < destR && destC == col);
  }

  boolean reachedDest() {
    return (round(row) == round(destR) && round(col) == round(destC));
  }

  float getR() {
    return row;
  }

  float getC() {
    return col;
  }

  // return true if two roles touched each other
  boolean hasCollide(Role other) {
    float subR = abs(this.row-other.row);
    float subC = abs(this.col-other.col);
    if (subR <= 0.8 && subC <= 0.3) {
      return true;
    } else if (subR <= 0.3 && subC <= 0.8) {
      return true;
    }
    return false;
  }

  // return true if two roles are close to each other
  boolean closeTo(Role other) {
    float subR = abs(this.row-other.row);
    float subC = abs(this.col-other.col);
    if (subR <= 1.5 && subC <= 0.3) {
      return true;
    } else if (subR <= 0.3 && subC <= 1.5) {
      return true;
    }
    return false;
  }

  // setters
  // set the character row and col position, assign it to two fields, final one and changable one
  void setCharacterPos(float r, float c) {
    row = r;
    col = c;
    ROW = r;
    COL = c;
  }

  // set the character destination row and col, assign it to two fields, final one and changable one
  void setMonsterDest(float r, float c) {
    destR = r;
    destC = c;
    DESTR = r;
    DESTC = c;
  }

  void setFront() {
    faceF = true;
    faceL = false;
    faceR = false;
    faceB = false;
  }

  void setBack() {
    faceF = false;
    faceL = false;
    faceR = false;
    faceB = true;
  }

  void setRight() {
    faceF = false;
    faceL = false;
    faceR = true;
    faceB = false;
  }

  void setLeft() {
    faceF = false;
    faceL = true;
    faceR = false;
    faceB = false;
  }
}
