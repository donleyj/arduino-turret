#include <Servo.h>

Servo myservo;

void setup()
{
  myservo.attach(10);
}

void loop()
{
  myservo.write(180);
  delay(500);
  myservo.write(150);
  delay(500);
}
