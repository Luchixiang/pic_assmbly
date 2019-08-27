#include "xc.h"
#include <eeprom_routines.h>
// CONFIG1
#pragma config FOSC = ECH // Oscillator Selection (ECH, External Clock, High Power Mode (4-32 MHz): device clock supplied to CLKIN pin)
#pragma config WDTE = OFF // Watchdog Timer Enable (WDT disabled)
#pragma config PWRTE = OFF // Power-up Timer Enable (PWRT disabled)
#pragma config MCLRE = ON // MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
#pragma config CP = OFF // Flash Program Memory Code Protection (Program memory code protection is disabled)
#pragma config CPD = OFF // Data Memory Code Protection (Data memory code protection is disabled)
#pragma config BOREN = ON // Brown-out Reset Enable (Brown-out Reset enabled)
#pragma config CLKOUTEN = OFF // Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
#pragma config IESO = ON // Internal/External Switchover (Internal/External Switchover mode is enabled)
#pragma config FCMEN = ON // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)

// CONFIG2
#pragma config WRT = OFF // Flash Memory Self-Write Protection (Write protection off)
#pragma config VCAPEN = OFF // Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
#pragma config PLLEN = ON // PLL Enable (4x PLL enabled)
#pragma config STVREN = ON // Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
#pragma config BORV = LO // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
#pragma config LPBOR = OFF // Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
#pragma config LVP = ON // Low-Voltage Programming Enable (Low-voltage programming enabled)
const unsigned int pos[] = {0x0e,0x0d,0x0b,0x07}; //0,1,2,3
const unsigned int num[] = {0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x79};
//0-9,e
//udata_shr
unsigned char roll_count = 0;
unsigned char num_0 = 0;
unsigned char num_1 = 0;
unsigned char num_2 = 0;
unsigned char num_3 = 0;
unsigned char count = 0;
unsigned char last = 0;
unsigned char flag = 0;
//other fuction
void show_btn(int position_index,int btn_index);
void interrupt irs_routine(void);
void delay(void);
void close_tube(void);
void union_delay_closetube(void);
void number_show(void);
void btn_get(void);
void out_put0(void);
void out_put(void);
void out_put2(void);
void eeprom_write(unsigned char addr, unsigned char value);
unsigned char eeprom_read(unsigned char addr);
void main(void){
// initial ports
PORTA = 0x00;
PORTB = 0x00;
TRISA = 0x00;
TRISB = 0x00;
OSCCON = 0x5a; // 1 MHz
OPTION_REG = 0x87; // 1:256
INTCON = 0xa0;
TMR0 = 250;
num_0 = eeprom_read(0x21);
last = eeprom_read(0x22);
while(1){
btn_get();
}
}
//other fuction
void show_btn(int position_index,int btn_index){
//can show correct button in right position
LATB = 0;
LATA = pos[position_index];
LATB = num[btn_index];
return;
}
void interrupt irs_routine(void){ // interrupt
number_show();
INTCON = INTCON & 0xfb;
TMR0 = 250;
return;
}
void delay(void){ // delay
for(int i=0;i<6;i++){;}
return;
}
void close_tube(void){ // close all tubes
LATA = 0xff;
return;
}
void union_delay_closetube(void){
delay();
close_tube();
return;
}
void number_show(void){
show_btn(0,num_0);
union_delay_closetube();
show_btn(1,num_1);
union_delay_closetube();
show_btn(2,num_2);
union_delay_closetube();
show_btn(3,num_3);
union_delay_closetube();
return;
}
void btn_get(void){
LATC = 0x0f;
TRISC = 0x0f;
count = 0;
int i = 0;
for(i=0;i<4;i++){
if(!((PORTC>>i)&1)){ // portc[i] = 0
count++;
num_0 = 7+i;
}
}
if(count==2){out_put2();}
else if(count==1){out_put();}
else{
TRISC = 0x07;
LATC = 0x07;
for(i=0;i<3;i++){
if(!((PORTC>>i)&1) && !((PORTC>>3)&1)){
count++;
num_0 = 4+i;
}
}
if(count==2){out_put2();}
else{
TRISC = 0x0b;
LATC = 0x0b;
for(i=0;i<2;i++){
if(!((PORTC>>i)&1) && !((PORTC>>2)&1)){
count++;
num_0 = 2+i;
}
}
if(count==2){out_put2();}
else{
TRISC = 0x0d;
LATC = 0x0d;
if(!((PORTC>>0)&1) && !((PORTC>>1)&1)){
count++;
num_0 = 1;
}
if(count==2){out_put2();}
else if(count==1){out_put();}
else{out_put0();}
}
}
}
return;
}
void out_put0(void){
flag = 0;
num_0 = last;
//last = 0;
}
void out_put(void){
last = num_0;
flag = 1;
eeprom_write(0x21, num_0);
eeprom_write(0x22, last);
}
void out_put2(void){
num_0 = 3;
flag = 2;
//last = 3;
}