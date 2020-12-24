;*******************************************************************************
; Universidad Nacional de Colombia
; Facultad de ingeniería mecánica y mecatrónica
; Microcontroladores 2018-I
; Programador:
; -Sebastian Cepeda Espinosa
; -Javier Mauricio Pinilla Garcia
; Version: 1.0
; Microcontrolador: MC9S08QG8CPBE
; Codigo para usar 4 display 7 segmento con el fin de implementar
; un reloj y un calendario cuyo cambio esta dado por IRQ
;*******************************************************************************
                    #ListOff
                    #Uses     qg8.inc
                    #ListOn
;*******************************************************************************
                    #RAM
;*******************************************************************************

estado              rmb       1
numero              rmb       1                   ; numero pulsado
fkbi                rmb       1                   ; flag kbi
rowa                rmb       1                   ; row actual
row                 rmb       1                   ; row activada cuando se dio la interrupcion
col                 rmb       1                   ; col activada cuando se dio la interrupcion
numa                rmb       1
numb                rmb       1
numc                rmb       1
numd                rmb       1
nume                rmb       1
aux                 rmb       1
escrito             rmb       1
tono                rmb       1

;*******************************************************************************
                    #ROM                          ;Retraso             section
;*******************************************************************************

IRQ_Handler         proc
                    bset      IRQACK.,IRQSC       ; Reconocimiento de int y forza la bandera a 0.
                    bclr      IRQIE.,IRQSC
                    lda       #1
                    jsr:4     Delay1ms
                    brclr     5,PTAD,*
                    lda       #1
                    cmpa      estado
                    bne       _1@@
                    clra
                    sta       estado
                    bra       Done@@
_1@@                lda       #1
                    sta       estado
Done@@              bset      IRQIE.,IRQSC
                    rti

;*******************************************************************************

KBI_Handler         proc
                    bset      KBACK.,KBISC        ; Reconocimiento de int y forza la bandera a 0.
                    bclr      KBIE.,KBISC
                    lda       #1
                    jsr:4     Delay1ms
                    lda       PTAD
                    sta       col

Loop@@              brset     0,PTAD,*
                    brset     1,PTAD,Loop@@
                    brset     2,PTAD,Loop@@

                    lda       rowa
                    sta       row
                    lda       #1
                    cmpa      fkbi
                    bne       _1@@

                    clra
                    sta       fkbi
                    bra       Done@@

_1@@                lda       #1
                    sta       fkbi

Done@@              bset      KBIE.,KBISC
                    rti

;*******************************************************************************

RTC_Handler         proc
                    lda       SRTISC
                    ora       #%01000000
                    sta       SRTISC              ; Borra la bandera de interrupcion
                    lda       nume
                    sta       aux
                    lda       numd
                    sta       nume
                    lda       numc
                    sta       numd
                    lda       numb
                    sta       numc
                    lda       numa
                    sta       numb
                    lda       aux
                    sta       numa
                    rti

;*******************************************************************************

Start               proc
                    ldhx      #STACKTOP           ; initialize the stack pointer
                    txs
                    jsr       ConfigIRQ
                    jsr       ConfigRTC
                    lda       #$52
                    sta       SOPT1               ; Desactivar watchdog
                    clra
                    sta       fkbi
                    sta       row
                    sta       rowa
                    lda       #10
                    sta       numero
                    lda       #1
                    sta       estado
                    clra
                    sta       numa
                    sta       numb
                    sta       numc
                    sta       numd
                    sta       nume
                    sta       tono

                    lda       #%11111000          ; Puertos de lectura, columnas
                              ; ||||||||_col 1
                              ; |||||||__col 2
                              ; ||||||___col 3
                    sta       PTADD
                    lda       #%00000111          ; pull up puertos de lectura
                              ; ||||||||_col 1
                              ; |||||||__col 2
                              ; ||||||___col 3
;                   sta       PTAPE

                    lda       #%11111111          ; Puertos de escritura
                              ; ||||||||_row 1
                              ; |||||||__row 2
                              ; ||||||___row 3
                              ; |||||____row 4
                    sta       PTBDD
                    jsr       ConfigKBI
                    cli                           ; enable interrup
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
Loop@@              jsr       escritura
                    lda       #1
                    cmpa      fkbi
                    beq       _1@@

                    lda       estado
                    cmpa      #1
                    beq       Loop@@

                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000100          ; row 1 = 1
                    sta       PTBD
                    lda       #1
                    sta       rowa

                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000101          ; row 2 = 1
                    sta       PTBD
                    lda       #2
                    sta       rowa

                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000110          ; row 3 = 1
                    sta       PTBD
                    lda       #3
                    sta       rowa

                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000111          ; row 4 = 1
                    sta       PTBD
                    lda       #4
                    sta       rowa
                    bra       Loop@@

_1@@                lda       #1
                    cmp       row
                    bne       _2@@
                    brset     0,col,N1@@          ; col 1 = 1
                    brset     1,col,N2@@          ; col 2 = 1
                    brset     2,col,N3@@          ; col 3 = 1
                    bra       Cont@@

_2@@                nop
                    lda       #2
                    cmp       row
                    bne       _3@@
                    brset     0,col,N4@@          ; col 1 = 1
                    brset     1,col,N5@@          ; col 2 = 1
                    brset     2,col,N6@@          ; col 3 = 1
                    bra       Cont@@

_3@@                lda       #3
                    cmp       row
                    bne       _4@@
                    brset     0,col,N7@@          ; col 1 = 1
                    brset     1,col,N8@@          ; col 2 = 1
                    brset     2,col,N9@@          ; col 3 = 1
                    bra       Cont@@

_4@@                brset     1,col,N0@@          ; col 1 = 1
                    bra       Cont@@

N1@@                lda       #1
                    sta       numero
                    bra       Cont@@

N2@@                lda       #2
                    sta       numero
                    bra       Cont@@

N3@@                lda       #3
                    sta       numero
                    bra       Cont@@

N4@@                lda       #4
                    sta       numero
                    bra       Cont@@

N5@@                lda       #5
                    sta       numero
                    bra       Cont@@

N6@@                lda       #6
                    sta       numero
                    bra       Cont@@

N7@@                lda       #7
                    sta       numero
                    bra       Cont@@

N8@@                lda       #8
                    sta       numero
                    bra       Cont@@

N9@@                lda       #9
                    sta       numero
                    bra       Cont@@

N0@@                clra
                    sta       numero

Cont@@              lda       numd
                    sta       nume
                    lda       numc
                    sta       numd
                    lda       numb
                    sta       numc
                    lda       numa
                    sta       numb
                    lda       numero
                    sta       numa
                    clra
                    sta       fkbi

                    bsr       Sonar
                    jmp       Loop@@

;*******************************************************************************
; 23456789012345678901234567890123456789012345

Sonar               proc
                    lda       numero
                    cbeqa     #0,_0@@
                    cbeqa     #1,_1@@
                    cbeqa     #2,_2@@
                    cbeqa     #3,_3@@
                    cbeqa     #4,_4@@
                    cbeqa     #5,_5@@
                    cbeqa     #6,_6@@
                    cbeqa     #7,_7@@
                    cbeqa     #8,_8@@
                    cbeqa     #9,_9@@
MainLoop@@          lda       #$ff
                    sub       numero
Loop@@              psha
                    lda       tono
                    jsr       Delay1ms
                    bset      3,PTAD
                    lda       tono
                    jsr       Delay1ms
                    bclr      3,PTAD
                    pula
                    dbnza     Loop@@
                    rts

_0@@                lda       #10
                    bra       Cont@@

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
Cont@@              sta       tono
                    bra       MainLoop@@

;*******************************************************************************

escritura           proc
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000000
                    sta       PTBD
                    lda       numd
                    sta       escrito
                    bsr       escnum
                    nop
                    lda       #$0f
                    jsr       Delay1ms
                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000001
                    sta       PTBD
                    lda       numc
                    sta       escrito
                    bsr       escnum
                    nop
                    lda       #$0f
                    jsr       Delay1ms
                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000010
                    sta       PTBD
                    lda       numb
                    sta       escrito
                    bsr       escnum
                    nop
                    lda       #$0f
                    jsr       Delay1ms
                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000011
                    sta       PTBD
                    lda       numa
                    sta       escrito
                    bsr       escnum
                    nop
                    lda       #$0f
                    jsr       Delay1ms
                    nop
                    rts

;*******************************************************************************

escnum              proc
Loop@@              lda       escrito
                    cbeqa     #0,_0@@
                    cbeqa     #1,_1@@
                    cbeqa     #2,_2@@
                    cbeqa     #3,_3@@
                    cbeqa     #4,_4@@
                    cbeqa     #5,_5@@
                    cbeqa     #6,_6@@
                    cbeqa     #7,_7@@
                    cbeqa     #8,_8@@
                    cbeqa     #9,_9@@
                    rts
          ;--------------------------------------
_0@@                lda       PTBD                ; Escribir 8b0000xxxx
                    bra       Cont@@
          ;--------------------------------------
_1@@                lda       PTBD                ; Escribir 8b0001xxxx
                    ora       #%00010000
                    bra       Cont@@
          ;--------------------------------------
_2@@                lda       PTBD                ; Escribir 8b0010xxxx
                    ora       #%00100000
                    bra       Cont@@
          ;--------------------------------------
_3@@                lda       PTBD                ; Escribir 8b0011xxxx
                    ora       #%00110000
                    bra       Cont@@
          ;--------------------------------------
_4@@                lda       PTBD                ; Escribir 8b0100xxxx
                    ora       #%01000000
                    bra       Cont@@
          ;--------------------------------------
_5@@                lda       PTBD                ; Escribir 8b0101xxxx
                    ora       #%01010000
                    bra       Cont@@
          ;--------------------------------------
_6@@                lda       PTBD                ; Escribir 8b0110xxxx
                    ora       #%01100000
                    bra       Cont@@
          ;--------------------------------------
_7@@                lda       PTBD                ; Escribir 8b0111xxxx
                    ora       #%01110000
                    bra       Cont@@
          ;--------------------------------------
_8@@                lda       PTBD                ; Escribir 8b1000xxxx
                    ora       #%10000000
                    bra       Cont@@
          ;--------------------------------------
_9@@                lda       PTBD                ; Escribir 8b1000xxxx
                    ora       #%10010000
Cont@@              and       #%00001111
                    sta       PTBD
                    bra       Loop@@

;*******************************************************************************
; Configure timer interrupts

ConfigRTC           proc
;                   bclr      5, SRTISC           ; Habilita el reloj de referencia interno RTICLKS (32.768 kHz por defecto - revisar hoja de datos del uC seleccionado)
                    lda       #%01010111
                              ; ||  |
                              ; ||  +----------------- interrupcion cada segundo
                              ; |+-------------------- Interrupcion temporizada cada 1 segundo habilitada
                              ; |+-------------------- IRCLK seleccionado como fuente de reloj del modulo RTC
                    sta       SRTISC
                    rts

;*******************************************************************************

ConfigIRQ           proc                          ; Label de la Interrupción
                                                  ; 76543210 Bits
                    lda       #%01010011
                              ; ||||||||
                              ; |||||||+--------- IRQMODE  = Flanco de Bajada
                              ; ||||||+---------- IRQIE = IRQ habilitada
                              ; |||||+----------- IRQACK = Para reconocimiento
                              ; ||||+------------ IRQF  = Solo lectura
                              ; |||+------------- IRQPE = Pin Habilitado disponible .
                              ; ||+-------------- No Disponible
                              ; |+--------------- IRQPDD =
                              ; +---------------- NO disponible
                    sta       IRQSC               ; Configura la Interrupción
                    rts                           ; Retorno de subrutina de IRQ

;*******************************************************************************
; Configuracion del KBI
; KBISC_MOD= 1b1 --> detecta flanco y nivel
; PTAPE = #%00000111 --> activa dispositivo de pull up en pines KBI a usar
; KBIES = FF --> selecciona resistencia de pull down, la interrupcion
; se activa con un 1 en el pin

ConfigKBI           proc
                    lda       #%00000001
                    sta       KBISC               ; 1 IE=0, MOD=1
                    lda       #$FF
                    sta       KBIES               ; 2 Seleccionar pull up/down 0/1 activa con 0/activa con 1
                    lda       #%00000111
                    sta       PTAPE               ; 3 Configurar pullup de los pines ausar
                    lda       #%00000111
                    sta       KBIPE               ; 4 PTB3 como KBI, configurar pin KBI a usar
                    lda       KBISC
                    ora       #%00000100
                    sta       KBISC               ; 5 ACK=1
                    lda       KBISC
                    ora       #%00000011
                    sta       KBISC               ; 6 IE=1, MOD=1
                    rts

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
