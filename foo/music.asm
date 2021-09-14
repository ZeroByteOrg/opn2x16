;.include "x16.inc" ; include this one for R38
.include "x16r39.inc" ; x16.inc by SlithyMatt

.export data

.struct SONGPTR
	addr		.word	1
	bank		.byte	1
.endstruct

databank	= 2
playerbank	= 1

.segment "ZEROPAGE"

data:	.tag	SONGPTR
delay:	.res	1
cmd:	.res	3

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

;cbm_k_setnam("petfont.bin");
;cbm_k_setlfs(0,8,0);

irq:
			jsr	playmusic
			jmp	(kernal_irq)

kernal_irq:	.word	$ffff

init_player:
			; hard-wired to play from $a000 and loop full tune for now.
			lda #1 ; start delay = 1
			sta delay
init_dataptr:
			ldx #databank
			lda #$a0
			stz data + SONGPTR::addr
			sta data + SONGPTR::addr + 1
			stx data + SONGPTR::bank
			rts

startmusic:
			rts
stopmusic:
			stz	delay
			rts

nextdata:
			; advance the data pointer, with bank-wrap if necessary
			inc	data
			beq	:+
			rts
			; next page
:			lda data+1
			inc
			cmp	#$c0		; Check for bank wrap.
			bcc @nobankwrap
			; bank wrapped.
			lda #$a0		; return to page $a000
			inc RAM_BANK	; bank in the next RAM bank
			inc data + SONGPTR::bank
			
			; TODO: Make this a cpx w/ actual # of avail banks.
			;       (don't assume 2MB of HIRAM installed)
			beq	@die		; out-of-memory error
@nobankwrap:
			sta	data+1	
			rts
@die:
			; stop the music and return error (carry bit = 1)
			jsr stopmusic
			lda #1
			ror
			rts

delayframe:
			jsr nextdata
			lda (data)
			bne :+
			inc				; if delay=0, set delay=1
:			sta delay
			jsr nextdata
noop:
			rts
playmusic:
			; first check the delay. 0 = not playing.
			lda delay
			beq noop
			; delay >0. Decrement, and if now 0, then play, else exit.
			dec	
			sta delay
			bne noop
			; bank in the song data
			lda data + SONGPTR::bank
			sta RAM_BANK
			; point VERA to PSG page
			lda #$01		; bank 1, 0 stride
			sta VERA_addr_bank
			lda #$f9		; PSG are on page $F9 of VRAM
			sta VERA_addr_high
nextnote:	; data->next command in song data.
			; Load next command and advance the pointer.
			lda (data)
			beq delayframe	; cmd 0 = delay frame.
			bmi loopsong	; cmd $80-$FF = end of data
			; cmd is not control-related, so load cmd + 2 bytes
			sta cmd			; tmp store cmd in ZP
			jsr nextdata
			; get reg / val for chip write - hold in X and Y
			lda (data)
			tax
			jsr nextdata
			lda (data)
			tay
			jsr nextdata
			; check cmd to see which sound chip should be updated
			lda cmd
			cmp #2		; 2 = PSG note
			beq	playPSG
			cmp #1		; 1 = FM note
			bne nextnote	; skip non-supported commands
playFM:
			bit YM_data
			bmi	playFM		; wait for YM busy flag to be clear
			stx	YM_reg
			nop
			sty	YM_data
			jsr NOP30
			bra	nextnote
playPSG:
			txa				; for PSG, move "reg" value into A...
			clc
			adc #$c0		; ...to offset it properly into VRAM location
			sta VERA_addr_low
			sty VERA_data0
			bra nextnote
			
loopsong:
			ldx #databank
			lda #$a0
			stz data + SONGPTR::addr
			sta data + SONGPTR::addr + 1
			stx data + SONGPTR::bank
			stx RAM_BANK
			jmp	nextnote
			
NOP30:
			ldx #0
			dex
			bne NOP30+2
			rts
						
start:
			;  ==== load zsm file into memory ====

			; set BANKRAM to the first bank where song should load
			lda	#databank
			sta	RAM_BANK
			lda #filename_end-filename
			ldx #<filename
			ldy #>filename
			jsr SETNAM
			lda #0	; logical file id 0
			ldx	#8	; device 8
			ldy #0	; no command
			jsr	SETLFS
			; load song to $A000
			lda	#0		; 0=load, 1=verify, 2|3 = VLOAD to VRAM bank0/bank1
			ldx	#0
			ldy #$a0
			jsr LOAD
			
			; save the current IRQ vector so player can call it when done
			lda IRQVec
			sta kernal_irq
			lda IRQVec+1
			sta kernal_irq+1
			; install player as the IRQ handler
			sei
			lda #<irq
			sta IRQVec
			lda #>irq
			sta IRQVec+1
			cli
			
			jsr init_player
			jsr startmusic
forever:	bra forever

.segment	"RODATA"
filename:	.byte "bgm.zsm"
filename_end:
			

