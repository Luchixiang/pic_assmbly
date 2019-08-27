#include "p16F1786.inc"

; CONFIG1
; __config 0x3FE4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
    UDATA_SHR
	ORDER RES 1H
	LOOPCNT RES 1H
	LENGTH RES 1H
	STARTTIME RES 1H
	LOOP2NUM RES 1H
RES_VECT  CODE    0x0000            ; processor reset vector 
    PAGESEL START
    GOTO    START                   ; go to beginning of program


MAIN_PROG CODE                      ; let linker place main program

START
    MOVLW H'01'
    MOVWF ORDER
    BANKSEL TRISA
    MOVLW H'FF'
    MOVFW TRISA
    BCF TRISA,1
    MOVLW H'01'
    INCF WREG
    DECFSZ WREG,0
    INCF WREG
 END