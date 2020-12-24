                    #ListOff
                    #Uses     qg8.inc
                    #ListOn
;*******************************************************************************
; Configuracion del modulo Real-Time Counter

configRTC           proc
;                   bclr      5,SRTISC            ; Habilita el reloj de referencia interno RTICLKS (32.768 kHz por defecto - revisar hoja de datos del uC seleccionado)
                    lda       #%01010111
                              ; ||  |
                              ; ||  +----------------- interrupcion cada segundo
                              ; |+-------------------- Interrupcion temporizada cada 1 segundo habilitada
                              ; |+-------------------- IRCLK seleccionado como fuente de reloj del modulo RTC
                    sta       SRTISC
                    rts

;*******************************************************************************
; Rutina de interrupcion temporizada

rutinaRTC           proc
                    lda       SRTISC
                    ora       #%01000000
                    sta       SRTISC              ; Borra la bandera de interrupcion
                    rti
