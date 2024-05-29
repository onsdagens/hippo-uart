//tb_fifo_interleaved.sv
`timescale 1ns / 1ps

module tb_n_cobs;
  import decoder_pkg::*;
  import config_pkg::*;

  n_cobs_encoder enc (
      .clk_i(clk),
      .reset_i(reset),
      .csr_enable(csr_enable),
      .csr_addr('h51),
      .timer('h12000078),

      .rs1_data(rs1_data),

      .level(level),
      .write_data(enc_write_data),
      .write_width(enc_write_width),
      .write_enable(enc_write_enable)
  );


  fifo_interleaved dut (
      .clk_i  (clk),
      .reset_i(reset),

      .write_enable(enc_write_enable),
      .write_data  (enc_write_data),
      .write_width (enc_write_width),

      .ack(ack)
  );
  logic clk;
  logic reset;
  PrioT level;
  logic ack;
  logic csr_enable;
  logic [FifoEntryWidthBits-1:0] rs1_data;
  logic [FifoEntryWidthSize:0] enc_write_width;
  logic [FifoEntryWidthBits-1:0] enc_write_data;
  logic enc_write_enable;
  always #10 clk = ~clk;
  initial begin
    ack = 0;
    clk = 0;
    reset = 1;
    level = 2;
    csr_enable = 0;
    rs1_data = 0;
    #20;
    reset = 0;
    #20;
    level = 1;
    #20;
    csr_enable = 1;
    rs1_data   = 'h13;
    #20;
    rs1_data = 'h00;
    #20;
    rs1_data = 'h37;
    #20;
    rs1_data = 'hDE;
    #20;
    rs1_data = 'h13;
    #20;
    rs1_data = 'h00;
    #20;
    rs1_data = 'h37;
    #20;
    level = 0;
    rs1_data = 'hDE;
    #20;
    csr_enable = 0;
    level = 1;
    #20;
    level = 2;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;
    ack = 1;
    #20;
    ack = 0;
    #80;


    $finish;
  end
endmodule

