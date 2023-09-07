.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Prologue
    # |1 2 3| --> [1 2 3 4 5 6]
    # |4 5 6|           ^
    #
    # |7   8|
    # |9  10| --> [7 8 9 10 11 12]
    # |11 12|         ^    ^
    addi sp sp -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)

    mv s0, a0 #s0 = arr1
    mv s1, a1 #s1 = arr1 rows
    mv s2, a2 #s2 = arr1 cols
    mv s3, a3 #s3 = arr2
    mv s4, a4 #s4 = arr2 rows
    mv s5, a5 #s5 = arr2 cols
    mv s6, a6 #s6 = return arr
    add s7, x0, s1 #s7 = counter for outer loop (rows in arr1)
    # Error checks
    ble s1, x0, err #check m0's height >= 1
    ble s2, x0, err #check m0's width >= 1
    ble s4, x0, err #check m1's height >= 1
    ble s5, x0, err #check m1's width >= 1
    bne s2, s4, err #check m0's width == m1's height

outer_loop_start:
    beq s7, x0, outer_loop_end
    add s8, x0, s5 #s8 = counter for inner loop (cols in arr2)
    j inner_loop_start

inner_loop_start:
    # addi sp sp -20
    # sw a1, 0(sp) # a1 = pointer to arr2
    # sw a2, 4(sp) # a2 = num elements to use in dot 
    # sw a3, 8(sp) # stride of arr1
    # sw a4, 12(sp) # stride of arr2
    # sw a0, 16(sp) # a0 = pointer to arr1

    beq s8, x0, inner_loop_end #s8 is the counter for inner loop 

    mv a0 s0       #a0 = arr1 
    mv a1, s3      #a1 = arr2 
    mv a2, s2      #a2 = arr1 cols 
    addi a3, x0, 1 #strides for arr1 (one) 
    add a4, s5, x0 #strides for arr2 

    jal ra dot

    sw a0 0(s6) #save dot product in s6 
    addi s6 s6 4 #shift s6 by 4 to store next thing 

    # lw a1, 0(sp) 
    # lw a2, 4(sp)
    # lw a3, 8(sp)
    # lw a4, 12(sp)
    # lw a0, 16(sp)
    # addi sp sp 24 #shift stack 

    addi s8 s8 -1 #inner loop counter 
    addi s3 s3 4 #shift arr2 by one 
    j inner_loop_start

inner_loop_end:
    addi t0 x0 4 #t0 = 4 
    mul t0 s2 t0 # t0 = numcols in arr1 * 4 
    add s0 s0 t0 # shift arr1 by t0 

    addi t0 x0 -4 
    mul t0 s5 t0 
    add s3 s3 t0
    addi s7 s7 -1 
    j outer_loop_start

outer_loop_end:

    
    # Epilogue

    lw ra, 48(sp)
    lw s11, 44(sp)
    lw s10, 40(sp)
    lw s9, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 52



    jr ra


err:
    li a0 38
    j exit

