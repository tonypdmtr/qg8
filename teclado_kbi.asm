;*******************************************************************************
; Universidad Nacional de Colombia
; Facultad de ingeniería mecánica y mecatrónica
; Microcontroladores 2018-I
; Programador:
; -Javier Mauricio Pinilla Garcia  25481244
;
; Version: 1.0
; Microcontrolador: MC9S08QG8CPBE
; Codigo para leer un teclado 4x4 (sin la ultima columna
; habilitada) a traves del uso de interrupciones KBI
;*******************************************************************************

                    #Uses     mc9s08qg8.inc

                    xref      __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack

;*******************************************************************************
                    #RAM                          ; variable/data section
;*******************************************************************************

numero              rmb       1                   ; numero pulsado
fkbi                rmb       1                   ; flag kbi
rowa                rmb       1                   ; row actual
row                 rmb       1                   ; row activada cuando se dio la interrupcion
col                 rmb       1                   ; col activada cuando se dio la interrupcion

;*******************************************************************************
                    #ROM                          ;Javier: SECTION
;*******************************************************************************

KBI_Handler         proc
                    bset      KBISC_KBACK,KBISC   ; Reconocimiento de int y forza la bandera a 0.
                    bclr      KBISC_KBIE,KBISC
                    jsr:4     Delay
                    lda       PTAD
                    sta       col

Loop@@              brset     0,PTAD,*
                    brset     1,PTAD,Loop@@
                    brset     2,PTAD,Loop@@

                    lda       rowa
                    sta       row
                    lda       #1
                    sta       fkbi

                    bset      KBISC_KBIE,KBISC
                    rti

;*******************************************************************************

Start               proc
                    ldhx      #__SEG_END_SSTACK   ; initialize the stack pointer
                    txs

                    lda       #$52
                    sta       SOPT1               ; Desactivar watchdog y BKGD como PTA4
                    clra
                    sta       fkbi
                    sta       row
                    sta       rowa
                    lda       #10
                    sta       numero

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

                    lda       #%00001111          ; Puertos de escritura
                              ; ||||||||_row 1
                              ; |||||||__row 2
                              ; ||||||___row 3
                              ; |||||____row 4
                    sta       PTBDD
                    jsr       kbi_conf

                    cli                           ; enable interrupts
;                   bra       MainLoop

;*******************************************************************************

MainLoop            proc
                    lda       #1
                    cmpa      fkbi
                    beq       ver0
                    nop
                    lda       #%00000001          ; row 1 = 1
                    sta       PTBD
                    lda       #1
                    sta       rowa

                    nop
                    lda       #%00000010          ; row 2 = 1
                    sta       PTBD
                    lda       #2
                    sta       rowa

                    nop
                    lda       #%00000100          ; row 3 = 1
                    sta       PTBD
                    lda       #3
                    sta       rowa

                    nop
                    lda       #%00001000          ; row 4 = 1
                    sta       PTBD
                    lda       #4
                    sta       rowa
                    bra       MainLoop

;*******************************************************************************

ver0                lda       #1
                    cmpa      row
                    bne       ver1
                    brset     0,col,num1          ; col 1 = 1
                    brset     1,col,num2          ; col 2 = 1
                    brset     2,col,num3          ; col 3 = 1
                    bra       clrfkbi

ver1                nop
                    lda       #2
                    cmpa      row
                    bne       ver2
                    brset     0,col,num4          ; col 1 = 1
                    brset     1,col,num5          ; col 2 = 1
                    brset     2,col,num6          ; col 3 = 1
                    bra       clrfkbi

ver2                lda       #3
                    cmpa      row
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
                    bra       clrfkbi

num4                lda       #4
                    sta       numero
                    bra       clrfkbi

num5                lda       #5
                    sta       numero
                    bra       clrfkbi

num6                lda       #6
                    sta       numero
                    bra       clrfkbi

num7                lda       #7
                    sta       numero
                    bra       clrfkbi

num8                lda       #8
                    sta       numero
                    bra       clrfkbi

num9                lda       #9
                    sta       numero
                    bra       clrfkbi

num0                clra
                    sta       numero
                    bra       clrfkbi

clrfkbi             clra
                    sta       fkbi
                    jmp       MainLoop

;*******************************************************************************
; Configuracion del KBI
; KBISC_MOD= 1b1 --> detecta flanco y nivel
; PTAPE = #%00000111 --> activa dispositivo de pull up en pines KBI a usar
; KBIES = FF --> selecciona resistencia de pull down, la interrupcion
; se activa con un 1 en el pin

kbi_conf            proc
                    lda       #%00000001
                    sta       KBISC               ; 1 IE=0, MOD=1
                    lda       #$FF
                    sta       KBIES               ; 2 Seleccionar pull up/down 0/1 activa con 0/activa con 1

                    lda       #%00000111
                    sta       PTAPE               ; 3 Configurar pullup de los pines a usar
                    lda       #%00000111
                    sta       KBIPE               ; 4 Configurar pines KBI a usar
                    lda       KBISC
                    ora       #%00000100
                    sta       KBISC               ; 5 ACK=1
                    lda       KBISC
                    ora       #%00000011
                    sta       KBISC               ; 6 IE=1, MOD=1
                    rts

;*******************************************************************************

Delay               proc
                    psha
                    lda       #1
Loop@@              psha
                    lda       #$ff
                    dbnza     *
                    pula
                    dbnza     Loop@@
                    pula
                    rts
