/* POCI type definitions */

package pk_poci;
   parameter
     data_width = 32,
     addr_width = 32;

   parameter bit [addr_width - 1:0] /* LEDs */
				    base_leds = 32'h80000000,
                                    addr_hex  = base_leds + 32'h00000000,
                                    addr_ledg = base_leds + 32'h00000010,
                                    addr_ledr = base_leds + 32'h00000020,
                                    /* switches and keys */
				    base_keys = 32'h80001000,
                                    addr_key  = base_keys + 32'h00000000,
                                    addr_sw   = base_keys + 32'h00000010;
endpackage
