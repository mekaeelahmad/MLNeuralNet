.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    add t0 x0 x0 # maxindex = 0
    add t1 x0 x0 # maxvalue = 0 
    add t3 x0 x0 # currindex = 0 
    addi t4 x0 1 
    blt a1 t4 exiterror
loop:
    beq t3 a1 loop_end # currindex = max index
    lw t5 0(a0) # currvalue = a[i]
    blt t1 t5 max_found # if a[i] > max 
    addi a0 a0 4 # a[i] = a[i+1]
    addi t3 t3 1 # index++
    j loop 
max_found: 
    add t0 x0 t3 # maxindex = currindex 
    add t1 t5 x0 # max = a[i]
    addi t3 t3 1 # currindex++ 
    addi a0 a0 4 
    j loop 
exiterror: 
    li a0 36 
    j exit 
    
loop_end:
    # Epilogue
    add a0 t0 x0 
    jr ra 
