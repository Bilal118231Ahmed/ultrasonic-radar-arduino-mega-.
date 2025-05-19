
import processing.serial.*;

Serial myPort;
int angle;
int distance;

void setup() {
  size(800, 600);
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);
  translate(width/2, height);
  fill(0, 255, 0);
  text("Ultrasonic Radar GUI", -100, -height + 20);
  stroke(0, 255, 0);
  noFill();
  arc(0, 0, 400, 400, PI, TWO_PI);
  arc(0, 0, 300, 300, PI, TWO_PI);
  arc(0, 0, 200, 200, PI, TWO_PI);
  arc(0, 0, 100, 100, PI, TWO_PI);
  stroke(255, 0, 0);
  float x = cos(radians(angle)) * distance * 2;
  float y = -sin(radians(angle)) * distance * 2;
  line(0, 0, x, y);
}

void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null && data.contains("Angle") && data.contains("Distance")) {
    String[] parts = data.trim().split(",");
    angle = int(parts[0].split(":")[1]);
    distance = int(parts[1].split(":")[1]);
  }
}
