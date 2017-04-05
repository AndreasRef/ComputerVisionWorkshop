import org.jorgecardoso.processing.eyetribe.*;
import com.theeyetribe.client.data.*;

import processing.sound.*;
SinOsc sine;

int COLS = 4;
int ROWS = 4;

EyeTribe eyeTribe;

float grid[][];
String note[] = {"C", "D", "E", "F", "G", "A", "B", "C", "D", "E", "F", "G", "A", "B", "C", "D"};
float noteFreq[] = {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50, 1174.66 };

int x, y;

PVector point;

PImage img;


void setup() {
  fullScreen(2);
   textSize(50);
  textAlign(CENTER);
  
  smooth();
  grid = new float[ROWS][COLS];
  point = new PVector();
  eyeTribe = new EyeTribe(this);
  
  sine = new SinOsc(this);
  sine.play();
  sine.freq(0);
}

void draw() {
  background(0);
  noStroke();
  for ( int i = 0; i < ROWS*COLS; i++ ) {
    int x = i % COLS;
    int y = i / ROWS;

    fill(#2FACC4, 255-grid[y][x]);
    rect(x*width/COLS, y*height/ROWS, width/COLS, height/ROWS);
    fill(255);
    text(note[i], x*width/COLS + 0.5*width/COLS, y*height/ROWS+0.5*height/ROWS);
    if ( grid[y][x] > 0 ) {
      grid[y][x] -= 3;
    }
  }

  noFill();
  stroke(255);
  ellipse(point.x, point.y, 5, 5);
  
  //Test 
  pushStyle();
  fill(255);
  textSize(20);
  text("x: " + x + " y: " + y, width/2, height/2);
  popStyle();
  
  sine.freq(noteFreq[x+y*4]);
  
}


void onGazeUpdate(PVector gaze, PVector leftEye_, PVector rightEye_, GazeData data) {

  if ( gaze != null ) {
    point = gaze.get(); 

    x = (int)constrain(round(map(point.x, 0, width, 0, COLS-1)), 0, COLS-1);
    y = (int)constrain(round(map(point.y, 0, height, 0, ROWS-1)), 0, ROWS-1);
    
    grid[y][x] = constrain( grid[y][x]+10, 0, 255);
  }
}

void trackerStateChanged(String state) {
  println("Tracker state: " + state);
}