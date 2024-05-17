
//tb_fifo_interleaved.sv
`timescale 1ns / 1ps

module tb_fifo_interleaved;
  import decoder_pkg::*;
  import config_pkg::*;
  fifo_interleaved dut (
      .clk_i  (clk),
      .reset_i(reset),

      .write_enable(write_enable),
      .write_data  (write_data),
      .write_width (write_width),

      .ack(ack)
  );
  logic clk;
  logic reset;

  logic ack;
  logic write_enable;
  logic [FifoEntryWidthBits-1:0] write_data;
  logic [FifoEntryWidthSize:0] write_width;
  always #10 clk = ~clk;
  initial begin
    ack = 0;
    clk = 0;
    reset = 1;
    write_enable = 0;
    write_width = 0;
    write_data = 0;
    #20;
    reset = 0;
    write_enable = 1;
    write_data = 'hDEADBEEF;
    write_width = 4;
    //#20;
    //write_data  = 'hADBE;
    //write_width = 2;
    //#20;
    //write_data  = 'hEF;
    //write_width = 1;
    #20;
    write_enable = 0;
    #20;
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
    write_enable = 1;
    write_data = 'h12345678;
    write_width = 4;
    //#20;
    //write_data  = 'hADBE;
    //write_width = 2;
    //#20;
    //write_data  = 'hEF;
    //write_width = 1;
    #20;
    write_enable = 0;
    #20;
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

