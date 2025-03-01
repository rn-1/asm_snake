// This code is meant to generate a random number mod 256 with which to add a fruit to the board
// This can be done via the system clock as far as I'm aware

.align 4
.global gen_random
.global timeval

// REGISTERS USED:
// -- X20: stores the final random output
// -- X21: loop iterator
// -- X22: a prime that I've picked to multiply by
// -- X23: upper of time
gen_random:
    MOV X22, #2113 // a random prime by which to multiply
    MOV X21, #3

    // syscall for unix epoch time
    ADRP X0, timeval@PAGE         // Load page address of timeval
    ADD X0, X0, timeval@PAGEOFF   // Add page offset
    MOV X1, #0                    // NULL for timezone
    mov X16, #116 // syscall number for gettimeofday
    svc #0x80

    // we now have it and we will get our result
    ADRP X1, timeval@PAGE // reset bc idk
    ADD X1, X1, timeval@PAGEOFF
    LDR X20, [X1], #8 // store the seconds as our base values

    LDR X2, [X1]
mult:
    
    ADD X20, X20, X2 // use the nanoseconds as salt

    MUL X20, X20, X22 // this fits in a 64 bit register
    // overflow schmoverflow
    AND X20, X20, #0xFF // mod 256 again

    SUBS W21, W21, #1
    B.NE mult

end:
    RET

.data
    timeval: 
        .space 16