#include <SPI.h>
#include <SD.h>
#include "pindefs.h"
#include "preset.h"
#include <MFRC522.h>

MFRC522 mfrc522(SS_PIN, RST_PIN);

void setup() {
  Serial.begin(9600);
  SPI.begin();
  mfrc522.PCD_Init();
  pinMode(LED, OUTPUT);
}

void loop() {
  handleRFID();
  handleTemperature();
  handleLighting();
}

void handleRFID() {
  // Look for new cards
  if (!mfrc522.PICC_IsNewCardPresent()) {
    return;
  }

  // Select one of the cards
  if (!mfrc522.PICC_ReadCardSerial()) {
    return;
  }
  
  //Mostra UID na serial
  Serial.print("UID da tag :");
  String conteudo = "";
  byte letra;
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
    Serial.print(mfrc522.uid.uidByte[i], HEX);
    conteudo.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
    conteudo.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
}

void handleTemperature() {
  int temperatureReading = analogRead(TEMP_SENSOR);
  float millivoltage = (temperatureReading / 1024.0) * 5000;
  float temperature = millivoltage / 10;

  if (temperature < data[MIN_TEMP] || temperature > data[MAX_TEMP]) {
    // liga ar
    Serial.println((String) temperature);
  }
}

void handleLighting() {
  int lightReading;
  int light;

  lightReading = analogRead(LIGHT_SENSOR);
  light = map(lightReading, 0, 1023, 0, 100);

  if (light < data[MIN_LIGHT] || light > data[MAX_LIGHT]) {
    analogWrite(LED, data[IDEAL_LIGHT]);
  } else {
    analogWrite(LED, LOW);
  }

  Serial.println("light level" + (String)light);
}

