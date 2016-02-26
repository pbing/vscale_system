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
1:	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	j 1b

.section ".tdata.begin"
.globl _tdata_begin
_tdata_begin:

.section ".tdata.end"
.globl _tdata_end
_tdata_end:

.section ".tbss.end"
.globl _tbss_end
_tbss_end:
