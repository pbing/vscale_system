/* HASTI master to slaves multiplexor. */

module hasti_slave_mux
   (input wire          hclk,
    input wire          hresetn,
    if_hasti_slave_io.n in0, in1, // from differen masters
    if_hasti_slave_io.f out);     // to slave

   import pk_hasti::*;

   // FIXME
   assign out.haddr	= in0.haddr;
   assign out.hwrite	= in0.hwrite;
   assign out.hsize	= in0.hsize;
   assign out.hburst	= in0.hburst;
   assign out.hprot	= in0.hprot;
   assign out.htrans	= in0.htrans;
   assign out.hmastlock = in0.hmastlock;
   assign out.hwdata	= in0.hwdata;
   assign in0.hrdata	= out.hrdata;
   assign out.hsel	= in0.hsel;
   assign out.hready	= in0.hready;
   assign in0.hreadyout = out.hreadyout;
   assign in0.hresp	= out.hresp;

   assign in1.hrdata	= '0;
   assign in1.hreadyout = 1'b1;
   assign in1.hresp	= OKAY;

endmodule
