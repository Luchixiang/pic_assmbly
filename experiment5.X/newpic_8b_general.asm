#include "p16F1786.inc"

    UDATA_SHR
	T RES 1H; ????
	t RES 1h; ??????
	Det RES 1H;??????
	STS RES 1H;???? 1???2???3??
	tt res 1h;????????
	WHICH RES 1H ;0-10?????
START
    BANKSEL INTCON
    MOVLW B'11110000'  ;??????
    MOVWF INTCON
    ; ??????
    ; ?????????
    ; ??TIMER0??
    ; ???INT????
    ; ????????
    BANKSEL OPTION_REG
;    MOVLW B'11111111'
;    ANDWF OPTION_REG,F	; ??INT??????????
    
    ; ????????TMR2??
    BANKSEL T2CON	;??tmr2
    MOVLW B'01111011' ;??tmr2
    MOVWF T2CON ;USE 16 AND 64;??tmr2
    BANKSEL PR2	    ;??tmr2
    MOVLW .255	    ;??tmr2
    MOVWF PR2	    ;??tmr2
    BANKSEL PIE1
    BANKSEL T2CON	
    BSF T2CON,TMR2ON;
    BANKSEL PIR1

MAINLOOP
    NOP
    GOTO MAINLOOP
    
TMR2LOOP
    BTFSC PIR1,TMR2IF ;???tmr2????? ???0
    GOTO TMR2LOOP    ;&&&&t++?????timer2??????
    BCF PIR1,TMR2IF
    INCF t?1 ;t++
    RETURN
    
JUDGE1
    CALL TMR2LOOP ;??tmr2loop ????
    CLRF WREG
    ADDWF T?0	;??t????T
    BSF STATUS,C
    SUBWFB t,0 ;t-w
    BTFSS status,C;t<T?
    BSF STS,3 ;???????????1 ??????t>T
    BANKSEL PORTC
    CLRF WREG
    ADDWF PORTC,0
    ANDWF PORTNUM,0
    INCF WREG
    DECFSZ WREG,0
    GOTO JUDGE2;?????,??????????
    GOTO JUDGE1
    
    
JUDGE2
    CLRF WREG
    ADDWF T,0
    MOVWF t; t???T
    CLRF IOCCF  ;??ioccf????             &&&&&&&?????
    
    loop
    CALL TMR2LOOP ;t++ 
    CLRF WREG
    ADDWF IOCCF,0
    ANDWF PORTNUM,0
    INCF WREG
    DECFSZ WREG,0                   
    BSF STS,2	    ;?dt????????
    SUBWFB t,0  ;t-T ??W
    BCF STATUS,C ;??C
    SUBWFB dt,0 ;dt -w 
    BTFSS STATUS,C  ;?????0???dt<w ???
    GOTO  loop
    BSF STS,1	;?????