const int speakerPins[] = {A1, 5, A0, 6, 12, 7, 13, 8, A2, 9, A3, 4, A4, 10, A5, 11};
const int numSpeakers = 16;

void setup() {
  Serial.begin(9600); // Start serial communication
  for (int i = 0; i < numSpeakers; i++) {
    pinMode(speakerPins[i], OUTPUT); // Set each speaker pin as output
    digitalWrite(speakerPins[i], LOW); // Turn all speakers off initially
  }
}

void loop() {

  if (Serial.available()) {
    String input = Serial.readStringUntil('>');
    if (input.startsWith("<")) {
      input = input.substring(1, input.length()); // Remove start and end markers
        int colonIndex = input.indexOf(":");
        if (colonIndex > 0) {
          int state = input.substring(0, colonIndex).toInt();
          input = input.substring(colonIndex+1); //first number after the colon
          while (input.length() > 0) {
            int commaIndex = input.indexOf(",");
            if (commaIndex < 0) {
              commaIndex = input.length();
            }
            int speakerIndex = input.substring(0, commaIndex).toInt() - 1; // Speaker indexes start from 1, so subtract 1
            if (speakerIndex >= 0 && speakerIndex <= numSpeakers) { 
              digitalWrite(speakerPins[speakerIndex], state); 
            }
            input = input.substring(commaIndex+1);
        }
      }
    }
  }
}
