import gab.opencv.*;
import processing.video.*;
import blobDetection.*;
import controlP5.*;

Capture video;
OpenCV opencv;
ControlP5 cp5;
BlobDetection theBlobDetection;

float minimumBlobSize = 10;
int thresholdVal = 122;
int blurRadius = 2;

int dilateN = 1;
int erodeN = 1;

PImage img;

void setup() {
  size(640, 480);  
  String[] cameras = Capture.list();
  printArray(cameras);
  
  video = new Capture(this, width, height, cameras[0]); 
  opencv = new OpenCV(this, width, height);
  video.start();
  
  img = new PImage(width, height); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(false);
  
  //ControlP5 gui
  cp5 = new ControlP5(this);
  cp5.addSlider("minimumBlobSize", 0, 300).linebreak();
  cp5.addSlider("thresholdVal", 0, 300).linebreak();
  cp5.addSlider("blurRadius", 0, 15).linebreak();
  cp5.addSlider("dilateN", 0, 15).linebreak();
  cp5.addSlider("erodeN", 0, 15).linebreak();
}

void draw() {
    opencv.loadImage(video); //perform openCV effects
    opencv.gray();
    opencv.threshold(thresholdVal);
    
    for (int i = 0; i< dilateN; i++) {
    opencv.dilate();
    } 
    for (int i = 0; i< erodeN; i++) {
    opencv.erode();
    } 
    
    img = opencv.getOutput(); //make img the output of openCV
    fastblur(img, blurRadius); //Apply fastblur
    image(img, 0, 0, width, height); //draw the processed image
    
    //Do the blob detection
    theBlobDetection.setThreshold(0.8); 
    theBlobDetection.computeBlobs(img.pixels);
    drawBlobsAndEdges(true, true);
    
    //Draw a semi transparent rectangle to make the gui more visible 
    noStroke();
    fill(0,122);
    rect(0,0,200,160); 
}

void captureEvent(Capture c) {
  c.read();
}


//Don't worry too much about the rest of the code, unless you are really interested ;-) 

void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges) {
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    if ((theBlobDetection.getBlob(n).w*width + theBlobDetection.getBlob(n).h*height)>minimumBlobSize) {
      b=theBlobDetection.getBlob(n);

      if (b!=null)
      {
        // Edges
        if (drawEdges)
        {
          strokeWeight(3);
          stroke(0, 255, 0);
          for (int m=0; m<b.getEdgeNb(); m++)
          {
            eA = b.getEdgeVertexA(m);
            eB = b.getEdgeVertexB(m);
            if (eA !=null && eB !=null)
              line(
                eA.x*width, eA.y*height, 
                eB.x*width, eB.y*height
                );
          }
        }

        // Blobs
        if (drawBlobs)
        {
          noFill();
          strokeWeight(1);
          stroke(255, 0, 0);
          rect(
            b.xMin*width, b.yMin*height, 
            b.w*width, b.h*height
            );
            textSize(24);
            fill(255,0,0);
            text(n, b.xMin*width, b.yMin*height);
        }
      }
    }
  }
}

// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0; i<256*div; i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0; y<h; y++) {
    rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0; x<w; x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0; y<h; y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}