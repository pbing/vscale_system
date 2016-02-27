/* HASTI type definitions */

package pk_hasti;
   parameter
     data_width = 32,
     addr_width = 32;

   parameter bit [addr_width - 1:0] addr_rom = 32'h00000000, size_rom = 32'd1024,
				    addr_ram = 32'h20000000, size_ram = 32'd1024;

   typedef enum logic [1:0] {IDLE,
			     BUSY,
			     NONSEQ,
			     SEQ} htrans_t;

   typedef enum logic [2:0] {SINGLE,
			     INCR,
			     WRAP4,
			     INCR4,
			     WRAP8,
			     INCR8,
			     WRAP16,
			     INCR16} hburst_t;

   typedef enum logic       {OKAY,
			     ERROR} hresp_t;

   typedef enum logic [2:0] {BYTE,
			     HALFWORD,
			     WORD,
			     DWORD} hsize_t;
endpackage
