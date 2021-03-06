# vim: set noai ts=8 sw=8 softtabstop=8 noexpandtab:


####################################################
##################### CORE 0 #######################
####################################################

	org	0x0000
	ori	$sp, $0, 0x7000

	ori	$a0, $0, lock_data
	jal	lock

	ori	$a0, $0, 32
	jal	pause

	ori	$a0, $0, lock_data
	jal	unlock

	halt



####################################################
##################### CORE 1 #######################
####################################################

	org	0x0200
	ori	$sp, $0, 0x8000

	ori	$a0, $0, 32
	jal	pause

	ori	$a0, $0, lock_data
	jal	lock
	
	halt



####################################################
##################### COMMON #######################
####################################################

lock:
spin_lock:
	ll	$t1, 0($a0)
	bne	$t1, $0, spin_lock
	ori	$t1, $0, 1
	sc	$t1, 0($a0)
	beq	$t1, $0, spin_lock
	jr	$ra

unlock:
	sw	$0, 0($a0)
	jr	$ra

pause:
	ori	$t0, $0, 0
spin_pause:
	beq	$t0, $a0, pause_done
	addiu	$t0, $t0, 1
	j	spin_pause
pause_done:
	jr	$ra

####################################################
###################### DATA ########################
####################################################

	org	0x1000
lock_data:
	cfw	0
