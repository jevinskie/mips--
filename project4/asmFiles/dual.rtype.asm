#------------------------------------------------------------------
# Dual-core R-type Instruction Test Program
#------------------------------------------------------------------

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

# Processor 1

	org	0x0000
	ori	$1,$zero,0xD269
	ori	$2,$zero,0x37F1

	ori	$21,$zero,0x80
	ori	$22,$zero,0xF0

# Now running all R type instructions
	or	$3,$1,$2
	and	$4,$1,$2
	andi	$5,$1,0xF
	addu	$6,$1,$2
	addiu	$7,$1,0x8740
	subu	$8,$1,$2
	xor	$9,$1,$2
	xori	$10,$1,0xf33f
	sll	$11,$1,4
	srl	$12,$1,5
	nor	$13,$1,$2
# Store them to verify the results
	sw	$3,0($21)
	sw	$4,4($21)
	sw	$5,8($21)
	sw	$6,12($21)
	sw	$7,16($21)
	sw	$8,20($21)
	sw	$9,24($21)
	sw	$10,28($21)
	sw	$11,32($21)
	sw	$12,36($21)
	sw	$13,0($22)
	halt	# that's all

# Processor 2

        org     0x0200
        ori     $1,$zero,0xD269
        ori     $2,$zero,0x37F1

        ori     $21,$zero,0x280
        ori     $22,$zero,0x2F0

# Now running all R type instructions
        or      $3,$1,$2
        and     $4,$1,$2
        andi    $5,$1,0xF
        addu    $6,$1,$2
        addiu   $7,$1,0x8740
        subu    $8,$1,$2
        xor     $9,$1,$2
        xori    $10,$1,0xf33f
        sll     $11,$1,4
        srl     $12,$1,5
        nor     $13,$1,$2
# Store them to verify the results
        sw      $3,0($21)
        sw      $4,4($21)
        sw      $5,8($21)
        sw      $6,12($21)
        sw      $7,16($21)
        sw      $8,20($21)
        sw      $9,24($21)
        sw      $10,28($21)
        sw      $11,32($21)
        sw      $12,36($21)
        sw      $13,0($22)
        halt    # that's all


