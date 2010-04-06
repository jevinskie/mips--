#------------------------------------------------------------------
# Dual Core load and store test program
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

	org		0x0000	
	ori		$1,$zero,0xF0
	ori		$2,$zero,0x80
	lui		$7,0xdead
	ori		$7,$7,0xbeef
	lw		$3,0($1)
	lw		$4,4($1)
	lw		$5,8($1)
	
	sw		$3,0($2)
	sw		$4,4($2)
	sw		$5,8($2)
	sw		$7,12($2)
	halt			# that's all

	org		0x00F0
	cfw		0x7337
	cfw		0x2701
	cfw		0x1337


# Processor 2

        org             0x0200  
        ori             $1,$zero,0x2F0
        ori             $2,$zero,0x280
        lui             $7,0xdead
        ori             $7,$7,0xbeef
        lw              $3,0($1)
        lw              $4,4($1)
        lw              $5,8($1)
        
        sw              $3,0($2)
        sw              $4,4($2)
        sw              $5,8($2)
        sw              $7,12($2)
        halt                    # that's all

        org             0x02F0
        cfw             0x7337
        cfw             0x2701
        cfw             0x1337

