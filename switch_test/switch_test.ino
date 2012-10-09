/*
  Switch test
  Control an LED with a switch
 */

// Pin 13 is our LED light
int led = 13;

// Pin 2 is our switch output
int pb = 2;

void setup()
{
  // set pin 13 to be an output (writable)
  pinMode(led, OUTPUT);
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
    light();
  }
  else
  {
    dark();
  }
}

// for now, just light the LED
void light()
{
  digitalWrite(led, HIGH);
}

// for now, just darken the LED
void dark()
{
  digitalWrite(led, LOW);
}
