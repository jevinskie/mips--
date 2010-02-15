	org 0x0000
   ori $sp, $zero, 0x3FFC

   ori $t0, $zero, 5
   ori $t1, $zero, 6
   slt $t3, $t0, $t1
   sw $t3, 0($sp)

   ori $t0, $zero, 5
   ori $t1, $zero, 6
   sltu $t3, $t0, $t1
   sw $t3, -4($sp)

   lui $t0, 0x8000
   lui $t1, 0x7FFF
   ori $t1, $zero, 0xFFFF
   slt $t3, $t0, $t1
   sw $t3, -8($sp)

   lui $t0, 0x8000
   lui $t1, 0x7FFF
   ori $t1, $zero, 0xFFFF
   sltu $t3, $t0, $t1
   sw $t3, -8($sp)

   ori $t0, $zero, 1337
   ori $t1, $zero, 243
   slt $t3, $t0, $t1
   sw $t3, -12($sp)

   ori $t0, $zero, 5
   slti $t3, $t0, 6
   sw $t3, -16($sp)

   halt

