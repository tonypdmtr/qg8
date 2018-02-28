;*******************************************************************
;* Universidad Nacional de Colombia                                *
;* Facultad de ingeniería mecánica y mecatrónica                   *
;* Microcontroladores 2018-I                                       *
;* Programador:                                                    *
;* -Javier Mauricio Pinilla Garcia  25481244                       *
;* Version: 1.0                                                    *
;* Microcontrolador: MC9S08QG8CPBE                                 *
;* Codigo creado para la practica No 3 donde se muestran los       *
;* diferentes modos de direccionamiento                            *
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

; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
			CLI			; enable interrupts

mainLoop:   lda     #$52
            sta     SOPT1
            mov     #00111100,PTADD
            mov     #00000011,PTASE
            mov     #11110001,PTBDD
			mov     #00001110,PTBSE
			
			bset    0,PTBD
			bset    3,PTAD
  			
  			lda 	#00001000	;enmascarar ptb3
  			and 	PTBD
  		    cmp     #00001000
  		    beq     if1 ;if1
  		    bne     else1 ;else1
r1:			


if1:		bset	0,PTBD
			bset	3,PTAD
			bra     r1
			
else1:		bset	0,PTBD
			bset	3,PTAD
			bra		r1




