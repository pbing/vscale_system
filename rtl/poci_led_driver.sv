/* LED driver with POCI interface */

module poci_led_driver
  (input wire              pclk,
   input wire              presetn,
   if_poci.f               bus,

   output logic [3:0][6:0] hex,   // 7-segment display
   output logic [7:0]      ledg,  // LED green
   output logic [9:0]      ledr); // LED red

   logic read_en;
   logic write_en;
   logic sel_hex, sel_ledg, sel_ledr;

   assign bus.pready  = 1'b1;
   assign bus.pslverr = 1'b0;

   assign read_en  = bus.psel & ~bus.pwrite;                // assert for whole read transfer
   assign write_en = bus.psel &  bus.pwrite & ~bus.penable; // assert for 1st cycle of write transfer

   assign sel_hex  = (bus.paddr[11:0] >= 12'h000 && bus.paddr[11:0] <= 12'h010);
   assign sel_ledg = (bus.paddr[11:0] >= 12'h010 && bus.paddr[11:0] <= 12'h020);
   assign sel_ledr = (bus.paddr[11:0] >= 12'h020 && bus.paddr[11:0] <= 12'h030);

   /* multiplexor */
   always_comb
     if(read_en)
       unique case (1'b1)
	 sel_hex:
	   begin
	      bus.prdata[ 7-:8] = {1'b0, hex[0]};
	      bus.prdata[15-:8] = {1'b0, hex[1]};
	      bus.prdata[23-:8] = {1'b0, hex[2]};
	      bus.prdata[31-:8] = {1'b0, hex[3]};
	   end

	 sel_ledg: bus.prdata = {24'b0, ledg};

	 sel_ledr: bus.prdata = {22'b0, ledg};

	 default bus.prdata = 'x;
       endcase
     else
       bus.prdata = 'x;

   /* 7 segment display has inverted inputs */
   always_ff @(posedge pclk)
     if (!presetn)
       hex <= '1;
     else if (write_en && sel_hex)
       begin
	  hex[0] <= ~bus.pwdata[ 6-:7];
	  hex[1] <= ~bus.pwdata[14-:7];
	  hex[2] <= ~bus.pwdata[22-:7];
	  hex[3] <= ~bus.pwdata[30-:7];
       end

   always_ff @(posedge pclk)
     if (!presetn)
       ledg <= '0;
     else if (write_en && sel_ledg)
       ledg <= ~bus.pwdata[7:0];

   always_ff @(posedge pclk)
     if (!presetn)
       ledr <= '0;
     else if (write_en && sel_ledr)
       ledr <= ~bus.pwdata[9:0];
endmodule
