; x16.inc by SlithyMatt - slightly modified for multi-revision support
.include "x16.inc"

; exports for subroutines and public variables
;.export		streamPCM
;.export		playdigi
;.export		stopdigi

; ---------------------------------------------------------------------------
; Hello World:	prints "hello world"
; ---------------------------------------------------------------------------

.export		helloworld
.import		start
.segment  "CODE"

		jmp	start
.proc helloworld: near

		ldx	#0
nextchar:
		lda str_hello,x
		beq	done
		jsr CHROUT
		inx
		bra nextchar
done:	RTS                    ; Return to caller

.endproc

.segment "RODATA"

str_hello:	.byte	"hello world", 0
strlen	= (* - str_hello)
string_length:	.byte	strlen
