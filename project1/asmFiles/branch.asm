org 0
ori $20, $0, 0x80
ori $1, $0, 1
ori $2, $0, 2
ori $3, $0, 3
ori $4, $0, 0
bne $1, $0, not_zero
sw $3, 0($20)
not_zero:
beq $2, $0, zero
sw $3, 4($20)
zero:
sw $3, 8($20)
beq $4, $0, zero2
sw $3, 12($20)
zero2:
sw $3, 16($20)
ori $1, $0, 243
ori $1, $0, 243
ori $1, $0, 243
sw $1, 20($20)
halt
