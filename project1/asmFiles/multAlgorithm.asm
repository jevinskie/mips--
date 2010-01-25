	org 0x0000
   ori $sp, $zero, 0x3FF8

mult:
   lw $t0, 0($sp)
   addi $sp, $sp, 4
   lw $t1, 0($sp)
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
   halt 


	org 0x3FF8
	cfw 5
	cfw 10 

