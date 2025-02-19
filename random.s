// This code is meant to generate a random number mod 256 with which to add a fruit to the board
// This can be done via the system clock as far as I'm aware


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
    mov X16, #0x1000000
    svc #0x80

    // we now have it and we will get our result
    MOV X20, X3 // store the lower bits as our base value
    

    // TODO it should not be making fruits every tick, perhaps every 8?
    // We will need to make a divclk 😭

mult:
    ADD X20, X20, X2 // add the upper bits as salt
    AND X20, X20, #0b11111111 // mod 256
    
    MUL X20, X22, X2 // this fits in a 64 bit register
    AND X20, X20, #0b11111111 // mod 256 again

    SUBS X21, X21, #1
    B.NE end
    B mult

end:
    RET