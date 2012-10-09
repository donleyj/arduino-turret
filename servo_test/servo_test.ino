/*
  Basic Servo Test
  Test how a servo works
 */

// Pin 13 is our servo's input
int servo = 13;

void setup()
{
  // set pin 13 to be writable as an output
  pinMode(servo, OUTPUT);
  // call our "action" function and see what happens when the servo is wired
  act();
  digitalWrite(servo, LOW);    // turn the LED off by making the voltage LOW
}

// unused for now
void loop()
{
  
}

// output function test
void act()
{
  digitalWrite(servo, HIGH);    // turn the LED on by making the voltage HIGH
  delay(4000);
}
