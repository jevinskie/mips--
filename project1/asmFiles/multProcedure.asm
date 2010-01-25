	org		0x0000

	ori		$sp, $zero, 0x4000
	ori		$3, $zero, 15
	ori		$4, $zero, 8
	ori		$5, $zero, 3
	ori		$6, $zero, 17
	ori		$7, $zero, 6

   addi $sp, $sp, -4
   sw $3, 0($sp)
   addi $sp, $sp, -4
   sw $4, 0($sp)
   addi $sp, $sp, -4
   sw $5, 0($sp)
   addi $sp, $sp, -4
   sw $6, 0($sp)
   addi $sp, $sp, -4
   sw $7, 0($sp)


   jal mult
   jal mult
   jal mult
   jal mult
#	15 * 8 * 3 * 17 * 6  should be at 0x3FFC
	halt




	org 0x0800
mult:
   lw $t0, 0($sp)
   lw $t1, 4($sp)
   addi $sp, $sp, 4
   # dont inc $sp, we will store here at the end

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

