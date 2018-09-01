var x;
var y;
var outsideRadius = 150;
var insideRadius = 100;
var counter1 = 0;
var counter2 = 0;

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

  var numPoints = int(map(mouseX, 0, width, 6, 60));
  var angle = 0;
  var angleStep = 180.0/numPoints;

  beginShape(TRIANGLE_STRIP);
  for (var i = 0; i <= numPoints; i++) {
    var px = x + cos(radians(angle)) * outsideRadius;
    var py = y + sin(radians(angle)) * outsideRadius;
    angle += angleStep;
    vertex(px, py);
    px = x + cos(radians(angle)) * insideRadius;
    py = y + sin(radians(angle)) * insideRadius;
    vertex(px, py);
    angle += angleStep;
  }
  endShape();

  imageMode(CENTER);

  x_location = x + (sin(counter1) * width);
  y_location = y + (sin(counter2) * height);

  image(logo, x_location, y);
  image(colors, x, y_location);

  counter1 += 0.02;
  if ( counter1 > PI*2 ) {
      counter1 -= PI*2;
  }
  counter2 += 0.04;
  if ( counter2 > PI*2 ) {
      counter2 -= PI*2;
  }

}
