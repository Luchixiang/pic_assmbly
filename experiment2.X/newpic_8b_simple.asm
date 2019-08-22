#include "p16F1786.inc"

; CONFIG1
; __config 0x3FE4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

 COUNT EQU 70H
 COUNTFORNOP EQU 20H
 
START
    
    BANKSEL OSCCON  ; CP
    MOVLW B'01010000';500kHZ
    MOVWF OSCCON
    
    BANKSEL OPTION_REG 
    MOVLW B'01000111' ;1:256
    MOVWF OPTION_REG
    
    BANKSEL TRISA
    CLRF TRISA
    
    BANKSEL PORTA
    MOVLW H'ff'
    MOVWF PORTA
    BANKSEL INTCON 
    CLRF INTCON

MAINLOOP
    
    MOVLW 0x02
    MOVWF COUNT
    MOVLW 0x10
    MOVWF COUNTFORNOP
    LOOP0
	BANKSEL TMR0
	MOVLW B'00001100';256-244 
	MOVWF TMR0
	    LOOP1
		BTFSS  INTCON,2
		GOTO LOOP1
    CLRF INTCON
    DECFSZ COUNT,1
    GOTO LOOP0
	LOOP3
	    DECFSZ COUNTFORNOP,1
	    GOTO LOOP3 
    MOVLW B'00000001'
    BANKSEL LATA
    XORWF LATA,1
    CLRWDT
    GOTO MAINLOOP                         ; loop forever
    
END