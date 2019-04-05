; Clear the screen in an ordered, top to bottom fashion
;
; Entry: None
; Exit: A, BC, D, HL all trashed
;       (push on stack if needed)
;
; Notes:
;
; This is obviously slower than simply blatting from
; $4000 to $5800, but that would reveal the three sectors
; of the screen AND the alternate line pattern
; (both seen when loading screens)
; This is an example method to show how to address screen
; RAM using a Y coordinate instead, so we can move from
; top to bottom, line by line.
;

clearscreen_ordered:
                LD   B,192 ; num y lines
                XOR  A ; clear the accumulator
                       ; (MUCH faster than LD A,$00)
                LD   C,A ; c == y coord

; Here, we create the screen line pointer in HL,
; based upon the given y-coordinate in C.
; The y coordinate needs to be shuffled about a bit to be
; in the correct format for the Spectrum's bizarre
; hardware.

ylinesloop:
                LD   A,C
                AND  $7 ; get first three bits,
                        ; in the same position in H
                LD   H,A
                LD   A,C
                AND  $38 ; next three bits need to be
                         ; shifted left twice,
                         ; and placed in L
                RLA
                RLA
                LD   L,A
                LD   A,C
                AND  $C0 ; last two bits need to be
                         ; shifted right three times,
                         ; and placed in H
                RRA
                RRA
                RRA
                OR   H
                OR   $40 ; also include the base address
                         ; (screen mem starts at $4000)
                LD   H,A ; HL = ptr to line

; Individual lines are thankfully arranged in a linear
; fashion in memory. We can simply increase the
; pointer by one each time to clear a single line.

                LD   D,32 ; bytes per line (256 pixels)
xbytesloop:
                LD   (HL),$00 ; all pixels cleared
                INC  HL
                DEC  D
                JP   NZ,xbytesloop
                INC  C
                DEC  B
                JP   NZ,ylinesloop

                ret
