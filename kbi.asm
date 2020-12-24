;*******************************************************************************
; This stationery serves as the framework for a user application.
; For a more comprehensive program that demonstrates the more
; advanced functionality of this processor, please see the
; demonstration applications, located in the examples
; subdirectory of the "Freescale CodeWarrior for HC08" program
; directory.
;*******************************************************************************
                    #ListOff
                    #Uses     qg8.inc
                    #ListOn
;*******************************************************************************
                    #RAM                          ; variable/data section
;*******************************************************************************

estado              rmb       1

;*******************************************************************************
                    #ROM                          ;Javier              section
;*******************************************************************************

;*******************************************************************************
; Rutina  de Interrupcion por KBI

kbirutina           proc
                    pshh
                    bset      KBACK.,KBISC        ; Reconocimiento de int y forza la bandera a 0.
                    bclr      KBIE.,KBISC
                    bsr:4     Delay1ms
                    brclr     3,PTBD,*

                    lda       #1
                    cmpa      estado
                    bne       _1@@
                    clra
                    sta       estado
                    bra       Done@@

_1@@                lda       #1
                    sta       estado

Done@@              bset      KBIE.,KBISC
                    pulh
                    rti

;*******************************************************************************

main
_Startup            proc
                    ldhx      #STACKTOP           ; initialize the stack pointer
                    txs

                    lda       #$52
                    sta       SOPT1               ; Desactivar watchdog y BKGD como PTA4
                    lda       #%00000011
                    sta       PTADD
                    lda       #%11110000
                    sta       PTBDD
                    lda       #$FF
                    sta       PTAPE
                    lda       #%00000001
                    sta       KBISC               ; 1 IE=0
                    lda       #$00
                    sta       KBIES               ; 2
                    lda       #$FF
                    sta       PTBPE               ; 3

                    lda       #%10000000
                    sta       KBIPE               ; 4
                    lda       KBISC
                    ora       #%00000100
                    sta       KBISC               ; 5
                    lda       KBISC
                    ora       #%00000011
                    sta       KBISC               ; 6

                    clra
                    sta       estado
                    bsr       ConfigIRQ
                    cli
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    lda       #1
                    cmp       estado
                    beq       _1@@
                    bsr:4     Delay1ms
                    lda       #1
                    sta       PTAD
                    bsr:4     Delay1ms
                    clra
                    sta       PTAD
                    bra       MainLoop
_1@@                lda       #1
                    sta       PTAD
                    bra       MainLoop

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

;*******************************************************************************
ConfigIRQ           def       :AnRTS
;*******************************************************************************
