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

var1                rmb       1
var11               rmb       2
var2                rmb       1
var3                rmb       4

;*******************************************************************************
                    #ROM
;*******************************************************************************

Start               proc
                    @rsp                          ; initialize the stack pointer
                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
Loop@@              !...      Insert your code here
                    lda       #2
                    sta       var1
                    sta       var2
                    sta       var3

                    ldhx      #104
                    sta       ,x                  ; INDEXADO

                    ldhx      #var1               ; tomando var1 como un numero, no como direccion
                    sta       ,x                  ; INDEXADO

                    sta       var1,x              ; va a guardar lo que este en el acumulador en la posicion #var1=60 + lo que sea X

                    ldhx      #2
                    sta       var1,x

                    ldx       #1
                    sta       var11,x             ; escribe en la parte baja de la variable
                    clrx
                    sta       var11               ; escribe en la parte alta de la variable

                    @cop
                    bra       Loop@@
