 lst off

 org $2000

*-------------------------------------------------
*
* 06/28/89 Prince of Persia boot code
* for rw18 3.5" version
*
* Last mod: 09/05/89
*

rw18 = $D000

slot = $FD

*-------------------------------------------------
*
* Tell RW18 which slot to use
*

start bit RW18temp

 ldx #$FF
 txs

 lda $43 ;ProDOS boot drive
 sta slot

* Clear screen, etc...

 jsr init

* Check system for 128k of RAM

 jsr check128k

* Determine if we are running on a GS
* and do GS specific stuff also...

 jsr setGSflag

* Move rw18 to its home

 jsr moverw18

* Start loading the game

 jsr rw18
 db 7,$A9 ;Bbund ID=$A9 for side one

 jsr rw18 ;"seek" track one
 db 2,0,1

 jsr rw18 ;read in $EE00-FFFF
 hex C3EE

 jmp $EE00

*-------------------------------------------------
text = $fb2f
home = $fc58
vtab = $FB5B
cout = $FDF0
normal = $fe84
pr0 = $fe93
in0 = $fe89

init ldx #$ff
 stx $4fb
 stx $3f3
 stx $3f4
 stx $c000 ;80store off
 stx $c002 ;RAMRD main
 stx $c004 ;RAMWRT main
 stx $c00c ;80col off
 stx $c00e ;Altcharset off
 stx $c081 ;write RAM, read ROM (2nd 4k bank)
 jsr text
 jsr home
 jsr normal
 jsr pr0
 jsr in0

 rts

*-------------------------------------------------
*
* Check to make sure //c or //e
* with 128k
*

check128k sta $C081

 lda $FBB3 ;Apple // family ID byte
 cmp #6
 bne NOT128K ;Must be e/c/GS

 bit $C017
 bmi NOT128K

 ldx #CHECKEND
:0 lda CHECKER,X
 sta $180,X
 dex
 bpl :0

 jsr $180
 bcs NOT128K

 rts

NOT128K jsr text
 jsr home
 lda #8
 jsr vtab

 ldy #0
:0 lda MEMTEXT,Y
 beq *
 jsr cout
 cmp #$8D
 bne :1
 lda #4
 sta $24
:1 iny
 bne :0

MEMTEXT hex 8D
 asc "REQUIRES A //C OR //E WITH 128K"
 hex 00

*-------------------------------------------------
* Check for AUX memory routine

CHECKER lda #$EE
 sta $C005
 sta $C003
 sta $0800
 lda $0C00
 cmp #$EE
 bne :0
 asl $0C00
 lda $0800
 cmp $0C00
 beq :1
:0 clc
:1 sta $C004
 sta $C002
 rts

CHECKEND = *-CHECKER

*------------------------------------------------- setGSflag
*
* Set the GS? flag in rw18
*

setGSflag sta $C081
 sec
 jsr $FE1F
 lda #$FF
 adc #0
 sta GS?
 bpl :notGS

* Set background color to black, text to white

 lda #$F0
 sta $C022

* Set border color to black

 lda $C034
 and #$F0
 sta $C034

:notGS rts

*------------------------------------------------- moverw18
*
* Move RW18 to it's final home in $D000
*

moverw18 bit $C08B
 bit $C08B

 ldy #0
:0 lda RW18temp,y
:1 sta $D000,y
 iny
 bne :0

 inc :0+2
 inc :1+2
 bne :0

 rts

*-------------------------------------------------

 sav popboot35

*------------------------------------------------- EOF
 dum *
RW18temp ds 3
GS? ds 1
 dend
*-------------------------------------------------
 lst off
