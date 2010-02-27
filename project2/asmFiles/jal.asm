   org 0

   ori $sp, $zero, 0x100

   ori $ra, $zero, 0x243
   jal labelb
   jal labela
   j done

labela:
   ori $t0, $zero, 1
   sw $t0, 0($sp)
   jr $ra

labelb:
   ori $t0, $zero, 2
   sw $t0, 4($sp)
   jr $ra

labelc:
   ori $t0, $zero, 3
   sw $t0, 8($sp)

done:
   halt

