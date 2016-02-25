/* HASTI bus module */

module hasti_bus
  (input wire           hclk,
   input wire           hresetn,
   if_hasti_master_io.f m,
   if_hasti_slave_io.f  s0, s1);

   import pk_hasti::*;

   logic       hready;
   logic [1:0] hsel_r;

   /* decoder */
   assign s0.hsel = (m.haddr >= 32'h00000000 && m.haddr <= 32'h000003ff); // ROM
   assign s1.hsel = (m.haddr >= 32'h20000000 && m.haddr <= 32'h200003ff); // SRAM

   /* HREADY */
   assign m.hready  = hready;
   assign s0.hready = hready;
   assign s1.hready = hready;

   /* bus connections */
   assign s0.haddr	= m.haddr;
   assign s0.hwrite	= m.hwrite;
   assign s0.hsize	= m.hsize;
   assign s0.hburst	= m.hburst;
   assign s0.hprot	= m.hprot;
   assign s0.htrans	= m.htrans;
   assign s0.hmastlock	= m.hmastlock;
   assign s0.hwdata	= m.hwdata;
   assign s1.haddr	= m.haddr;
   assign s1.hwrite	= m.hwrite;
   assign s1.hsize	= m.hsize;
   assign s1.hburst	= m.hburst;
   assign s1.hprot	= m.hprot;
   assign s1.htrans	= m.htrans;
   assign s1.hmastlock	= m.hmastlock;
   assign s1.hwdata	= m.hwdata;

   /* multiplexor */
   always_comb
     case(1'b1)
       hsel_r[0]:
	 begin
	    m.hrdata = s0.hrdata;
	    m.hresp  = s0.hresp;
	    hready   = s0.hreadyout;
	 end

       hsel_r[1]:
	 begin
	    m.hrdata = s1.hrdata;
	    m.hresp  = s1.hresp;
	    hready   = s1.hreadyout;
	 end

       /* default slave */
       default
	 begin
	    m.hrdata = 'x;
	    m.hresp  = (m.htrans == NONSEQ || m.htrans == SEQ) ? ERROR : OKAY;
	    hready   = 1'b1;
	 end
     endcase

   /* registered mux control */
   always_ff @(posedge hclk)
     if (!hresetn)
       hsel_r <= '0;
     else
       hsel_r <= {s0.hsel, s1.hsel};
endmodule
