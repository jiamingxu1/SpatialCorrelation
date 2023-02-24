String message;
void setup() 
{
Serial.begin(115200);
}

void loop() 
{
  if (Serial.available()>0)
  {
    message = Serial.readStringUntil("\n");
    Serial.print("I have received message: ");
    Serial.print(message);
  }
}
