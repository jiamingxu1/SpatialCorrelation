
// digital pin
int digitalPin;
// analog pin
int analogPin;
// initialize binary state
int digitalPinState = LOW;

// amplifier toggle pins
int onPin;
int offPin1 = 2;
int offPin2 = 3;
int offPin3 = 4;
int offPin4 = 5;
int offPin5 = 6;

// stimulus duration in ms
int duration;

// flicker-flutter frequency
int frequency;
// period length in ms
int periodLength;

// store start time of each function call
unsigned long startTime;
// current time in ms
unsigned long currentMillis;
// last time the pin state was updated
unsigned long previousMillis = 0;

// max number of characters to be received
const byte numChars = 32;
// array of received characters
char receivedChars[numChars];
// temporary array for use when parsing
char tempChars[numChars];

// tracks whether there is still new serial information
boolean newData = false;

void setup() {
  // set pins to output
  pinMode(digitalPin, OUTPUT);
  pinMode(analogPin, OUTPUT);
  pinMode(onPin, OUTPUT);
  pinMode(offPin1, OUTPUT);
  pinMode(offPin2, OUTPUT);
  pinMode(offPin3, OUTPUT);
  pinMode(offPin4, OUTPUT);
  pinMode(offPin5, OUTPUT);
  // initialize serial monitor
  Serial.begin(9600);
}

void loop() {

  // debounce
  delay(10);

  // function to receive full serial code input
  // input is assumed to have the format <SOA>
  recvWithStartEndMarkers();

  // set the digital pin to the digitalPinState variable (high or low)
  digitalWrite(digitalPin, LOW);
  analogWrite(analogPin, 0);
  digitalWrite(onPin, 0);
  digitalWrite(offPin1, 0);
  digitalWrite(offPin2, 0);
  digitalWrite(offPin3, 0);
  digitalWrite(offPin4, 0);
  digitalWrite(offPin5, 0);

  // if there is input in the serial port
  if (newData == true) {

    // copy the incoming string into a temporary variable
    strcpy(tempChars, receivedChars);
    // call function to parse the string, i.e., extract the SOA
    parseData();
    // reset boolean
    newData = false;

    // period length in ms
    periodLength = 1000 / frequency;

    // current time in ms
    currentMillis = millis();
    // update start time every time something comes through the serial part
    startTime = currentMillis;
    // save the last time the digital state was changed
    previousMillis = currentMillis - periodLength / 4;

    if (currentMillis - startTime < duration) {
      digitalWrite(onPin, 1);
      analogWrite(analogPin, 20);
      // check to see if it's time to (de)activate the digital pin
      while (currentMillis - startTime < duration) {
        // update time
        currentMillis = millis();
        if (currentMillis - previousMillis >= periodLength / 2) {
          // if the digital pin is off turn it on and vice-versa:
          if (digitalPinState == LOW) {
            digitalPinState = HIGH;
          } else {
            digitalPinState = LOW;
          }
          // set the digital pin to the digitalPinState variable (high or low)
          digitalWrite(digitalPin, digitalPinState);
          // save the last time the digital state was changed
          previousMillis = currentMillis;
        }
      }
    }
    // debounce
    delay(5);
  }
}

//============

void recvWithStartEndMarkers() {
  static boolean recvInProgress = false;
  static byte ndx = 0;
  char startMarker = '<';
  char endMarker = '>';
  char rc;

  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();

    if (recvInProgress == true) {
      if (rc != endMarker) {
        receivedChars[ndx] = rc;
        ndx++;
        if (ndx >= numChars) {
          ndx = numChars - 1;
        }
      }
      else {
        receivedChars[ndx] = '\0'; // terminate the string
        recvInProgress = false;
        ndx = 0;
        newData = true;
      }
    }

    else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}

//============

void parseData() {      // split the data into its parts

  char * strtokIndx; // this is used by strtok() as an index

  strtokIndx = strtok(tempChars, ",");     // get the first part
  digitalPin = atoi(strtokIndx);     // convert this part to an integer and store as first pin

  strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
  analogPin = atoi(strtokIndx);     // convert this part to an integer and store as second pin

  strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
  onPin = atoi(strtokIndx);     // convert this part to an integer and store as second pin

  strtokIndx = strtok(NULL, ",");     // get the first part
  duration = atoi(strtokIndx);     // convert this part to an integer and store as duration of the first stimulus

  strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
  frequency = atoi(strtokIndx);     // convert this part to an integer and store as vibration frequency

}
