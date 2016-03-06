/* HASTI bus module */

module hasti_bus
  (input wire           hclk,
   input wire           hresetn,
   if_hasti_master_io.f m,
   if_hasti_slave_io.f  s0, s1, s2);

   import pk_hasti::*;

   enum int unsigned {SEL_ROM, SEL_RAM, SEL_IO, SEL_NONE} sel, sel_r;

   logic hready;

   /* default slave */
   logic   ds_hready;
   hresp_t ds_hresp;

   /*
    * decoder
    *
    * ROM   0x00000000...0x00000fff
    * SRAM  0x20000000...0x20000fff
    * I/O   0x80000000...0xffffffff
    */
   always_comb
     casez (m.haddr)
       32'h00000???                        : sel = SEL_ROM;
       32'h20000???                        : sel = SEL_RAM;
       32'b1???????????????????????????????: sel = SEL_IO;
       default                               sel = SEL_NONE;
     endcase

   /* HSEL */
   assign s0.hsel = (sel == SEL_ROM);
   assign s1.hsel = (sel == SEL_RAM);
   assign s2.hsel = (sel == SEL_IO);

   /* HREADY */
   assign m.hready  = hready;
   assign s0.hready = hready;
   assign s1.hready = hready;
   assign s2.hready = hready;

   /* remaining bus connections */
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
     case (sel_r)
       SEL_ROM:
	 begin
	    m.hrdata = s0.hrdata;
	    m.hresp  = s0.hresp;
	    hready   = s0.hreadyout;
	 end

       SEL_RAM:
	 begin
	    m.hrdata = s1.hrdata;
	    m.hresp  = s1.hresp;
	    hready   = s1.hreadyout;
	 end

       SEL_IO:
	 begin
	    m.hrdata = s2.hrdata;
	    m.hresp  = s2.hresp;
	    hready   = s2.hreadyout;
	 end

       /* default slave */
       default
	 begin
	    m.hrdata = 'x;
            m.hresp  = ds_hresp;
	    hready   = ds_hready;
	 end
     endcase

   /* registered mux control */
   always_ff @(posedge hclk)
     if (!hresetn)
       sel_r <= SEL_NONE;
     else
       /* advance pipeline */
       if (hready)
         sel_r <= sel;



   /* default slave */

   enum int unsigned {DS_IDLE, DS_RESP[2]} ds_state, ds_next;

   wire trans_req = (sel == SEL_NONE) && (m.htrans == NONSEQ || m.htrans == SEQ) && m.hready;

   always_ff @(posedge hclk)
     if (!hresetn)
       ds_state <= DS_IDLE;
     else
       ds_state <= ds_next;

   always_comb
     begin
        ds_next = ds_state;

        case (ds_state)
          DS_IDLE:
            begin
               ds_hresp  = OKAY;
               ds_hready = 1'b1;

               if (trans_req)
                 ds_next = DS_RESP0;
            end

          DS_RESP0:
            begin
               ds_hresp  = ERROR;
               ds_hready = 1'b0;

               if (!trans_req)
                 ds_next = DS_RESP1;
            end

          DS_RESP1:
            begin
               ds_hresp  = ERROR;
               ds_hready = 1'b1;

               if (!trans_req)
                 ds_next = DS_IDLE;
            end
        endcase
     end
endmodule
