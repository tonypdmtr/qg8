;*******************************************************************************
; This stationery serves as the framework for a user application.
; For a more comprehensive program that demonstrates the more
; advanced functionality of this processor, please see the
; demonstration applications, located in the examples
; subdirectory of the "Freescale CodeWarrior for HC08" program
; directory.
;*******************************************************************************

                    #Uses     mc9s08qg8.inc

                    xref      __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack

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
                    bset      KBISC_KBACK,KBISC   ; Reconocimiento de int y forza la bandera a 0.
                    bclr      KBISC_KBIE,KBISC
                    jsr:4     delay
                    brclr     3,PTBD,*

                    lda       #1
                    cmpa      estado
                    bne       _1@@
                    clra
                    sta       estado
                    bra       Done@@

_1@@                lda       #1
                    sta       estado
                    bra       Done@@

Done@@              bset      KBISC_KBIE,KBISC
                    pulh
                    rti

;*******************************************************************************

main
_Startup            proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
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
                    jsr       conf_IRQ
                    cli
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    lda       #1
                    cmp       estado
                    beq       _1@@
                    bsr:4     delay
                    lda       #1
                    sta       PTAD
                    bsr:4     delay
                    clra
                    sta       PTAD
                    bra       MainLoop
_1@@                lda       #1
                    sta       PTAD
                    bra       MainLoop

;*******************************************************************************

delay               proc
                    psha
                    lda       #$ff
Loop@@              psha
                    lda       #$ff
                    dbnza     *
                    pula
                    dbnza     Loop@@
                    pula
                    rts
