#--------------------------------------
# Test a multiply routine
#--------------------------------------
	org		0x0000
	ori		$15, $zero, 0x80
mult:
	sw		$zero, 8($15)     # clear result
	ori		$1, $zero, 0x01
	ori		$2, $zero, 0x02
	lw		$5, 0($15)
	lw		$6, 4($15)
	or		$7, $zero, $zero
	or		$8, $zero, $zero


# one operand in $5, one in $6
# shift the one in $5 right
# shift the one in $6 left

multloop:
	and		$7, $5, $1
	beq		$zero, $7, multnoadd
	addu	$8, $8, $6

multnoadd:
	sll		$6, $6, 1
	srl		$5, $5, 1
	beq		$zero, $5, multend
	beq		$zero, $zero, multloop
multend:
	sw		$8, 8($15) # answer 32 should be at address 88
	halt 
        	
	org 	0x80
	cfw		5
	cfw 	10 

