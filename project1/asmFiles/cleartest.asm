	org		0x0000

	ori		$1, $zero, start
	ori		$2, $zero, 0x7FFC
	ori		$10, $zero, 4

loop:
	sw		$0, 0($1)
	subu	$3, $2, $1
	beq		$3, $zero, end
	addu	$1, $1, $10
	j			loop
end:
	halt
 

start:
cfw 0

