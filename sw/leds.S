  .text
  .align 6
user_trap_entry:
  j user_trap_entry

  .align 6
supervisor_trap_entry:
  j supervisor_trap_entry

  .align 6
hypervisor_trap_entry:
  j hypervisor_trap_entry

  .align 6
machine_trap_entry:
  j machine_trap_entry

  .align 6
  .globl _start
_start:	la sp, _tdata_begin + 0x400

	li a0, 0x40000000	# KEY base address
	li a1, 0x40001000	# LED base address

	li t1, 1
	sw t1, 0x10(a1)		# LEDRG

	li t2, 0x3ff
	sw t2, 0x20(a1)		# LEDR

	li t3, 0x4f5b063f
	sw t3, 0x00(a1)		# HEX = '3210'

	#li t0, 0x55
	lw t0, 0x10(a0)		# SW
	xor t2, t2, t0
	sw t2, 0x20(a1)		# LEDR ^= KEY
1:	j 1b



.section ".tdata.begin"
.globl _tdata_begin
_tdata_begin:

.section ".tdata.end"
.globl _tdata_end
_tdata_end:

.section ".tbss.end"
.globl _tbss_end
_tbss_end:
