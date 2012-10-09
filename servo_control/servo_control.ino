/*
  Servo control
  Control a servo with a switch
 */

// Pin 13 is our servo
int srv = 13;

// Pin 2 is our switch output
int pb = 2;

void setup()
{
  // set pin 13 to be an output (writable)
  pinMode(srv, OUTPUT);
  // set pin 2 to be input data (readable)
  pinMode(pb, INPUT);
}

// repeats ad nauseum
void loop()
{
  // read button state
  int buttonState = digitalRead(pb);
  if (buttonState == HIGH)
  {
    act();
  }
  else
  {
    noAct();
  }
}

// spin the servo
void act()
{
  digitalWrite(srv, HIGH);
}

// stop servo
void noAct()
{
  digitalWrite(srv, LOW);
}
