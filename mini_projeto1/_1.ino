#include <SPI.h>
#include <SD.h>

#define LED               10
#define TEMP_SENSOR       A0
#define LIGHT_SENSOR      A1

#define IDEAL_TEMP        0
#define MIN_TEMP          1
#define MAX_TEMP          2
#define IDEAL_LIGHT       3
#define MIN_LIGHT         4
#define MAX_LIGHT         5

int i = 0;

File file;
int data[6] = {24, 20, 30, 80, 60, 100};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(LED, OUTPUT);

}

void loop() {
  // put your main code here, to run repeatedly:

  int temperatureReading = analogRead(TEMP_SENSOR);
  float millivoltage = (temperatureReading/1024.0)*5000; 
  float temperature = millivoltage / 10;

  if (temperature < data[MIN_TEMP] || temperature> data[MAX_TEMP]) {
    // liga ar
    Serial.println((String) temperature);
  }
 
  int lightReading = analogRead(LIGHT_SENSOR);
  int light = map(lightReading, 0, 1023, 0, 100);
  if (light < data[MIN_LIGHT] || light > data[MAX_LIGHT]) {
     analogWrite(LED, data[IDEAL_LIGHT]);
  } else {
    analogWrite(LED, LOW);
  }
  
  Serial.println("light level" + (String)light);  
}

