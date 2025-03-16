// This code reads cells from memory and processes them to be printed to the screen.
// The displaying is also done here.

// we use colored text to display the cells. Each character is a byte, so two bytes per tile.

.global read
.global cells
.align 4

// REGISTERS USED:
// -- X0-X2 - parameters to Unix system calls
// -- X4: memory addr
// -- X5: memory value
// -- X6: loop counter
// -- X7: display string addr (specific character)
// -- X8: stores result of modulo operation for checking when to print
// -- X9: letter to store in display string

read:

    MOV X6, #0 // start the iterator at 0.


    // clear the screen 
    MOV	X0, #1		// 1 = StdOut file descriptor
    ADRP X7, clear_string@PAGE // reset the pointer to the start of the display string
    ADD X7, X7, clear_string@PAGEOFF // i love darwin
    mov X1, X7 // since we already have the address might as well just use mov
    MOV X2, #11 // length of our string
    mov	X16, #4		// Unix write system call
    svc	#0x80 // execute syscall



    ADRP X4, cells@PAGE // setup
    ADD X4, X4, cells@PAGEOFF // get the address of the cells.

    ADRP X7, display_string@PAGE // setup
    ADD X7, X7, display_string@PAGEOFF // get the address of the display strings.

forloop:
    
    CMP X6, #256 // check if we've reached the end of the cells
    B.GE endforloop // if we have, end the loop

    CMP X6, #0 // Ignore the case that X6 is actually just zero
    B.EQ scan // 0 % anything is 0 and this shouldn't trigger anything

    AND X8, X6, #0b1111 // bitwise and with 15
    CMP X8, #0 // if it's zero, we've hit a multiple of 16
    B.NE scan // if not, skip the print and finish up the line
    
    // else, print and continue the scan. We also need to reset the pointer

    MOV	X0, #1		// 1 = StdOut file descriptor
    MOV X1, #0 //clear x1 just in case
    ADRP X7, display_string@PAGE // reset the pointer to the start of the display string
    ADD X7, X7, display_string@PAGEOFF // i love darwin
    mov X1, X7 // since we already have the address might as well just use mov
    MOV X2, #17 // length of our string
    mov	X16, #4		// Unix write system call
    svc	#0x80 // execute syscall
    



scan:
    // Cells are arranged in an 8x8 grid. Therefore, we scan row by row as we update.
    MOV X5, #0
    LDR X5, [X4], #1 // X5 now contains the value of the cell.
    AND X5, X5, #0x0F // isolate the last byte of the read. if cells is less than 32 bytes, it is bad if we don't.
    // also use lower bits since that holds type
    CMP X5, #1 // compare to value 1.
    B.EQ food // idk maybe we need this who knows.
    B.LT empty // value must be 0, so it must be empty.
    B.GT player // value must be 2, so it must be a player.
    
food:
    // print out an @
    MOV W9, #0x40 // ascii value of @
    STRB W9, [X7], #1 // store the value in the display string and increment by 1
    B finalise

empty:
    // print out a space.
    MOV W9, #0x20 // ascii value of space
    STRB W9, [X7], #1 // store the value in the display string and increment by 1
    B finalise

player:
    // print out an O
    MOV W9, #0x4F // ascii value of O
    STRB W9, [X7], #1 // store the value in the display string and increment by 1

finalise:
    ADD X6, X6, #1 // increment the loop counter.
    B forloop // go back to the start of the loop

endforloop:
    // we have read all the cells. Now we can return and be done.

    // one final print to finish up.
    MOV	X0, #1		// 1 = StdOut file descriptor
    MOV X1, #0 //clear x1 just in case
    ADRP X7, display_string@PAGE // reset the pointer to the start of the display string
    ADD X7, X7, display_string@PAGEOFF // i love darwin
    mov X1, X7 // since we already have the address might as well just use mov
    MOV X2, #17 // length of our string
    mov	X16, #4		// Unix write system call
    svc	#0x80 // execute syscall

    RET


//an additional quick modulo function since we do modulo 8 we can be fast

.data
    // the memory addresses to read from
    // We can definitely do this more efficiently, but wtv for now.
    cells: 
        .fill 256, 1, 0

    // we also need a set of ascii strings to write bytes to for displaying.
    display_string: .ascii "XXXXXXXXXXXXXXXX\n"; // if it ever prints like this, something is wrong.
    clear_string: .ascii "\033[H\033[2J"; // clears the screen between reads