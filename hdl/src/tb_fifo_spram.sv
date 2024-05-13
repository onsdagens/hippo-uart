//tb_fifo_spram.sv
`timescale 1ns / 1ps

module tb_fifo_spram;
  import decoder_pkg::*;
  import config_pkg::*;
  fifo_spram dut (
      .clk_i(clk),
      .reset_i(reset),
      .next(uart_next),
      .csr_enable(csr_enable),
      .csr_addr(csr_addr),
      .rs1_zimm(rs1_zimm),
      .rs1_data(rs1_data),
      .csr_op(csr_op),
      .level(0),

      .vcsr_addr(0),
      .vcsr_width(0),
      .vcsr_offset(0),
      .data(fifo_data),
      .csr_data_out(csr_data_out),
      .have_next(fifo_have_next)
  );
  logic clk;
  logic reset;
  logic uart_next;
  logic csr_enable;
  CsrAddrT csr_addr;
  r rs1_zimm;
  word rs1_data;
  csr_op_t csr_op;
  word csr_data_out;
  logic [7:0] fifo_data;
  logic fifo_have_next;
  always #10 clk = ~clk;
  initial begin
    clk = 0;
    reset = 1;
    uart_next = 0;
    csr_enable = 0;
    csr_addr = 'h51;
    rs1_zimm = 0;
    rs1_data = 0;
    csr_op = CSRRW;
    #20;
    reset = 0;
    csr_enable = 1;
    rs1_data = 'h13;
    #20;
    rs1_data = 'h37;
    #20;
    rs1_data = 'hDE;
    #20;
    rs1_data = 'hAD;
    #20;
    csr_enable = 0;
    #20;
    uart_next = 0;
    #20;
    uart_next = 1;
    #20;
    uart_next = 0;
    #20;
    uart_next = 0;
    #20;
    uart_next = 1;
    #20;
    uart_next = 0;
    #20;
    uart_next = 0;
    #20;
    uart_next = 1;
    #20;
    uart_next = 0;
    #20;
    uart_next = 0;
    #20;


    $finish;
  end
endmodule

