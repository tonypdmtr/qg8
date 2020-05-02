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

numero              rmb       1

;*******************************************************************************
                    #ROM
;*******************************************************************************

main
_Startup            proc                          ; 0->in 1->out
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs
                    lda       #$52
                    sta       SOPT1
                    clra
                    sta       PTADD
                    coma
                    sta       PTAPE
                    lda       #%11110000
                    sta       PTBPE
                    lda       #%00001111
                              ; ||||||||_fila 1
                              ; |||||||__fila 2
                              ; ||||||___fila 3
                              ; |||||____fila 4
                              ; ||||_____columna1
                              ; |||______columna2
                              ; ||_______columna3
                              ; |________columna4 sin usar
                    sta       PTBDD
                    lda       #%11110000
                    sta       PTBPE
                    lda       #10
                    sta       numero
                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    ...       Insert your code here
                    nop
                    lda       #%00000001          ; row 1 = 1
                    sta       PTBD
                    brset     0,PTAD,num1         ; col 1 = 1
                    brset     1,PTAD,num2         ; col 2 = 1
                    brset     2,PTAD,num3         ; col 3 = 1

                    nop
                    lda       #%00000010          ; row 2 = 1
                    sta       PTBD
                    brset     0,PTAD,num4         ; col 1 = 1
                    brset     1,PTAD,num5         ; col 2 = 1
                    brset     2,PTAD,num6         ; col 3 = 1

                    nop
                    lda       #%00000100          ; row 3 = 1
                    sta       PTBD
                    brset     0,PTAD,num7         ; col 1 = 1
                    brset     1,PTAD,num8         ; col 2 = 1
                    brset     2,PTAD,num9         ; col 3 = 1

                    nop
                    lda       #%00001000          ; row 4 = 1
                    sta       PTBD
                    brset     0,PTAD,num0         ; col 1 = 1
                    bra       MainLoop

num1                lda       #1
                    sta       numero
                    bra       MainLoop

num2                lda       #2
                    sta       numero
                    bra       MainLoop

num3                lda       #3
                    sta       numero
                    bra       MainLoop

num4                lda       #4
                    sta       numero
                    bra       MainLoop

num5                lda       #5
                    sta       numero
                    bra       MainLoop

num6                lda       #6
                    sta       numero
                    bra       MainLoop

num7                lda       #7
                    sta       numero
                    bra       MainLoop

num8                lda       #8
                    sta       numero
                    bra       MainLoop

num9                lda       #9
                    sta       numero
                    bra       MainLoop

num0                clra
                    sta       numero
                    bra       MainLoop
