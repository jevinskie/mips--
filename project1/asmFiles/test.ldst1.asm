
	#------------------------------------------------------------------
	# Test lw sw
	#------------------------------------------------------------------

	org		0x0000
	ori		$1, $zero, 0xF0
	nop
	nop
	nop
	nop
	ori		$2, $zero, 0x100
	nop
	nop
	nop
	nop
	lw		$3, 0($1)
	nop
	nop
	nop
	nop
	lw		$4, 4($1)
	nop
	nop
	nop
	nop
	lw		$5, 8($1)
	nop
	nop
	nop
	nop
	
	sw		$3, 0($2)
	nop
	nop
	nop
	nop
	sw		$4, 4($2)
	nop
	nop
	nop
	nop
	sw		$5, 8($2)
	nop
	nop
	nop
	nop
	halt			# that's all

	org		0x00F0
	cfw		0x7337
	cfw		0x2701
	cfw		0x1337
