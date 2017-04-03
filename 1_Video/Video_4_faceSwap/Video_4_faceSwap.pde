import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

void setup() {

  size(640, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  video.start();
}

void draw() {
  opencv.loadImage(video);
  image(video, 0, 0 );

  noFill();
  stroke(255, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  println(faces.length);

  if (faces.length == 2) {
    PImage firstFace = video.get(faces[0].x, faces[0].y, faces[0].width, faces[0].height);
    PImage secondFace = video.get(faces[1].x, faces[1].y, faces[1].width, faces[1].height);
    image(firstFace, faces[1].x, faces[1].y, faces[1].width, faces[1].height);
    image(secondFace, faces[0].x, faces[0].y, faces[0].width, faces[0].height);
  }
}

void captureEvent(Capture c) {
  c.read();
}