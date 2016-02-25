`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

interface if_hasti_master_io;
   import pk_hasti::*;

   logic [addr_width - 1:0] haddr;
   logic                    hwrite;
   hsize_t                  hsize;
   hburst_t                 hburst;
   logic [3:0]              hprot;
   htrans_t                 htrans;
   logic                    hmastlock;
   logic [data_width - 1:0] hwdata;
   logic [data_width - 1:0] hrdata;
   logic                    hready;
   hresp_t                  hresp;

   /* non flipped */
   modport n
     (output haddr,
      output hwrite,
      output hsize,
      output hburst,
      output hprot,
      output htrans,
      output hmastlock,
      output hwdata,
      input  hrdata,
      input  hready,
      input  hresp);

   /* flipped */
   modport f
     (input  haddr,
      input  hwrite,
      input  hsize,
      input  hburst,
      input  hprot,
      input  htrans,
      input  hmastlock,
      input  hwdata,
      output hrdata,
      output hready,
      output hresp);
endinterface:if_hasti_master_io

interface if_hasti_slave_io;
   import pk_hasti::*;

   logic [addr_width - 1:0] haddr;
   logic                    hwrite;
   hsize_t                  hsize;
   hburst_t                 hburst;
   logic [3:0]              hprot;
   htrans_t                 htrans;
   logic                    hmastlock;
   logic [data_width - 1:0] hwdata;
   logic [data_width - 1:0] hrdata;
   logic                    hsel;
   logic                    hready;
   logic                    hreadyout;
   hresp_t                  hresp;

   /* non flipped */
   modport n
     (input  haddr,
      input  hwrite,
      input  hsize,
      input  hburst,
      input  hprot,
      input  htrans,
      input  hmastlock,
      input  hwdata,
      output hrdata,
      input  hsel,
      input  hready,
      output hreadyout,
      output hresp);

   /* flipped */
   modport f
     (output haddr,
      output hwrite,
      output hsize,
      output hburst,
      output hprot,
      output htrans,
      output hmastlock,
      output hwdata,
      input  hrdata,
      output hsel,
      output hready,
      input  hreadyout,
      input  hresp);
endinterface:if_hasti_slave_io

interface if_htif;
   logic                         reset;
   logic                         id;
   logic                         pcr_req_valid;
   logic                         pcr_req_ready;
   logic                         pcr_req_rw;
   logic [`CSR_ADDR_WIDTH - 1:0] pcr_req_addr;
   logic [`HTIF_PCR_WIDTH - 1:0] pcr_req_data;
   logic                         pcr_resp_valid;
   logic                         pcr_resp_ready;
   logic [`HTIF_PCR_WIDTH - 1:0] pcr_resp_data;
   logic                         ipi_req_ready;
   logic                         ipi_req_valid;
   logic                         ipi_req_data;
   logic                         ipi_resp_ready;
   logic                         ipi_resp_valid;
   logic                         ipi_resp_data;
   logic                         debug_stats_pcr;

   modport master
     (output reset,
      output id,
      output pcr_req_valid,
      input  pcr_req_ready,
      output pcr_req_rw,
      output pcr_req_addr,
      output pcr_req_data,
      input  pcr_resp_valid,
      output pcr_resp_ready,
      input  pcr_resp_data,
      output ipi_req_ready,
      input  ipi_req_valid,
      input  ipi_req_data,
      input  ipi_resp_ready,
      output ipi_resp_valid,
      output ipi_resp_data,
      input  debug_stats_pcr);

   modport slave
     (input  reset,
      input  id,
      input  pcr_req_valid,
      output pcr_req_ready,
      input  pcr_req_rw,
      input  pcr_req_addr,
      input  pcr_req_data,
      output pcr_resp_valid,
      input  pcr_resp_ready,
      output pcr_resp_data,
      input  ipi_req_ready,
      output ipi_req_valid,
      output ipi_req_data,
      output ipi_resp_ready,
      input  ipi_resp_valid,
      input  ipi_resp_data,
      output debug_stats_pcr);
endinterface:if_htif

interface if_sram
  #(addr_width = 10);
   logic                    clock;
   logic [addr_width - 1:0] address;
   logic [3:0]              byteena;
   logic [31:0]             data;
   logic                    wren;
   logic [31:0]             q;

   modport master
     (output clock,
      output address,
      output byteena,
      output data,
      output wren,
      input  q);

   modport slave
     (input  clock,
      input  address,
      input  byteena,
      input  data,
      input  wren,
      output q);
endinterface:if_sram

