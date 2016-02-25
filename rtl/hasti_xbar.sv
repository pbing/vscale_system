/* HASTI cross bar */

module hasti_xbar
  (input wire           hclk,
   input wire           hresetn,
   if_hasti_master_io.f m0, m1,
   if_hasti_slave_io.f  s0, s1);

   if_hasti_slave_io sl00();
   if_hasti_slave_io sl01();
   if_hasti_slave_io sl10();
   if_hasti_slave_io sl11();

   hasti_bus hasti_bus_0
     (.hclk,
      .hresetn,
      .m(m0),
      .s0(sl00),
      .s1(sl01));

   hasti_bus hasti_bus_1
     (.hclk,
      .hresetn,
      .m(m1),
      .s0(sl10),
      .s1(sl11));

   hasti_slave_mux hasti_slave_mux_0
     (.hclk,
      .hresetn,
      .in1(sl00),
      .in2(sl10),
      .out(s0));

   hasti_slave_mux hasti_slave_mux_1
     (.hclk,
      .hresetn,
      .in1(sl01),
      .in2(sl11),
      .out(s1));
endmodule
