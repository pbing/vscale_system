/* FPGA top level
 *
 * KEY[0] external reset
 * 
 * I/O port addresses:
 * HEX  0x40000010
 * LEDG 0x40000020
 * LEDR 0x40000030
 * 
 * KEY  0x40001000
 * SW   0x40001010
 */

`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

module CII_Starter_TOP
  (/* Clock Input */
   input  wire [1:0]  CLOCK_24,    // 24 MHz
   input  wire [1:0]  CLOCK_27,    // 27 MHz
   input  wire        CLOCK_50,    // 50 MHz
   input  wire        EXT_CLOCK,   // External Clock

   /* Push Button */
   input  wire [3:0]  KEY,         // Pushbutton[3:0]

   /* DPDT Switch */
   input wire  [9:0]  SW,          // Toggle Switch[9:0]

   /* 7-SEG Display */
   output wire [6:0]  HEX0,        // Seven Segment Digit 0
   output wire [6:0]  HEX1,        // Seven Segment Digit 1
   output wire [6:0]  HEX2,        // Seven Segment Digit 2
   output wire [6:0]  HEX3,        // Seven Segment Digit 3

   /* LED */
   output wire [7:0]  LEDG,        // LED Green[7:0]
   output wire [9:0]  LEDR,        // LED Red[9:0]

   /* UART */
   output wire        UART_TXD,    // UART Transmitter
   input  wire        UART_RXD,    // UART Receiver

   /* SDRAM Interface */
   inout  wire [15:0] DRAM_DQ,     // SDRAM Data bus 16 Bits
   output wire [11:0] DRAM_ADDR,   // SDRAM Address bus 12 Bits
   output wire        DRAM_LDQM,   // SDRAM Low-byte Data Mask
   output wire        DRAM_UDQM,   // SDRAM High-byte Data Mask
   output wire        DRAM_WE_N,   // SDRAM Write Enable
   output wire        DRAM_CAS_N,  // SDRAM Column Address Strobe
   output wire        DRAM_RAS_N,  // SDRAM Row Address Strobe
   output wire        DRAM_CS_N,   // SDRAM Chip Select
   output wire        DRAM_BA_0,   // SDRAM Bank Address 0
   output wire        DRAM_BA_1,   // SDRAM Bank Address 0
   output wire        DRAM_CLK,    // SDRAM Clock
   output wire        DRAM_CKE,    // SDRAM Clock Enable

   /* Flash Interface */
   inout  wire [7:0]  FL_DQ,       // FLASH Data bus 8 Bits
   output wire [21:0] FL_ADDR,     // FLASH Address bus 22 Bits
   output wire        FL_WE_N,     // FLASH Write Enable
   output wire        FL_RST_N,    // FLASH Reset
   output wire        FL_OE_N,     // FLASH Output Enable
   output wire        FL_CE_N,     // FLASH Chip Enable

   /* SRAMwire  Interface */
   inout  wire [15:0] SRAM_DQ,     // SRAM Data bus 16 Bits
   output wire [17:0] SRAM_ADDR,   // SRAM Address bus 18 Bits
   output wire        SRAM_UB_N,   // SRAM High-byte Data Mask
   output wire        SRAM_LB_N,   // SRAM Low-byte Data Mask
   output wire        SRAM_WE_N,   // SRAM Write Enable
   output wire        SRAM_CE_N,   // SRAM Chip Enable
   output wire        SRAM_OE_N,   // SRAM Output Enable

   /* SD Card Interface */
   inout  wire        SD_DAT,      // SD Card Data
   inout  wire        SD_DAT3,     // SD Card Data 3
   inout  wire        SD_CMD,      // SD Card Command Signal
   output wire        SD_CLK,      // SD Card Clock

   /* I2C */
   inout  wire        I2C_SDAT,    // I2C Data
   output wire        I2C_SCLK,    // I2C Clock

   /* PS2 */
   input  wire        PS2_DAT,     // PS2 Data
   input  wire        PS2_CLK,     // PS2 Clock

   /* USB JTAG link */
   input  wire        TDI,         // CPLD -> FPGA (data in)
   input  wire        TCK,         // CPLD -> FPGA (clk)
   input  wire        TCS,         // CPLD -> FPGA (CS)
   output wire        TDO,         // FPGA -> CPLD (data out)

   /* VGA */
   output wire        VGA_HS,      // VGA H_SYNC
   output wire        VGA_VS,      // VGA V_SYNC
   output wire [3:0]  VGA_R,       // VGA Red[3:0]
   output wire [3:0]  VGA_G,       // VGA Green[3:0]
   output wire [3:0]  VGA_B,       // VGA Blue[3:0]

   /* Audio CODEC */
   inout  wire        AUD_ADCLRCK, // Audio CODEC ADC LR Clock
   input  wire        AUD_ADCDAT,  // Audio CODEC ADC Data
   inout  wire        AUD_DACLRCK, // Audio CODEC DAC LR Clock
   output wire        AUD_DACDAT,  // Audio CODEC DAC Data
   inout  wire        AUD_BCLK,    // Audio CODEC Bit-Stream Clock
   output wire        AUD_XCK,     // Audio CODEC Chip Clock

   /* GPIO */
   inout  wire [35:0] GPIO_0,      // GPIO Connection 0
   inout  wire [35:0] GPIO_1);     // GPIO Connection 1

   /* common signals */
   wire reset;
   wire clk = CLOCK_24[0];

   /* HASTI signals */
   wire hresetn = ~reset;
   wire hclk    = clk;

   /* interfaces */
   if_hasti_master_io imem();
   if_hasti_master_io dmem();
   if_hasti_slave_io  rom_if();
   if_hasti_slave_io  sram_if();
   if_hasti_slave_io  hasti_to_poci_if();
   if_poci            poci_if();
   if_htif            htif();

   assign htif.reset          = reset;
   assign htif.id             = 1'b0;
   assign htif.pcr_req_valid  = 1'b1;
   assign htif.pcr_req_rw     = 1'b0;
   assign htif.pcr_req_addr   = `CSR_ADDR_TO_HOST;
   assign htif.pcr_req_data   = '0;
   assign htif.pcr_resp_ready = 1'b0;

   assign htif.ipi_req_ready  = 1'b0;
   assign htif.ipi_resp_valid = 1'b0;
   assign htif.ipi_resp_data  = 1'b0;

   /* prevent deleting vscale due to optimization */
   assign GPIO_0 = imem.haddr;

   sync_reset sync_reset
     (.clk,
      .key(KEY[0]),
      .reset);

   vscale_core vscale_core
     (.clk,
      .imem_haddr           (imem.haddr),
      .imem_hwrite          (imem.hwrite),
      .imem_hsize           ({imem.hsize}),
      .imem_hburst          ({imem.hburst}),
      .imem_hmastlock       (imem.hmastlock),
      .imem_hprot           (imem.hprot),
      .imem_htrans          ({imem.htrans}),
      .imem_hwdata          (imem.hwdata),
      .imem_hrdata          (imem.hrdata),
      .imem_hready          (imem.hready),
      .imem_hresp           ({imem.hresp}),

      .dmem_haddr           (dmem.haddr),
      .dmem_hwrite          (dmem.hwrite),
      .dmem_hsize           ({dmem.hsize}),
      .dmem_hburst          ({dmem.hburst}),
      .dmem_hmastlock       (dmem.hmastlock),
      .dmem_hprot           (dmem.hprot),
      .dmem_htrans          ({dmem.htrans}),
      .dmem_hwdata          (dmem.hwdata),
      .dmem_hrdata          (dmem.hrdata),
      .dmem_hready          (dmem.hready),
      .dmem_hresp           ({dmem.hresp}),

      .htif_reset           (htif.reset),
      .htif_id              (htif.id),
      .htif_pcr_req_valid   (htif.pcr_req_valid),
      .htif_pcr_req_ready   (htif.pcr_req_ready),
      .htif_pcr_req_rw      (htif.pcr_req_rw),
      .htif_pcr_req_addr    (htif.pcr_req_addr),
      .htif_pcr_req_data    (htif.pcr_req_data),
      .htif_pcr_resp_valid  (htif.pcr_resp_valid),
      .htif_pcr_resp_ready  (htif.pcr_resp_ready),
      .htif_pcr_resp_data   (htif.pcr_resp_data),
      .htif_ipi_req_ready   (htif.ipi_req_ready),
      .htif_ipi_req_valid   (htif.ipi_req_valid),
      .htif_ipi_req_data    (htif.ipi_req_data),
      .htif_ipi_resp_ready  (htif.ipi_resp_ready),
      .htif_ipi_resp_valid  (htif.ipi_resp_valid),
      .htif_ipi_resp_data   (htif.ipi_resp_data),
      .htif_debug_stats_pcr (htif.debug_stats_pcr));

   hasti_xbar hasti_xbar
     (.hclk,
      .hresetn,
      .m0(imem),
      .m1(dmem),
      .s0(rom_if),
      .s1(sram_if),
      .s2(hasti_to_poci_if));

   hasti_rom rom
     (.hclk,
      .bus(rom_if));

   hasti_sram sram
     (.hclk,
      .hresetn,
      .bus(sram_if));

   hasti_to_poci_bridge bridge
     (.hclk,
      .hresetn,
      .in (hasti_to_poci_if),
      .out(poci_if));

   poci_led_driver led_driver
       (.pclk    (hclk),
	.presetn (hresetn),
	.bus     (poci_if), // FIXME
	.hex     ({HEX3, HEX2, HEX1, HEX0}),
	.ledg    (LEDG),
	.ledr    (LEDR));
endmodule
