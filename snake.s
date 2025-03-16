/*
    This file is responsible for handling the logic of the snake
    We do this by saving the direction of a player cell in the upper bits for that cell (since each cell is a byte).
    When we check the cell for print, we just and the lower 4 bites
    Direction encoding key:
        00: up
        01: right
        10: down
        11: left
    We then maintain an index to the head and tail of the snake.
    This way we can always track the bends in the path of the snake and update optimally.
*/


.align 4
.global update
.global set
.extern cells

/* REGISTERS USED:
    -- X2: stores the active ptr index
    -- X3: stores the cells ptr
    -- X4: holds values to write to the cell
    !- X10: we update x10 on player loss
*/ 


update:
    ADRP X2, head@PAGE
    ADD X2, X2, head@PAGEOFF
    MOV X4, #0 
    LDR X4, [X2]
    AND X4, X4, 0XFF

    ADRP X3, cells@PAGE
    ADD X3, X3, cells@PAGEOFF
    ADD X3, X3, X4 // move ptr to head cells

    LDR X4, [X3]
    AND X4, X4, #0xF0
    // switch statement

    CMP X4, #0x00
    B.EQ up
    CMP X4, #0x10
    B.EQ right
    CMP X4, #0x20
    B.EQ down
    
    B left


// below are update branches for head. I would generalise them but nah. In the head case, we don't need to clear any cells.
up:
    SUB X3, X3, #16
    // TODO check wall
    MOV X4, #0x02
    STRB W4, [X3] // store at address

    LDR X4, [X2]
    SUB X4, X4, #16 // update the head ptr value for later storage


    B update_tail

right:
    ADD X3, X3, #1

    // TODO: how do i know if they've hit the wall here?

    MOV X4, #0x12 // preserve direction
    STRB W4, [X3] // store at address

    LDR X4, [X2]
    ADD X4, X4, #1 // update the head ptr value for later storage

    B update_tail

down:
    ADD X3, X3, #16

    // TODO check wall
    MOV X4, #0x22
    STRB W4, [X3] // store at address

    LDR X4, [X2]
    ADD X4, X4, #16 // update the head ptr value for later storage

    B update_tail

left:
    SUB X3, X3, #1
    SUB X2, X2, #1
    // TODO: how do i know if they've hit the wall here?
    MOV X4, #0x32 // preserve direction
    STRB W4, [X3] // store at address

    LDR X4, [X2]
    SUB X4, X4, #1 // update the head ptr value for later storage

//update head ptr

update_tail:
    STRB W4, [X2] // store the new index val to head

    ADRP X2, tail@PAGE
    ADD X2, X2, tail@PAGEOFF
    LDR X4, [X2] // same stuff as for the head
    AND X4, X4, 0XFF

    ADRP X3, cells@PAGE
    ADD X3, X3, cells@PAGEOFF
    ADD X3, X3, X4 // move ptr to tail cells

    LDR X4, [X3]
    AND X4, X4, #0xF0

    // switch statement
    CMP X4, #0x00
    B.EQ t_up
    CMP X4, #0x10
    B.EQ t_right
    CMP X4, #0x20
    B.EQ t_down
    B t_left
// tail has no wall checks yippee!
t_up:
    MOV X4, #0x00 // clear the old cell (we always do this)
    STRB W4, [X3] // this is crappy, pls clean

    LDR X4, [X2]
    SUB X4, X4, #16 // this is where we can check
    
    B stop

t_right:
    MOV X4, #0x00 // clear the old cell (we always do this)
    STRB W4, [X3]
    
    LDR X4, [X2]
    SUB X4, X4, #1 // this is where we can check
    

    B stop

t_down:
    MOV X4, #0x00 // clear the old cell (we always do this)
    STRB W4, [X3]
    
    LDR X4, [X2]
    ADD X4, X4, #16 // this is where we can check

    B stop

t_left:
    MOV X4, #0x00 // clear the old cell (we always do this)
    STRB W4, [X3]
    
    LDR X4, [X2]
    ADD X4, X4, #1 // this is where we can check

stop:

    STRB W4, [X2] // update tail ptr

    RET

kill:
    MOV X10, #0 
    RET

set:
    // head should always start at 136


    MOV X4, #136 // cells start up
    ADRP X3, cells@PAGE
    ADD X3, X3, cells@PAGEOFF
    ADRP X2, head@PAGE
    ADD X2, X2, head@PAGEOFF
    STRB W4, [X2] // store the head index

    ADD X3, X3, X4 // move to cell to fill
    MOV X4, #0b00000010 // value of a player cell with direction up.
    STRB W4, [X3], #16 // write to cell and increment to next row
    STRB W4, [X3], #16 // write to cell and increment to next row
    STRB W4, [X3] // write to cell, no increment as we're done.
    // do the same for the next two rows

    ADRP X2, tail@PAGE
    ADD X2, X2, tail@PAGEOFF
    MOV X4, #168 // our starting tail.
    STRB W4, [X2] // store tail ind

    // done
    RET

// todo: interrupt for player input

.data
    // indices for the head and tail of the snake
    head: .space 1 // 1 byte of space allocated for each var, since we need a number 0 - 255
    tail: .space 1
