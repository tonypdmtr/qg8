;*******************************************************************
;* Universidad Nacional de Colombia                                *
;* Facultad de ingeniería mecánica y mecatrónica                   *
;* Microcontroladores 2018-I                                       *
;* Programador:                                                    *
;* -Javier Mauricio Pinilla Garcia  25481244                       *
;* -Sebastian Cepeda Espinosa	    25481375                       *
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
;23456789012345678901234567890123456789012345
mainLoop:   lda   #$52
            sta   SOPT1		  ;Desactiva el Waatchdog, y el modo STOP, activa el pin BKGD
            mov   #00111100,PTADD ;Define los pines PTA 2,3,4 y 5 como salidas, el resto son entradas, a excepción de los pines 6 y 7 que son restringidos
            mov   #00000011,PTASE ;Slew Rate Enable para los pines PTA 0 y 1
            mov   #11110001,PTBDD ;Define los pines PTB 0,4,5,6 y 7 como salidas, y los pines PTB 1,2,3
	    	mov	  #00001110,PTBSE ;Slew Rate Enable para los pines PTB 
							  ;pone el estado inicial de los pines ## para iniciar la comunicación con la ROM		
	    	bclr    0,PTBD	  ;Escribe 0b0 en el pin PTB0, pin CE de la ROM 
	   		bset    3,PTAD	  ;Escribe 0b1 en el pin PTA3, pin OE de la ROM
  							  ;verifica si el usuario desea leer o escribir 
  			lda 	#00001000 ;carga en el acomuador la mácara para el bit 4
  	    	and 	PTBD	  ;enmascara el bit 4 del registro PTBD con el fin de leer su estado
  		    cmp     #00001000 ;Compara el registro con el valor del acomulador
  		    beq     read	  
  		    bne     write
  		    
read:		bset	3,PTAD	  ;escribe 0b1 en el pin PTA3 
			bra     r1		  ;volver a la línea 53
  		    
r1:			lda		#00000100 ;enmascarar el bit PTBD_PTBD2
			and		PTBD	  ;Si ptb2 esta en 0 (modo data seleccionado, para este caso se desea modo address) se repite el ciclo hasta que este en 1
			jsr		retardo	  ;llama la subrutina retardo   
			cmp 	#0		  	
			beq		r1
			bne		r2
			
r2:			lda		#00000010 ;Enmascarar el bit PTBD_PTBD1
			and		PTBD	  ;Si ptb1 esta en 0 (input disable) se repite el ciclo hasta que este en 1
			jsr		retardo	  ;llama la subrutina retardo
			cmp 	#0
			beq		r2
			bne		r3
							  ;Asignar el valor de PTAD_PTAD0 à PTBD_PTBD6
r3:			lda		#10111111 ;preparar registro PTBD para escribir el bitt PTBD_PTBD6
			and		PTBD		
			sta		PTBD
			lda 	#00000001 ;Lectura del bit PTAD_PTAD0
			and		PTAD
			ora		PTBD	  ;Escritura del bit en el registro PTBD 
			sta		PTBD
							  ;Asignar el valor de PTAD_PTAD1 à PTBD_PTBD7
			lda		#01111111 ;preparar registro PTBD para escribir el bit PTBD_PTBD6
			and		PTBD		
			sta		PTBD
			lda 	#00000010 ;Lectura del bit PTAD_PTAD1
			and		PTAD
			ora		PTBD	  ;Escritura del bit en el registro PTBD 
			sta		PTBD
										
			jsr		retardo	  ;llama la subrutina retardo
  			bclr	3,PTAD	  ;Asignar 0b0 al bit PTBD_PTAD3, pin OE de la ROM
  			clrh			  ;Asignar 0x00 al registro H
  			ldx		#01		  ;Asigna 0x01 al Registro X
            sta		data_address,X ;Guarda la informacion en la parte baja de la variable
            jsr		retardo	  ;llama la subrutina retardo
  			bset	3,PTAD	  ;Asignar 0b1 al bit PTAD_PTAD3 pin OE de la ROM
  			BRA    mainLoop	
            
            

			
write:		bset	2,PTAD	  ;Asignar 0b1 al bit PTAD_PTAD2, WE de la ROM
			bclr	3,PTAD	  ;Asignar 0b0 al bit PTAD_PTAD3, OE de la ROM
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
							  ;Asignar el valor de PTAD_PTAD0 à PTBD_PTBD6
			lda		#10111111 ;preparar registro PTBD para escribir el bitt PTBD_PTBD6
			and		PTBD		
			sta		PTBD
			lda 	#00000001 ;Lectura del bit PTAD_PTAD0
			and		PTAD
			ora		PTBD	  ;Escritura del bit en el registro PTBD 
			sta		PTBD
							  ;Asignar el valor de PTAD_PTAD1 à PTBD_PTBD7
			lda		#01111111 ;preparar registro PTBD para escribir el bit PTBD_PTBD6
			and		PTBD		
			sta		PTBD
			lda 	#00000010 ;Lectura del bit PTAD_PTAD1
			and		PTAD
			ora		PTBD
		  	jsr		retardo	  ;llama la subrutina retardo
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

w6:							  ;Asignar el valor de PTAD_PTAD0 à PTBD_PTBD4
			lda		#11101111 ;preparar registro PTBD para escribir el bitt PTBD_PTBD4
			and		PTBD		
			sta		PTBD
			lda 	#00000001 ;Lectura del bit PTAD_PTAD0
			and		PTAD
			ora		PTBD	  ;Escritura del bit en el registro PTBD 
			sta		PTBD
							  ;Asignar el valor de PTAD_PTAD1 à PTBD_PTBD5
			lda		#11011111 ;preparar registro PTBD para escribir el bit PTBD_PTBD5
			and		PTBD		
			sta		PTBD
			lda 	#00000010 ;Lectura del bit PTAD_PTAD1
			and		PTAD
			ora		PTBD
  			jsr		retardo	  ;llama la subrutina retardo
  			bset	2,PTAD
  			jsr		retardo	  ;llama la subrutina retardo
  			bset	0,PTBD
  			bclr	3,PTAD
  			BRA     mainLoop	
  			
retardo:					  ;esperar 16^3 ciclos de reloj (aproximadamente)
			lda 	#$0F	
rt1:		psha
			lda		#$FF
rt2:		dbnza	rt2
			pula
			dbnza	rt1
			rts

