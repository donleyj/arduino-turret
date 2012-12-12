#include <AFMotor.h>
#include <Servo.h>

AF_DCMotor motor(1, MOTOR12_64KHZ); // 64KHz pwm
Servo trigger;

void setup()
{
  Serial.begin(9600);
  motor.setSpeed(196);
  // Set up the trigger servo and move into position
  trigger.attach(10);
  trigger.write(170);
}

void loop()
{
  while (Serial.available() > 0)
  {
    // Serial.parseInt interprets character data
    // we want Serial.read() since we're getting raw 0s/1s
    int a = (int) Serilal.read();
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
      trigger.write(150);
      delay(250);
      trigger.write(170);
    }
  }
}

