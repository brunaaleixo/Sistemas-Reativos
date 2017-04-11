#include "pindefs.h"
#include "app.h"

int buttonStates[numButtons];
int maxInterval;
int initialTime;

void setup () {
  Serial.begin(9600);
  initialize_pressed_buttons();
  initialize();
}

void initialize_pressed_buttons() {
  int i; 
  for (i=0; i<numButtons; i++) {
    buttonStates[i] = -1; 
  }
}

void button_listen (int button) {
  buttonStates[button - BUTTON1] = digitalRead(button);
}

void timer_set (int ms) {
  initialTime = millis();
  maxInterval = ms;
}


void verifyButton(int button) {
  int currentState = digitalRead(button + BUTTON1);
  if (currentState != buttonStates[button]) {
    button_changed(button, currentState);
  }
}

void loop () {
  int i;
  for (i=0; i<numButtons; i++) {
    // button is being listened to
    if (buttonStates[i] != -1) {
      verifyButton(i);
    }
  }

  int currentTime = millis();
  if (currentTime - initialTime > maxInterval) {
    timer_expired();
  }
}
