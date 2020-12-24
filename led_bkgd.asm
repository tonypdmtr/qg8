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
                    #ListOff
                    #Uses     qg8.inc
                    #ListOn
;*******************************************************************************

Start               proc
                    ldhx      #STACKTOP           ; initialize the stack pointer
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
                    bsr       Delay1ms
                    lda       #%11111111
                    sta       PTAD
                    bsr       Delay1ms
                    bra       Loop@@

;*******************************************************************************
                              #Cycles
Delay1ms            proc                          ; esperar 16^3 ciclos de reloj (aproximadamente)
                    pshhx
                    ldhx      #DELAY@@
                              #Cycles
Loop@@              aix       #-1
                    cphx      #0
                    bne       Loop@@
                              #temp :cycles
                    pulhx
                    rts

DELAY@@             equ       BUS_KHZ-:cycles-:ocycles/:temp
