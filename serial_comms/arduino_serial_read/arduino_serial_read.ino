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
    // we want Serial,read() since we're getting raw 0s/1s
    int a = (int) Serial.read();
    // show what we're getting in the arduino serial monitor
    Serial.println(a);
    if (a)
    {
      digitalWrite(pin, HIGH);
    }
    else
    {
      digitalWrite(pin, LOW);
    }
  }
}

