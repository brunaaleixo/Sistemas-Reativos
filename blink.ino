// DESCRIÇÃO DA TAREFA
// Piscar o LED a cada 1 segundo
// Botão 1: Acelerar o pisca-pisca a cada pressionamento
// (somente na transição de LOW->HIGH)
// Botão 2: Desacelerar a cada pressionamento
// (somente na transição de LOW->HIGH)
// Botão 1+2 (em menos de 500ms): Parar

#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define KEY1       A1
#define KEY2       A2
#define KEY3       A3
#define POT        A0

unsigned long pastTimestamp;
int currentState;
int interval;
int buttonPressTimestamp;
int lastButtonPressed;

// the setup function runs once when you press reset or power the board
void setup() {
  pastTimestamp = millis();
  currentState = LOW;
  interval = 1000;
  lastButtonPressed = NULL;
  buttonPressTimestamp = 0;
  
  Serial.begin(9600);
  // initialize digital pin 13 as an output.
  pinMode(LED1, OUTPUT);
}

// the loop function runs over and over again forever
void loop() {
  unsigned long currentTimestamp = millis();
  if (currentTimestamp - pastTimestamp >= interval) {
    digitalWrite(LED1, !currentState);
    currentState = !currentState; 
    pastTimestamp = currentTimestamp;
  }
  
   int but1 = digitalRead(KEY1);
   int but2 = digitalRead(KEY2);

   if (!but1) {
     if (lastButtonPressed == but2 && currentTimestamp - buttonPressTimestamp < 500) {
       digitalWrite(PIN1, HIGH);
       while(1); 
     } else {
       lastButtonPressed = but1;
       buttonPressTimestamp = currentTimestamp;
     }
     
     if (currentState == HIGH) {
       Serial.println("acelerando");
       
       if (interval >= 500) {
         interval -= 250;
       }
       delay(100);
     }
   }
   else if (!but2) {
      if (lastButtonPressed == but1 && currentTimestamp - buttonPressTimestamp < 500) {
       digitalWrite(PIN1, HIGH);
       while(1); 
     } else {
       lastButtonPressed = but2;
       buttonPressTimestamp = currentTimestamp;
     }
     
     if (currentState == HIGH) {
       Serial.println("desacelerando");
       
       if (interval <= 2500) {
         interval += 250;
       }
       delay(100);
     }
    }
}
