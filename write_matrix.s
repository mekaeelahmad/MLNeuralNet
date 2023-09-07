.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:


    

    # Prologue
    addi sp sp -28 

    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp) 
    sw s3 12(sp) 
    sw s4 16(sp) 
    sw s5 20(sp)
    sw ra 24(sp)
    

    mv s0 a0        #s0 = filename
    mv s1 a1        #s1 = matrix 
    mv s2 a2        #s2 = numrows 
    mv s3 a3        #s3 = numcols 
    add s4 x0 x0   #s4 = total elements 

    mv a0 s0        #a0 = filename 
    addi a1 x0 1    #a1 = 1 for write only 
    jal fopen       #a0 should be file descriptor 
    addi t3 x0 -1
    beq a0 t3 error2    #fopen failed 
    mv s0 a0            #s0 = descriptor 


    addi sp sp -8 
    sw s2 0(sp) 
    sw s3 4(sp)

    mv a1 sp        #a1 is a pointer to the stack 
    mv a0 s0        #a0 decrypter
    addi a2 x0 2 
    addi a3 x0 4    #size of each element 
    jal fwrite #decrypter, the pointer to buffer, num elements, size of each element   returns num of elements written
    addi t1 x0 2
    bne a0 t1 error4 #fwrite errored 
    addi sp sp 8 


    mul s4 s3 s2    #s4 = num elements 
    mv a1 s1        #a1 = matrix 
    mv a0 s0        #a0 = decryptor 
    mv a2 s4        #a2 = num elements of matrix 
    addi a3 x0 4    #a3 = 4 since size of int is 4
    jal fwrite 
    bne a0 s4 error4

    mv a0 s0        #a0 is decrypter 
    jal fclose 
    bne a0 x0 error3



    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp) 
    lw s3 12(sp) 
    lw s4 16(sp) 
    lw s5 20(sp) 
    lw ra 24(sp)

    addi sp sp 28 

    jr ra

    error2:         #error for the fopen
    addi a0 x0 27
    j exit 

    error3:         #error for the fclose 
    addi a0 x0 28 
    j exit 

    error4:         #error for the fwrite 
    addi a0 x0 30
    j exit 

