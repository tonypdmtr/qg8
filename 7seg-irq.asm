;*******************************************************************************
; Universidad Nacional de Colombia
; Facultad de ingeniería mecánica y mecatrónica
; Microcontroladores 2018-I
; Programador:
; -Javier Mauricio Pinilla Garcia  25481244
; -Sebastian Cepeda Espinosa
; Version: 1.0
; Microcontrolador: MC9S08QG8CPBE
; Codigo para usar 4 display 7 segmento con el fin de implementar
; un reloj y un calendario cuyo cambio esta dado por IRQ
;*******************************************************************************

                    #Uses     mc9s08qg8.inc

                    XREF      __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack

;*******************************************************************************
                    #RAM                          ;MY_ZEROPAGE: SECTION SHORT
;*******************************************************************************

estado              rmb       1
minh                rmb       1
minl                rmb       1
horah               rmb       1
horal               rmb       1
diah                rmb       1
dial                rmb       1
mesh                rmb       1
mesl                rmb       1
          ;-------------------------------------- ; Acnoledge:      SECTION
acka                rmb       1
ackb                rmb       1
ackc                rmb       1
ackd                rmb       1
          ;-------------------------------------- ; Aux:            SECTION
seg                 rmb       1
seg_aux             rmb       1
segundos            rmb       1

;*******************************************************************************
                    #ROM                          ;Javier: SECTION
;*******************************************************************************

;*******************************************************************************
; Rutina de Interrupcion por IRQ

IRQ_Handler         proc
                    pshh
                    bset      IRQSC_IRQACK,IRQSC  ; Reconocimiento de int y forza la bandera a 0.
                    bclr      IRQSC_IRQIE,IRQSC
                    bsr:4     retardo
                    brclr     5,PTAD,*
                    lda       #1
                    cmpa      estado
                    bne       _2@@
                    clra
                    sta       estado
                    bra       Done@@
_2@@                lda       #1
                    sta       estado
Done@@              bset      IRQSC_IRQIE,IRQSC
                    pulh
                    rti

;*******************************************************************************
; Main Program

Start               proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs
                    bsr       Init
                    jsr       conf_IRQ            ;Rutina configuracion de IRQ
                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    ...       Insert your code here
Loop@@              bsr       escritura
                    jsr       verif
                    jsr       verif_digito
                    jsr       segundo
                    bra       Loop@@
r1                  equ       Loop@@

;*******************************************************************************

Init                proc
                    lda       #$52
                    sta       SOPT1               ; Desactivar watchdog y BKGD como PTA4
                    lda       #%00011111
                    sta       PTADD
                    lda       #%11110000
                    sta       PTBDD
                    lda       #%00100000
                    sta       PTAPE
                    lda       #%00001111
                    sta       PTBPE
                    clra
                    sta       seg
                    sta       seg_aux
                    sta       segundos
                    inca
                    sta       estado

                    clra
                    sta       minh
                    sta       minl
                    sta       horah
                    lda       #9
                    sta       horal
                    lda       #1
                    sta       diah
                    lda       #4
                    sta       dial
                    clra
                    sta       mesh
                    lda       #3
                    sta       mesl
                    clra
                    sta       acka
                    sta       ackb
                    sta       ackc
                    sta       ackd
                    rts

;*******************************************************************************

retardo             proc
                    psha
                    lda       #1
Loop@@              psha
                    lda       #$ff
                    dbnza     *
                    pula
                    dbnza     Loop@@
                    pula
                    rts

;*******************************************************************************
; 23456789012345678901234567890123456789012345

escritura           proc
                    lda       #1
                    cmpa      estado
                    bne       whora
;                   bra       wfecha

;*******************************************************************************

wfecha              proc
                    lda       #%00000001
                    sta       PTAD
                    lda       mesh
                    bsr       escnum
                    bsr       retardo
                    lda       #%00000010
                    sta       PTAD
                    lda       mesl
                    bsr       escnum

                    bsr       retardo

                    lda       #%00000100
                    sta       PTAD
                    lda       diah
                    bsr       escnum

                    bsr       retardo

                    lda       #%00001000
                    sta       PTAD
                    lda       dial
                    bsr       escnum
                    bra       retardo

whora               lda       #%00000001
                    sta       PTAD
                    lda       horah
                    bsr       escnum

                    bsr       retardo

                    lda       #%00000010
                    sta       PTAD
                    lda       horal
                    bsr       escnum

                    bsr       retardo

                    lda       #%00000100
                    sta       PTAD
                    lda       minh
                    bsr       escnum

                    bsr       retardo

                    lda       #%00001000
                    sta       PTAD
                    lda       minl
                    bsr       escnum

                    bsr       retardo
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
nf                  rts

;*******************************************************************************
; 23456789012345678901234567890123456789012345

esc0                proc
                    lda       PTBD                ; Escribir 8b0000xxxx
                    and       #%00001111
                    sta       PTBD
                    bra       n1

;*******************************************************************************

esc1                proc
                    lda       PTBD                ; Escribir 8b0001xxxx
                    and       #%00001111
                    ora       #%00010000
                    sta       PTBD
                    bra       n2

;*******************************************************************************

esc2                proc
                    lda       PTBD                ; Escribir 8b0010xxxx
                    and       #%00001111
                    ora       #%00100000
                    sta       PTBD
                    bra       n3

;*******************************************************************************

esc3                proc
                    lda       PTBD                ; Escribir 8b0011xxxx
                    and       #%00001111
                    ora       #%00110000
                    sta       PTBD
                    bra       n4

;*******************************************************************************

esc4                proc
                    lda       PTBD                ; Escribir 8b0100xxxx
                    and       #%00001111
                    ora       #%01000000
                    sta       PTBD
                    bra       n5

;*******************************************************************************

esc5                proc
                    lda       PTBD                ; Escribir 8b0101xxxx
                    and       #%00001111
                    ora       #%01010000
                    sta       PTBD
                    bra       n6

;*******************************************************************************

esc6                proc
                    lda       PTBD                ; Escribir 8b0110xxxx
                    and       #%00001111
                    ora       #%01100000
                    sta       PTBD
                    bra       n7

;*******************************************************************************

esc7                proc
                    lda       PTBD                ; Escribir 8b0111xxxx
                    and       #%00001111
                    ora       #%01110000
                    sta       PTBD
                    bra       n8

;*******************************************************************************

esc8                proc
                    lda       PTBD                ; Escribir 8b1000xxxx
                    and       #%00001111
                    ora       #%10000000
                    sta       PTBD
                    bra       n9

;*******************************************************************************

esc9                proc
                    lda       PTBD                ; Escribir 8b1000xxxx
                    and       #%00001111
                    ora       #%10010000
                    sta       PTBD
                    bra       nf

;*******************************************************************************

verif               proc                          ; Función para verificar el estado de las entradas de los pulsadores
                    lda       #%00000001          ; Verificación de cambios en el pulsador1 PTB0
                    and       PTBD
                    beq       _4@@
                    bra       verack1

_1@@                lda       #%00000010          ; Verificación de cambios en el pulsador2 PTB1
                    and       PTBD
                    beq       aug2
                    bra       verack2

_2@@                lda       #%00000100          ; Verificación de cambios en el pulsador3 PTB2
                    and       PTBD
                    beq       aug3
                    bra       verackc

_3@@                lda       #%00001000          ; Verificación de cambios en el pulsador4 PTB3
                    and       PTBD
                    beq       aug4
                    bra       verack4
                                                  ; Para el pulsador 1
_4@@                lda       acka                ; Verificación para evitar repetición de aumento del registro
                    beq       a1
_5@@                bra       _1@@
                                                  ; Para el pulsador 2:
aug2                clra                          ; Verificación para evitar repetición de aumento del registro
                    cmpa      ackb
                    beq       a2
aug2r               bra       _2@@
                                                  ; Para el pulsador 3:
aug3                lda       ackc                ; Verificación para evitar repetición de aumento del registro
                    beq       a3
aug3r               bra       _3@@
                                                  ; Para el pulsador 4:
aug4                lda       ackd                ; Verificación para evitar repetición de aumento del registro
                    beq       a4
aug4r               rts

verack1             lda       acka                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vack1
verack1r            bra       _1@@

verack2             lda       ackb                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vack2
verack2r            bra       _2@@

verackc             lda       ackc                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vackc
verackcr            bra       _3@@

verack4             lda       ackd                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vack4
verack4r            rts

vack1               clra
                    sta       acka
                    bra       verack1r

vack2               clra
                    sta       ackb
                    bra       verack2r

vackc               clra
                    sta       ackc
                    bra       verackcr

vack4               clra
                    sta       ackd
                    bra       verack4r

a1                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a1fecha
                    bra       a1hora

a2                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a2fecha
                    bra       a2hora

a3                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a3fecha
                    bra       a3hora

a4                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a4fecha
                    bra       a4hora

a1fecha             inc       mesh                ; subrutina de aumento del registro fecha para el pin dado
                    lda       #1
                    sta       acka
                    bra       _5@@

a1hora              inc       horah               ; subrutina de aumento del registro hora para el pin dado
                    lda       #1
                    sta       acka
                    bra       _5@@

a2fecha             inc       mesl                ; subrutina de aumento del registro fecha para el pin dado
                    lda       #1
                    sta       ackb
?aug2r              bra       aug2r

a2hora              inc       horal               ; subrutina de aumento del registro hora para el pin dado
                    lda       #1
                    sta       ackb
                    bra       ?aug2r

a3fecha             inc       diah                ; subrutina de aumento del registro fecha para el pin dado
                    lda       #1
                    sta       ackc
                    jmp       aug3r

a3hora              inc       minh                ; subrutina de aumento del registro hora para el pin dado
                    lda       #1
                    sta       ackc
                    jmp       aug3r

a4fecha             inc       dial                ; subrutina de aumento del registro fecha para el pin dado
                    lda       #1
                    sta       ackd
                    bra       ?aug4r

a4hora              inc       minl                ; subrutina de aumento del registro hora para el pin dado
                    lda       #1
                    sta       ackd
?aug4r              jmp       aug4r

;*******************************************************************************

verif_digito        proc
                    lda       #10                 ; carga 10 al acumulador
                    cmpa      minl                ; compara con minl
                    bne       vd1                 ; si es diferente va a vd1
                    clra                          ; si minl==10
                    sta       minl                ; minl=0
                    inc       minh                ; suma 1 al acumulador

vd1                 lda       #10                 ; carga 10 al acumulador
                    cmpa      dial                ; compara con dial
                    bne       vd2                 ; si es diferente va a vd2
                    clra                          ; si dial==10
                    sta       dial                ; dial=0
                    inc       diah                ; suma 1 al acumulador

vd2                 lda       #10                 ; carga 10 al acumulador
                    cmpa      horal               ; compara con horal
                    bne       vd3                 ; si es diferente va a vd3
                    clra                          ; si horal==10
                    sta       horal               ; horal=0
                    inc       horah               ; suma 1 al acumulador

vd3                 lda       #10                 ; carga 10 al acumulador
                    cmpa      mesl                ; compara con mesl
                    bne       vd4                 ; si es diferente va a vd4
                    clra                          ; si mesl==10
                    sta       mesl                ; mesl=0
                    inc       mesh                ; suma 1 al acumulador

vd4                 lda       #3                  ; carga 3 al acumulador
                    cmpa      diah                ; compara con diah
                    bne       vd5                 ; si es diferente va a vd5
                    clra                          ; si diah==3
                    sta       diah                ; diah=0
                    lda       #1
                    sta       dial                ; dial=1
                    inc       mesl                ; suma 1 al acumulador

vd5                 lda       #6                  ; carga 6 al acumulador
                    cmpa      minh                ; compara con minh
                    bne       vd6                 ; si es diferente va a vd6
                    clra                          ; si minh==6
                    sta       minh                ; minh=0
                    inc       horal               ; suma 1 al acumulador

vd6                 lda       #2                  ; carga 2 al acumulador
                    cmpa      horah               ; compara con horah
                    bne       vd7                 ; si es diferente va a vd7
                                                  ; si horah==2
                    lda       #4                  ; carga 4 al acumulador
                    cmpa      horal               ; compara con horal
                    bne       vd7                 ; si es diferente va a vd7
                    clra                          ; si horal==4
                    sta       horah               ; horah=0
                    sta       horal               ; horal=0
                    sta       minh                ; minh=0
                    sta       minl                ; minl=0

vd7                 lda       #1                  ; carga 1 al acumulador
                    cmpa      mesh                ; compara con mesh
                    bne       sr1                 ; si es diferente va a sr1
                    inca                          ; carga 2 al acumulador
                    cmpa      mesl                ; compara con mesl
                    bne       sr1                 ; si es diferente va a sr1
                                                  ; si mesh=1 y mesl=2
                    clra                          ; carga 0 al acumulador
                    sta       mesh                ; mesh=0
                    sta       diah                ; diah=0
                    inca                          ; carga 1 al acumulador
                    sta       mesl                ; mesl=1
                    sta       dial                ; dial=1
                    jmp       r1
sr1                 rts

;*******************************************************************************
; rutna para establecer el segundero del sistema
; la ejecución del MainLoop toma 4716 ciclos de bus, el cual opera a 4MHz
; de tal forma se ejecuta 848 veces en un segundo, para efectos de contar
; se decidio dividir dicho valor entre 4 obteniendo 212; asi se procede a la
; siguiente rutina
; seg cuenta hasta 212, seg_aux cuenta 4 veces eso, finalmente segundos
; cuenta los segundos transcurridos

segundo             proc
                    lda       #%11010100          ; carga 212 al acumulador
                    cmpa      seg                 ; compara con segundo
                    beq       _1@@                ; si es igual va a aum_seg_aux
                    inc       seg                 ; incrementa en 1 seg
                    rts

_1@@                clra
                    sta       seg                 ; asigna 0 a seg
                    lda       #4
                    cmpa      seg_aux             ; compara seg_aux con 4
                    beq       _2@@                ; si es igual va a cambio_seg
                    inc       seg_aux             ; incrementa en 1 seg_aux
                    rts

_2@@                clra
                    sta       seg_aux             ; asigna 0 a seg_aux
                    inc       segundos            ; incrementa en 1 segundos

                    brclr     4,PTAD,_4@@         ; si PTA4== 0 va a stx2
                    brset     4,PTAD,_3@@         ; si PTA4== 0 va a stx1

_3@@                bclr      4,PTAD              ; PTA4=0
                    bra       _5@@                ; va a _5@@

_4@@                bset      4,PTAD              ; PTA4=1
;                   bra       _5@@                ; va a _5@@

_5@@                lda       #60
                    cmpa      segundos            ; compara segundos con 60
                    beq       _6@@                ; si es igual va a _6@@
                    jmp       r1                  ; si no vuelve a r1
_6@@                inc       minl                ; suma 1 a minl
                    jmp       r1                  ; vuelve a r1

;*******************************************************************************
; Subrutina de configuraciÛn del Modulo IRQ

conf_IRQ            proc                          ; Label de la Interrupción
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
