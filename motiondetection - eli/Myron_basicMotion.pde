import JMyron.*;

int squares = 20;

JMyron webCam;
int sampleWidth, sampleHeight;
int numSamplePixels;
int[] oldPixels;
int thresh = 9;
int blueDiff;
int greenDiff;
int redDiff;
int totalDiff;
int curSquare;
boolean first = true;
boolean[] detectedMotion;

void setup() {
  size(320, 240);

  webCam = new JMyron();
  webCam.start(width, height);
  webCam.findGlobs(0);

  sampleWidth = width/squares;
  sampleHeight = height/squares;
  numSamplePixels = sampleWidth*sampleHeight;
  oldPixels = new int[squares*squares];
}

void draw() {
  webCam.update();
  int[] curFrame = webCam.image();
  curSquare = 0;
  detectedMotion = new boolean[squares*squares];

  // go through all the cells
  for (int y=0; y < height; y += sampleHeight) {
    for (int x=0; x < width; x += sampleWidth) {
      // reset the averages
      float r = 0;
      float g = 0;
      float b = 0;

      // go through all the pixels in the current cell
      for (int yIndex = 0; yIndex < sampleHeight; yIndex++) {
        for (int xIndex = 0; xIndex < sampleWidth; xIndex++) {
          // add each pixel in the current cell's RGB values to the total
          // we have to multiply the y values by the width since we are 
          // using a one-dimensional array
          r += red(curFrame[x+y*width+xIndex+yIndex*width]);
          g += green(curFrame[x+y*width+xIndex+yIndex*width]);
          b += blue(curFrame[x+y*width+xIndex+yIndex*width]); 
        }
      }

      r /= numSamplePixels;
      g /= numSamplePixels;
      b /= numSamplePixels;
      

      if(!first){
        redDiff = (int)abs(red(oldPixels[curSquare]) - r);
        greenDiff = (int)abs(green(oldPixels[curSquare]) - g);
        blueDiff = (int)abs(blue(oldPixels[curSquare]) - b);
        totalDiff = redDiff+greenDiff+blueDiff;
        if (totalDiff > thresh){
          fill(255, 0, 0);
          detectedMotion[curSquare] = true;
        } else {
          fill(r,g,b);
        }
        rect(x, y, sampleWidth, sampleHeight);
      } else {
        first = false;
        fill(r, g, b);
        rect(x, y, sampleWidth, sampleHeight);
      }
      oldPixels[curSquare] = color(r,g,b);
      curSquare++;
    }
  }
  int xTotal, xAvg, yTotal, yAvg, sum;
  xTotal = 0;
  xAvg = 0;
  yTotal = 0;
  yAvg = 0;
  sum = 0;
  for(int i=0; i < (squares*squares); i++){
    if(detectedMotion[i]){
      yTotal += (i/squares);
      xTotal += i%squares;
      sum++;
    }
  }
  if(sum > 0){
    xAvg = xTotal / sum;
    yAvg = yTotal / sum;
    fill(0,255,0);
    rect(xAvg * sampleWidth, yAvg * sampleHeight, sampleWidth, sampleHeight);
  }
  
}

public void stop() {
  webCam.stop();
  super.stop();
}


