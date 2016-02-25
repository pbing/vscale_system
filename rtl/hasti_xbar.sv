/* HASTI cross bar */

module hasti_xbar
  (input wire           hclk,
   input wire           hresetn,
   if_hasti_master_io.f m0, m1,
   if_hasti_slave_io.f  s0, s1);

   if_hasti_slave_io m0s0();
   if_hasti_slave_io m0s1();
   if_hasti_slave_io m1s0();
   if_hasti_slave_io m1s1();

   hasti_bus hasti_bus_0
     (.hclk,
      .hresetn,
      .m(m0),
      .s0(m0s0),
      .s1(m0s1));

   hasti_bus hasti_bus_1
     (.hclk,
      .hresetn,
      .m(m1),
      .s0(m1s0),
      .s1(m1s1));

   hasti_slave_mux hasti_slave_mux_0
     (.hclk,
      .hresetn,
      .in1(m0s0),
      .in2(m1s0),
      .out(s0));

   hasti_slave_mux hasti_slave_mux_1
     (.hclk,
      .hresetn,
      .in1(m0s1),
      .in2(m1s1),
      .out(s1));
endmodule
