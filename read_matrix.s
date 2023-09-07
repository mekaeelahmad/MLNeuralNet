.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp sp -64
    sw ra 12(sp)

    #saving inputs and ra 

    sw s0 16(sp)
    sw s1 20(sp)
    sw s2 24(sp)
    sw s3 28(sp)
    sw s4 32(sp) 
    sw s5 36(sp)
    sw s6 40(sp)
    sw s7 44(sp)
    sw s8 48(sp)
    sw s9 52(sp)
    sw s10 56(sp)
    sw s11 60(sp)
    #saving callers saved registers

    mv s5 a1        #s5 is address of numrows     
    mv s6 a2        #s6 is address of numcols      

    mv s2 a1        #s2 is value of num rows 
    mv s3 a2        #s3 is value of num cols 

    mv a1 x0        #a1 = read permission (0)
    jal fopen       #calling fopen to change a0 which is now the descriptor
    addi t3 x0 -1
    beq a0 t3 error2    #fopen failed 
    mv s0 a0        #s0 = descriptor

    addi a0 x0 8    #8 bytes for first two elements
    jal malloc      #a0 is buffer for two elements          #mallocing 8 bytes for the first two elements  
    beq a0 x0 error1 
    mv s11 a0 

    mv a1 a0        #a1 = buffer 
    mv s1 a1        #s1 = buffer 
    mv a0 s0        #a0 = descriptor 
    addi a2 x0 8    #reading two elements (8 bytes) 
    jal fread
    addi t3 x0 8
    bne a0 t3 error4 #fread errored 
    lw s2 0(s1)     #s2 is num rows 
    lw s3 4(s1)     #s3 is num cols

    mv a0 s11 
    jal ra free 


    mul s4 s3 s2    #s4 is num elements
    slli s4 s4 2    #s4 is the number of bytes now 
    mv a0 s4        #a0 is the num of bytes 
    jal malloc 
    beq a0 x0 error1 #a0 is the buffer for num elements 

    mv a1 a0        #a1 is the buffer 
    mv s1 a1        #s1 = a1 for calling convention
    mv a0 s0        #a0 is the descriptor
    mv a2 s4        #a2 is num of bytes 
    

    jal fread 
    bne a0 s4 error4    #fread errored 

    mv a0 s1        #a0 is matrix  
    mv a0 s0        #a0 is now descriptor 
    jal fclose      
    bne a0 x0 error3

    mv a0 s1        #a0 is done now 
    sw s2 0(s5)     #a1 address is now num rows 
    sw s3 0(s6)     #a2 address is now num cols 

    #mv a1 s5        
    #mv a2 s6



    # Epilogue
    lw s0 16(sp)
    lw s1 20(sp)
    lw s2 24(sp)
    lw s3 28(sp)
    lw s4 32(sp) 
    lw s5 36(sp)
    lw s6 40(sp)
    lw s7 44(sp)
    lw s8 48(sp)
    lw s9 52(sp)
    lw s10 56(sp)
    lw s11 60(sp)
    lw ra 12(sp) 
    addi sp sp 64
    jr ra

    error1:         #error for the malloc 
    addi a0 x0 26 
    j exit 

    error2:         #error for the fopen
    addi a0 x0 27
    j exit 

    error3:         #error for the fclose 
    addi a0 x0 28 
    j exit 

    error4:         #error for the fread 
    addi a0 x0 29 
    j exit 
