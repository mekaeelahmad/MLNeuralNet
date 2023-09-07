.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    
loop_start:
    bgt a1, x0, loop_continue
    li a0 36
    j exit

loop_continue:
    ble a1, x0, loop_end
    lw t0 0(a0)
    blt t0, x0, zero_
    addi a0, a0, 4
    addi a1, a1, -1
    j loop_continue
zero_:
    sw x0 0(a0)
    addi a0, a0, 4
    addi a1, a1, -1
    j loop_continue

loop_end:
    # Epilogue

    jr ra
