/* ----------------------------------------------------------------------
 *      gcc(ld) linker script for Triton
 * ---------------------------------------------------------------------- */
ENTRY(_start)


/* ----------------------------------------------------------------------
 *      memory definitions for Triton
 * ---------------------------------------------------------------------- */

MEMORY
{
   ram (rwx) : ORIGIN = 0x20000000, LENGTH = 0x400
   rom (rwx) : ORIGIN = 0x00000000, LENGTH = 0x400
}


SECTIONS
{
  .text  :     
  {
    crt.o(.text)
    *.o(.text .rodata)
  } >rom 

  .data :
  {
   *.o(.data .bss COMMON)
   } > ram

 }





