#--------------------------------------
# Test a multiply routine
#--------------------------------------

# the following program is fully parallel to be executed in two processors, 
# which does not require a coherence controler but needs a memory arbitrator.
# you can initially use this program to test out your dual pipeline and arbitrator,
# (required by 2nd week's demo)
# then you can change the memory pointers and the stacks 
# to have two programs working on the same piece of memory
# to test out yout coherence controler and snooping 
# feel free to add more instructions and functionalities 
# specifcally the ll and sc instructions to test even more. 
# refer to example.asm for a real dual-core program with memory coherence.

# Processor 1:

	org		0x0000
	ori		$15, $zero, 0x80
mult1:
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

multloop1:
	and		$7, $5, $1
	beq		$zero, $7, multnoadd1
	addu		$8, $8, $6

multnoadd1:
	sll		$6, $6, 1
	srl		$5, $5, 1
	beq		$zero, $5, multend1
	beq		$zero, $zero, multloop1
multend1:
	sw		$8, 8($15) # answer 32 should be at address 88
	halt 
        	
	org 	0x80
	cfw	5
	cfw 	10 

# Processor 2:

	org		0x0200
	ori		$15, $zero, 0x280
mult2:
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

multloop2:
	and		$7, $5, $1
	beq		$zero, $7, multnoadd2
	addu	$8, $8, $6

multnoadd2:
	sll		$6, $6, 1
	srl		$5, $5, 1
	beq		$zero, $5, multend2
	beq		$zero, $zero, multloop2
multend2:
	sw		$8, 8($15) # answer 3C should be at address 288
	halt 
        	
	org 	0x280
	cfw	3
	cfw 	20 

