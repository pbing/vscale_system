/* POCI bus module */

module poci_bus
  (input wire pclk,
   input wire presetn,
   if_poci.f  m,
   if_poci.n  s0, s1);

   import pk_poci::*;

   enum integer unsigned {SEL_LEDS, SEL_KEYS, SEL_NONE} sel;

   /* decoder */
   always_comb
     if (m.psel)
       case (m.paddr[31:12])
         base_leds[31:12]: sel = SEL_LEDS;
         base_keys[31:12]: sel = SEL_KEYS;
         default           sel = SEL_NONE;
       endcase
     else
       sel = SEL_NONE;

   /* bus connections */
   assign s0.psel    = (sel == SEL_LEDS);
   assign s0.paddr   = m.paddr;
   assign s0.penable = m.penable;
   assign s0.pwrite  = m.pwrite;
   assign s0.pwdata  = m.pwdata;

   assign s1.psel    = (sel == SEL_KEYS);
   assign s1.paddr   = m.paddr;
   assign s1.penable = m.penable;
   assign s1.pwrite  = m.pwrite;
   assign s1.pwdata  = m.pwdata;

   /* multiplexor */
   always_comb
     case (sel)
       SEL_LEDS:
	 begin
	    m.prdata  = s0.prdata;
	    m.pready  = s0.pready;
	    m.pslverr = s0.pslverr;
	 end

       SEL_KEYS:
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
