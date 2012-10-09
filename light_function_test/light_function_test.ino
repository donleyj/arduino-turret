/*
  Light Test
  Test a "light" function that modifies LED voltage
 */

// Pin 13 is our LED light
int led = 13;

void setup()
{
  // set pin 13 to be writable as an output
  pinMode(led, OUTPUT);
  // call our "light" function and then turn the LED off if it was left on
  light();
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
}

// unused for now
void loop()
{
  
}

// output function test
void light()
{
  digitalWrite(led, HIGH);    // turn the LED on by making the voltage HIGH
  delay(4000);
}
