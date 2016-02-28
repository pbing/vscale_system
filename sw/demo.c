#define REG32(x)    (*(unsigned int volatile *)(x))                                                                                     

#define LEDR 0x40001020

void main(void) {
  REG32(LEDR) = 0x155;
  for (;;);
}
