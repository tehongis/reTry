var x;
var y;
var outsideRadius = 150;
var insideRadius = 100;
var counter1 = 0;
var counter2 = 0;
var counter3 = 1;

function preload() {
  soundFormats("mp3");
  mySound = loadSound("assets/MRT - Phat Frog.mp3");
  logo = loadImage("assets/retry.png");
  colors = loadImage("assets/colors.png");
}

function setup() {
  //createCanvas(windowWidth, windowHeight);
  createCanvas(800,600);
  background(0);
  x = width/2;
  y = height/2;
  mySound.setVolume(1.0);
  mySound.play();
}

function draw() {
  background(0);

  imageMode(CENTER);

  x_location = x + (sin(counter1) * (width/2));
  y_location = y + (sin(counter2) * (height/4));
  y2_location = y + (sin(counter3) * (height/4));

  image(colors, x, y_location,width,colors.height*2);
  image(colors, x, y2_location,width,colors.height*2);
  image(logo, x_location, y);

  counter1 += 0.02;
  if ( counter1 > PI*2 ) {
      counter1 -= PI*2;
  }
  counter2 += 0.04;
  if ( counter2 > PI*2 ) {
      counter2 -= PI*2;
  }
  counter3 += 0.04;
  if ( counter3 > PI*2 ) {
      counter3 -= PI*2;
  }

}
