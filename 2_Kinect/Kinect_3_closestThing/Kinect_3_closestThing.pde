
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

// Depth image
PImage img;

// Which pixels do we care about?
int minDepth =  320;
int maxDepth = 650;

// What is the kinect's angle
float angle;

void setup() {
  size(640, 480);

  kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt();

  // Blank image
  img = new PImage(kinect.width, kinect.height);
  println(kinect.width);
  println(kinect.height);
}

void draw() {
  kinect.enableMirror(true); //Mirror the image
  //background(0);
  img.loadPixels();

  PImage dImg = kinect.getDepthImage();
  //image(dImg, 0, 0);

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();
  
  //int record = 4500;
  int record = kinect.height;
  int rx = 0;
  int ry = 0;

  for (int x = 0; x < kinect.width; x++) {
    for (int y = 0; y < kinect.height; y++) {
      int offset = x + y * kinect.width;
      int d = depth[offset];

      if (d > minDepth && d < maxDepth) {
        img.pixels[offset] = color(255, 0, 150);
        
        if (y < record) {
          record = y;
          rx = x;
          ry = y;
        }
      } else {
        img.pixels[offset] = dImg.pixels[offset];
      }
    }
  }
  img.updatePixels();
  image(img,0,0);
  
  fill(255);
  ellipse(rx, ry, 32, 32);
  
  fill(0,255,0);
  text("TILT: " + angle, 10, 20);
  text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
  
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  } else if (key == 'c') {
   background(0); 
  }
}