/* HASTI master to slaves multiplexor. */

module hasti_slave_mux
  (input wire          hclk,
   input wire          hresetn,
   if_hasti_slave_io.n in0, in1, // from masters
   if_hasti_slave_io.f out);     // to slave

   import pk_hasti::*;

   localparam nmasters = 2;

   logic [addr_width - 1:0] skb_haddr[nmasters];
   logic [0:nmasters - 1]   skb_hwrite;
   hsize_t                  skb_hsize[nmasters];
   hburst_t                 skb_hburst[nmasters];
   logic [3:0]              skb_hprot[nmasters];
   htrans_t                 skb_htrans[nmasters];
   logic [0:nmasters - 1]   skb_hmastlock;

   wire  [0:nmasters - 1]   request;
   wire  [0:nmasters - 1]   valid;
   logic [0:nmasters - 1]   skb_valid;

   enum int unsigned {GNT[2], NO_GNT} gnt_addr_phase, gnt_data_phase;

   /****************************************************************
    * PORT 0
    ****************************************************************/

   /* skid buffers */
   always_ff @(posedge hclk)
     if (!hresetn)
       begin
          skb_haddr[0]     <= '0;
          skb_hwrite[0]    <= 1'b0;
          skb_hsize[0]     <= BYTE;
          skb_hburst[0]    <= SINGLE;
          skb_hprot[0]     <= '0;
          skb_htrans[0]    <= IDLE;
          skb_hmastlock[0] <= 1'b0;
       end
     else
       if (valid[0])
         begin
            skb_haddr[0]     <= in0.haddr;
            skb_hwrite[0]    <= in0.hwrite;
            skb_hsize[0]     <= in0.hsize;
            skb_hburst[0]    <= in0.hburst;
            skb_hprot[0]     <= in0.hprot;
            skb_htrans[0]    <= in0.htrans;
            skb_hmastlock[0] <= in0.hmastlock;
         end

   assign in0.hrdata = out.hrdata;

   always_comb
     if (!skb_valid[0] || gnt_data_phase == GNT0)
       in0.hreadyout = out.hreadyout;
     else if (skb_valid[0])
       in0.hreadyout = 1'b0;
     else
       in0.hreadyout = 1'b1;

   assign in0.hresp = (gnt_data_phase == GNT0) ? out.hresp : OKAY;

   /****************************************************************
    * PORT 1
    ****************************************************************/

   /* skid buffers */
   always_ff @(posedge hclk)
     if (!hresetn)
       begin
          skb_haddr[1]     <= '0;
          skb_hwrite[1]    <= 1'b0;
          skb_hsize[1]     <= BYTE;
          skb_hburst[1]    <= SINGLE;
          skb_hprot[1]     <= '0;
          skb_htrans[1]    <= IDLE;
          skb_hmastlock[1] <= 1'b0;
       end
     else
       if (valid[1])
         begin
            skb_haddr[1]     <= in1.haddr;
            skb_hwrite[1]    <= in1.hwrite;
            skb_hsize[1]     <= in1.hsize;
            skb_hburst[1]    <= in1.hburst;
            skb_hprot[1]     <= in1.hprot;
            skb_htrans[1]    <= in1.htrans;
            skb_hmastlock[1] <= in1.hmastlock;
         end

   assign in1.hrdata = out.hrdata;

   always_comb
     if (!skb_valid[1] || gnt_data_phase == GNT1)
       in1.hreadyout = out.hreadyout;
     else if (skb_valid[1])
       in1.hreadyout = 1'b0;
     else
       in1.hreadyout = 1'b1;

   assign in1.hresp = (gnt_data_phase == GNT1) ? out.hresp : OKAY;

   /****************************************************************
    * output multiplexor signals
    ****************************************************************/

   /* multiplexor address phase */
   always_comb
     case (gnt_addr_phase)
       GNT0:
         begin
            out.haddr     = skb_valid[0] ? skb_haddr[0]     : in0.haddr;
            out.hwrite    = skb_valid[0] ? skb_hwrite[0]    : in0.hwrite;
            out.hsize     = skb_valid[0] ? skb_hsize[0]     : in0.hsize;
            out.hburst    = skb_valid[0] ? skb_hburst[0]    : in0.hburst;
            out.hprot     = skb_valid[0] ? skb_hprot[0]     : in0.hprot;
            out.htrans    = skb_valid[0] ? skb_htrans[0]    : in0.htrans;
            out.hmastlock = skb_valid[0] ? skb_hmastlock[0] : in0.hmastlock;
         end

       GNT1:
         begin
            out.haddr     = skb_valid[1] ? skb_haddr[1]     : in1.haddr;
            out.hwrite    = skb_valid[1] ? skb_hwrite[1]    : in1.hwrite;
            out.hsize     = skb_valid[1] ? skb_hsize[1]     : in1.hsize;
            out.hburst    = skb_valid[1] ? skb_hburst[1]    : in1.hburst;
            out.hprot     = skb_valid[1] ? skb_hprot[1]     : in1.hprot;
            out.htrans    = skb_valid[1] ? skb_htrans[1]    : in1.htrans;
            out.hmastlock = skb_valid[1] ? skb_hmastlock[1] : in1.hmastlock;
         end

       default
         begin
            out.haddr     = '0;
            out.hwrite    = 1'b0;
            out.hsize     = BYTE;
            out.hburst    = SINGLE;
            out.hprot     = '0;
            out.htrans    = IDLE;
            out.hmastlock = 1'b0;
         end
     endcase

   /* multiplexor data phase */
   always_comb
     case (gnt_data_phase)
       GNT0:   out.hwdata = in0.hwdata;
       GNT1:   out.hwdata = in1.hwdata;
       default out.hwdata = '0;
     endcase

   assign out.hready = out.hreadyout;
   assign out.hsel   = (gnt_addr_phase != NO_GNT);

   /****************************************************************
    * Control
    ****************************************************************/

   assign valid[0] = in0.hsel && in0.hready && (in0.htrans == NONSEQ || in0.htrans == SEQ);
   assign valid[1] = in1.hsel && in1.hready && (in1.htrans == NONSEQ || in1.htrans == SEQ);

   always_ff @(posedge hclk)
     if (!hresetn)
       skb_valid[0] <= 1'b0;
     else
       if (gnt_addr_phase == GNT0)
         skb_valid[0] <= 1'b0;
       else if (!skb_valid[0])
         skb_valid[0] <= valid[0];

   always_ff @(posedge hclk)
     if (!hresetn)
       skb_valid[1] <= 1'b0;
     else
       if (gnt_addr_phase == GNT1)
         skb_valid[1] <= 1'b0;
       else if (!skb_valid[1])
         skb_valid[1] <= valid[1];

   assign request[0] = valid[0] | skb_valid[0];
   assign request[1] = valid[1] | skb_valid[1];

   /* port #0 has highest priority */
   always_comb
     if (request[0])
       gnt_addr_phase = GNT0;
     else if (request[1])
       gnt_addr_phase = GNT1;
     else
       gnt_addr_phase = NO_GNT;

   always_ff @(posedge hclk)
     if (!hresetn)
       gnt_data_phase <= NO_GNT;
     else if (out.hreadyout)
       gnt_data_phase <= gnt_addr_phase;

   /****************************************************************
    * DEBUG
    ****************************************************************/

`ifndef SYNTHESIS
   always @(posedge hclk)
     if (hresetn)
       assert (!(request[0] && request[1])) else $info("Concurrent transaction.");
`endif
endmodule
