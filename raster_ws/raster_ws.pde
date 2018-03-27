import frames.timing.*;
import frames.primitives.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

void setup() {
  //use 2^n to change the dimensions
  size(1024, 1024, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      spin();
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
  
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow( 2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  pushStyle();
  stroke(0, 255, 255, 125);
  //System.out.println("Preparing function");
  
  //startSearchingAndRastering(); 
  popStyle();
   
  if (debug) {
    pushStyle();
    stroke(255, 255, 0, 125);
    point(round(frame.coordinatesOf(v1).x()), round(frame.coordinatesOf(v1).y()));
    point((frame.coordinatesOf(v2).x()), (frame.coordinatesOf(v2).y()));
    popStyle();
  }
}

Vector findLimitOfTwoVectors(Vector a, Vector b, String search, String instruction){
  if(search == "x"){
    if(instruction == "min"){
      if(a.x() < b.x()){
       return a;
      }
      return b;
    }
    if(instruction == "max"){
      if(a.x() > b.x()){
       return a;
      }
      return b;   
    }    
  }
  else{
    if(instruction == "min"){
      if(a.y() < b.y()){
       return a;
      }
      return b;
    }
    if(instruction == "max"){
      if(a.y() > b.y()){
       return a;
      }
      return b;   
    }
  }
  return new Vector(0,0);
}


Vector findLowXOfAll(){
  return(findLimitOfTwoVectors(findLimitOfTwoVectors(v1,v2, "x", "min"),v3, "x", "min"));  
}

Vector findLowYOfAll(){
  return(findLimitOfTwoVectors(findLimitOfTwoVectors(v1,v2, "y", "min"),v3, "y", "min"));  
}

Vector findHighXOfAll(){
  return(findLimitOfTwoVectors(findLimitOfTwoVectors(v1,v2, "x", "max"),v3, "x", "max"));  
}

Vector findHighYOfAll(){
  return(findLimitOfTwoVectors(findLimitOfTwoVectors(v1,v2, "y", "max"),v3, "y", "max"));  
}

boolean isInTriangle(float x, float y){
  for(float a = 0; a <1 ; a += 0.001){
    for(float b = 0; b <1 ; a += 0.001){
      for(float c = 0; c <1 ; a += 0.001){
         //System.out.println("Inside triangle raster");
        if (x == a*v1.x()+ b*v2.x() + c*v3.x() && y == a*v1.y()+ b*v2.y() + c*v3.y() && a+b+c == 1){
           System.out.println("Found point");
          return true;
        }
        if(a == 0.3 && b == 0.3 && c == 0.3){
          return true;
        }
        
      }
    }
  
  }
  
  return true;
}


void startSearchingAndRastering(){
  
  
  
  for(float x = -width/2; x<= width/2; ++x){
    for(float y = -width/2; y<= width/2; ++y){
      
       System.out.println("Inside search");
        if(isInTriangle( x,y)){
         
          point(x,y);        
        }    
    }  
  }
}


void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void spin() {
  if (scene.is2D())
    scene.eye().rotate(new Quaternion(new Vector(0, 0, 1), PI / 100), scene.anchor());
  else
    scene.eye().rotate(new Quaternion(yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100), scene.anchor());
}

void mouseClicked(){
  System.out.println("x:"+mouseX);
  System.out.println("y:"+mouseY);
}



void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
}
