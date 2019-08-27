#include <xc.h>
// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

// CONFIG1
#pragma config FOSC = INTOSC    // Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
#pragma config WDTE = OFF       // Watchdog Timer Enable (WDT disabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable (PWRT disabled)
#pragma config MCLRE = ON       // MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
#pragma config CP = OFF         // Flash Program Memory Code Protection (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Memory Code Protection (Data memory code protection is disabled)
#pragma config BOREN = ON       // Brown-out Reset Enable (Brown-out Reset enabled)
#pragma config CLKOUTEN = OFF   // Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
#pragma config IESO = ON        // Internal/External Switchover (Internal/External Switchover mode is enabled)
#pragma config FCMEN = ON       // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)

// CONFIG2
#pragma config WRT = OFF        // Flash Memory Self-Write Protection (Write protection off)
#pragma config VCAPEN = OFF     // Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
#pragma config PLLEN = ON       // PLL Enable (4x PLL enabled)
#pragma config STVREN = ON      // Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
#pragma config BORV = LO        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
#pragma config LPBOR = OFF      // Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
#pragma config LVP = ON         // Low-Voltage Programming Enable (Low-voltage programming enabled)

const unsigned int pos[] =    {0x0e,0x0d,0x0b,0x07};    //0,1,2,3
const unsigned int num[] =    {0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x79};
                                                        //0-9,e
int value;
float vdd;
int value_0,value_1,value_2,value_3;

void interrupt irs_routine(void);
void init(void);
void data_calculate(void);
void show_num(void);
void show_single(int position_index,int num_index);
void union_delay_closetube(void);
void close_tube(void);
void delay(void);
void delay_long(void);
void main(void) {
    init();
    while(1){  
        ADCON0bits.GO_nDONE = 1;
        //data_calculate();
    }
    return;
}
void interrupt irs_routine(void){
    PIR1 = 0B00000000; //??ADC????
    data_calculate();
    show_num();
    
    return;
}
void init(void){
    PORTA = 0x00;
    PORTB = 0x00;
    TRISA = 0x00;
    TRISB = 0x00;
    OSCCON = 0x5a;
    OPTION_REG = 0x87;
    TMR0 = 255;
    INTCON = 0B11000000; //?????????????
    PIR1 = 0B00000000; //??ADC????
    PIE1 = 0B01000000; //??ADC??
    
    ADCON0 = 0B01111111; //?????FVR,GO/DONE=1?????ADON=1??
    ADCON1 = 0B10000000; //??????????????
    ADCON2 = 0B00001111;
    FVRCON = 0B11000011;
}
void data_calculate(){
    value = ADRESH<<8; 
    value = value+ADRESL;
    vdd = 4.096*4095/value;
    value_0 = (int)vdd;
    value_1 = (int)((vdd-value_0)*10);
    value_2 = (int)(((vdd-value_0)*10-value_1)*10);
    value_3 = (int)((((vdd-value_0)*10-value_1)*10-value_2)*10);
    int value_4 = (int)(((vdd-value_0)*10-value_1)*10-value_2)*10;
    return;
}
void show_single(int position_index,int num_index){
        //can show correct button in right position
        LATB = 0;
        LATA = pos[position_index];
        LATB = num[num_index];
        return;
    }
void show_num(void){
    for(int i=0;i<20;i++){
        for(int i=0;i<20;i++){
            show_single(0,value_0);
            union_delay_closetube();
            show_single(1,value_1);
            union_delay_closetube();
            show_single(2,value_2);
            union_delay_closetube();
            show_single(3,value_3);
            //close_tube();
            union_delay_closetube();
            }
}
    
    return;
    
}
void delay(void){
    for(int i=0;i<3;i++){;}
    return;
}
void union_delay_closetube(void){
        delay();
        close_tube();
        return;
}
void close_tube(void){                      // close all tubes
        LATA = 0xff;
        return;
}
void delay_long(void){
    for(int i=0;i<6;i++){
        for(int i=0;i<6;i++){;}
    }
    return;
}

