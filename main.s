// Snake in ASM.
// This is the main file from which the program will run.


.global _start
.align 4

// data from read.s
.extern cells

// REGISTERS USED:
// -- X0-X2 - parameters to Unix system calls
// -- X10: stores the runflag to tell us whether or not we are still playing
// -- X11: value of cell to be stored

_start:
    // main body of the program
    MOV X10, #1 // 1 means we are playing. This is much simpler thankfully, but now we cannot use X10 :( too bad!
    

game:
    CMP X10, #1 // compare the value of runflag to 1 --> this compare is the header of a while loop!
    B.NE endgame // if runflag is not 1, end the game

    BL read // call the read function and print out our funny little guy
    BL random // generates a random number, stored in X20


    // generate a random food
    ADRP X11, cells@PAGE
    ADD X11, X11, cells@PAGEOFF

    ADD X11, X11, X20 // move address to the cell we want to edit
    MOV W12, #1
    STRB W12, [X11]


    // TODO: write the rest of the logic

    // go back to the start of the game loop
    B game

endgame:

    // first tell the player they suck
    mov	X0, #1		// 1 = StdOut
    adr	X1, gameover 	// string to print
	mov	X2, #9	    	// length of our string
	mov	X16, #4		// Unix write system call
	svc	#0x80

    // end the game
    mov X0, #0 // return 0
    mov X16, #1 // exit
    svc #0x80 // syscall linux
    
_data:
    gameover: .ascii "you suck\n" // message to print when the player loses
