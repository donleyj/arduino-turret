import JMyron.*;
import java.io.*;
import java.net.*;

int squares = 20;

JMyron webCam;
int sampleWidth, sampleHeight;
int numSamplePixels;
int[] oldPixels;
int thresh = 13;
int blueDiff;
int greenDiff;
int redDiff;
int totalDiff;
int curSquare;
boolean first = true;
boolean[] detectedMotion;
//Socket dSocket = null;
//PrintWriter out = null;

Writer output = null;
File file = null;
boolean fire = false;

String host = "ANDREW_ZIMNY-PC";


void setup() {
  
  //JMyron setup
  size(320, 240);

  webCam = new JMyron();
  webCam.start(width, height);
  webCam.findGlobs(0);

  sampleWidth = width/squares;
  sampleHeight = height/squares;
  numSamplePixels = sampleWidth*sampleHeight;
  oldPixels = new int[squares*squares];
  
  try{
    file = new File("C:\\MotionDetection\\motion.txt");
    
    file.delete();
    //file = new File("youFileName.txt");
    //file.createNewFile();
    
    output = new BufferedWriter(new FileWriter(file));
  }catch(IOException ex) {
    System.out.println("error");
  }
  
  //PrintWriter out = null;
/*
  try {
      dSocket = new Socket(host, 4444);
      out = new PrintWriter(dSocket.getOutputStream(), true);
      out.println("START");
  } catch (UnknownHostException e) {
      System.err.println("Don't know about host: " + host);
      System.exit(1);
  } catch (IOException e) {
      System.err.println("Couldn't get I/O for the connection to: " + host);
      System.exit(1);
  }
  */
}

void draw() {
  try {
    Thread.sleep(250);
  } catch (InterruptedException e){
    System.out.println("error");
  }
  String clientMsg = "0000";
  webCam.update();
  int[] curFrame = webCam.image();
  curSquare = 0;
  detectedMotion = new boolean[squares*squares];

  int locks = 0;
  int location = 0;

  for(int y = 0; y < 12; y += 1){
    for(int x = 0; x < width; x+= 1){
      if(locks < 3){
        float tempr = red(curFrame[x+y*width]);
        float tempg = green(curFrame[x+y*width]);
        float tempb = blue(curFrame[x+y*width]);
        if((tempr < 120)&&(tempg < 50)&&(tempb < 80)){
          locks++;
          //System.out.println(locks);
        } else {
          locks = 0;
        }
      } else {
        location = x;
        x = width;
        y = 12;
      }
    }
  }
  if(locks == 3){
    System.out.println("Turret found at: ");
    System.out.println(location);
  } else {
    //System.out.println("Turret not found.");
  }

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
          float tempr = red(curFrame[x+y*width+xIndex+yIndex*width]);
          float tempg = green(curFrame[x+y*width+xIndex+yIndex*width]);
          float tempb = blue(curFrame[x+y*width+xIndex+yIndex*width]); 
          //if((tempg > 230)&&(tempr < 170)&&(tempb < 170))
            //System.out.println("X: " + (xIndex + x) + " Y: " + (yIndex + y) + "   colors: r-" + tempr + " g-" + tempg + " b-" + tempb);
          r += tempr;
          g += tempg;
          b += tempb;
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
          //Make the square red
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
  clientMsg = "N";
  if(sum > 0){
    xAvg = xTotal / sum;
    yAvg = (yTotal / sum);
    clientMsg = null;
    fill(0,255,0);
    int xCoord = xAvg * sampleWidth;
    int yCoord = (yAvg * sampleHeight);//+12;
    rect(xCoord, yCoord, sampleWidth, sampleHeight);
    if (xCoord > (width / 2) + 15){
      clientMsg = "L";
    } else if (xCoord < (width / 2) - 15){
      clientMsg = "R";
    } else {
      clientMsg = "F";
    }
      
    //clientMsg = "h:" + (xCoord - (width /2)) + " v:" + (yCoord - (height / 2));
  }
  try{
    output.write(clientMsg);
    output.flush();
  } catch (IOException ex1){
    System.out.println(ex1);
  }
  
  
}
  
public void stop() {
  System.out.println("Stop!");
  try{
    output.close();
    System.out.println("Closed");
  } catch (IOException ex2){
    System.out.println();
  }
  webCam.stop();
  super.stop();
}
