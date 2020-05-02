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

__SEG_END_SSTACK    equ       $100

; export symbols
; XDEF _Startup, main, IRQ_Handler
; we export both '_Startup' and 'main' as symbols. Either can
; be referenced in the linker .prm file or from C/C++ later on



; XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack

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

main
_Startup            proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs
                    bsr       init
                    jsr       conf_IRQ            ;Rutina configuracion de IRQ

; ========= Habilita procesar interrupciones
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

init                proc
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

esc1                lda       PTBD                ; Escribir 8b0001xxxx
                    and       #%00001111
                    ora       #%00010000
                    sta       PTBD
                    bra       n2

esc2                lda       PTBD                ; Escribir 8b0010xxxx
                    and       #%00001111
                    ora       #%00100000
                    sta       PTBD
                    bra       n3

esc3                lda       PTBD                ; Escribir 8b0011xxxx
                    and       #%00001111
                    ora       #%00110000
                    sta       PTBD
                    bra       n4

esc4                lda       PTBD                ; Escribir 8b0100xxxx
                    and       #%00001111
                    ora       #%01000000
                    sta       PTBD
                    bra       n5

esc5                lda       PTBD                ; Escribir 8b0101xxxx
                    and       #%00001111
                    ora       #%01010000
                    sta       PTBD
                    bra       n6

esc6                lda       PTBD                ; Escribir 8b0110xxxx
                    and       #%00001111
                    ora       #%01100000
                    sta       PTBD
                    bra       n7

esc7                lda       PTBD                ; Escribir 8b0111xxxx
                    and       #%00001111
                    ora       #%01110000
                    sta       PTBD
                    bra       n8

esc8                lda       PTBD                ; Escribir 8b1000xxxx
                    and       #%00001111
                    ora       #%10000000
                    sta       PTBD
                    bra       n9

esc9                lda       PTBD                ; Escribir 8b1000xxxx
                    and       #%00001111
                    ora       #%10010000
                    sta       PTBD
                    bra       nf

verif                                             ; Función para verificar el estado de las entradas de los pulsadores
                    lda       #%00000001          ; Verificación de cambios en el pulsador1 PTB0
                    and       PTBD
                    beq       aug1
                    bra       verack1

v1                  lda       #%00000010          ; Verificación de cambios en el pulsador2 PTB1
                    and       PTBD
                    beq       aug2
                    bra       verack2

v2                  lda       #%00000100          ; Verificación de cambios en el pulsador3 PTB2
                    and       PTBD
                    beq       aug3
                    bra       verackc

v3                  lda       #%00001000          ; Verificación de cambios en el pulsador4 PTB3
                    and       PTBD
                    beq       aug4
                    bra       verack4

veriffin            rts
                                                  ; Para el pulsador 1
aug1                lda       acka                ; Verificación para evitar repetición de aumento del registro
                    beq       a1
aug1r               bra       v1
                                                  ; Para el pulsador 2:
aug2                clra                          ; Verificación para evitar repetición de aumento del registro
                    cmpa      ackb
                    beq       a2
aug2r               bra       v2
                                                  ; Para el pulsador 3:
aug3                lda       ackc                ; Verificación para evitar repetición de aumento del registro
                    beq       a3
aug3r               bra       v3
                                                  ; Para el pulsador 4:
aug4                lda       ackd                ; Verificación para evitar repetición de aumento del registro
                    beq       a4
aug4r               bra       veriffin

verack1             lda       acka                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vack1
verack1r            bra       v1

verack2             lda       ackb                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vack2
verack2r            bra       v2

verackc             lda       ackc                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vackc
verackcr            bra       v3

verack4             lda       ackd                ; subrutina de limpieza de acknoledge para el pulsador dado
                    cmpa      #1
                    beq       vack4
verack4r            bra       veriffin

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

a1r                 bra       aug1r

a2                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a2fecha
                    bra       a2hora

a2r                 bra       aug2r

a3                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a3fecha
                    bra       a3hora

a3r                 bra       aug3r

a4                  lda       estado              ; subrutina de selección de registro para aumento según estado
                    cmpa      #1
                    beq       a4fecha
                    bra       a4hora

a4r                 bra       aug4r

a1fecha             lda       mesh                ; subrutina de aumento del registro fecha para el pin dado
                    add       #1
                    sta       mesh
                    lda       #1
                    sta       acka
                    bra       a1r

a1hora              lda       horah               ; subrutina de aumento del registro hora para el pin dado
                    add       #1
                    sta       horah
                    lda       #1
                    sta       acka
                    bra       a1r

a2fecha             lda       mesl                ; subrutina de aumento del registro fecha para el pin dado
                    add       #1
                    sta       mesl
                    lda       #1
                    sta       ackb
                    bra       a2r

a2hora              lda       horal               ; subrutina de aumento del registro hora para el pin dado
                    add       #1
                    sta       horal
                    lda       #1
                    sta       ackb
                    bra       a2r

a3fecha             lda       diah                ; subrutina de aumento del registro fecha para el pin dado
                    add       #1
                    sta       diah
                    lda       #1
                    sta       ackc
                    bra       a3r

a3hora              lda       minh                ; subrutina de aumento del registro hora para el pin dado
                    add       #1
                    sta       minh
                    lda       #1
                    sta       ackc
                    bra       a3r

a4fecha             lda       dial                ; subrutina de aumento del registro fecha para el pin dado
                    add       #1
                    sta       dial
                    lda       #1
                    sta       ackd
                    bra       a4r

a4hora              lda       minl                ; subrutina de aumento del registro hora para el pin dado
                    add       #1
                    sta       minl
                    lda       #1
                    sta       ackd
                    bra       a4r

verif_digito        proc
                    lda       #10                 ; carga 10 al acumulador
                    cmpa      minl                ; compara con minl
                    bne       vd1                 ; si es diferente va a vd1
                    clra                          ; si minl==10
                    sta       minl                ; minl=0
                    lda       minh                ; carga minh al acumulador
                    add       #1                  ; suma 1 al acumulador
                    sta       minh                ; carga a minh el acumulador

vd1                 lda       #10                 ; carga 10 al acumulador
                    cmpa      dial                ; compara con dial
                    bne       vd2                 ; si es diferente va a vd2
                    clra                          ; si dial==10
                    sta       dial                ; dial=0
                    lda       diah                ; carga diah al acumulador
                    add       #$01                ; suma 1 al acumulador
                    sta       diah                ; carga a diah el acumulador

vd2                 lda       #10                 ; carga 10 al acumulador
                    cmpa      horal               ; compara con horal
                    bne       vd3                 ; si es diferente va a vd3
                    clra                          ; si horal==10
                    sta       horal               ; horal=0
                    lda       horah               ; carga horah al acumulador
                    add       #1                  ; suma 1 al acumulador
                    sta       horah               ; carga a horah el acumulador

vd3                 lda       #10                 ; carga 10 al acumulador
                    cmpa      mesl                ; compara con mesl
                    bne       vd4                 ; si es diferente va a vd4
                    clra                          ; si mesl==10
                    sta       mesl                ; mesl=0
                    lda       mesh                ; carga mesh al acumulador
                    add       #1                  ; suma 1 al acumulador
                    sta       mesh                ; carga a mesh el acumulador

vd4                 lda       #3                  ; carga 3 al acumulador
                    cmpa      diah                ; compara con diah
                    bne       vd5                 ; si es diferente va a vd5
                    clra                          ; si diah==3
                    sta       diah                ; diah=0
                    lda       #1
                    sta       dial                ; dial=1
                    lda       mesl                ; carga mesl al acumulador
                    add       #1                  ; suma 1 al acumulador
                    sta       mesl                ; carga a mesl el acumulador

vd5                 lda       #6                  ; carga 6 al acumulador
                    cmpa      minh                ; compara con minh
                    bne       vd6                 ; si es diferente va a vd6
                    clra                          ; si minh==6
                    sta       minh                ; minh=0
                    lda       horal               ; carga horal al acumulador
                    add       #1                  ; suma 1 al acumulador
                    sta       horal               ; carga a horal el acumulador

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
                    beq       aum_seg_aux         ; si es igual va a aum_seg_aux
                    lda       seg                 ; si no es igual
                    add       #1                  ; incrementa en 1 seg
                    sta       seg
                    rts

aum_seg_aux         clra
                    sta       seg                 ; asigna 0 a seg
                    lda       #4
                    cmpa      seg_aux             ; compara seg_aux con 4
                    beq       cambio_seg          ; si es igual va a cambio_seg
                    lda       seg_aux
                    add       #1
                    sta       seg_aux             ; incrementa en 1 seg_aux
                    rts

cambio_seg          clra
                    sta       seg_aux             ; asigna 0 a seg_aux
                    lda       segundos
                    add       #1
                    sta       segundos            ; incrementa en 1 segundos

                    brclr     4,PTAD,stx2         ; si PTA4== 0 va a stx2
                    brset     4,PTAD,stx1         ; si PTA4== 0 va a stx1

stx1                bclr      4,PTAD              ; PTA4=0
                    bra       stx3                ; va a stx3

stx2                bset      4,PTAD              ; PTA4=1
;                   bra       stx3                ; va a stx3

stx3                lda       #60
                    cmpa      segundos            ; compara segundos con 60
                    beq       stx4                ; si es igual va a stx4
                    jmp       r1                  ; si no vuelve a r1
stx4                lda       minl
                    add       #1
                    sta       minl                ; suma 1 a minl
                    jmp       r1                  ; vuelve a r1

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
