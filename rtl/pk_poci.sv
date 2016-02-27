/* POCI type definitions */

package pk_poci;
   parameter
     data_width = 32,
     addr_width = 32;

   parameter bit [addr_width - 1:0] /* switches and keys */
				    base_keys       = 32'h40000000,
                                    addr_key        = base_keys + 32'h00000000,
                                    addr_sw         = base_keys + 32'h00000010,

                                    /* LED displays */
				    base_led_driver = 32'h40001000,
                                    addr_hex        = base_led_driver + 32'h00000000,
                                    addr_ledg       = base_led_driver + 32'h00000010,
                                    addr_ledr       = base_led_driver + 32'h00000020;
endpackage
