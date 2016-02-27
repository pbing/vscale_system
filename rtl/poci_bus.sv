/* POCI bus module */

module poci_bus
  (input wire pclk,
   input wire presetn,
   if_poci.f  m,
   if_poci.n  s0, s1);

   import pk_poci::*;

   /* decoder */
   assign s0.psel = (m.psel && m.paddr[31:12] == base_keys[31:12]);       // switches and keys
   assign s1.psel = (m.psel && m.paddr[31:12] == base_led_driver[31:12]); // LED displays

   /* bus connections */
   assign s0.paddr   = m.paddr;
   assign s0.penable = m.penable;
   assign s0.pwrite  = m.pwrite;
   assign s0.pwdata  = m.pwdata;

   assign s1.paddr   = m.paddr;
   assign s1.penable = m.penable;
   assign s1.pwrite  = m.pwrite;
   assign s1.pwdata  = m.pwdata;

   /* multiplexor */
   always_comb
     case (1'b1)
       s0.psel:
	 begin
	    m.prdata  = s0.prdata;
	    m.pready  = s0.pready;
	    m.pslverr = s0.pslverr;
	 end

       s1.psel:
	 begin
	    m.prdata  = s1.prdata;
	    m.pready  = s1.pready;
	    m.pslverr = s1.pslverr;
	 end

       default
	 begin
	    m.prdata  = 'x;
	    m.pready  = ~m.psel;
	    m.pslverr = 1'b0;
	 end
     endcase
endmodule
