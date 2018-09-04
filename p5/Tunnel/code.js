//Code by Tero Hongisto - 2018

var cloud;
var theta = 0;
var i;

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
  ambientLight(150);
//  pointLight(250, 250, 250, 0, 400, -50);
//  plane(500, 500);
//  rotate(90,0,0);
    rotateX(theta);
    rotateY(theta);
    rotateZ(theta);

    for (i = 0 ; i < 30 ; i++) {
        push();
        texture(cloud);
        translate(0,0,i*50);
        rotate(10*i,0,10*i);
        box(100, 100,100);
        pop();
    }

  theta += 0.02;
  if ( theta > TWO_PI ) {
      theta -= TWO_PI;
  }
}
