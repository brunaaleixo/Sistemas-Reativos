#include <SPI.h>
#include <SD.h>
#include <string.h>
#include "pindefs.h"
#include "preset.h"
#include <MFRC522.h>

MFRC522 mfrc522(SS_PIN, RST_PIN);
int presets[5];
int rfidPresent = 0;

void setup() {
  Serial.begin(9600);
  SPI.begin();
  mfrc522.PCD_Init();
  pinMode(LED, OUTPUT);
}

void loop() {
  handleRFID();

  if (rfidPresent) {
    Serial.print("rfid identified\n");
    handleTemperature();
    handleLighting();
  }
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
  String content = "";
  
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    Serial.println(String(mfrc522.uid.uidByte[i], HEX));
    if (i != 0) content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
    content.concat(String(mfrc522.uid.uidByte[i], HEX));
  }

  int i, j;
  for (i=0; i<NUM_IDS; i++) {
    if (strncmp(data[i].id.c_str(), content.c_str(), 8) == 0) {
      for (j=0; j<5; j++) {
        presets[j] = data[i].presets[j];
        Serial.print(presets[j]);
        Serial.print(" ");
      }
      rfidPresent = true;
      break;
    } else {
      rfidPresent = false;
    }
  }
}

void handleTemperature() {
  int temperatureReading = analogRead(TEMP_SENSOR);
  float millivoltage = (temperatureReading / 1024.0) * 5000;
  float temperature = millivoltage / 10;

  if (temperature < presets[MIN_TEMP] || temperature > presets[MAX_TEMP]) {
    // liga ar
  }
  Serial.println((String) temperature);
}

void handleLighting() {
  int lightReading;
  int light;

  lightReading = analogRead(LIGHT_SENSOR);
  light = map(lightReading, 0, 1023, 0, 100);

  if (light < presets[MIN_LIGHT]) {
    analogWrite(LED, presets[IDEAL_LIGHT]);
  } else {
    analogWrite(LED, LOW);
  }

  Serial.println("light level" + (String)light);
}

