# Generate memory image from assembly file

RISCV_PREFIX=riscv64-unknown-elf-
RISCV_GCC = $(RISCV_PREFIX)gcc -m32 -march=RV32IM
RISCV_GCC_OPTS = -O2 -static
RISCV_LINK = $(RISCV_GCC) -T vscale.ld
RISCV_LINK_OPTS = -nostdlib -nostartfiles
RISCV_OBJDUMP = $(RISCV_PREFIX)objdump

.PHONY: copy clean

copy: leds.mif
	cp $< ../sim/rom.mif
	cp $< ../syn/rom.mif

%.mif: %.dump
	perl objdump2mif.pl $< > $@

%.dump: %.elf
	$(RISCV_OBJDUMP) -d $< > $@

%.elf: %.o crt.o
	$(RISCV_LINK) $^ -o $@ $(RISCV_LINK_OPTS)

%.o: %.c
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

clean:
	rm -f *.o *.elf *.dump *.mif
