.globl classify
#this is for one commit 
.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    ebreak 
    addi sp sp -52
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp) 
    sw s3 12(sp) 
    sw s4 16(sp) 
    sw s5 20(sp)
    sw s6 24(sp) 
    sw s7 28(sp) 
    sw s8 32(sp) 
    sw ra 36(sp)
    sw s9 40(sp)
    sw s10 44(sp)
    sw s11 48(sp)  

    
    mv s0 a0        #s0 = num arguments 
    mv s1 a1        #s1 = pointer to argument filenames
    mv s2 a2        #s2 = mode 
    addi t0 x0 5
    bne s0 t0 error31   #s0 is no longer needed! 
    ebreak

    # Read pretrained m0
    addi a0 x0 4    
    jal ra malloc 
    beq a0 x0 error26
    mv s3 a0           #s3 is pointer to m0 num rows                                                                                              #we malloced this 
    addi a0 x0 4 
    jal ra malloc 
    beq a0 x0 error26
    mv s4 a0           #s4 is pointer to m0 num cols                                                                                              #we malloced this 

    mv a1 s3 
    mv a2 s4 
    lw a0 4(s1)        #a0 = filename for m0
    jal ra read_matrix                                                                                                                            #we malloced so we must free 
    mv s0 a0           #s0 = pointer to m0 

    # Read pretrained m1
    addi a0 x0 4 
    jal ra malloc 
    beq a0 x0 error26
    mv s6 a0        #s6  is pointer to m1 num rows                                                                                         # we malloced this 
    addi a0 x0 4 
    jal ra malloc 
    beq a0 x0 error26
    mv s7 a0        #s7 is pointer to m1 num cols                                                                                          # we malloced this 

    mv a1 s6 
    mv a2 s7 
    lw a0 8(s1) 
    jal ra read_matrix #input: filename,    output: a0 = pointer to matrix, a1 = pointer to num rows, a2 = pointer to num cols          #we malloced here so we must free 
    mv s5 a0        #s5 = pointer to m1 

    # Read input matrix

    addi a0 x0 4 
    jal ra malloc 
    beq a0 x0 error26
    mv s9 a0        #s9 is the pointer to input num rows                                                                                      # we malloced this  
    addi a0 x0 4 
    jal ra malloc  
    beq a0 x0 error26 
    mv s10 a0       #s10 is the pointer to input num cols                                                                                 # we malloced this 

    mv a1 s9        #a1 is input's numrows 
    mv a2 s10       #a2 is input's num cols 
    lw a0 12(s1)    #input's filename 
    jal ra read_matrix                                                                                                                  # we malloced here so we must free 
    mv s8 a0        #s8 = pointer to input 

    # Compute h = matmul(m0, input) h = rows of m0 X cols of input
    lw t0 0(s3)     #t0 = m0's rows 
    lw t1 0(s10)    #t1 = input's cols 

    mul t2 t0 t1    #t2 is h's num elements 
    addi sp sp -4 
    sw t2 0(sp)

    mv a0 t2        #a0 = num elements of h 
    addi t6 x0 4 
    mul a0 a0 t6
    jal ra malloc                                                                                                                     # we malloced here so we must free 
    beq a0 x0 error26
    mv s11 a0       #s11 is buffer for h 

    mv a0 s0        #a0 = m0 
    lw a1 0(s3)     #a1 = m0's rows 
    lw a2 0(s4)     #a2 = m0's cols 
    mv a3 s8        #a3 = input 
    lw a4 0(s9)     #a4 = input's rows 
    lw a5 0(s10)     #a5 = input's cols 
    mv a6 s11 
    jal ra matmul

    # Compute h = relu(h)   inputs: a0, num elements    output = new array 
    lw t2 0(sp)     #load back t2, which is h's num elements
    addi sp sp 4 
    mv a0 s11       #a0 = h 
    mv a1 t2        #a1 = h's num elements
    jal ra relu

    # Compute o = matmul(m1, h)
    
    mv a0 s0        #first free! freeing m0. no longer needed                                                                          #first free of s0 (m0)
    jal ra free     #freeing m0 

    lw t0 0(s6)
    lw t1 0(s10)
    mul a0 t0 t1    #a0 = o's num elements = m1's rows * h's cols 
    addi t6 x0 4 
    mul a0 a0 t6
    jal ra malloc                                                                                                                     #we malloced here so we must free 
    beq a0 x0 error26 
    mv s0 a0        #s0 is not m0, s0 = pointer to o 
    

    mv a0 s5        #a0 = m1 
    lw a1 0(s6)     #a1 = m1's rows 
    lw a2 0(s7)     #a2 = m1's cols 
    mv a3 s11       #a3 = h 
    lw a4 0(s3)     #a4 = h's rows = m0's rows 
    lw a5 0(s10)    #a5 = h's cols = input's cols 
    mv a6 s0        #a6 = pointer to o
    jal ra matmul 
    beq a0 x0 error26 



    #starting to free stuff 
    # Write output matrix o
    lw a0 16(s1)    #filename for output 
    mv a1 s0        #a1 = o's buffer 
    lw a2 0(s6)        #a2 = o's rows 
    lw a3 0(s10)        #a3 = o's cols 
    jal ra write_matrix 

    # Compute and return argmax(o)
    ebreak
    mv a0 s0        #a0 = o's buffer 
    lw t5 0(s6)        #a2 = o's rows 
    lw t6 0(s10)        #a3 = o's cols 
    mul a1 t5 t6    #a1 = o's num elements 
    jal ra argmax   #a0 should be the max 
    mv s1 a0 
    
    
    #freeing!!!! Yayy!!!! 
    mv a0 s3        #freeing s3                                                                                 #freeing s3 which is m1's rows
    jal ra free 

    mv a0 s4        #freeing s4                                                                                 #freeing s4 which is m1's cols 
    jal ra free 

    mv a0 s5        #freeing m1 
    jal ra free 

    mv a0 s8        #freeing s8! 
    jal ra free 

    mv a0 s11       #freeing s11! 
    jal ra free 

    mv a0 s0        #freeing a0! 
    jal ra free 
    
    mv a0 s6        #freeing s6 
    jal ra free 

    mv a0 s7        #freeing s7 
    jal ra free 

    mv a0 s9        #freeing s9 
    jal ra free 

    mv a0 s10       #freeing s10
    jal ra free 


    # If enabled, print argmax(o) and newline
    addi t0 x0 1 
    beq s2 t0 finish


    mv a0 s1 
    jal ra print_int 
    li a0 '\n'
    jal ra print_char 



    finish:
    #Epilogue 
    mv a0 s1 
    
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp) 
    lw s3 12(sp) 
    lw s4 16(sp) 
    lw s5 20(sp)
    lw s6 24(sp) 
    lw s7 28(sp) 
    lw s8 32(sp) 
    lw ra 36(sp)
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)  
    addi sp sp 52 

    jr ra

    error31: 
        addi a0 x0 31
        j exit 
    error26: 
        addi a0 x0 26 
        j exit 



