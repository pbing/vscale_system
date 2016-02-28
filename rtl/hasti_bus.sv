/* HASTI bus module */

module hasti_bus
  (input wire           hclk,
   input wire           hresetn,
   if_hasti_master_io.f m,
   if_hasti_slave_io.f  s0, s1, s2);

   import pk_hasti::*;

   logic       hready;
   logic [2:0] hsel_r;

   /* decoder */
   assign s0.hsel = (m.haddr >= addr_rom && m.haddr < (addr_rom + size_rom)); // ROM
   assign s1.hsel = (m.haddr >= addr_ram && m.haddr < (addr_ram + size_ram)); // SRAM
   assign s2.hsel = (m.haddr[31:30] != 2'b00);                                // I/O

   /* HREADY */
   assign m.hready  = hready;
   assign s0.hready = hready;
   assign s1.hready = hready;
   assign s2.hready = hready;

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

   assign s2.haddr	= m.haddr;
   assign s2.hwrite	= m.hwrite;
   assign s2.hsize	= m.hsize;
   assign s2.hburst	= m.hburst;
   assign s2.hprot	= m.hprot;
   assign s2.htrans	= m.htrans;
   assign s2.hmastlock	= m.hmastlock;
   assign s2.hwdata	= m.hwdata;

   /* multiplexor */
   always_comb
     unique case (1'b1)
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

       hsel_r[2]:
	 begin
	    m.hrdata = s2.hrdata;
	    m.hresp  = s2.hresp;
	    hready   = s2.hreadyout;
	 end

       /* default slave */
       default
	 begin
	    m.hrdata = 'x;
	    m.hresp  = (m.htrans[1]) ? ERROR : OKAY;
	    hready   = 1'b1;
	 end
     endcase

   /* registered mux control */
   always_ff @(posedge hclk)
     if (!hresetn)
       hsel_r <= '0;
     else
       hsel_r <= {s2.hsel, s1.hsel, s0.hsel};
endmodule
