#define A11 8              
#define A12 9
#define B21 10
#define B22 11
#define trigger 2         

#define VIBRATION_SENSOR_PIN A0 
#define IR_SENSOR_PIN A1 


#include <SoftwareSerial.h>
SoftwareSerial bluetooth(12, 13); 


int steps[4][4] = {
    {LOW, HIGH, HIGH, LOW},
    {LOW, HIGH, LOW, HIGH},
    {HIGH, LOW, LOW, HIGH},
    {HIGH, LOW, HIGH, LOW}
};


const float distanceThreshold = 5.0;  
const int validReadingsRequired = 1;    
const int irThreshold = 500;   
void setup() {
    
    pinMode(A11, OUTPUT);
    pinMode(A12, OUTPUT);
    pinMode(B21, OUTPUT);
    pinMode(B22, OUTPUT);
    pinMode(trigger, OUTPUT);
    for (int i = 3; i <= 6; i++) {  
        pinMode(i, INPUT);
    }
    pinMode(VIBRATION_SENSOR_PIN, INPUT);
    pinMode(IR_SENSOR_PIN, INPUT); 

    
    Serial.begin(9600);           
    bluetooth.begin(9600);        
    Serial.println("System Initialized...");
}

void rotateMotorForTenSeconds() {
    Serial.println("Starting motor rotation...");
    while (analogRead(IR_SENSOR_PIN) > irThreshold) {  
        for (int i = 0; i < 4; i++) {
            digitalWrite(A11, steps[i][0]);
            digitalWrite(A12, steps[i][1]);
            digitalWrite(B21, steps[i][2]);
            digitalWrite(B22, steps[i][3]);
            delay(5);  
        }
    }
}


void holdMotorTorqueForTenSeconds() {
    unsigned long startTime = millis();
    
    while (millis() - startTime < 10000) 
    {
        
        digitalWrite(A11, HIGH);  
        digitalWrite(A12, LOW);
        digitalWrite(B21, HIGH);
        digitalWrite(B22, LOW);
        delay(5);  
    }
}

float ultrasonicSensor(int triggerPin, int echoPin) {
    digitalWrite(triggerPin, LOW);
    delayMicroseconds(2);
    digitalWrite(triggerPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(triggerPin, LOW);
    float duration = pulseIn(echoPin, HIGH);
    return duration * 0.0343 / 2;  
}

void loop() {
    
    for (int i = 3; i <= 6; i++) {  
        int validReadings = 0;
        for (int j = 0; j < validReadingsRequired; j++) {
            float distance = ultrasonicSensor(trigger, i);
            if (distance > 0 && distance < distanceThreshold) {
                validReadings++;
            } else {
                validReadings = 0;  
                break;
            }
            delay(50); 
        }
        if (validReadings == validReadingsRequired) {
            Serial.println("Object detected within threshold. Rotating motor...");
            rotateMotorForTenSeconds();             
            holdMotorTorqueForTenSeconds();            
            int vibrationStatus = digitalRead(VIBRATION_SENSOR_PIN);
            if (vibrationStatus == HIGH) {  
                Serial.println("Vibration detected after motor rotation and holding.");
                
                bluetooth.println("A");
                Serial.println("Bluetooth message sent: Accident happened!");
            } else {
                Serial.println("No vibration detected after motor rotation and holding.");
            }
        } else {
            Serial.println("No object detected within threshold.");
        }
    }
    delay(50);  
}