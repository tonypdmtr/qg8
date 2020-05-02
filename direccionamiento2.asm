;*******************************************************************************
; Universidad Nacional de Colombia
; Facultad de ingeniería mecánica y mecatrónica
; Microcontroladores 2018-I
; Programador:
; -Javier Mauricio Pinilla Garcia  25481244
; Version: 1.0
; Microcontrolador: MC9S08QG8CPBE
; Codigo creado para la practica No 3 donde se muestran los
; diferentes modos de direccionamiento
;*******************************************************************************

                    #Uses     mc9s08qg8.inc

                    xref      __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack

;*******************************************************************************
                    #RAM                          ; variable/data section
;*******************************************************************************

var_sb              rmb       1
var_b               rmb       1

;*******************************************************************************
                    #ROM
;*******************************************************************************

main
_Startup            proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs
                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    ...       Insert your code here
                    lda       #2                  ; IMM
                    sta       var_sb              ; DIR
                    sta       var_b               ; EXT
                    sec                           ; INH
                    clrh
                    ldx       #104
                    txs
                    sta       ,x                  ; IX
                    sta       var_sb,x            ; IX1
                    sta       var_b,x             ; IX2
                    sta       var_sb,sp           ; SP1
                    sta       var_b,sp            ; SP2
                    mov       x+,var_sb           ; IX+
                    clrx
                    cbeq      var_sb,x+,Finish    ; IX1+
Finish              feed_watchdog
                    bra       MainLoop
