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

numero              rmb       1

;*******************************************************************************
                    #ROM
;*******************************************************************************

Start               proc                          ; 0->in 1->out
                    @rsp                          ; initialize the stack pointer
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
                    mov       #10,numero
                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
Loop@@              !...      Insert your code here
                    nop
                    mov       #%00000001,PTBD     ; row 1 = 1
                    brset     0,PTAD,_1@@         ; col 1 = 1
                    brset     1,PTAD,_2@@         ; col 2 = 1
                    brset     2,PTAD,_3@@         ; col 3 = 1

                    nop
                    mov       #%00000010,PTBD     ; row 2 = 1
                    brset     0,PTAD,_4@@         ; col 1 = 1
                    brset     1,PTAD,_5@@         ; col 2 = 1
                    brset     2,PTAD,_6@@         ; col 3 = 1

                    nop
                    mov       #%00000100,PTBD     ; row 3 = 1
                    brset     0,PTAD,_7@@         ; col 1 = 1
                    brset     1,PTAD,_8@@         ; col 2 = 1
                    brset     2,PTAD,_9@@         ; col 3 = 1

                    nop
                    mov       #%00001000,PTBD     ; row 4 = 1
                    brset     0,PTAD,_0@@         ; col 1 = 1
                    bra       Loop@@

_1@@                lda       #1
                    bra       Cont@@

_2@@                lda       #2
                    bra       Cont@@

_3@@                lda       #3
                    bra       Cont@@

_4@@                lda       #4
                    bra       Cont@@

_5@@                lda       #5
                    bra       Cont@@

_6@@                lda       #6
                    bra       Cont@@

_7@@                lda       #7
                    bra       Cont@@

_8@@                lda       #8
                    bra       Cont@@

_9@@                lda       #9
                    bra       Cont@@

_0@@                clra
Cont@@              sta       numero
                    bra       Loop@@
