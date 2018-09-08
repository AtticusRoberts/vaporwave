import ddf.minim.*;
import ddf.minim.analysis.FFT;

Minim minim;
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

  in=minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);
  fft.logAverages(22, 7);
}
void draw() {
  level = in.mix.level();
  fft.forward(in.mix);
  bass = fft.calcAvg(0, 400);
  acl=level/2;
  flying-=acl;
  yin=flying;
  for (int y=0;y<rows;y++) {
    xin=0;
    for (int x=0;x<cols;x++) {
      tall=150;
      summits[y][x]=map(noise(xin,yin),0,1,-tall,tall);
      xin+=0.2;
    }
    yin+=0.2;
  }
  fill(backgroundColor);
  strokeWeight(3);
  stroke(255,0,255);
  background(backgroundColor);
  translate(width/2,height/2);
  rotateX(PI/2.3);
 
  translate(-w/2,-h/2);

  for (int y=0;y<rows-1;y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x=0;x<cols;x++) {
      vertex(x*triSize,y*triSize,summits[y][x]);
      vertex(x*triSize,(y+1)*triSize,summits[y+1][x]);
    }
  endShape();
  }
  rotateX(-(PI/2.3));
  image(sun,w/2-sunWidth/2,-600);
  for (int i=0;i<starCount;i++) {
    stars[i].gen();
  }

}

class star {
  float x,y,clr,clrInc,starSize;
  star() {
    //clr=0;
    //clrInc=1;
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
    //if (clr>255 | clr<0) {
    //  clrInc=-clrInc;
    //}
    //clr+=clrInc;
    fill(255);
    noStroke();
    starSize=random(bass*3,bass*3+(bass*3)*0.5);
    ellipse(x,y,starSize,starSize);
  }
}
