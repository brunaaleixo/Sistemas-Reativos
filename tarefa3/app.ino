#include "pindefs.h"
#include "event_driven.h"

/* Callbacks */

void initialize() {
  timer_set(2000);
  button_listen(BUTTON1);
  button_listen(BUTTON2);

 initialize_leds();
}

void initialize_leds() {
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);

  digitalWrite(LED1, HIGH);
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
  digitalWrite(LED4, HIGH);
}

void button_changed (int button, int v) {
  switch (button + BUTTON1) {
    case BUTTON1:
      digitalWrite(LED1, LOW);
      break;
    case BUTTON2:
      digitalWrite(LED2, LOW);
      break;
    case BUTTON3:
      digitalWrite(LED3, LOW);
      break;
  }
}

void timer_expired() {
  digitalWrite(LED4, LOW);
}

