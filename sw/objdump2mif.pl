# OBJDUMP to MIF
use warnings;
use strict;

my $addr;
my $code;

print <<EOL;
-- Quartus II generated Memory Initialization File (.mif)
WIDTH=32;
DEPTH=1024;
ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT BEGIN
EOL

while (<>) {
    if (m/([[:xdigit:]]+):\s+([[:xdigit:]]+)\s+/) {
	($addr, $code) =  ($1, $2);

	printf("%08x: %s;\n", hex($addr) / 4, $code);
    }
}

print "END;\n"
