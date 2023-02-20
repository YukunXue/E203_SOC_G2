// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Mon Sep 19 12:22:23 2022
// Host        : DESKTOP-3PN6QK7 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/genesys2_test/ip_list/e203_ip_axi_mem/ip/e203/src/clk_wiz_0_1/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(CLK_O_16M, CLK_O_8M388, resetn, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="CLK_O_16M,CLK_O_8M388,resetn,locked,clk_in1" */;
  output CLK_O_16M;
  output CLK_O_8M388;
  input resetn;
  output locked;
  input clk_in1;
endmodule
