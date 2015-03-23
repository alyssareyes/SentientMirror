// based on Vehicle class - http://natureofcode.com/book/chapter-6-autonomous-agents/
class MonMove {
  PVector location;
  PVector headLocation;
  float face;
  PVector velocity;
  PVector acceleration;
  float easingSpeed;
  // Additional variable for size
  float r;
  float maxforce;
  float maxspeed;
  float wandertheta;
  MonReach reach;
  boolean isSeekingLeft;

  MonMove(float x, float y) {
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    location = new PVector(x, y);
    headLocation = new PVector(0, 0);
    face = 10;
    r = 3.0;
    //[full] Arbitrary values for maxspeed and
    // force; try varying these!
    maxspeed = 1;
    maxforce = 0.1;
    //[end]
    reach = new MonReach();
    isSeekingLeft = false;
  }

  // Our standard “Euler integration” motion model
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  // Newton’s second law; we could divide by mass if we wanted.
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  // Our seek steering force algorithm
  void seek(PVector target) {
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    applyForce(steer);
  }

  //random, wandering motion
  void wander() {
    float wanderR = 20;         // Radius for our "wander circle"
    float wanderD = 80;         // Distance for our "wander circle"
    float change = 0.3;
    wandertheta += random(-change, change);     // Randomly change wander theta

    // Now we have to calculate the new location to steer towards on the wander circle
    PVector circleloc = velocity.get();    // Start with velocity
    circleloc.normalize();            // Normalize to get heading
    circleloc.mult(wanderD);          // Multiply bcy distance
    circleloc.add(location);               // Make it relative to boid's location

      float h = velocity.heading2D();        // We need to know the heading to offset wandertheta

    PVector circleOffSet = new PVector(wanderR*cos(wandertheta+h), wanderR*sin(wandertheta+h));
    PVector target = PVector.add(circleloc, circleOffSet);
    seek(target);
    update();
  }

  // sway left and right
  void leftRight(float amount) {
    PVector leftTarget = new PVector(0+ amount, height/4);
    PVector rightTarget = new PVector(width - amount, height/4);

    if (isSeekingLeft)
      ease(leftTarget, false);
    else if (!isSeekingLeft)
      ease(rightTarget, false);

    if (location.x - 200 <= leftTarget.x)
      isSeekingLeft = false;
    else if (location.x + 200 >= rightTarget.x)
      isSeekingLeft = true;


    update();
  }


  // easing - http://processing.org/examples/easing.html
  void ease(PVector target, boolean isFast) {
    float easing;
    if (isFast)
      easing = 0.3;
    else
      easing = 0.05;
    float dx = target.x - location.x;
    if (abs(dx) > 1) {
      location.x += dx * easing;
    }
    float dy = target.y - location.y;
    if (abs(dy) > 1) {
      location.y += dy * easing;
    }
  }

  void easeFace(float targetWidth) {
    float dw = targetWidth - face;
    if (abs(dw) > 1) {
      face += dw * 0.3;
    }
  }


  void reach() {
    reach.reach(location, face);
    headLocation = reach.getHeadLocation();
  }
}


// Reach - http://www.processing.org/examples/reach2.html
class MonReach {
  PVector target;
  int numSegments = 50;
  float segLength = 5;

  float[] x = new float[numSegments];
  float[] y = new float[numSegments];
  float[] angle = new float[numSegments];

  MonReach() {
    x[x.length-1] = width/2;     // Set base x-coordinate
    y[x.length-1] = height;  // Set base y-coordinate
  }

  PVector getHeadLocation() {
    return new PVector(x[0], y[0]);
  }

  void reach(PVector location, float face) {
    reachSegment(0, location);
    for (int i=1; i<numSegments; i++)
      reachSegment(i, target);
    for (int i=x.length-1; i>=1; i--)
      positionSegment(i, i-1);
    for (int i=0; i<x.length; i++) {
      drawSegment(x[i], y[i], angle[i], lerp(face, 20, float(i)/float(x.length)));
    }
  }

  void positionSegment(int a, int b) {
    x[b] = x[a] + cos(angle[a]) * segLength;
    y[b] = y[a] + sin(angle[a]) * segLength;
  }

  void reachSegment(int i, PVector location) {
    float dx = location.x - x[i];
    float dy = location.y - y[i];
    angle[i] = atan2(dy, dx);  
    target = new PVector(location.x - cos(angle[i]) * segLength, location.y - sin(angle[i]) * segLength);
  }

  void drawSegment(float x, float y, float a, float w) {
    strokeWeight(w);
    stroke(#61b594);
    pushMatrix();
    translate(x, y);
    rotate(a);
    line(0, 0, segLength, 0);
    popMatrix();
  }
}

