org 0

   ori $t0, $zero, 128
   j one

org 64
one:
   addiu $t0, $t0, -1
   bne $t0, $zero, two
   j done

org 128
two:
   addiu $t0, $t0, -1
   bne $t0, $zero, one
   j done

org 192
done:
   halt

