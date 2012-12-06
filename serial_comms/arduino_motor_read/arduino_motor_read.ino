const int pin = 13;

void setup()
{
  Serial.begin(9600);
  pinMode(pin, OUTPUT);
  // start in an off state
  digitalWrite(pin, LOW);
}

void loop()
{
  while (Serial.available() > 0)
  {
    // Serial.parseInt interprets character data
    // we want Serial.read() since we're getting raw 0s/1s
    int a = (int) Serial.read();
    // show what we're getting in the arduino serial monitor
    Serial.println(a);
    if (a == 1)
    {
      //motor_right
    }
    else if (a == 0)
    {
      //motor_stop
    }
    else if (a == 2)
    {
      //motor_left
    }
    else if (a == 3)
    {
      //motor_fire
    }
  }
}

