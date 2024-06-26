/* Pinout definition */
#define MOSFET 13
#define SWITCH 2
#define BUTTON 3

/* Macro functionality definition */
#define JUMP 20
#define LIMIT 500


#include <Arduino.h>


#include <Wire.h>
#include "Adafruit_GFX.h"
#include "Adafruit_SSD1306.h"

#define SCREEN_WIDTH    128
#define SCREEN_HEIGHT   64
#define OLED_RESET      -1 
#define SCREEN_ADDRESS  0x3C

#define CHAR_WIDTHX2  14
#define CHAR_HEIGHX2  16

#define CHAR_WIDTHX1  7
#define CHAR_HEIGHX1  8

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
volatile bool quickshift_on = false;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void increment_delay_interrupt ();
void switch_interrupt ();
void show_cutoff(int *);
void testdrawbitmap(const unsigned char *);
void textprint(String texto, int X=0, int Y=0, int textsize=2, int on=1);

void setup() {
  pinMode(SWITCH, INPUT);
  pinMode(BUTTON, INPUT);
  pinMode(MOSFET,    OUTPUT);

  attachInterrupt(digitalPinToInterrupt(SWITCH), switch_interrupt, FALLING);
  attachInterrupt(digitalPinToInterrupt(BUTTON), increment_delay_interrupt, FALLING);

  // Set the MOSFET ON
  digitalWrite(MOSFET, HIGH);

  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    for(;;);
  }

  // Show logo
  display.clearDisplay();
  testdrawbitmap(logo_bmp);
  display.display();
  delay(4000);

  // Show text
  display.clearDisplay();
  textprint(" Quick\n  shifter",25,15);
  textprint("Kevin Giribuela", 0,6*CHAR_HEIGHX1+3, 1);
  delay(3000);
  display.clearDisplay();
  textprint("Cut-off:");
  textprint("Kevin Giribuela", 0,6*CHAR_HEIGHX1+3, 1);
  textprint("OFF",0,CHAR_HEIGHX2);
}

void loop() {
  int milisec = 0;

  while(1){
    if(increment){
      if(milisec == LIMIT){
        milisec = 0;
        quickshift_on = false;
      }
      else{
        milisec += JUMP;
        quickshift_on = true;
      }
      show_cutoff(&milisec);

      delay(100);
      increment = false;
    }

    if(quickshift_on & switch_on){
      digitalWrite(MOSFET, LOW);
      delay(milisec);
      digitalWrite(MOSFET, HIGH);

      switch_on = false;
    }
  }
}

void show_cutoff(int *milisec){
  int time = *milisec;
  display.clearDisplay();
  textprint("Cut-off:");
  textprint("Kevin Giribuela", 0,6*CHAR_HEIGHX1+3, 1);
  if(time!=0){
    textprint((String)time+" ms", 0, CHAR_HEIGHX2);
  }
  else{
    textprint("OFF   ", 0, CHAR_HEIGHX2);
  }

}

void switch_interrupt() {
  if(!switch_on){
    switch_on = true;
  }
}

void increment_delay_interrupt(){
  if(!increment){
      increment = true;
  }
}

void textprint(String texto, int X, int Y, int textsize, int on){
  display.setTextSize(textsize);
  if(on){
    display.setTextColor(SSD1306_WHITE);
  }
  else{
    display.setTextColor(SSD1306_BLACK);;
  }
  display.setCursor(X, Y);
  display.println(texto);
  display.display();
}

void testdrawbitmap(const unsigned char *logo_bmp) {
  display.clearDisplay();

  display.drawBitmap(
    (display.width()  - SCREEN_WIDTH ) / 2,
    (display.height() - SCREEN_HEIGHT) / 2,
    logo_bmp, SCREEN_WIDTH, SCREEN_HEIGHT, 1);
  display.display();
}