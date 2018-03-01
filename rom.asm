;*******************************************************************
;* Universidad Nacional de Colombia                                *
;* Facultad de ingeniería mecánica y mecatrónica                   *
;* Microcontroladores 2018-I                                       *
;* Programador:                                                    *
;* -Javier Mauricio Pinilla Garcia  25481244                       *
;* Version: 1.0                                                    *
;* Microcontrolador: MC9S08QG8CPBE                                 *
;* Lectura y escritura en EEPROM at28c64b, laboratorio No 3        *
;*                                                                 *
;*******************************************************************


; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            

; export symbols
            XDEF _Startup, main
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            
            
            
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


; variable/data section
MY_ZEROPAGE: SECTION  SHORT			; Se reserva 1 byte en la Z-RAM para cte1
data_address:       ds.b   1
; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
			CLI			; enable interrupts
;23456789012345678901234567890123456789
mainLoop:   lda     #$52
            sta     SOPT1
            mov     #00111100,PTADD
            mov     #00000011,PTASE
            mov     #11110001,PTBDD
			mov     #00001110,PTBSE
			
			bset    0,PTBD
			bset    3,PTAD
  			
  			lda 	#00001000  ;enmascarar ptb3
  			and 	PTBD
  		    cmp     #00001000
  		    beq     read ;
  		    bne     write ;
  		    
read:		bset	0,PTBD
			bset	3,PTAD
			bra     r1
  		    
r1:			lda		#00000100   ;enmascarar ptb2
			and		PTBD	    ;Si ptb2 esta en 0 (modo data seleccionado, para este caso se desea modo address) se repite el ciclo hasta que este en 1
			cmp 	#0
			beq		r1
			bne		r2
			
r2:			lda		#00000010	;enmascarar ptb1
			and		PTBD	    ;Si ptb1 esta en 0 (input disable) se repite el ciclo hasta que este en 1
			cmp 	#0
			beq		r2
			bne		r3
			
r3:			;PTBD_PTBD6=PTAD_PTAD0;		/*escribe en a0*/
  			;PTBD_PTBD7=PTAD_PTAD1;
  			bclr	0,PTBD
  			bclr	3,PTAD
  			clrh
  			ldx		#01
            sta		data_address,X ;se guarda la informacion en la parte baja de la variable
            ;retardo
            bset	0,PTBD
  			bset	3,PTAD
  			BRA    mainLoop	
            
            

			
write:		bset	0,PTBD
			bset	2,PTAD
			bclr	3,PTAD
			BRA		w1
			
w1:			lda		#00000100	;enmascarar ptb2
			and		PTBD	    ;Si ptb2 esta en 0 (seleccion modo address) se repite el ciclo hasta que este en 1, analogo a r1
			cmp 	#0
			beq		w1
			bne		w2
			
w2:			lda		#00000010	;enmascarar ptb1
			and		PTBD	    ;Si ptb1 esta en 0 (input disable) se repite el ciclo hasta que este en 1
			cmp 	#0
			beq		w2
			bne		w3
			
w3:			bset	3,PTAD
			bclr	0,PTBD			
		  	;PTBD_PTBD6=PTAD_PTAD0;		/*escribe en a0*/
		  	;PTBD_PTBD7=PTAD_PTAD1;		/*escribe en a1*/
		  	;retardo(0xFF);
		  	bra		w4

w4:			lda		#00000100	;enmascarar ptb2			
			and		PTBD		;si esta en 1 vuelve a w4
			cmp		#00000100	;si esta en 0 es modo D
			beq		w4
			bne		w5

w5:			lda		#00000010	;enmascarar ptb2			
			and		PTBD		;si esta en 0 vuelve a w4
			cmp		#0	        ;si esta en 1, input enable
			beq		w5
			bne		w6	

w6:			;PTBD_PTBD4=PTAD_PTAD0;			/*escribe en I/O0*/
  			;PTBD_PTBD5=PTAD_PTAD1;			/*escribe en I/O1*/
  			;retardo(0xFF);
  			bset	2,PTAD
  			;retardo(0xFF);
  			bset	0,PTBD
  			bclr	3,PTAD
  			BRA    mainLoop		



