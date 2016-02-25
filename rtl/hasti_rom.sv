/* HASTI ROM */

module hasti_rom
  (input wire          hclk,
   input wire          hresetn,
   if_hasti_slave_io.n bus);

   import pk_hasti::*;

   logic [31:0] q;
   logic        trans_valid;

   rom1kx32 rom
     (.address(bus.haddr[11:2]),
      .clock(hclk),
      .q);

   always_ff @(posedge hclk)
     if (trans_valid)
       bus.hrdata <= q;

   assign bus.hreadyout = 1'b1;
   assign bus.hresp     = OKAY;

   /* control */
   assign trans_valid = (bus.hsel && bus.hready && (bus.htrans == NONSEQ || bus.htrans == SEQ));
endmodule
