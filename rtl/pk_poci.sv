/* POCI type definitions */

package pk_poci;
   parameter
     data_width = 32,
     addr_width = 32;

   parameter bit [addr_width - 1:0] addr_key  = 32'h40000000,
				    addr_sw   = 32'h40000010,
				    addr_hex  = 32'h40001000,
				    addr_ledg = 32'h40001010,
				    addr_ledr = 32'h40001020;
endpackage
