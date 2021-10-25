; x16.inc by SlithyMatt - slightly modified for multi-revision support
.include "x16.inc"
.include "zsm.inc"

.export init_player
.export playmusic
.export startmusic
.export stopmusic

ZSM_HDR_SIZE	=	3	; will soon be larger

.segment "ZEROPAGE"

data:	.tag	SONGPTR
delay:	.res	1
cmd:	.res	1

.segment "BSS"

loop_pointer:	.tag	SONGPTR
tmp:			.tag	SONGPTR

.segment "CODE"

.proc init_player: near
			stz delay ; initialize to "not playing"
			lda #$FF
			sta	loop_pointer + SONGPTR::bank
			stz loop_pointer + SONGPTR::addr
			stz loop_pointer + SONGPTR::addr+1
			ldx #databank
			lda #ZSM_HDR_SIZE
			sta data + SONGPTR::addr
			lda #$a0
			sta data + SONGPTR::addr + 1
			stx data + SONGPTR::bank
			rts
.endproc

; ---------------------------------------------------------------------------
; startmusic: Begins playing a ZSM music stream.
;	A	: HIRAM bank of tune
;	X/Y	: Memory address of beginning of ZSM header
; ---------------------------------------------------------------------------
;
; Initializes the song data pointer, loop pointer, and sets delay = 1
; Music will begin playing on the following frame
;

.proc startmusic: near
			; ensure music does not attempt to play due to an IRQ
			stz delay
			; store the passed arguments into data pointer and a tmp space
			sta data + SONGPTR::bank
			stx data + SONGPTR::addr
			sty data + SONGPTR::addr+1
			sta tmp + SONGPTR::bank
			stx tmp + SONGPTR::addr
			sty tmp + SONGPTR::addr+1
			; bank in the music data
			ldx RAM_BANK
			phx		; save current BANK to restore later
			sta RAM_BANK
			; copy the loop pointer from the header data into main memory
			lda (data)
			sta loop_pointer + SONGPTR::addr
			jsr nextdata
			lda (data)
			sta	loop_pointer + SONGPTR::addr + 1
			jsr nextdata
			lda	(data)
			sta loop_pointer + SONGPTR::bank
			tax
			; move data pointer past the remaining header bytes
			ldy #(ZSM_HDR_SIZE-2)
:			jsr nextdata
			dey
			bne :-
			cpx #$FF	; check if there is a loop or not
			beq	done
			; add load address to loop pointer
			clc
			lda tmp + SONGPTR::addr
			adc loop_pointer + SONGPTR::addr
			sta loop_pointer + SONGPTR::addr
			lda loop_pointer + SONGPTR::addr + 1
			cmp #$20
			bcs die ; invalid loop data >= $2000 
			adc tmp + SONGPTR::addr + 1
			cmp #$c0
			bcc	calculate_bank
			sbc #$20
			inc loop_pointer + SONGPTR::bank
calculate_bank:
			sta loop_pointer + SONGPTR::addr + 1
			lda tmp + SONGPTR::bank
			adc loop_pointer + SONGPTR::bank
			bcs	die ; loop bank points past end of HIRAM
			cmp #$FF	; did we end up with loop bank = FF?
			beq die		; if so, then die (FF is an invalid loop bank)
			sta loop_pointer + SONGPTR::bank
			
done:		pla
			sta RAM_BANK
			lda #1
			sta delay	; start the music
			clc			; return clear carry flag to indicate no errors
			rts
die:
			pla
			sta RAM_BANK
			stz delay	; ensure the music is not playing
			sec
			rts
.endproc

.proc stopmusic: near
			stz	delay
			rts
.endproc

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
noop:		rts

delayframe:
			and #$7F		; mask off the delay command flag
			beq loopsong
			sta delay
			jmp nextdata

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

nextnote:
			lda (data)			; 5
			bmi delayframe  	;
								; 2
			bit #$40			; 2
			bne YMPCM			; 
playPSG:						; 2
			tax
			jsr nextdata		; +X
			lda (data)			; 5		; get the value for writing into PSG
			tay					; 2
			jsr nextdata		; +X
			txa					; 2		; put the register number into A....
			clc					; 2
			adc #$c0			; 		; ...to offset it properly into VRAM location
			sta VERA_addr_low	; 4
			sty VERA_data0		; 4
			bra nextnote		; 3

YMPCM:							; 3
			and #$3f			; 2
			beq PCMcommand		;
playYM:							; 2
			tax					; 2		; X now holds number of reg/val pairs to process
nextYM:	
			jsr nextdata
			dex
			bmi nextnote	; note: the most YM writes is 63, so this is a safe test
			lda (data)
			tay				; Y now holds the YM register address
			jsr nextdata
:			bit YM_data
			bmi :-			; wait for YM busy flag to be clear
			sty YM_reg
			lda (data)
			sta YM_data
			bra nextYM		; 3
PCMcommand:
			jsr nextdata
			rts				; no PCM commands defined yet...

loopsong:

			; check if loop_ptr bank = $FF
			lda loop_pointer+SONGPTR::bank
			cmp	#$FF
			bne :+
			jmp stopmusic
:			sta data + SONGPTR::bank
			sta RAM_BANK
			lda	loop_pointer + SONGPTR::addr
			sta	data + SONGPTR::addr
			lda	loop_pointer + SONGPTR::addr+1
			sta	data + SONGPTR::addr+1
			jmp	nextnote

