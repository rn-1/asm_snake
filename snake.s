// This file is responsible for handling the logic of the snake
// the way that this works 


.align 4
.global update

.extern cells

/* REGISTERS USED:
   ?
*/ 


update:
    
    


up:
    SUBS X2, X2, #8 // where our head should be
    B.EQ kill // kill, ceebs wrapping, you can't move up


right:
    ADD X2, X2, #1 // where our head should be
    ADD X2, X2, #1
    B.EQ kill // kill, ceebs wrapping, you can't move up

down:

left:

update_tail:


RET

kill:
    MOV X10, #0 
    RET

set: