/* Testbench hasti_slave_mux */

module tb_hasti_slave_mux;
   timeunit 1ns;
   timeprecision 1ps;

   const realtime thclk = 1s / 20.0e6;

   import pk_hasti::*;

   bit hclk;
   bit hresetn;

   if_hasti_slave_io m0s();  // master0 -- slave
   if_hasti_slave_io m1s();  // master1 -- slave
   if_hasti_slave_io hbus(); // slave out

   hasti_slave_mux dut
     (.hclk,
      .hresetn,
      .in0(m0s),
      .in1(m1s),
      .out(hbus));

   tb_master master_0
     (.hclk,
      .hresetn,
      .s(m0s));

   tb_master master_1
     (.hclk,
      .hresetn,
      .s(m1s));

   tb_slave slave
     (.hclk,
      .hresetn,
      .m(hbus));

   always #(0.5 * thclk) hclk = ~hclk;

   initial
     begin:main
        $timeformat(-9, 3, " ns");

	repeat (2) @(negedge hclk);
	hresetn = 1'b1;
        #2us $stop;
     end:main
endmodule

module tb_master
  (input wire          hclk,
   input wire          hresetn,
   if_hasti_slave_io.f s);

   import pk_hasti::*;

   bit hsel_r, hwrite_r;

   always @(posedge hclk)
     if (!hresetn)
       begin
          hsel_r   <= 1'b0;
          hwrite_r <= 1'b0;
       end
     else
       if (s.hreadyout)
         begin
            hsel_r   <= s.hsel;
            hwrite_r <= s.hwrite;
         end

   always @(posedge hclk)
     if (!hresetn)
       begin
          s.haddr     <= '0;
          s.hwrite    <= 1'b0;
          s.hsize     <= WORD;
          s.hburst    <= SINGLE;
          s.hprot     <= '0;
          s.htrans    <= IDLE;
          s.hmastlock <= 1'b0;
          s.hwdata    <= '0;
          s.hsel      <= 1'b0;
       end
     else
       begin
          repeat ({$random} % 5) @(posedge hclk);
          s.haddr  <= {$random} & -4;
          s.hwrite <= $random;
          s.htrans <= NONSEQ;
          s.hsel   <= 1'b1;

          @(posedge hclk);
          s.haddr  <= '0;
          s.hwrite <= 1'b0;
          s.htrans <= IDLE;
          s.hsel   <= 1'b0;
          if (s.hwrite)
            begin
               bit [31:0] hwdata;

               hwdata = $random;
               $display("%t %M.hwdata = %h", $realtime, hwdata);
               s.hwdata <= hwdata;
            end

          do @(posedge hclk); while (!s.hreadyout);
          if (hsel_r && !hwrite_r && s.hreadyout)
            $display("%t %M.hrdata = %h", $realtime, s.hrdata);
       end

   assign s.hready = s.hreadyout;
endmodule

module tb_slave
  (input wire          hclk,
   input wire          hresetn,
   if_hasti_slave_io.n m);

   import pk_hasti::*;

   wire hasti_access = (m.htrans == NONSEQ || m.htrans == SEQ) & m.hsel & m.hready;
   wire hasti_write  = hasti_access &   m.hwrite;
   wire hasti_read   = hasti_access & (~m.hwrite);

   always_ff @(posedge hclk)
     if (!hresetn)
       m.hrdata <= '0;
     else 
       if (hasti_read)
         m.hrdata <= $random;
       else
         m.hrdata <= '0;

   assign m.hresp     = OKAY;
   assign m.hreadyout = 1'b1;
endmodule
