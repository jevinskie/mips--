# vim: set noai ts=8 sw=8 softtabstop=8 noexpandtab:


####################################################
##################### CORE 0 #######################
####################################################

	org	0x0000
	ori	$sp, $0, 0x8000

	# a0 = array
	ori	$a0, $0, sortdata
	# a1 = length / 2
	ori	$a1, $0, sortdata_end
	subu	$a1, $a1, $a0
	addiu	$a1, $a1, 4
	srl	$a1, $a1, 3

	jal	insertion_sort

	ori	$t0, $0, 1
	ori	$at, $0, core0_sort_done
	sw	$t0, 0($at)

	# wait until core 1 is done sorting
	ori	$t0, $0, core1_sort_done
core0_spin:
	lw	$at, 0($t0)
	beq	$at, $0, core0_spin

	# a2 = array start of other core
	sll	$at, $a1, 2
	addiu	$a2, $at, sortdata

	jal	merge


	halt



####################################################
##################### CORE 1 #######################
####################################################

	org	0x0200
	ori	$sp, $0, 0x7000
	
	# a1 = length / 2
	ori	$a1, $0, sortdata_end
	ori	$at, $0, sortdata
	subu	$a1, $a1, $at
	addiu	$a1, $a1, 4
	srl	$a1, $a1, 3

	# a0 = array_start = sortdata + length / 2
	sll	$at, $a1, 2
	addiu	$a0, $at, sortdata

	jal	insertion_sort

	# set the sort done flag
	ori	$t0, $0, 1
	ori	$at, $0, core1_sort_done
	sw	$t0, 0($at)


	# wait until core 0 is done sorting
	ori	$t0, $0, core0_sort_done
core1_spin:
	lw	$at, 0($t0)
	beq	$at, $0, core1_spin
	
	# a2 = array start of other core
	ori	$a2, $0, sortdata

	jal	merge

	halt




####################################################
################# INSERTION SORT ###################
####################################################


insertion_sort:
	# $a0 has the array address and $a1 has the length

	# for (i = 1; i < length; i++)

	# i (t0) = 1
	ori	$t0, $0, 1

start_insertion_sort:
	# i < length
	beq	$t0, $a1, done_insertion_sort

	# value (t2) = a[i]
	sll	$at, $t0, 2
	addu	$at, $a0, $at
	lw	$t2, 0($at)

	# for  (j = i-1; j >= 0 && a[j] > value; j--)

	# j (t3) = i-1
	addiu	$t3, $t0, -1

start_inner_insertion_sort:
	# break from loop if j < 0
	slt	$at, $t3, $0
	bne	$at, $0, done_inner_insertion_sort

	# a[j] in t4
	sll	$at, $t3, 2
	addu	$at, $a0, $at
	lw	$t4, 0($at)

	# break from the loop if a[j] <= value
	# break if !(value < a[j])
	slt	$at, $t2, $t4
	beq	$at, $0, done_inner_insertion_sort

	# a[j+1] = a[j]
	sll	$at, $t3, 2
	addu	$at, $a0, $at
	sw	$t4, 4($at)

	# j--
	addiu	$t3, $t3, -1
	j	start_inner_insertion_sort
done_inner_insertion_sort:
	# a[j+1] = value
	sll	$at, $t3, 2
	addu	$at, $a0, $at
	sw	$t2, 4($at)

	# i++
	addiu	$t0, $t0, 1
	j	start_insertion_sort
done_insertion_sort:
	jr	$ra


####################################################
##################### MERGE ########################
####################################################

merge:
	# a0 is our array
	# a1 is the length
	# a2 is the other array

	# i (t0)
	addiu	$t0, $a1, -1

	# b[0] (t2)
	lw	$t2, 0($a2)
	# b[-1] (t3)
	sll	$at, $a1, 2
	addu	$at, $a2, $at
	lw	$t3, -4($at)

start_merge_loop:


	# if a[i] (t1) < b[0] (t2)
	sll	$at, $t0, 2
	addu	$at, $a0, $at
	lw	$t1, 0($at)

	slt	$at, $t1, $t2
	beq	$at, $0, merge_test2

	# out[i] = a[i]
	sll	$at, $t0, 2
	addiu	$at, $at, out
	sw	$t1, 0($at)
	j	done_merge_loop

merge_test2:
	# if a[i] (t1) > b[-1] (t3)
	# if t3 < t2
	slt	$at, $t3, $t2
	beq	$at, $0, merge_test3

	# out[i+len(b)] = a[i]
	addu	$at, $t0, $a1
	sll	$at, $at, 2
	addiu	$at, $at, out
	sw	$t1, 0($at)
	j	done_merge_loop

merge_test3:
	# the else clause

	# p (t4) = other array
	or	$t4, $0, $a2
#j	done_merge_loop
find_index_start:
	# load p
	lw	$at, 0($t4)
	slt	$at, $at, $t1
	beq	$at, $0, find_index_done
	addiu	$t4, $t4, 4
	j	find_index_start

find_index_done:
	sll	$at, $t0, 2
	addu	$at, $at, $t4
	subu	$at, $at, $a2
	addiu	$at, $at, out
	sw	$t1, 0($at)


done_merge_loop:
	beq	$t0, $0, done_merge
	addiu	$t0, $t0, -1
	j	start_merge_loop

done_merge:
	jr	$ra

core0_sort_done:
	cfw	0
core1_sort_done:
	cfw	0
core0_merge_done:
	cfw	0
core1_merge_done:
	cfw	0

	org	0x3FFC
	# this marker will be easy to find in a hex dump
	cfw	0xDEADBEEF
	# this data will be aligned nicely now

sortdata:
cfw 0x087d
cfw 0x5fcb
cfw 0xa41a
cfw 0x4109
cfw 0x4522
cfw 0x700f
cfw 0x766d
cfw 0x6f60
cfw 0x8a5e
cfw 0x9580
cfw 0x70a3
cfw 0xaea9
cfw 0x711a
cfw 0x6f81
cfw 0x8f9a
cfw 0x2584
cfw 0xa599
cfw 0x4015
cfw 0xce81
cfw 0xf55b
cfw 0x399e
cfw 0xa23f
cfw 0x3588
cfw 0x33ac
cfw 0xbce7
cfw 0x2a6b
cfw 0x9fa1
cfw 0xc94b
cfw 0xc65b
cfw 0x0068
cfw 0xf499
cfw 0x5f71
cfw 0xd06f
cfw 0x14df
cfw 0x1165
cfw 0xf88d
cfw 0x4ba4
cfw 0x2e74
cfw 0x5c6f
cfw 0xd11e
cfw 0x9222
cfw 0xacdb
cfw 0x1038
cfw 0xab17
cfw 0xf7ce
cfw 0x8a9e
cfw 0x9aa3
cfw 0xb495
cfw 0x8a5e
cfw 0xd859
cfw 0x0bac
cfw 0xd0db
cfw 0x3552
cfw 0xa6b0
cfw 0x727f
cfw 0x28e4
cfw 0xe5cf
cfw 0x163c
cfw 0x3411
cfw 0x8f07
cfw 0xfab7
cfw 0x0f34
cfw 0xdabf
cfw 0x6f6f
cfw 0xc598
cfw 0xf496
cfw 0x9a9a
cfw 0xbd6a
cfw 0x2136
cfw 0x810a
cfw 0xca55
cfw 0x8bce
cfw 0x2ac4
cfw 0xddce
cfw 0xdd06
cfw 0xc4fc
cfw 0xfb2f
cfw 0xee5f
cfw 0xfd30
cfw 0xc540
cfw 0xd5f1
cfw 0xbdad
cfw 0x45c3
cfw 0x708a
cfw 0xa359
cfw 0xf40d
cfw 0xba06
cfw 0xbace
cfw 0xb447
cfw 0x3f48
cfw 0x899e
cfw 0x8084
cfw 0xbdb9
cfw 0xa05a
cfw 0xe225
cfw 0xfb0c
cfw 0xb2b2
cfw 0xa4db
cfw 0x8bf9
cfw 0x12f7
sortdata_end:


	org	0x4FFC
	# this marker will be easy to find in a hex dump
	cfw	0xBAADF00D
	# this data will be aligned nicely now
out:

