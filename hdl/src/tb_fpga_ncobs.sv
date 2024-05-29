//tb_fpga_ncobs.sv
`timescale 1ns / 1ps

module tb_fpga_ncobs;
  import decoder_pkg::*;
  import config_pkg::*;
  fpga_n_cobs dut (
      .sysclk  (clk),
      .sw,
      .rx
  );
  logic clk;
  logic reset;
  logic[1:0] sw;
  logic rx;
  logic reset_sysclk;
  assign sw[1] = reset_sysclk;
  assign sw[0] = reset;

  always #10 clk = ~clk;
  initial begin
    clk = 0;
    reset = 1;
    reset_sysclk = 1;
    #20;
    reset_sysclk = 0;
 
    #20;
    #20000; 
    reset = 0;
    #200000;

    $finish;
  end
endmodule

