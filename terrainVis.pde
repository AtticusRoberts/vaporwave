import ddf.minim.*;
import ddf.minim.analysis.FFT;

Minim minim; //I got a lot of variables I need to initilize. 
FFT fft;
AudioInput in;
AudioInput bassIn;
star[] stars;
int triSize=30;
int rows,cols,w;
int h=1500;
float sampleRate = 44100;
int bufferSize = 1024;
float xin,yin,level,bass,sunWidth,scl,tall;
float acl=0.05;
float flying=0;
boolean toggle=true;
int starCount=100;
float[][] summits;
PImage sun;
int backgroundColor=25;

void setup() {
  //Setting widths and heights, loading images, creating objects of classes
  
  size(1600,1000,P3D);
  sunWidth=500; 
  w=width*2;
  scl=100;
  sun=loadImage("sun.jpg");
  rows=h/triSize;
  cols=w/triSize;
  minim=new Minim(this);
  summits=new float[rows][cols];
  stars=new star[starCount];
  for (int i=0;i<starCount;i++) {
    stars[i]=new star();
  }
  
  //Setting up the sound monitoring
  
  in=minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);
  fft.logAverages(22, 7);
}
void draw() {
  //More sound monitoring stuff
  level = in.mix.level();
  fft.forward(in.mix);
  bass = fft.calcAvg(0, 400);
  
  //the level of acceleration changes with the level of sound. 
  acl=level/2;
  flying-=acl;
  yin=flying;
  
  //This goes through and changes all of the Z axies. I have an multilevel array of Z axies, which I go through and change
  //with two for loops. 
  
  for (int y=0;y<rows;y++) {
    xin=0;
    for (int x=0;x<cols;x++) {
      
      summits[y][x]=map(noise(xin,yin),0,1,-150,150);
      //I use the noise() function to generate sudo random numbers based off of how far in the loops I am. Then I map those 
      //numbers so that they become noticible. This is how I generate the terrain. When I increase the y and xins in the for 
      //loops, it itterates through all of the triangle strips. When I increase the starting level of yin, it moves the area that
      //it's refreshing forward. This gives the illusion of movement, so I don't even need to do any fancy translations or anything.
      //for it to "move" forward.
      xin+=0.2;
    }
    yin+=0.2;
  }
  fill(backgroundColor);
  strokeWeight(3);
  stroke(255,0,255);
  background(backgroundColor);
  translate(width/2,height/2); 
  rotateX(PI/2.3); //When I first generate the triangle strips, the appear flat down on the x axis, giving the camera a birds 
  //eye view. To make the terrain appear in a more interesting way, I rotate the x axis. 
 
  translate(-w/2,-h/2);

  for (int y=0;y<rows-1;y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x=0;x<cols;x++) {
      vertex(x*triSize,y*triSize,summits[y][x]);
      vertex(x*triSize,(y+1)*triSize,summits[y+1][x]);
    }
  endShape(); //This is where I itterate through and actually draw my triangle strips, with the fancy new perlin noise Z axis. 
  }
  rotateX(-(PI/2.3)); //Now we rotate it back so that the stars and the image can apear in the sky, instead of on the same axis as the terrain.
  image(sun,w/2-sunWidth/2,-600);
  for (int i=0;i<starCount;i++) { //Generate the stars.
    stars[i].gen();
  }

}

class star {
  float x,y,clr,clrInc,starSize;
  star() { //Generates the x and y of the stars as random numbers with the parammeter that they can't be too close to the sun image

    toggle=true;
    while (toggle==true) {
      x=random(200,w);
      y=random(-750,-100);
      if (x>=w/2-sunWidth/2 & x<=w/2+sunWidth/2+50 & y>=-500) {
        x=random(200,w);
      }
      else {
        toggle=false;
      }
      print(x);
    }  
  }
  
  void gen() {
    fill(255);
    noStroke();
    starSize=random(bass*3,bass*3+(bass*3)*0.5); //Also the star size is based of of the bass, rather then the same level as the terrain,
    //because it looks more interesting. 
    
    ellipse(x,y,starSize,starSize);
  }
}
