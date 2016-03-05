 /* C runtime */
	.text

        .org 0x100
user_trap_entry:
	li a1, 0x80000000	# LED.HEX address
	li t3, 0x40793f40
	sw t3, 0x00(a1)		# HEX = '-E0-'
1:	j 1b

        .org 0x120
supervisor_trap_entry:
	li a1, 0x80000000	# LED.HEX address
	li t3, 0x40790640
	sw t3, 0x00(a1)		# HEX = '-E1-'
1:	j 1b

        .org 0x140
hypervisor_trap_entry:
	li a1, 0x80000000	# LED.HEX address
	li t3, 0x40795b40
	sw t3, 0x00(a1)		# HEX = '-E2-'
1:	j 1b

        .org 0x160
machine_trap_entry:
	li a1, 0x80000000	# LED.HEX address
	li t3, 0x40794f40
	sw t3, 0x00(a1)		# HEX = '-E3-'
1:	j 1b

	/* start of program */
	.org 0x200 - 4
	.globl _start
        nop                     # avoid exception with zscale
_start:	li sp, 0x20000400
	j main
