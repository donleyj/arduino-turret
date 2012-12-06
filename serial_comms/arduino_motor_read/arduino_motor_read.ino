#include <AFMotor.h>

AF_DCMotor motor(1, MOTOR12_64KHZ); // 64KHz pwm
const int pin = 13;

void setup()
{
  Serial.begin(9600);
  pinMode(pin, OUTPUT);
  motor.setSpeed(255);
  digitalWrite(pin, LOW);
}

void loop()
{
  while (Serial.available() > 0)
  {
    // Serial.parseInt interprets character data
    // we want Serial.read() since we're getting raw 0s/1s
    int a = (int) Serial.read();
    //DEBUG show what we're getting in the arduino serial monitor
    Serial.println(a);
    if (a == 1)
    {
      motor.run(FORWARD);
    }
    else if (a == 0)
    {
      motor.run(RELEASE);
    }
    else if (a == 2)
    {
      motor.run(BACKWARD);
    }
    else if (a == 3)
    {
      //servo.trigger
    }
  }
}

