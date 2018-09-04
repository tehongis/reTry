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
    translate(30,20,100);
    plane(200, 200);

    rotateZ(theta);
    rotateX(theta);
    rotateY(theta);
    translate(30,20,200);
    plane(200, 200);

    rotateZ(theta);
    rotateX(theta);
    rotateY(theta);
    translate(30,20,300);
    plane(200, 200);



  theta += 0.02;
  if ( theta > TWO_PI ) {
      theta -= TWO_PI;
  }
}
