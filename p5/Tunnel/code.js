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
  ambientLight(50);
  pointLight(250, 250, 250, 0, 400, -50);
//  plane(500, 500);
//  rotate(90,0,0);
    texture(cloud);
    rotateZ(theta);
    rotateX(theta);
    rotateY(theta);

    push();
    plane(200, 200);
    rotate(33,0,33)
    translate(0,20,0);
    pop();

    push();
    plane(200, 200);
    rotate(63,0,33)
    translate(0,20,0);
    pop();

    push();
    plane(200, 200);
    rotate(93,0,33)
    translate(0,20,0);
    pop();

  theta += 0.02;
  if ( theta > TWO_PI ) {
      theta -= TWO_PI;
  }
}
