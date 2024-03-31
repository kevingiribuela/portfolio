/* Pinout definition */
#define LED 13
#define SWITCH 2
#define BUTTON 3

/* Macro functionality definition */
#define JUMP 10


#include <Arduino.h>


#include <Wire.h>
#include "Adafruit_GFX.h"
#include "Adafruit_SSD1306.h"

#define SCREEN_WIDTH    128
#define SCREEN_HEIGHT   64
#define OLED_RESET      -1 
#define SCREEN_ADDRESS  0x3D
#define NUMFLAKES       10

/* Revisar dimensiones si no encaja logo */
#define LOGO_HEIGHT   16
#define LOGO_WIDTH    16

const unsigned char PROGMEM logo_bmp[] = {
	// 'Screenshot from 2024-03-15 08-58-43, 128x64px
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf9, 0x00, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0x00, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0x00, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x00, 0x01, 0xff, 0x9f, 0xfb, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0xff, 0x8f, 0xf9, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x00, 0x00, 0x00, 0xff, 0x87, 0xff, 0xff, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xf0, 0x00, 0x00, 0x13, 0xff, 0x83, 0xfc, 0x3f, 0xff, 0xff, 0xff, 
	0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x00, 0x00, 0x7f, 0xff, 0x03, 0xf8, 0x0f, 0xff, 0xff, 0xff, 
	0x1f, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x7f, 0xef, 0xe1, 0xf8, 0x07, 0xff, 0xfe, 0x3f, 
	0x00, 0x0f, 0xff, 0xff, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x1f, 0xe0, 0xf0, 0x03, 0xff, 0xfc, 0x1f, 
	0x38, 0x1f, 0xff, 0xff, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x01, 0xf0, 0x18, 0x01, 0xff, 0xf8, 0x0f, 
	0x00, 0xf9, 0x1f, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x0c, 0x40, 0xff, 0xf8, 0x03, 
	0x07, 0xf8, 0x07, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x60, 0xff, 0xf0, 0x01, 
	0x07, 0xf8, 0x03, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xe0, 0x7f, 0xe0, 0x00, 
	0x01, 0xf4, 0x00, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x01, 0xfc, 0x04, 0x00, 0xe0, 0x7f, 0xc0, 0x00, 
	0x00, 0x00, 0x09, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x10, 0x7f, 0xc0, 0x00, 
	0x00, 0x00, 0x0d, 0xe0, 0x00, 0x00, 0x00, 0x3f, 0xc0, 0x40, 0x00, 0x00, 0x10, 0x3f, 0x80, 0x00, 
	0xc0, 0x00, 0x01, 0xc0, 0x00, 0x00, 0x00, 0xff, 0x83, 0xe0, 0x00, 0xe4, 0x18, 0x3e, 0x00, 0x00, 
	0xc0, 0x00, 0x01, 0xc0, 0x00, 0x00, 0x00, 0xff, 0x01, 0xe0, 0x00, 0x67, 0x1f, 0xff, 0xfe, 0x00, 
	0x00, 0x20, 0x01, 0x80, 0x00, 0x00, 0x00, 0x07, 0xc3, 0xff, 0xe0, 0x7c, 0x0f, 0xc0, 0x00, 0x00, 
	0x00, 0x00, 0x63, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x7f, 0xf8, 0x00, 0x30, 0x0f, 0xfc, 0x00, 0x00, 
	0x00, 0x00, 0x63, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x80, 0x00, 0x00, 0x0f, 0xfe, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x01, 0x1f, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0f, 0x80, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x81, 0x8f, 0xc0, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x8f, 0xc0, 0x10, 
	0xff, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x38, 0x7f, 0xff, 0xe2, 0x00, 
	0xff, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0xf8, 0x00, 0x3c, 0x3f, 0xef, 0xfe, 0x00, 
	0xff, 0xf9, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x3a, 0x3c, 0x03, 0xff, 0x00, 
	0xff, 0xff, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x78, 0x0e, 0x00, 0x07, 0x00, 
	0xff, 0xff, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0xfc, 0x06, 0x00, 0x03, 0x00, 
	0xff, 0xff, 0xc0, 0x70, 0x00, 0x00, 0x00, 0x78, 0x00, 0x00, 0x07, 0xf8, 0x00, 0x00, 0x01, 0x80, 
	0xff, 0xfc, 0x00, 0x3f, 0xc0, 0x00, 0x00, 0x70, 0x20, 0x00, 0x0f, 0xf0, 0x00, 0x00, 0x00, 0xe0, 
	0xff, 0xf0, 0x00, 0x04, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0xf0, 0x00, 0x3f, 0x00, 0x7c, 
	0xff, 0xc0, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0xe0, 0x00, 0xbf, 0xe0, 0x3c, 
	0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x47, 0xc0, 0x18, 0x7f, 0xf0, 0x1c, 
	0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x72, 0x06, 0x13, 0xc0, 0x10, 0x0b, 0xe0, 0x0c, 
	0xfc, 0x06, 0x03, 0xc0, 0x00, 0x02, 0x00, 0x01, 0xf9, 0xe6, 0x33, 0x80, 0x00, 0x00, 0x66, 0x0c, 
	0xf8, 0x1e, 0x03, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x08, 0xe4, 0x33, 0x80, 0x40, 0x06, 0x3e, 0x04, 
	0xf0, 0x3e, 0x61, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x67, 0xc0, 0x40, 0x00, 0x3f, 0x06, 
	0xf0, 0x3e, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4f, 0xe0, 0x00, 0x00, 0x7f, 0x06, 
	0xe0, 0x78, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xcf, 0xe0, 0x5c, 0x01, 0x3e, 0x00, 
	0xe0, 0x7c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x9f, 0xe0, 0x7c, 0x00, 0x3e, 0x03, 
	0xe0, 0x7c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x3f, 0xe0, 0xfe, 0x00, 0x04, 0x07, 
	0xe0, 0x7c, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x06, 0x3f, 0xe0, 0x7f, 0x00, 0xc0, 0x07, 
	0xe0, 0x7c, 0x00, 0x00, 0x07, 0xb0, 0x1e, 0x00, 0x00, 0x00, 0x3f, 0xf0, 0x1f, 0xbf, 0xe0, 0x07, 
	0xe0, 0x7c, 0x30, 0x00, 0x00, 0x0c, 0xdb, 0xfc, 0x00, 0x00, 0x7f, 0xf0, 0x0f, 0x3f, 0xe0, 0x07, 
	0xf0, 0x38, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0xff, 0xff, 0xf8, 0x01, 0x3f, 0x80, 0x07, 
	0xf0, 0x18, 0x06, 0x00, 0x1c, 0x00, 0x00, 0xfe, 0x7f, 0xff, 0xff, 0xfc, 0x00, 0x00, 0x00, 0x3f, 
	0xf8, 0x00, 0x03, 0x00, 0x18, 0x00, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x7f, 
	0x00, 0x00, 0x0f, 0x00, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x00, 0xf0, 
	0xfe, 0x00, 0x00, 0x00, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe0, 0x00, 0x00, 0x00, 
	0xff, 0x00, 0x00, 0x00, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf8, 0x00, 0x00, 0x00, 
	0xff, 0xc0, 0x00, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0xff, 0xff, 0xff, 0xfb, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x00, 0x00, 0x00
};

volatile bool increment = false;
volatile bool switch_on = false;
volatile bool quickshift_on = true;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void increment_delay ();
void switch_interrupt ();
void activate_qs();
void deactivate_qs();
void show_cutoff(int *);
void coil(bool);
void testdrawbitmap(const unsigned char *);
void testscrolltext(String);

void setup() {
  Serial.begin(9600);
  pinMode(SWITCH, INPUT);
  pinMode(BUTTON, INPUT);
  pinMode(LED,    OUTPUT);

  attachInterrupt(digitalPinToInterrupt(SWITCH), switch_interrupt, FALLING);
  attachInterrupt(digitalPinToInterrupt(BUTTON), increment_delay, FALLING);

  digitalWrite(LED, HIGH);

  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }
  // Show monzi
  display.clearDisplay();
  testdrawbitmap(logo_bmp);
  display.display();
  delay(2000);

  // Show scrolling text
  display.clearDisplay();
  testscrolltext("Monzi");
  display.display();
  delay(2000);

  Serial.println("Quickshifter ON!");
  Serial.println("Todo listo!");
}

void loop() {
  int milisec = JUMP;
  bool quickshift_prev = quickshift_on;

  while(1){
    if(increment){
      if(milisec == 10*JUMP){
        milisec = 0;
        quickshift_on = false;
      }
      else{
        milisec += JUMP;
        quickshift_on = true;
        show_cutoff(&milisec);
      }

      delay(250);
      increment = false;
    }

    if(quickshift_on & switch_on){
      coil(false);
      delay(milisec);
      coil(true);
      switch_on = false;
    }

    if(quickshift_prev != quickshift_on){
      if(quickshift_prev){
        deactivate_qs();
      }
      else{
        activate_qs();
      }
      quickshift_prev = quickshift_on;
    }
  }
}

void coil(bool state){
  if(state){
    Serial.println("Encendiendo bobina");
    digitalWrite(LED, HIGH);
  } else{
    Serial.println("Apagando bobina");
    digitalWrite(LED, LOW);
  }
}

void show_cutoff(int *milisec){
  Serial.print("Cutoff time: ");
  Serial.print(*milisec);
  Serial.println(" ms");
}

void activate_qs(){
  Serial.println("Quickshifter ACTIVADO!");
}

void deactivate_qs(){
  Serial.println("Quickshifter DESACTIVADO!");
}

void switch_interrupt() {
  if(!switch_on){
    switch_on = true;
  }
}

void increment_delay(){
  if(!increment){
      increment = true;
  }
}

void testdrawline() {
  int16_t i;

  display.clearDisplay(); // Clear display buffer

  for(i=0; i<display.width(); i+=4) {
    display.drawLine(0, 0, i, display.height()-1, SSD1306_WHITE);
    display.display(); // Update screen with each newly-drawn line
    delay(1);
  }
  for(i=0; i<display.height(); i+=4) {
    display.drawLine(0, 0, display.width()-1, i, SSD1306_WHITE);
    display.display();
    delay(1);
  }
  delay(250);

  display.clearDisplay();

  for(i=0; i<display.width(); i+=4) {
    display.drawLine(0, display.height()-1, i, 0, SSD1306_WHITE);
    display.display();
    delay(1);
  }
  for(i=display.height()-1; i>=0; i-=4) {
    display.drawLine(0, display.height()-1, display.width()-1, i, SSD1306_WHITE);
    display.display();
    delay(1);
  }
  delay(250);

  display.clearDisplay();

  for(i=display.width()-1; i>=0; i-=4) {
    display.drawLine(display.width()-1, display.height()-1, i, 0, SSD1306_WHITE);
    display.display();
    delay(1);
  }
  for(i=display.height()-1; i>=0; i-=4) {
    display.drawLine(display.width()-1, display.height()-1, 0, i, SSD1306_WHITE);
    display.display();
    delay(1);
  }
  delay(250);

  display.clearDisplay();

  for(i=0; i<display.height(); i+=4) {
    display.drawLine(display.width()-1, 0, 0, i, SSD1306_WHITE);
    display.display();
    delay(1);
  }
  for(i=0; i<display.width(); i+=4) {
    display.drawLine(display.width()-1, 0, i, display.height()-1, SSD1306_WHITE);
    display.display();
    delay(1);
  }

  delay(2000); // Pause for 2 seconds
}

void testdrawrect(void) {
  display.clearDisplay();

  for(int16_t i=0; i<display.height()/2; i+=2) {
    display.drawRect(i, i, display.width()-2*i, display.height()-2*i, SSD1306_WHITE);
    display.display(); // Update screen with each newly-drawn rectangle
    delay(1);
  }

  delay(2000);
}

void testfillrect(void) {
  display.clearDisplay();

  for(int16_t i=0; i<display.height()/2; i+=3) {
    // The INVERSE color is used so rectangles alternate white/black
    display.fillRect(i, i, display.width()-i*2, display.height()-i*2, SSD1306_INVERSE);
    display.display(); // Update screen with each newly-drawn rectangle
    delay(1);
  }

  delay(2000);
}

void testdrawcircle(void) {
  display.clearDisplay();

  for(int16_t i=0; i<max(display.width(),display.height())/2; i+=2) {
    display.drawCircle(display.width()/2, display.height()/2, i, SSD1306_WHITE);
    display.display();
    delay(1);
  }

  delay(2000);
}

void testfillcircle(void) {
  display.clearDisplay();

  for(int16_t i=max(display.width(),display.height())/2; i>0; i-=3) {
    // The INVERSE color is used so circles alternate white/black
    display.fillCircle(display.width() / 2, display.height() / 2, i, SSD1306_INVERSE);
    display.display(); // Update screen with each newly-drawn circle
    delay(1);
  }

  delay(2000);
}

void testdrawroundrect(void) {
  display.clearDisplay();

  for(int16_t i=0; i<display.height()/2-2; i+=2) {
    display.drawRoundRect(i, i, display.width()-2*i, display.height()-2*i,
      display.height()/4, SSD1306_WHITE);
    display.display();
    delay(1);
  }

  delay(2000);
}

void testfillroundrect(void) {
  display.clearDisplay();

  for(int16_t i=0; i<display.height()/2-2; i+=2) {
    // The INVERSE color is used so round-rects alternate white/black
    display.fillRoundRect(i, i, display.width()-2*i, display.height()-2*i,
      display.height()/4, SSD1306_INVERSE);
    display.display();
    delay(1);
  }

  delay(2000);
}

void testdrawtriangle(void) {
  display.clearDisplay();

  for(int16_t i=0; i<max(display.width(),display.height())/2; i+=5) {
    display.drawTriangle(
      display.width()/2  , display.height()/2-i,
      display.width()/2-i, display.height()/2+i,
      display.width()/2+i, display.height()/2+i, SSD1306_WHITE);
    display.display();
    delay(1);
  }

  delay(2000);
}

void testfilltriangle(void) {
  display.clearDisplay();

  for(int16_t i=max(display.width(),display.height())/2; i>0; i-=5) {
    // The INVERSE color is used so triangles alternate white/black
    display.fillTriangle(
      display.width()/2  , display.height()/2-i,
      display.width()/2-i, display.height()/2+i,
      display.width()/2+i, display.height()/2+i, SSD1306_INVERSE);
    display.display();
    delay(1);
  }

  delay(2000);
}

void testdrawchar(void) {
  display.clearDisplay();

  display.setTextSize(1);      // Normal 1:1 pixel scale
  display.setTextColor(SSD1306_WHITE); // Draw white text
  display.setCursor(0, 0);     // Start at top-left corner
  display.cp437(true);         // Use full 256 char 'Code Page 437' font

  // Not all the characters will fit on the display. This is normal.
  // Library will draw what it can and the rest will be clipped.
  for(int16_t i=0; i<256; i++) {
    if(i == '\n') display.write(' ');
    else          display.write(i);
  }

  display.display();
  delay(2000);
}

void testdrawstyles(void) {
  display.clearDisplay();

  display.setTextSize(1);             // Normal 1:1 pixel scale
  display.setTextColor(SSD1306_WHITE);        // Draw white text
  display.setCursor(0,0);             // Start at top-left corner
  display.println(F("Hello, world!"));

  display.setTextColor(SSD1306_BLACK, SSD1306_WHITE); // Draw 'inverse' text
  display.println(3.141592);

  display.setTextSize(2);             // Draw 2X-scale text
  display.setTextColor(SSD1306_WHITE);
  display.print(F("0x")); display.println(0xDEADBEEF, HEX);

  display.display();
  delay(2000);
}

void testscrolltext(String texto) {
  display.clearDisplay();

  display.setTextSize(2); // Draw 2X-scale text
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 0);
  display.println(texto);
  display.display();      // Show initial text
  delay(100);

  // Scroll in various directions, pausing in-between:
  display.startscrollright(0x00, 0x0F);
  delay(2000);
  display.stopscroll();
  delay(1000);
  display.startscrollleft(0x00, 0x0F);
  delay(2000);
  display.stopscroll();
  delay(1000);
  display.startscrolldiagright(0x00, 0x07);
  delay(2000);
  display.startscrolldiagleft(0x00, 0x07);
  delay(2000);
  display.stopscroll();
  delay(1000);
}

void testdrawbitmap(const unsigned char *logo_bmp) {
  display.clearDisplay();

  display.drawBitmap(
    (display.width()  - LOGO_WIDTH ) / 2,
    (display.height() - LOGO_HEIGHT) / 2,
    logo_bmp, LOGO_WIDTH, LOGO_HEIGHT, 1);
  display.display();
  delay(1000);
}

#define XPOS   0 // Indexes into the 'icons' array in function below
#define YPOS   1
#define DELTAY 2

void testanimate(const uint8_t *bitmap, uint8_t w, uint8_t h) {
  int8_t f, icons[NUMFLAKES][3];

  // Initialize 'snowflake' positions
  for(f=0; f< NUMFLAKES; f++) {
    icons[f][XPOS]   = random(1 - LOGO_WIDTH, display.width());
    icons[f][YPOS]   = -LOGO_HEIGHT;
    icons[f][DELTAY] = random(1, 6);
    Serial.print(F("x: "));
    Serial.print(icons[f][XPOS], DEC);
    Serial.print(F(" y: "));
    Serial.print(icons[f][YPOS], DEC);
    Serial.print(F(" dy: "));
    Serial.println(icons[f][DELTAY], DEC);
  }

  for(;;) { // Loop forever...
    display.clearDisplay(); // Clear the display buffer

    // Draw each snowflake:
    for(f=0; f< NUMFLAKES; f++) {
      display.drawBitmap(icons[f][XPOS], icons[f][YPOS], bitmap, w, h, SSD1306_WHITE);
    }

    display.display(); // Show the display buffer on the screen
    delay(200);        // Pause for 1/10 second

    // Then update coordinates of each flake...
    for(f=0; f< NUMFLAKES; f++) {
      icons[f][YPOS] += icons[f][DELTAY];
      // If snowflake is off the bottom of the screen...
      if (icons[f][YPOS] >= display.height()) {
        // Reinitialize to a random position, just off the top
        icons[f][XPOS]   = random(1 - LOGO_WIDTH, display.width());
        icons[f][YPOS]   = -LOGO_HEIGHT;
        icons[f][DELTAY] = random(1, 6);
      }
    }
  }
}