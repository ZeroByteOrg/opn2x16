Sound_Ptr    = $38

.DATA
Sound_Delay:    .byte $FF
Sound_Voice:    .byte 7*4   ; holds voice offset


.CODE

.macro PlaySFX sfx, voice
        LDX #<(sfx)
        LDY #>(sfx)
        LDA #(voice)
        JSR Sound_Play
.endmacro


; X/Y - Pointer to Sfx data
; A - Voice on which to play
.proc Sound_Play
        STX Sound_Ptr
        STY Sound_Ptr + 1

        ASL
        ASL
        STA Sound_Voice

        LDA #1
        STA Sound_Delay
        RTS
.endproc


.proc Sound_Tick
        LDA Sound_Delay     ; nothing to play
        BMI end

        DEC
        STA Sound_Delay     ; Is it time for PSG Writes?
        BNE end

        LDA #^VRAM_PSG      ; set the PSG register
        STA VERA_Addr_Bank
        LDA #>VRAM_PSG
        STA VERA_Addr_High

 push:  CLC
        LDA (Sound_Ptr)
        TAX
        AND #%11
        ADC Sound_Voice
        ADC #<VRAM_PSG
        STA VERA_Addr_Low

        LDY #1
        LDA (Sound_Ptr), Y  ; write to PSG
        STA VERA_Data1

        CLC
        LDA Sound_Ptr       ; increase the pointer
        ADC #2
        STA Sound_Ptr
        LDA Sound_Ptr + 1
        ADC #0
        STA Sound_Ptr + 1

        TXA
        LSR
        LSR
        BEQ push            ; when delay = 0, start new write
        CMP #%111111        ; when delay = 63 - end of SFX
        BNE next
        ORA #%10000000
 next:  STA Sound_Delay

 end:   RTS
.endproc