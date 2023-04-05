const int speakerPins[] = {A1, 5, A0, 6, 12, 7, 13, 8, A2, 9, A3, 4, A4, 10, A5, 11};
const int numSpeakers = 16;

void setup() {
  Serial.begin(9600); // Start serial communication
  Serial.setTimeout(100);
  for (int i = 0; i < numSpeakers; i++) {
    pinMode(speakerPins[i], OUTPUT); // Set each speaker pin as output
    digitalWrite(speakerPins[i], LOW); // Turn all speakers off initially
  }
}

void loop() {

  if (Serial.available()) {
    String input = Serial.readStringUntil('>');
//    Serial.print(input);
    if (input.startsWith("<")) {
      input = input.substring(1, input.length()); // Remove start and end markers
//      Serial.print(input);
        int colonIndex = input.indexOf(":");
//        Serial.print(colonIndex);
//        Serial.print(',');
        if (colonIndex > 0) {
          int state = input.substring(0, colonIndex).toInt(); //turn on or off
//          Serial.print(state);
          input = input.substring(colonIndex+1); //first number after the colon
          
          while (input.length() > 0) {
            int commaIndex = input.indexOf(",");
            if (commaIndex < 0) {
              commaIndex = input.length();
//              Serial.print(commaIndex);
//              Serial.print(',');
            }
            int speakerIndex = input.substring(0, commaIndex).toInt() - 1; // Speaker indexes start from 1, so subtract 1
//            Serial.print(speakerIndex);
//            Serial.print(',');
            if (speakerIndex >= 0 && speakerIndex <= numSpeakers) { 
              digitalWrite(speakerPins[speakerIndex], state); 
            }
            input = input.substring(commaIndex+1);
//            Serial.print(input);
//            Serial.print(',');
        }
      }
    }
  }
}
