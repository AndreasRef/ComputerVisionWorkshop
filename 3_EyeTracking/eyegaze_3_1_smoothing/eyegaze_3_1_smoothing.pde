import org.jorgecardoso.processing.eyetribe.*;
import com.theeyetribe.client.data.*;

EyeTribe eyeTribe;
PVector point;

float x;
float y;
float easing = 0.05;

void setup() {
  //size(displayWidth, displayHeight);
  fullScreen(2);
  point = new PVector();
  eyeTribe = new EyeTribe(this);
}

void draw() {
  background(0);
  stroke(255);

  float targetX = point.x;
  float dx = targetX - x;
  x += dx * easing;

  float targetY = point.y;
  float dy = targetY - y;
  y += dy * easing;

  ellipse(x, y, 15, 15);
}


void onGazeUpdate(PVector gaze, PVector leftEye_, PVector rightEye_, GazeData data) {
  if ( gaze != null ) {
    point = gaze.get();
  }
}


void trackerStateChanged(String state) {
  println("Tracker state: " + state);
}