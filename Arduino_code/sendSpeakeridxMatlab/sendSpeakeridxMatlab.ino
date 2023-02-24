int matlabData;

void setup() {
    pinMode(4,OUTPUT);
    pinMode(5,OUTPUT);
    pinMode(6,OUTPUT);
    pinMode(7,OUTPUT);
    pinMode(8,OUTPUT);
    pinMode(9,OUTPUT);
    pinMode(10,OUTPUT);
    pinMode(11,OUTPUT);
    pinMode(12,OUTPUT);
    pinMode(13,OUTPUT);
    pinMode(A0,OUTPUT);
    pinMode(A1,OUTPUT);
    pinMode(A2,OUTPUT);
    pinMode(A3,OUTPUT);
    pinMode(A4,OUTPUT);
    pinMode(A5,OUTPUT);
    digitalWrite(4,LOW);
    digitalWrite(5,LOW);
    digitalWrite(6,LOW);
    digitalWrite(7,LOW);
    digitalWrite(8,LOW);
    digitalWrite(9,LOW);
    digitalWrite(10,LOW);
    digitalWrite(11,LOW);
    digitalWrite(12,LOW);
    digitalWrite(13,LOW);
    digitalWrite(A0,LOW);
    digitalWrite(A1,LOW);
    digitalWrite(A2,LOW);
    digitalWrite(A3,LOW);
    digitalWrite(A4,LOW);
    digitalWrite(A5,LOW);

    Serial.begin(115200);
}

void loop() {
     delay(1);
     if (Serial.available()>0) {
      matlabData = Serial.read(); 
      Serial.print(matlabData);
  }
Serial.print(matlabData);
delay(5000);
    if (matlabData == 2) {
      digitalWrite(5, HIGH);
      delay(50000);
      digitalWrite(5, LOW);
    }
    if (matlabData == 3) {
      digitalWrite(A0, HIGH);
      delay(5000);
      digitalWrite(A0, LOW);
    }
    if (matlabData == 4) {
      digitalWrite(6, HIGH);
      delay(5000);
      digitalWrite(6, LOW);
    }
    if (matlabData == 5) {
      digitalWrite(12, HIGH);
      delay(50000);
      digitalWrite(12, LOW);
    }
    if (matlabData == 6) {
      digitalWrite(7, HIGH);
      delay(50000);
      digitalWrite(7, LOW);
    }
    if (matlabData == 7) {
      digitalWrite(13, HIGH);
      delay(50000);
      digitalWrite(13, LOW);
    }
    if (matlabData == 8) {
      digitalWrite(8, HIGH);
      delay(50000);
      digitalWrite(8, LOW);
    }
    if (matlabData == 9) {
      digitalWrite(A2, HIGH);
      delay(50000);
      digitalWrite(A2, LOW);
    }
    if (matlabData == 10) {
      digitalWrite(9, HIGH);
      delay(50000);
      digitalWrite(9, LOW);
    }
    if (matlabData == 11) {
      digitalWrite(A3, HIGH);
      delay(50000);
      digitalWrite(A3, LOW);
    }
    if (matlabData == 12) {
      digitalWrite(4, HIGH);
      delay(50000);
      digitalWrite(4, LOW);
    }
    if (matlabData == 13) {
      digitalWrite(A4, HIGH);
      delay(50000);
      digitalWrite(A4, LOW);
    }
    if (matlabData == 14) {
      digitalWrite(10, HIGH);
      delay(50000);
      digitalWrite(10, LOW);
    }
    if (matlabData == 15) {
      digitalWrite(A5, HIGH);
      delay(50000);
      digitalWrite(A5, LOW);
    }
    if (matlabData == 16) {
      digitalWrite(11, HIGH);
      delay(50000);
      digitalWrite(11, LOW);
    }
   
}
