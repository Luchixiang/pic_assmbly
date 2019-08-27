 #include "p16F1786.inc"
; CONFIG1
; __config 0xFFE7
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
    ; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    UDATA_SHR
	MAINCOUNT RES 1H;主循环的四次循环
	PORTNUM RES 1H;用来记录是哪个端口发生了电平中断
	DELAYTIME RES 1H;用来防抖动
	DELAYTIME2 RES 1H
	TEMPPORT RES 1H;用来在防抖动的时候记录portc
	WHICH RES 1H;记录是哪个按键
	WHICHLAST RES 1H;记录上一个按钮
	BIAS RES 1H
	STS RES 1H
	T RES 1H; 长按阈值
	t1 RES 1H; 当前时刻指针
	DET RES 1H;双击时间间隔
	TEMP RES 1H
	TEMP2 RES 1H
RES_VECT  CODE    0x0000            ; processor reset vector 
    PAGESEL START
    GOTO    START                   ; go to beginning of program
MAIN_PROG CODE  ; let linker place main program
 
 
 
 
isr CODE 0x40
    BANKSEL INTCON
    BTFSC INTCON,TMR0IF
    CALL LIGHT
    BCF INTCON,TMR0IF
    CLRF TMR0
   RETFIE
    
   
DELAY
    MOVLW H'FF'
    MOVWF DELAYTIME
    MOVLW H'20'
    MOVWF DELAYTIME2
    STARTLOOP
        LOOP2
	    DECFSZ DELAYTIME2
	    GOTO LOOP2
	DECFSZ DELAYTIME
	GOTO STARTLOOP
    RETURN

   
LIGHT1 
    BANKSEL TRISA
    CLRF TRISA
    BANKSEL TRISB
    MOVLW B'11111101'
    MOVWF TRISB
    CLRF WREG
    ADDWF WHICH,0
    CALL CONSTANTS
    BANkSEL LATA
    MOVWF LATA
    RETURN

 LIGHT2
    BANKSEL TRISA
    CLRF TRISA
    BANKSEL TRISB
    LSLF TRISB,1
    INCF TRISB,1
    CALL CLEAR2
    CLRF WREG
    ADDWF WHICH,0
    CALL CONSTANTS
    BANKSEL LATA
    MOVWF LATA
    RETURN
    
CLEAR2
    BANKSEL TRISB
    MOVLW B'11111101'
    BTFSS TRISB,3
    MOVWF TRISB
    RETURN
    
    
LIGHT3
    
    BANKSEL TRISA
    CLRF TRISA
    BANKSEL TRISB
    LSLF TRISB,1
    INCF TRISB,1
    CALL CLEAR3
    CLRF WREG
    ADDWF WHICH,0
    CALL CONSTANTS
    BANKSEL LATA
    MOVWF LATA
    RETURN
    
 CLEAR3
    BANKSEL TRISB
    MOVLW B'11111101'
    BTFSS TRISB,4
    MOVWF TRISB  
    RETURN
    
 LIGHT
    BTFSC STS,0
    CALL LIGHT1
    BTFSC STS,1
    CALL LIGHT2
    BTFSC STS,2
    CALL LIGHT3
    RETURN
 
; LIGHT ;显示函数
;    BANKSEL TRISA
;    CLRF TRISA
;    BANKSEL TRISB
;    LSLF TRISB,1
;    INCF TRISB,1
;    CALL CLEAR
;    CLRF WREG
;    ADDWF WHICH,0
;    CALL CONSTANTS
;    BANKSEL LATA
;    MOVWF LATA
;    RETURN
;    
;CLEAR
;    CLRF WREG
;    ADDWF BIAS
;    ANDWF STS,0;相等就不会是0，就会进入归零操作
;    INCF WREG
;    DECFSZ WREG,0
;    CALL CHANGE
;    RETURN
;    
;CHANGE
;    MOVLW H'01'
;    MOVWF BIAS
;    BANKSEL TRISB
;    MOVLW B'11111101'
;    ;BTFSS TRISB,5
;    MOVWF TRISB
;    RETURN
    
CONSTANTS ;查表
    BRW
    RETLW B'01110111' ;0
    RETLW B'00000110';1
    RETLW B'10111011';2  
    RETLW B'10011111';3
    RETLW B'11001110';4
    RETLW B'11011101';5
    RETLW B'11111100';6
    RETLW B'00000111';7
    RETLW B'11111111';8
    RETLW B'11001111';9
    RETLW B'11101111';A
    
    
    
START
    BANKSEL OSCCON  ; CP
    MOVLW B'01111010';500kHZ
    MOVWF OSCCON
    BANKSEL INTCON
    MOVLW B'11100000' 
    MOVWF INTCON
    BANKSEL OPTION_REG
    MOVLW B'01010000'
    MOVWF OPTION_REG ; TIMER0 
    BANKSEL ANSELA
    CLRF ANSELA
    BANKSEL TRISA
    CLRF TRISA
    BANKSEL ANSELB
    CLRF ANSELB
    BANKSEL PORTA
    MOVLW H'00'
    MOVWF PORTA 
    BANKSEL LATB
    MOVLW H'00'	
    MOVWF LATB
    MOVLW H'01'
    MOVWF BIAS
    MOVLW H'01'
    MOVWF STS
    
    BANKSEL LATA
    CLRF LATA
    BANKSEL TRISB
    MOVLW B'11111101'
    MOVWF TRISB   
    CLRF MAINCOUNT
    CLRF WHICH
    CLRF WHICHLAST
    CLRF TEMPPORT
    ; ENABLE GLOBAL INTERUP
  
    BANKSEL PIE1
    BCF PIE1,TMR2IE
    BANKSEL T2CON
    MOVLW B'00000100' 
    MOVWF T2CON ;USE 16 AND 64
    BANKSEL PR2
    MOVLW .128
    MOVWF PR2
    BANKSEL WPUC;允许所有弱上拉
    MOVLW H'FF'
    MOVWF WPUC
    
    BANKSEL PORTC;初始化c口
    CLRF PORTC
    BANKSEL IOCCN
    MOVLW H'11'
    MOVWF IOCCN
    MOVLW H'FF'
    MOVWF T
    CLRF t1
    MOVLW H'70'
    MOVWF DET

MAIN
    
    
    MOVLW H'00'
    MOVWF TEMP
    BANKSEL WPUC
    MOVLW H'FF'
    MOVWF WPUC
    BANKSEL TRISC
    MOVLW H'FF'
    MOVWF TRISC
    BANKSEL LATC
    MOVLW H'FF'
    MOVWF LATC
    MOVWF TEMP2
    NOP
    NOP
    BANKSEL PORTC
    MOVLW H'07'
    BTFSS PORTC,0
    CALL COPY
    MOVLW H'08'
    BTFSS PORTC,1
    CALL COPY
    MOVLW H'09'
    BTFSS PORTC,2
    CALL COPY
    MOVLW H'0A'
    BTFSS PORTC,3
    CALL COPY
    INCF TEMP,0
    DECFSZ WREG,0
    GOTO MAIN
    GOTO NEXTCHECK
    
 NEXTCHECK
    BANKSEL WPUC
    MOVLW H'FF'
    MOVWF WPUC
    MOVLW B'00001110'
    BANKSEL TRISC
    MOVWF TRISC
    BANKSEL LATC
    MOVWF LATC
    MOVWF TEMP2
    BANKSEL PORTC
    MOVLW H'05'
    BTFSS PORTC,1
    CALL COPY
    MOVLW H'01'
    BTFSS PORTC,2
    CALL COPY
    MOVLW H'02'
    BTFSS PORTC,3
    CALL COPY
    INCF TEMP,0
    DECFSZ WREG,0
    GOTO MAIN
    GOTO THIRDCHECK
THIRDCHECK
    BANKSEL WPUC
    MOVLW H'FF'
    MOVWF WPUC
    MOVLW B'00001101'
    BANKSEL TRISC
    MOVWF TRISC
    BANKSEL LATC
    MOVWF LATC
    MOVWF TEMP2
    BANKSEL PORTC
    MOVLW H'03'
    BTFSS PORTC,2
    CALL COPY
    MOVLW H'04'
    BTFSS PORTC,3
    CALL COPY
    INCF TEMP,0
    DECFSZ WREG,0
    GOTO MAIN
   GOTO FOURTHCHECK
FOURTHCHECK
   BANKSEL WPUC
   MOVLW H'FF'
   MOVWF WPUC
   MOVLW B'00001011'
   BANKSEL TRISC
   MOVWF TRISC
   BANKSEL LATC
   MOVWF LATC
   MOVWF TEMP2
   MOVLW H'06'
   BANKSEL PORTC
   BTFSS PORTC,3
   CALL COPY
   GOTO MAIN
COPY
    MOVWF TEMP
    MOVWF WHICH
    BANKSEL PORTC
    CLRF WREG
    ADDWF PORTC,0
    XORWF TEMP2,1
    MOVLW H'00'
    BTFSC TEMP2,0
    MOVWF PORTNUM
    MOVLW H'01'
    BTFSC TEMP2,1
    MOVWF PORTNUM
    MOVLW H'02'
    BTFSC TEMP2,2
    MOVWF PORTNUM
    MOVLW H'03'
    BTFSC TEMP2,3
    MOVWF PORTNUM
    RETURN
END