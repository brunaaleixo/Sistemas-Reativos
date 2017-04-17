#include "pindefs.h"
#include "app.h"

int buttonStates[numButtons];
int maxInterval;
int initialTime;

void initialize_button_states() {
  int i; 
  for (i=0; i<numButtons; i++) {
    buttonStates[i] = digitalRead(i + BUTTON1); 
  }
}

void setup () {
  Serial.begin(9600);
  initialize_button_states();
  initialize();
}

void pciSetup(byte pin){
  // enable pin
  *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));
  // clear any outstanding interrupt (Interrupt Flag) 
  PCIFR  |= bit (digitalPinToPCICRbit(pin)); 
  // enable interrupt for the group (Interrupt Control)
  PCICR  |= bit (digitalPinToPCICRbit(pin)); 
}

ISR(PCINT1_vect) {
  int i;
  for (i=0; i<numButtons; i++) {
    // button is being listened to
    if (buttonStates[i] != -1) {
      verifyButton(i);
    }
  }
}

void button_listen (int button) {
  buttonStates[button - BUTTON1] = digitalRead(button);

  pciSetup(button);
}

void timer_set (int ms) {
  initialTime = millis();
  maxInterval = ms;
}


void verifyButton(int button) {
  int currentState = digitalRead(button + BUTTON1);
  
  if (currentState != buttonStates[button] && currentState == 0) {
    button_changed(button);
  } 

  buttonStates[button] = currentState;
}

void loop () {
  int currentTime = millis();
  if (currentTime - initialTime > maxInterval) {
    timer_expired();
  }
}
