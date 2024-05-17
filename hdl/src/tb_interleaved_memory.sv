//tb_interleaved_memory.sv
`timescale 1ns / 1ps

module tb_interleaved_memory;
  import decoder_pkg::*;
  import config_pkg::*;
  interleaved_memory dut (
      .clk,
      .reset,
      .write_width,
      .write_addr,
      .read_addr,
      .data_in,
      .write_enable,
      .data_out
  );
  logic clk;
  logic reset;
  logic [FifoEntryWidthSize-1:0] write_width;
  logic [FifoAddrWidth-1:0] write_addr;
  logic [FifoAddrWidth-1:0] read_addr;
  logic [FifoEntryWidthBits-1:0] data_in;
  logic write_enable;
  logic [7:0] data_out;

  always #10 clk = ~clk;
  initial begin
    clk = 0;
    reset = 1;
    write_enable = 0;
    write_addr = 0;
    data_in = 0;
    write_width = 0;
    #20;
    reset = 0;
    #20;
    write_width = 1;
    write_enable = 1;
    read_addr = 0;
    data_in = 'h000000DE;
    #20;
    write_enable = 0;
    #20;
    #20;
    write_addr = 1;
    write_width = 2;
    write_enable = 1;
    data_in = 'h0000ADBE;
    #20;
    write_enable = 0;
    #20;
    write_addr = 3;
    write_width = 3;
    write_enable = 1;
    data_in = 'h00EF1234;
    #20;
    write_enable = 0;
    #20;
    write_addr = 6;
    write_width = 4;
    write_enable = 1;
    data_in = 'h5678ABCD;
    #20;
    write_enable = 0;
    #20;
    #20;
    #20;
    read_addr = 0;
    #20;
    #20;
    read_addr = 1;
    #20;
    #20;
    read_addr = 2;
    #20;
    #20;
    read_addr = 3;
    #20;
    #20;
    read_addr = 4;
    #20;
    #20;
    read_addr = 5;
    #20;
    #20;
    read_addr = 6;
    #20;
    #20;
    read_addr = 7;
    #20;
    #20;
    read_addr = 8;
    #20;
    #20;
    read_addr = 9;
    #20;
    #20;
    read_addr = 'hA;
    #20;
    #20;
    read_addr = 0;
    #20;
    #20;
    
    $finish;
  end
endmodule

