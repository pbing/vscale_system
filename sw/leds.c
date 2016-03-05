/* Simple demo with LEDs and SW */

#include "cii_de1.h"

/*
static char
table_hexdisplay [] = {0x3f,  // 0
		       0x06,  // 1
		       0x5b,  // 2
		       0x4f,  // 3
		       0x66,  // 4
		       0x6d,  // 5
		       0x7d,  // 6
		       0x07,  // 7
		       0x7f,  // 8
		       0x6f,  // 9
		       0x77,  // A
		       0x7c,  // b
		       0x39,  // C
		       0x5e,  // d
		       0x79,  // E
		       0x71}; // F
*/
	 
void main(void) {

  REG32(HEX) = 0x3f3f3f06; // version 0001

  REG32(LEDG) = 0xa5;		

   while (1) { 
     REG32(LEDR) = REG32(SW);
   } 
}
