/* SENTIENT MIRROR
  A sassy processing creature that tends to mirror you, but doesn't always want to
  
  Created for ARTS444 at University of Illinois, Urbana-Champaign
  
  Authored by Alyssa Reyes, 2014
*/

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// opencv: https://github.com/atduskgreg/opencv-processing
Capture video;
OpenCV opencv;

MonMove pos;
Rectangle[] faces;
String [] lines;
boolean isPayingAttention = true;

// eye animation variables
boolean isblinking = false;
int blinkTimer;
boolean isLookingAway = false;
int lookAwayTimer;
int attentionTimer;

// user movement tracking variables
float faceWAvg = 10;
float faceWstart = 0;
float faceWprev = 10;
int numChecks = 1;

float totalMoveAvg = 1;
float moveAvg = 10;
float moveStart = 0;
float movePrev = 10;
int totalMoveChecks = 1;

// color info variables
float redAvg = 0;
float greenAvg = 0;
float blueAvg = 0;
boolean isRedAvg = true;
int colorCount = 0;
float brightness = -1;

int processTimer;

boolean isWandering = true;

// text variables
int speakTimer;
String words;
boolean isTalking = true;

PFont font;
color fontColor;

void setup() {
  noCursor();
  font = loadFont("Bebas-58.vlw");
  size(640, 480);
  pos = new MonMove(0, 0);

  initVideo();
  initTimers();

  popualteText();        //populates string array from text file
  isTalking = true;
  words = "Hi There!";
}


void initVideo() {
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  video.start();
}


void initTimers() {
  blinkTimer = millis();
  lookAwayTimer = millis();
  processTimer = millis();
  speakTimer = millis();
}


void draw() {
  opencv.loadImage(video);
  faces = opencv.detect();
  background(#E6E4DC);

  processVideo();
  speak();
  drawSpeechBubble();
  moveFace();
}


void captureEvent(Capture c) {
  c.read();
}

void popualteText() {
  //  http://www.generatorland.com/glgenerator.aspx?id=116
  //  http://www.generatorland.com/glgenerator.aspx?id=130
  //  http://www.generatorland.com/glgenerator.aspx?id=86&rlx=y
  lines = loadStrings("generatedText.txt");
}


// anomate face --> follow face detection, or randomly wander
void moveFace() {
  //get open cv data
  float tempX, tempY, tempW;
  if (faces.length >=1) {
    tempX = (faces[0].x + faces[0].width/2)*2;
    tempY = (faces[0].y + faces[0].height/2 + 20)*2;
    tempW = faces[0].width;
  }
  else {
    tempX = pos.headLocation.x;
    tempY = pos.headLocation.y;
    tempW = pos.face;
  }

  // anomate face movements
  pos.easeFace(tempW);
  if (isPayingAttention)
    pos.ease(new PVector(tempX, tempY), true);
  else {
    pos.location = pos.headLocation;
    beBored();
  }
  
  pos.reach();
  animateEyes();
  checkBoredness();    //checks user movement for if monster should loose attention
}


void animateEyes() {
  drawEyes();
  blink();
  lookAway();
}


void speak() { 
  //stop talking after 8 seconds
  if (millis() > speakTimer + 8000) {
    isTalking = false;
  }

  //restart talking every 10 seconds
  if (millis() > speakTimer + 10000) {
    //new workds 
    if (brightness%2==0) {
      changeText();
      isTalking = true;
    }
    speakTimer = millis();
  }
}


void drawSpeechBubble() {
  if (!isTalking)
    return;
  textFont(font, 58);
  fill(fontColor);
  text(words, 10, 10, width - 100, 300);
}


void changeText() {
  if (brightness <=0 || brightness % 3 == 0) {
    isTalking = false;
    return;
  }

  // generate different types of text based on image brightness
  if (brightness <= 70) {
    fontColor = color(#332f28);
    words = lines[(int)random(20, 39)];
  }
  else if (brightness > 70 && brightness <= 160) {
    fontColor = color(#c44e18);
    words = lines[(int)random(0, 19)];
  }
  else if (brightness > 160) {
    fontColor = color(#597533);
    words = lines[(int)random(40, 59)];
  }
  else
    return;
}



void drawEyes() {
  noStroke();
  if (isblinking)
    fill(#61b594);
  else
    fill(255);

  if ((isWandering && !isPayingAttention && !isLookingAway) || (isPayingAttention && isLookingAway)
    || (!isPayingAttention && !isWandering && isLookingAway))
  {
    //attention to the right
    ellipse(pos.headLocation.x + pos.face/4, pos.headLocation.y-10, pos.face/10, pos.face/10);
    ellipse(pos.headLocation.x + pos.face/2, pos.headLocation.y-10, pos.face/10, pos.face/10);
  }
  else if ((isPayingAttention && !isLookingAway) || (isWandering && !isPayingAttention && isLookingAway)
    || (!isPayingAttention && !isWandering && !isLookingAway))
  {
    ellipse(pos.headLocation.x - pos.face/4, pos.headLocation.y-10, pos.face/10, pos.face/10);
    ellipse(pos.headLocation.x + pos.face/4, pos.headLocation.y-10, pos.face/10, pos.face/10);
  }
}


void blink() {
  int blinkRate =2000;
  int blinkTime = 300;
  if (!isblinking && millis() > blinkTimer + blinkRate) {
    if (int(random(10))%2==0)
      isblinking = true;
    blinkTimer = millis();
  }
  else if (isblinking && millis() > blinkTimer + blinkTime) {
    isblinking = false;
    blinkTimer = millis();
  }
}

void lookAway() {
  int lookAwayRate = 5000;
  int lookAwayTime = 1000;
  boolean tempLooking;
  boolean isAway;

  if (!isLookingAway && millis() > lookAwayTimer + lookAwayRate) {
    if (int(random(10))==0)
      isLookingAway = true;
    lookAwayTimer = millis();
  }
  else if (isLookingAway && millis() > lookAwayTimer + lookAwayTime) {
    isLookingAway = false;
    lookAwayTimer = millis();
  }
}


// iterate through vieo pixel array & get color info
void processVideo() {
  if (millis() > processTimer + 5000) {
    for (int y=0; y<video.height; y++) {
      for (int x=0; x<video.width; x++) {
        int loc = x + y * video.width;
        color c = video.pixels[loc];
        getColorAverages(c);
        brightness = brightness(c);
        processTimer = millis();
      }
    }
  }
}


void getColorAverages(color pixel) {
  redAvg = ((redAvg * colorCount) + red(pixel))/(colorCount+1);
  greenAvg = ((greenAvg * colorCount) + green(pixel))/(colorCount+1);
  blueAvg = ((blueAvg * colorCount) + blue(pixel))/(colorCount+1);
  colorCount++;

  if (redAvg > greenAvg && redAvg > blueAvg)
    isRedAvg = true;
  else
    isRedAvg = false;
}


// select if monster should wander or sway
void selectBoredom() {
  if (isRedAvg)
    isWandering = false;
  else
    isWandering = true;
}


// execute monster's boredom action
void beBored() {
  if (!isWandering)
    pos.leftRight(totalMoveAvg);
  else
    pos.wander();
}


// check user's x & z movement.  
//Monster will loose attention if there is minal movement in eith dimmension
void checkBoredness() {
  int attentionRate = 5000;

  if (millis() > attentionTimer + attentionRate) {
    if ((isPayingAttention && faceWAvg < 1) || (isPayingAttention && moveAvg < 1)) {
      selectBoredom();
      isPayingAttention = false;
    }
    if (!isPayingAttention && abs(faceWprev - pos.face) > 10)
      isPayingAttention = true;
    else if (isPayingAttention) {
      numChecks = 1;
      faceWAvg = 10;
      moveAvg = 10;
      attentionTimer = millis();
      return;
    }
  }

  if (isPayingAttention) {
    faceWAvg = ((faceWAvg * numChecks) + abs(faceWprev - pos.face)) / (numChecks + 1);
    numChecks++; 
    faceWprev = pos.face;
    totalMoveAvg = ((totalMoveAvg * totalMoveChecks) + abs(movePrev - pos.location.x)) / (totalMoveChecks + 1);
    moveAvg = ((moveAvg * numChecks) + abs(movePrev - pos.location.x)) / (numChecks + 1);
    totalMoveChecks++;
    movePrev = pos.location.x;
  }
}

