/* Keys and switches with POCI interfaces */

module poci_keys
  (input wire       pclk,
   input wire       presetn,
   if_poci.f        bus,
   input wire [3:0] key,
   input wire [9:0] sw);

   import pk_poci::*;

   logic read_en;
   
   enum int unsigned {SEL_KEY, SEL_SW, SEL_NONE} sel;

   assign bus.pready  = 1'b1;
   assign bus.pslverr = 1'b0;

   assign read_en = bus.psel & ~bus.pwrite; // assert for whole read transfer

   /* decoder */
   always_comb
     if (bus.paddr[11:0] == addr_key[11:0])
       sel = SEL_KEY;
     else if (bus.paddr[11:0] == addr_sw[11:0])
       sel = SEL_SW;
     else
       sel = SEL_NONE;

   /* multiplexor */
   always_comb
     if(read_en)
       case (sel)
	 SEL_KEY: bus.prdata = {28'b0, key};
	 SEL_SW:  bus.prdata = {22'b0, sw};
	 default  bus.prdata = 'x;
       endcase
     else
       bus.prdata = 'x;
endmodule
