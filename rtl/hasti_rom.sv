/* HASTI ROM */

module hasti_rom
  (input wire          hclk,
   if_hasti_slave_io.n bus);

   import pk_hasti::*;

   rom1kx32 rom
     (.address(bus.haddr[11:2]),
      .clock(hclk),
      .q(bus.hrdata));

   assign bus.hreadyout = 1'b1;
   assign bus.hresp     = OKAY;
endmodule
