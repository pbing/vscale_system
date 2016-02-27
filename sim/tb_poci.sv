/* Testbench POCI modules */

module tb_poci;
   timeunit 1ns;
   timeprecision 1ps;

   const realtime tpclk = 1s / 24.0e6;
   
   import pk_poci::*;

   bit        pclk;
   bit        presetn;

   /* I/O */
   bit  [3:0] KEY;			// Pushbutton[3:0]
   bit  [9:0] SW;			// Toggle Switch[9:0]
   wire [6:0] HEX0, HEX1, HEX2, HEX3;	// Seven Segment Digit 0..3
   wire [7:0] LEDG;			// LED Green[7:0]
   wire [9:0] LEDR;			// LED Red[9:0]

   /* testbench signals */
   logic [data_width - 1:0] pwdata;

   if_poci pbus();
   if_poci pbus_s0();
   if_poci pbus_s1();

   poci_bus poci_bus
     (.pclk,
      .presetn,
      .m(pbus),
      .s0(pbus_s0),
      .s1(pbus_s1));

   poci_keys poci_keys
     (.pclk    (pclk),
      .presetn (presetn),
      .bus     (pbus_s0),
      .key     (KEY),
      .sw      (SW));

   poci_led_driver poci_led_driver
     (.pclk    (pclk),
      .presetn (presetn),
      .bus     (pbus_s1),
      .hex     ({HEX3, HEX2, HEX1, HEX0}),
      .ledg    (LEDG),
      .ledr    (LEDR));

   always #(0.5 * tpclk) pclk = ~pclk;

   initial
     begin:main
	pbus.paddr   = '0;
	pbus.pwrite  = 1'b0;
	pbus.psel    = 1'b0;
	pbus.penable = 1'b0;
	pbus.pwdata  = '0;

	repeat (2) @(negedge pclk);
	presetn = 1'b1;

	#100ns;
	pwdata = $random;
	pwrite(addr_hex, pwdata);
	chk1a: assert (HEX0 == ~pwdata[6-:7]);
	chk1b: assert (HEX1 == ~pwdata[14-:7]);
	chk1c: assert (HEX2 == ~pwdata[22-:7]);
	chk1d: assert (HEX3 == ~pwdata[30-:7]);

	pwdata = $random;
	pwrite(addr_ledg, pwdata);
	chk2: assert (LEDG == pwdata[7:0]) else $error("LEDG = %h (exp. %h)", LEDG, pwdata[7:0]);;

	pwdata = $random;
	pwrite(addr_ledr, pwdata);
	chk3: assert (LEDR == pwdata[9:0]) else $error("LEDR = %h (exp. %h)", LEDR, pwdata[9:0]);

	#100ns;
	pread(addr_hex, {1'b0, ~HEX3, 1'b0, ~HEX2, 1'b0, ~HEX1, 1'b0, ~HEX0});

	pread(addr_ledg, {24'b0, LEDG});

	pread(addr_ledr, {22'b0, LEDR});

	#100ns $stop;
     end:main

   /************************************************************
    * Tasks
    ************************************************************/

   task pwrite
     (input [addr_width - 1:0] addr,
      input [data_width - 1:0] wdata);

      @(posedge pclk);
      pbus.paddr  <= addr;
      pbus.pwdata <= wdata;
      pbus.pwrite <= 1'b1;
      pbus.psel   <= (addr >= 32'h40000000);

      @(posedge pclk);
      pbus.penable <= 1'b1;

      @(posedge pclk);
      pbus.psel <= 1'b0;
      pbus.penable <= 1'b0;
   endtask 

   task pread
     (input [addr_width - 1:0] addr,
      input [data_width - 1:0] rdata);

      @(posedge pclk);
      pbus.paddr  <= addr;
      pbus.pwdata <= $random;
      pbus.pwrite <= 1'b0;
      pbus.psel   <= (addr >= 32'h40000000);

      @(posedge pclk);
      pbus.penable <= 1'b1;
      #(0.9 * tpclk);
      chk: assert (pbus.prdata == rdata) else $error("PRDATA = %h (exp. %h)", pbus.prdata, rdata);

      @(posedge pclk);
      pbus.psel <= 1'b0;
      pbus.penable <= 1'b0;
   endtask 
endmodule
