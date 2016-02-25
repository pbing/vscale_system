/* HASTI master to slaves multiplexor. */

module hasti_slave_mux
   (input wire          hclk,
    input wire          hresetn,
    if_hasti_slave_io.n in1, in2,
    if_hasti_slave_io.f out);

   import pk_hasti::*;

   // FIXME
   assign out.haddr	= in1.haddr;
   assign out.hwrite	= in1.hwrite;
   assign out.hsize	= in1.hsize;
   assign out.hburst	= in1.hburst;
   assign out.hprot	= in1.hprot;
   assign out.htrans	= in1.htrans;
   assign out.hmastlock = in1.hmastlock;
   assign out.hwdata	= in1.hwdata;
   assign in1.hrdata	= out.hrdata;
   assign out.hsel	= in1.hsel;
   assign out.hready	= in1.hready;
   assign in1.hreadyout = out.hreadyout;
   assign in1.hresp	= out.hresp;

endmodule
