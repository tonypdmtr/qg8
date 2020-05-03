;*******************************************************************************
; Universidad Nacional de Colombia
; Facultad de ingeniería mecánica y mecatrónica
; Microcontroladores 2018-I
; Programador:
; -Javier Mauricio Pinilla Garcia  25481244
; Version: 1.0
; Microcontrolador: MC9S08QG8CPBE
; Codigo para encender un LED a traves del pin de BKGD/PTA5
;*******************************************************************************

                    #Uses     mc9s08qg8.inc

                    xref      __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack

;*******************************************************************************

Start               proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs
                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    lda       #%01010000
                    sta       SOPT1
                    lda       #%11111111
                    sta       PTADD
Loop@@              lda       #%00000000
                    sta       PTAD
                    bsr       Delay
                    lda       #%11111111
                    sta       PTAD
                    bsr       Delay
                    bra       Loop@@

;*******************************************************************************

Delay               proc
                    psha
                    lda       #1
Loop@@              psha
                    lda       #$ff
                    dbnza     *
                    pula
                    dbnza     Loop@@
                    pula
                    rts
