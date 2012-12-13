import JMyron.*;
import java.io.*;
import java.net.*;

//public class motionDetection{

int squares = 20;

JMyron webCam;
int sampleWidth, sampleHeight;
int numSamplePixels;
int[] oldPixels;
int thresh = 15;
int blueDiff;
int greenDiff;
int redDiff;
int totalDiff;
int curSquare;
int count = 0;
boolean first = true;
boolean[] detectedMotion;
String filename;
boolean rightEdge = false;
boolean leftEdge = false;
int location = 0;

Writer output = null;
File file = null;
boolean fire = false;
static String[] args;


//Setup webcam, open file to be written to
void setup() {

    
    //camera setup
    size(320, 240);
  
    webCam = new JMyron();
    webCam.start(width, height);
    webCam.findGlobs(0);
  
    sampleWidth = width/squares;
    sampleHeight = height/squares;
    numSamplePixels = sampleWidth*sampleHeight;
    oldPixels = new int[squares*squares];
    
    try{
      file = new File("G:\\motion.txt");
      
      file.delete();
      output = new BufferedWriter(new FileWriter(file));
    }catch(IOException ex) {
      System.out.println("File error");
      exit();
    }
  
}

int locateTurret(int[] curFrame){
  
  int locks = 0;
  
  for(int y = 0; y < 24; y += 1){
    for(int x = 0; x < width; x+= 1){
      if(locks < 3){
        float tempr = red(curFrame[x+y*width]);
        float tempg = green(curFrame[x+y*width]);
        float tempb = blue(curFrame[x+y*width]);
        //Parameters for turret detection. Must be calibrated in different lighting.
        if(((85 < tempr)&&(tempr < 110))&&((tempg > 40)&&(tempg < 60))&&((tempb > 50)&&(tempb < 75))){
          locks++;
        } else {
          locks = 0;
        }
      } else {
        location = x;
        x = width;
        y = 24;
      }
    }
  }
  if(locks == 3){
    count = 0;
    //System.out.println("Turret found at: ");
    // System.out.println(location);
    if (location > 160){
      rightEdge = true;
      leftEdge = false;
    }
    if (location < 160){
      leftEdge = true;
      rightEdge = false;
    }
  } else {
    count++;
    if(count >= 6){
      if(leftEdge)
        offEdge('r');
      if(rightEdge)
        offEdge('l');
    }
    //Turret not found
  }
  return location;
}

//Main motion detection method
void draw(){
  
  //Initialize the string to be sent as no movement
  String clientMsg="n";
  webCam.update();
  int[] curFrame = webCam.image();

  //Figure out where the turret is
  location = locateTurret(curFrame);
  
  curSquare = 40;
  detectedMotion = new boolean[squares*squares];

  // go through all the cells
  for (int y=24; y < height; y += sampleHeight) {
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
  clientMsg = "n";
  if(sum > 0){
    xAvg = xTotal / sum;
    yAvg = (yTotal / sum);
    clientMsg = null;
    fill(0,255,0);
    int xCoord = xAvg * sampleWidth;
    int yCoord = (yAvg * sampleHeight);//+12;
    rect(xCoord, yCoord, sampleWidth, sampleHeight);
    if (xCoord > (location + 70)){
      clientMsg = "r";
    } else if (xCoord < (location) - 20){
      clientMsg = "l";
    } else {
      clientMsg = "f";
    }
  }
  try{
    output.write(clientMsg);
    output.flush();
    Thread.sleep(50);
    output.write('n');
    output.flush();
    Thread.sleep(50);
    
  } catch (Exception ex1){
    System.out.println(ex1);
  }  
}

//A char is passed, either r or l depending on which way it went off
//This method moves the turret until it is in the center of the webcam
void offEdge(char dir){
  System.out.println("Moving turret back to the " + dir);
  
      
  int locks = 0;
  int location =0;
  
  while((locks < 3)&&((location > 130)||(location < 190))){
    try {
      Thread.sleep(50);
      output.write('n');
      output.flush();
      Thread.sleep(50);
    } catch (Exception e){
      System.out.println("error");
    }
    webCam.update();
    int[] curFrame = webCam.image();
  
    for(int y = 0; y < 24; y += 1){
      for(int x = 0; x < width; x+= 1){
        if(locks < 3){
          float tempr = red(curFrame[x+y*width]);
          float tempg = green(curFrame[x+y*width]);
          float tempb = blue(curFrame[x+y*width]);
          //Parameters for turret detection. Must be calibrated in different lighting.
          if(((85 < tempr)&&(tempr < 110))&&((tempg > 40)&&(tempg < 60))&&((tempb > 50)&&(tempb < 75))){
            locks++;
          } else {
            locks = 0;
          }
        } else {
          location = x;
          x = width;
          y = 24;
        }
      }
    }
    if(locks == 3){
      if (location > 160){
        rightEdge = true;
        leftEdge = false;
      }
      if (location < 160){
        leftEdge = true;
        rightEdge = false;
      }
    } else {
      try{
        output.write(dir);
        output.flush();
      } catch (Exception e){
      }
     }
    }


}
       
  void stop() {
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

