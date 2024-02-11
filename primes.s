; Visually displays distribution of the prime numbers between 1 and 128000
; (except for "2") using a sieve algorithm.
;
; Requires KIM-1 with a K-1008 Visable Memory Card
;
; Based on the description of a similar program that MTU's Hal Chamberlin
; wrote for the MTU-130
;
; Be sure your interrupt vector (at l7FE and 17FF) is set to address $1C00
;
; 04 Feb. 2024 - Eduardo Casino (mail@eduardocasino.es)
;
; This program is in the PUBLIC DOMAIN
;

.ifndef VMORG
VMORG           =       $A000           ; Visual memory location
.endif
NX              =       320             ; Number of bits in a row
NY              =       200             ; Number of rows
NPIX            =       NX*NY           ; Number of pixels
FIRST           =       3               ; First candidate to check
LAST            =       357             ; Last candidate to check:
                                        ;   Screen size is 64000, last odd
                                        ;   integer that fits is 127999:
                                        ;     trunc(127999/2) = 63999
                                        ;   so last int to check:
                                        ;     trunc(sqrt(127999)) = 357

                .segment "zp" : zeropage

ADP1:           .res    2               ; Address pointer    
CANDIDATE:      .res    2               ; Candidate counter
CNDP:           .res    2               ; Multiple of Candidate pixel
BTPT:           .res    1               ; Bit number
                .assert * <= $EF, error, "Page zero overflow!"

                .segment "code"

                jsr     FILLSCR

                lda     #FIRST          ; Initialize candidates counter and
                sta     CANDIDATE       ; position
                lda     #0
                sta     CANDIDATE+1

CHECK:          lda     CANDIDATE+1
                lsr
                sta     CNDP+1
                lda     CANDIDATE
                ror
                sta     CNDP
                jsr     PIXADR          ; Get pixel addr and bit pos
                ldy     BTPT
                lda     MSKTB1,Y        ; Get pixel mask
                ldy     #0 
                and     (ADP1),Y        ; Set?
                beq     NEXT            ; No, check next candidate

                ; Clear multiples
                ;
CLRMULT:        clc                     ; Advance CANDIDATE positions
                lda     CANDIDATE
                adc     CNDP
                sta     CNDP
                lda     CANDIDATE+1
                adc     CNDP+1
                sta     CNDP+1

                lda     #>(NPIX-1)      ; Compare to screen size
                cmp     CNDP+1
                bcc     NEXT            ; Greater, next candidate
                bne     @CONT           ; Smaller, continue
                lda     #<(NPIX-1)
                cmp     CNDP
                bcc     NEXT            ; Greater, next candidate
@CONT:          jsr     PIXADR          ; Get pixel addr and bit mask
                ldy     BTPT
                lda     MSKTB2,Y        ; Get inverted pixel mask
                ldy     #0 
                and     (ADP1),Y        ; Clear pixel
                sta     (ADP1),Y
                jmp     CLRMULT         ; Advance to next multiple

NEXT:           clc
                lda     #2
                adc     CANDIDATE
                sta     CANDIDATE
                bcc     ISBGR
                inc     CANDIDATE+1

ISBGR:          lda     #>(LAST+1)      ; Compare to last candidate
                cmp     CANDIDATE+1
                bcc     DONE            ; Greater, done 
                bne     CHECK           ; Lower, loop
                lda     #<(LAST+1)
                cmp     CANDIDATE
                bcs     CHECK           ; Lower, loop

DONE:           brk                     ; Yes, we're done!


;        These routines are adapted from the K-1008 Graphics Software Package
;

;        Fill entire screen routine
;
FILLSCR:        ldy     #0              ; Initialize address pointer
                sty     ADP1            ; and zero Y
                lda     #>VMORG
                sta     ADP1+1
                clc                     ; Compute end address
                adc     #NPIX/8/256
                tax                     ; Keep it in X
@SET1:          lda     #$FF            ; Set a byte
                sta     (ADP1),Y
                inc     ADP1            ; Next location
                bne     @SET2
                inc     ADP1+1
@SET2:          lda     ADP1            ; Done?
                cmp     #<(NPIX/8)
                bne     @SET1           ; Loop if not
                cpx     ADP1+1
                bne     @SET1
                rts

;       Find the address and bit number of the pixel representing
;       the candidate. Takes candidate position at CNDP and puts
;       the byte address in ADP1 and bit mask (bit 0 is leftmost)
;       in BTPT.
;
PIXADR:         lda     CNDP            ; Transfer position to ADP1
                sta     ADP1
                lda     CNDP+1
                sta     ADP1+1
                lda     ADP1            ; Compute bit address
                and     #$07
                sta     BTPT
                lsr     ADP1+1          ; Compute byte address
                ror     ADP1
                lsr     ADP1+1
                ror     ADP1
                lsr     ADP1+1
                ror     ADP1
                clc
                lda     #>VMORG         ; Add base address
                adc     ADP1+1
                sta     ADP1+1
                rts

;        Mask tables for individual pixel subroutines
;        MSKTB1 is a table of 1 bits corresponding to bit numbers
;        MSKTB2 is a table of 0 bits corresponding to bit numbers
;
MSKTB1:  .BYTE  $80,$40,$20,$10
         .BYTE  $08,$04,$02,$01
MSKTB2:  .BYTE  $7F,$BF,$DF,$EF
         .BYTE  $F7,$FB,$FD,$FE

                .end