.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    
    li t6 0 # t6=ret
    slli a3 a3 2 # multiply stride by 4 to get bytes
    slli a4 a4 2
    ble a2 x0 err1
    ble a3 x0 err2
    ble a4 x0 err2
loop_start:
    lw t0 0(a0) # t0 = a0[i]
    lw t1 0(a1) # t1 = a1[i]
    mul t0 t0 t1 # x[0] * y[0]
    add t6 t6 t0 # ret = ret + x[0] * y[0]
    add a0 a0 a3 # int* a0 = a0 + 4*stride
    add a1 a1 a4 # int* a1 = a1 + 4*stride
    addi a2 a2 -1 # n = n - 1
    bgt a2 x0 loop_start # if n > 0: continue
loop_end:
    # Epilogue
    add a0 t6 x0 # a0 = ret
    jr ra
err1:
    li a0 36
    j exit
err2:
    li a0 37
    j exit