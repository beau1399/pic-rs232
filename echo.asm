#include <p16F690.inc>
 __config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)
 org 0
prog:
 banksel OSCCON 
 movlw   B'01110000'   ; full 8mhz internal osc 
 iorwf   OSCCON,f 

 banksel SPBRG 
 movlw   .34     ;34 -> ~57.6kbps@8mhz (207 for 9600bps )
 movwf	 SPBRG		 
 banksel SPBRGH 
 movlw   .0 
 movwf	 SPBRGH	
 banksel TXSTA 
 bcf	 TXSTA,SYNC		;async, i.e. timed by bits in the xmit stream 
 banksel RCSTA 
 bcf RCSTA,CREN			;serial recv
 bsf RCSTA,CREN

 bsf	 RCSTA,SPEN  
 banksel TXSTA 
 bsf	 TXSTA,TXEN		;enable TX  
 bcf	 TXSTA,TX9		;we want 8 bit 
 bsf	 TXSTA,BRGH		;enable *64 baud generator w/o using SPBRGH 
 banksel BAUDCTL 
 bsf	 BAUDCTL, BRG16 
 bsf	 BAUDCTL, SCKP	;reverse polarity 
 
 banksel ANSELH	 
 bcf ANSELH,ANS11 			;Not using AN11- it is one of the serial pins

 banksel PIE1 				
 bsf PIE1,RCIE 				;Receive interrupt on
 bsf PIE1,TXIE 				;Xmit interrupt on
 
 banksel INTCON 			;General and peripheral interrupt enable
 bsf INTCON,PEIE	 
 bcf INTCON,GIE 
 
userprog:

 call getch
 call printch
 goto userprog


printch:

 banksel   TXREG
 movwf   TXREG
 nop
 btfss   PIR1,TXIF
 goto    $-1 
 return		


getch:
 banksel PIR1
 btfss PIR1,RCIF
 goto getch
 movf RCREG,w
 return


 end
