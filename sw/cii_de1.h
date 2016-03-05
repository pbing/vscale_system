/* Altera DE1 Development and Education board */

#ifndef __CII_DE1_H__

#include <stdint.h>

#define REG8(x)  (*(uint8_t  volatile *)(x))                                                                                     
#define REG16(x) (*(uint16_t volatile *)(x))                                                                                     
#define REG32(x) (*(uint32_t volatile *)(x))                                                                                     

/* LEDs */
#define HEX  0x80000000
#define LEDG 0x80000010
#define LEDR 0x80000020

/* keys and switches */
#define KEY  0x80001000
#define SW   0x80001010

#endif
