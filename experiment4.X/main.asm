#include "p16F1786.inc"

; CONFIG1
; __config 0x3FE4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
    UDATA_SHR
	ORDER RES 1H;????fsr0l
	LOOPCNT RES 1H
	LENGTH RES 1H
	STARTTIME RES 1H
	LOOP2NUM RES 1H
RES_VECT  CODE    0x0000            ; processor reset vector 
    PAGESEL START
    GOTO    START                   ; go to beginning of program


MAIN_PROG CODE                      ; let linker place main program

isr CODE 0x40 
    BANKSEL INTCON
    BTFSC INTCON,TMR0IF
    CALL LIGHT
    BANKSEL INTCON
    BTFSC INTCON,INTE  ;?int??????????????
    CALL FAST
    BCF INTCON,TMR0IF 
    BCF INTCON,INTF
    BANKSEL PIR1
    BTFSC PIR1,TMR2IF
    CALL DATA_SWITCH
    BCF PIR1,TMR2IF
    MOVLW H'04'
    MOVWF LENGTH
    RETFIE
    
DATA_SWITCH
    INCF LOOPCNT
    BTFSC LOOPCNT,2
    CLRF LOOPCNT
    RETURN
    
FAST 
    BANKSEL OPTION_REG
    MOVLW B'000100110'
    MOVWF OPTION_REG ; TIMER0 ?256??
    RETURN
    
LIGHT
    BCF STATUS,C
    BANKSEL TRISB
    LSLF TRISB,1;
    INCF TRISB,1
    BTFSS TRISB,5
    CALL CLEAR  ;?????
    BANKSEL STATUS
    BSF STATUS,C    ;??????
    CLRF WREG	    
    ADDWF ORDER,0	;WREG = ORDER+LOOP
    ADDWF LOOPCNT,0 	;WREG = ORDER+LOOP
    SUBWFB LENGTH,1	 ;LENGTH - ORDER+LOOP 
    BTFSS STATUS,C	;?????????
    CALL CHANGE
    CALL CONSTANTS
    BANKSEL LATA;
    MOVWF LATA
    INCF ORDER,1
    RETURN
CHANGE 
    COMF LENGTH
    CLRF WREG
    ADDWF LENGTH,0
    RETURN 
CLEAR 
    BANKSEL TRISB ;????
    MOVLW b'11111101'
    MOVWF TRISB	    ;?latB??10(RB1-RB4)
    CLRF ORDER ;????????led
    RETURN
    
CONSTANTS 
    BRW
    RETLW B'00000110'
    RETLW B'10110011'  
    RETLW B'10010111'
    RETLW B'11000110'
    RETLW B'11111101'

START
    BANKSEL OSCCON  ; CP
    MOVLW B'01011000';500kHZ
    MOVWF PR2
    MOVWF OSCCON
;    BANKSEL OPTION_REG 
;    MOVLW B'11000011' ;1:256
;    MOVWF OPTION_REG
    BANKSEL ANSELA;??
    CLRF ANSELA
    BANKSEL TRISA;??
    CLRF TRISA
    BANKSEL ANSELB;??
    CLRF ANSELB
    BANKSEL PORTA;??
    MOVLW H'00'
    MOVWF PORTA ;??
    BANKSEL LATB
    MOVLW H'00'	;??
    MOVWF LATB
    MOVLW H'04'
    MOVWF ORDER
    MOVLW H'FF'
    MOVWF STARTTIME
    MOVWF LOOP2NUM
    MOVLW H'04'
    CALL CONSTANTS
    BANKSEL LATA
    MOVWF LATA
    MOVLW B'000000000'
    BANKSEL TRISB
    MOVWF TRISB
    STARTLOOP
        LOOP2
	    DECFSZ LOOP2NUM
	    GOTO LOOP2
	DECFSZ STARTTIME
	GOTO STARTLOOP
    CLRF ORDER
    BANKSEL TRISB
    MOVLW B'11111110'
    MOVWF TRISB   
    MOVLW H'04'		;??????
    MOVWF LENGTH
    CLRF ORDER
    BANKSEL OPTION_REG
    MOVLW B'01010000'
    MOVWF OPTION_REG ; TIMER0 ?256??
    ; ENABLE GLOBAL INTERUPT
    BANKSEL INTCON
    MOVLW B'11110000' 
    MOVWF INTCON
  
    BANKSEL OPTION_REG
;    MOVLW B'11111111'
;    ANDWF OPTION_REG,F	; ??INT??????????
    
    ; ????????TMR2??
    BANKSEL PIE1
    BSF PIE1,TMR2IE
    BANKSEL T2CON
    MOVLW B'01111111' 
    MOVWF T2CON ;USE 16 AND 64
    BANKSEL PR2
    MOVLW .128
    MOVWF PR2
MAINLOOP
    NOP
    GOTO MAINLOOP                         ; loop forever
END