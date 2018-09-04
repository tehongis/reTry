//Code by Tero Hongisto - 2018

var cloud;
var theta = 0;

function preload() {
//  soundFormats("mp3");
//  mySound = loadSound("assets/MRT - Phat Frog.mp3");
  cloud = loadImage("assets/Cloud_tile.png");
}

function setup() {
  //createCanvas(windowWidth, windowHeight);
  createCanvas(800,600,WEBGL);
  background(0);
//  mySound.setVolume(1.0);
//  mySound.play();
}

function draw() {
  background(0);
  pointLight(250, 250, 250, 300, 300, 50);
//  translate(440,0,0);
//  push();
    rotateZ(theta);
    rotateX(theta);
    rotateY(theta);
    texture(cloud);
    box(200, 200, 200);
//  pop();

  theta += 0.02;
  if ( theta > TWO_PI ) {
      theta -= TWO_PI;
  }
}
