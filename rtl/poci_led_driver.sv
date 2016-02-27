/* LED driver with POCI interface */

module poci_led_driver
  (input wire              pclk,
   input wire              presetn,
   if_poci.f               bus,
   output logic [3:0][6:0] hex,   // 7-segment display
   output logic [7:0]      ledg,  // LED green
   output logic [9:0]      ledr); // LED red

   import pk_poci::*;

   logic read_en;
   logic write_en;

   enum integer unsigned {SEL_HEX, SEL_LEDG, SEL_LEDR, NOSEL} sel;

   assign bus.pready  = 1'b1;
   assign bus.pslverr = 1'b0;

   assign read_en  = bus.psel & ~bus.pwrite;                // assert for whole read transfer
   assign write_en = bus.psel &  bus.pwrite & ~bus.penable; // assert for 1st cycle of write transfer

   /* decoder */
   always_comb
     if (bus.paddr[11:0] == addr_hex[11:0])
       sel = SEL_HEX;
     else if (bus.paddr[11:0] == addr_ledg[11:0])
       sel = SEL_LEDG;
     else if (bus.paddr[11:0] == addr_ledr[11:0])
       sel = SEL_LEDR;
     else
       sel = NOSEL;

   /* multiplexor */
   always_comb
     if(read_en)
       case (sel)
	 SEL_HEX:
	   begin
	      bus.prdata[ 7-:8] = {1'b0, ~hex[0]};
	      bus.prdata[15-:8] = {1'b0, ~hex[1]};
	      bus.prdata[23-:8] = {1'b0, ~hex[2]};
	      bus.prdata[31-:8] = {1'b0, ~hex[3]};
	   end

	 SEL_LEDG: bus.prdata = {24'b0, ledg};

	 SEL_LEDR: bus.prdata = {22'b0, ledr};

	 default   bus.prdata = 'x;
       endcase
     else
       bus.prdata = 'x;

   /* 7 segment display has inverted inputs */
   always_ff @(posedge pclk)
     if (!presetn)
       hex <= '1;
     else if (write_en && sel == SEL_HEX)
       begin
	  hex[0] <= ~bus.pwdata[ 6-:7];
	  hex[1] <= ~bus.pwdata[14-:7];
	  hex[2] <= ~bus.pwdata[22-:7];
	  hex[3] <= ~bus.pwdata[30-:7];
       end

   always_ff @(posedge pclk)
     if (!presetn)
       ledg <= '0;
     else if (write_en && sel == SEL_LEDG)
       ledg <= bus.pwdata[7:0];

   always_ff @(posedge pclk)
     if (!presetn)
       ledr <= '0;
     else if (write_en && sel == SEL_LEDR)
       ledr <= bus.pwdata[9:0];
endmodule
