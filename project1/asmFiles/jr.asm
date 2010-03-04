   org 0

   ori $sp, $zero, 0x100

   ori $ra, $zero, labelb
   jr $ra

labela:
   ori $t0, $zero, 1
   sw $t0, 0($sp)
   j done

labelb:
   ori $t0, $zero, 2
   sw $t0, 4($sp)

done:
   halt

