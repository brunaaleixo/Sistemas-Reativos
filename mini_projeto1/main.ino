#include <SPI.h>
#include <SD.h>
#include "pindefs.h"
#include "preset.h"

void setup()
{
  Serial.begin(9600);
  pinMode(LED, OUTPUT);
}

void loop()
{
  int lightReading;
  int light;
  int temperatureReading   = analogRead(TEMP_SENSOR);
  float millivoltage       = (temperatureReading / 1024.0) * 5000;
  float temperature        = millivoltage / 10;

  if (temperature < data[MIN_TEMP] || temperature > data[MAX_TEMP]) {
    // liga ar
    Serial.println((String) temperature);
  }

  lightReading    = analogRead(LIGHT_SENSOR);
  light           = map(lightReading, 0, 1023, 0, 100);

  if (light < data[MIN_LIGHT] || light > data[MAX_LIGHT]) {
    analogWrite(LED, data[IDEAL_LIGHT]);
  } else {
    analogWrite(LED, LOW);
  }

  Serial.println("light level" + (String)light);
}
