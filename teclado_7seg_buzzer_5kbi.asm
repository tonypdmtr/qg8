;*******************************************************************************
; Universidad Nacional de Colombia                                *
; Facultad de ingeniería mecánica y mecatrónica                   *
; Microcontroladores 2018-I                                       *
; Programador:                                                    *
; -Sebastian Cepeda Espinosa                                      *
; -Javier Mauricio Pinilla Garcia                                 *
; Version: 1.0                                                    *
; Microcontrolador: MC9S08QG8CPBE                                 *
; Codigo para usar 4 display 7 segmento con el fin de implementar *
; un reloj y un calendario cuyo cambio esta dado por IRQ          *
;*******************************************************************

                    #Uses     mc9s08qg8.inc

                    xref      __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack

; variable/data section
MY_ZEROPAGE         section   SHORT               ; Insert here your data definition

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

;*******************************************************************************
; RUtina  de Interrupcion por IRQ

intirq              proc
                    pshh
                    bset      IRQSC_IRQACK,IRQSC  ; Reconocimiento de int y forza la bandera a 0.
                    bclr      IRQSC_IRQIE,IRQSC
                    lda       #1
                    jsr:4     retardo
                    brclr     5,PTAD,*
                    lda       #1
                    cmpa      estado
                    bne       st2
                    clra
                    sta       estado
                    bra       Done@@
st2                 lda       #1
                    sta       estado
                    bra       Done@@
Done@@              bset      IRQSC_IRQIE,IRQSC
                    pulh
                    rti

;*******************************************************************************
; Rutina KBI

kbirutina           proc
                    pshh
                    bset      KBISC_KBACK,KBISC   ; Reconocimiento de int y forza la bandera a 0.
                    bclr      KBISC_KBIE,KBISC
                    lda       #1
                    jsr:4     retardo
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
                    bra       Done@@

Done@@              bset      KBISC_KBIE,KBISC
                    pulh
                    rti

;*******************************************************************************
; Rutina RTC

rutinaRTC           proc
                    pshh
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

                    pulh
                    rti

;*******************************************************************************

main
_Startup            proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs
; ========= Rutina configuracion de IRQ
                    jsr       conf_IRQ
                    jsr       configRTC
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
                    jsr       kbi_conf
                    cli                           ; enable interrup

MainLoop            jsr       escritura
                    lda       #1
                    cmp       fkbi
                    beq       ver0

                    lda       estado
                    cmp       #1
                    bne       rows
                    jmp       MainLoop

rows                nop
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
                    bra       MainLoop

ver0                lda       #1
                    cmp       row
                    bne       ver1
                    brset     0,col,num1          ; col 1 = 1
                    brset     1,col,num2          ; col 2 = 1
                    brset     2,col,num3          ; col 3 = 1
                    bra       clrfkbi

ver1                nop
                    lda       #2
                    cmp       row
                    bne       ver2
                    brset     0,col,num4          ; col 1 = 1
                    brset     1,col,num5          ; col 2 = 1
                    brset     2,col,num6          ; col 3 = 1
                    bra       clrfkbi

ver2                lda       #3
                    cmp       row
                    bne       ver3
                    brset     0,col,num7          ; col 1 = 1
                    brset     1,col,num8          ; col 2 = 1
                    brset     2,col,num9          ; col 3 = 1
                    bra       clrfkbi

ver3                brset     1,col,num0          ; col 1 = 1
                    bra       clrfkbi

num1                lda       #1
                    sta       numero
                    bra       clrfkbi

num2                lda       #2
                    sta       numero
                    bra       clrfkbi

num3                lda       #3
                    sta       numero
                    jmp       clrfkbi

num4                lda       #4
                    sta       numero
                    jmp       clrfkbi

num5                lda       #5
                    sta       numero
                    jmp       clrfkbi

num6                lda       #6
                    sta       numero
                    jmp       clrfkbi

num7                lda       #7
                    sta       numero
                    jmp       clrfkbi

num8                lda       #8
                    sta       numero
                    jmp       clrfkbi

num9                lda       #9
                    sta       numero
                    jmp       clrfkbi

num0                clra
                    sta       numero
                    jmp       clrfkbi

clrfkbi             lda       numd
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

                    jsr       sonar
                    jmp       MainLoop

;*******************************************************************************
; 23456789012345678901234567890123456789012345

sonar               proc
                    lda       numero
                    cbeqa     #0,s0
                    cbeqa     #1,s1
                    cbeqa     #2,s2
                    cbeqa     #3,s3
                    cbeqa     #4,s4
                    cbeqa     #5,s5
                    cbeqa     #6,s6
                    cbeqa     #7,s7
                    cbeqa     #8,s8
                    cbeqa     #9,s9
fsonar
                    lda       #$ff
                    sub       numero
t1                  psha
                    lda       tono
                    jsr       retardo
                    bset      3,PTAD
                    lda       tono
                    jsr       retardo
                    bclr      3,PTAD
                    pula
                    dbnza     t1
                    rts

s0                  lda       #$0A
                    sta       tono
                    jmp       fsonar

s1                  lda       #$01
                    sta       tono
                    jmp       fsonar

s2                  lda       #$02
                    sta       tono
                    jmp       fsonar

s3                  lda       #$03
                    sta       tono
                    jmp       fsonar

s4                  lda       #$04
                    sta       tono
                    jmp       fsonar

s5                  lda       #$05
                    sta       tono
                    jmp       fsonar

s6                  lda       #$06
                    sta       tono
                    jmp       fsonar

s7                  lda       #$07
                    sta       tono
                    jmp       fsonar

s8                  lda       #$08
                    sta       tono
                    jmp       fsonar

s9                  lda       #$09
                    sta       tono
                    jmp       fsonar

;*******************************************************************************

escritura           proc
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000000
                    sta       PTBD
                    lda       numd
                    sta       escrito
                    jsr       escnum
                    nop
                    lda       #$0f
                    jsr       retardo
                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000001
                    sta       PTBD
                    lda       numc
                    sta       escrito
                    jsr       escnum
                    nop
                    lda       #$0f
                    jsr       retardo
                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000010
                    sta       PTBD
                    lda       numb
                    sta       escrito
                    jsr       escnum
                    nop
                    lda       #$0f
                    jsr       retardo
                    nop
                    lda       PTBD
                    and       #%11110000
                    ora       #%00000011
                    sta       PTBD
                    lda       numa
                    sta       escrito
                    jsr       escnum
                    nop
                    lda       #$0f
                    jsr       retardo
                    nop
                    rts

escnum              cbeqa     #0,esc0
n1                  cbeqa     #1,esc1
n2                  cbeqa     #2,esc2
n3                  cbeqa     #3,esc3
n4                  cbeqa     #4,esc4
n5                  cbeqa     #5,esc5
n6                  cbeqa     #6,esc6
n7                  cbeqa     #7,esc7
n8                  cbeqa     #8,esc8
n9                  cbeqa     #9,esc9
                    rts

;*******************************************************************************
; 23456789012345678901234567890123456789012345

esc0                lda       PTBD                ; Escribir 8b0000xxxx
                    and       #%00001111
                    sta       PTBD
                    lda       escrito
                    jmp       n1

esc1                lda       PTBD                ; Escribir 8b0001xxxx
                    and       #%00001111
                    ora       #%00010000
                    sta       PTBD
                    lda       escrito
                    jmp       n2

esc2                lda       PTBD                ; Escribir 8b0010xxxx
                    and       #%00001111
                    ora       #%00100000
                    sta       PTBD
                    lda       escrito
                    jmp       n3

esc3                lda       PTBD                ; Escribir 8b0011xxxx
                    and       #%00001111
                    ora       #%00110000
                    sta       PTBD
                    lda       escrito
                    jmp       n4

esc4                lda       PTBD                ; Escribir 8b0100xxxx
                    and       #%00001111
                    ora       #%01000000
                    sta       PTBD
                    lda       escrito
                    jmp       n5

esc5                lda       PTBD                ; Escribir 8b0101xxxx
                    and       #%00001111
                    ora       #%01010000
                    sta       PTBD
                    lda       escrito
                    jmp       n6

esc6                lda       PTBD                ; Escribir 8b0110xxxx
                    and       #%00001111
                    ora       #%01100000
                    sta       PTBD
                    lda       escrito
                    jmp       n7

esc7                lda       PTBD                ; Escribir 8b0111xxxx
                    and       #%00001111
                    ora       #%01110000
                    sta       PTBD
                    lda       escrito
                    jmp       n8

esc8                lda       PTBD                ; Escribir 8b1000xxxx
                    and       #%00001111
                    ora       #%10000000
                    sta       PTBD
                    lda       escrito
                    jmp       n9

esc9                lda       PTBD                ; Escribir 8b1000xxxx
                    and       #%00001111
                    ora       #%10010000
                    sta       PTBD
                    lda       escrito
                    rts

;*******************************************************************************
; Subrutina de configuración de interupción por tiempo

configRTC           proc
;                   bclr      5, SRTISC           ; Habilita el reloj de referencia interno RTICLKS (32.768 kHz por defecto - revisar hoja de datos del uC seleccionado)
                    lda       #%01010111
                              ; ||  |
                              ; ||  +----------------- interrupcion cada segundo
                              ; |+-------------------- Interrupcion temporizada cada 1 segundo habilitada
                              ; |+-------------------- IRCLK seleccionado como fuente de reloj del modulo RTC
                    sta       SRTISC
                    rts

;*******************************************************************************
; Subrutina de configuraciÛn del Modulo IRQ

conf_IRQ            proc                          ; Label de la Interrupción
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
;
; KBISC_MOD= 1b1 --> detecta flanco y nivel
;
; PTAPE = #%00000111 --> activa dispositivo de pull up en pines KBI a usar
;
; KBIES = FF --> selecciona resistencia de pull down, la interrupcion
; se activa con un 1 en el pin
;*******************************************************************************

kbi_conf            proc
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

retardo             proc
                    psha
Loop@@              psha
                    lda       #$ff
                    dbnza     *
                    pula
                    dbnza     Loop@@
                    pula
                    rts
