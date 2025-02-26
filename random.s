// This code is meant to generate a random number mod 256 with which to add a fruit to the board
// This can be done via the system clock as far as I'm aware

.align 4
.global gen_random

// REGISTERS USED:
// -- X20: stores the final random output
// -- X21: loop iterator
// -- X22: a prime that I've picked to multiply by
// -- X23: upper of time
gen_random:
    MOV X22, #2113 // a random prime by which to multiply
    MOV X21, #3

    // syscall for mach_absolute_time()
    MOV X0, #0
    LDR X1, TIME_OUTPUT@PAGE
    ADD X1, X1, TIME_OUTPUT@PAGEOFF
    mov x2, #0
    mov x3, #0
    mov X16, #116
    svc #0x80

    // we now have it and we will get our result
    MOV X20, X3 // store the lower bits as our base values

    // TODO it should not be making fruits every tick, perhaps every 8?
    // We will need to make a divclk 😭

mult:
    ADD X20, X20, X2 // add the upper bits as salt
    MUL X20, X20, X22 // this fits in a 64 bit register
    // overflow schmoverflow
    AND X20, X20, #0xFF // mod 256 again

    SUBS W21, W21, #1
    B.NE mult

end:
    RET



.data:
    TIME_OUTPUT: .zero 16 // reserve some bytes for the epoch time stamp.