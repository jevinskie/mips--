org 0

   ori $sp, $0, 0x4000

   ori $t0, $0, 2010
   sw $t0, -4($sp)
   ori $t1, $0, 4
   sw $t1, -8($sp)
   ori $t2, $0, 14
   sw $t2, -12($sp)
   addi $sp, $sp, -12
   jal calc_date
   lw $t3, 0($sp)
   addi $sp, $sp, 4
   halt

calc_date:
   lw $t0, 0($sp)
   lw $t1, 4($sp)
   lw $t2, 8($sp)
   addi $sp, $sp, 8

   addi $t2, $t2, -2000
   addi $t1, $t1, -1

   and $t4, $0, $0

   ori $t3, $0, 365

   # save callee-destroyed temps
   sw $ra, 0($sp)
   sw $t0, -4($sp)
   sw $t1, -8($sp)
   sw $t2, -12($sp)
   sw $t3, -16($sp)
   # save args
   sw $t2, -20($sp)
   sw $t3, -24($sp)
   # adjust sp
   addi $sp, $sp, -24
   jal mult
   # load result
   lw $t5, 0($sp)
   # restore temps
   lw $t3, 4($sp)
   lw $t2, 8($sp)
   lw $t1, 12($sp)
   lw $t0, 16($sp)
   lw $ra, 20($sp)
   # adjust stack
   addi $sp, $sp, 20

   add $t4, $t4, $t5


   ori $t3, $0, 30

   # save callee-destroyed temps
   sw $ra, 0($sp)
   sw $t0, -4($sp)
   sw $t1, -8($sp)
   sw $t2, -12($sp)
   sw $t3, -16($sp)
   # save args
   sw $t1, -20($sp)
   sw $t3, -24($sp)
   addi $sp, $sp, -24
   jal mult
   lw $t5, 0($sp)
   lw $t3, 4($sp)
   lw $t2, 8($sp)
   lw $t1, 12($sp)
   lw $t0, 16($sp)
   lw $ra, 20($sp)
   addi $sp, $sp, 20

   add $t4, $t4, $t5

   add $t4, $t4, $t0

   sw $t4, 0($sp)

   jr $ra


mult:
   lw $t0, 0($sp)
   lw $t1, 4($sp)
   addi $sp, $sp, 4

   and $t2, $0, $0

   beq $t1, $0, done
mult_loop:
   andi $t3, $t1, 1
   beq $t3, $0, no_add
   addu $t2, $t2, $t0
no_add:
   srl $t1, $t1, 1
   sll $t0, $t0, 1
   bne $t1, $0, mult_loop
done:
   sw $t2, 0($sp)
   jr $ra

