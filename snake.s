


.align 4
.global update

.extern cells

/* REGISTERS USED:
    X2: ptr to head cell
    X3: direction
    X4: register to store bytes with
*/ 


update:
    
    ADRP X2, head@PAGE
    ADD X2, X2 head@PAGEOFF

    ADRP X3, direction@PAGE
    ADD x3, x3 direction@PAGEOFF


    CMP direction, #0
    B.EQ up
    CMP direction, #1
    B.EQ right
    CMP direction, #2
    B.EQ down
    CMP direction, #3
    B.EQ left


up:
    SUBS X2, X2, #8
    B.EQ kill // kill, ceebs wrapping, you can't move up


right:

down:

left:



RET

kill:
    MOV X10, #0 
    RET

set:
    ADRP X2, cells@PAGE
    ADD X2, X2, cells@PAGEOFF
    ADD X2, X2, #136 // move to the 136th cell and make it a player cell

    ADRP X3, head@PAGE
    ADD X3, head@PAGEOFF
    STR X2, [X3] // store the pointer to the head. We can also manipulate this mathematically later.

    MOV X4, #2
    STRB W4, [X2], #8
    STRB W4, [X2], #8
    STRB W4, [X2] // this should set up our snake


    ADRP X3, direction@PAGE
    ADD X3, direction@PAGEOFF
    MOV X4, #0b00
    STRB W4, [X3] // and we're donw

    RET

.data 
    head: .space 8 // 64 bit ptr to our snake head
    direction: .space 1 // a byte to hold our direction
    /*
        encoded state direction: (clockwise)
        00 --> up
        01 --> right
        10 --> down
        11 --> left
    */
    // start off with length of 3, easy enough, direction up
    // in the 16x16 grid, center at 8,8
    // this is cell 16*8 + 8 = 136
