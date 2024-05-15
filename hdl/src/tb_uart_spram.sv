// tb_uart_spram
// example of how the UART can be used to push data over the wire.
`timescale 1ns / 1ps


module tb_uart_spram;
  import decoder_pkg::*;
  logic reset;
  logic clk;
  always #10 clk = ~clk;
  logic [7:0] fifo_data;
  logic uart_next;
  logic fifo_have_next;
  logic fifo_write_enable_in;
  word prescaler;
  word r_count;
  logic [7:0] fifo_data_in;
  assign prescaler = 0;
  uart uart_i (
      .clk_i    (clk),
      .reset_i  (reset),
      .prescaler(prescaler),       // this can be a config register, for now just wire it to a 0
      .d_in     (fifo_data),       // data in from fifo
      .rts      (fifo_have_next),  // queue ready signal
      //input logic cmp,
      .tx       (rx),              // the tx pin of the UART
      .next     (uart_next)        // next word request to the fifo
  );

  fifo_spram fifo_i (
      .clk_i(clk),
      .reset_i(reset),
      .next(uart_next),
      .csr_enable(fifo_write_enable_in),
      .csr_addr(FifoByteCsrAddr),
      .rs1_zimm(0),
      .rs1_data(32'(fifo_data_in)),
      .csr_op(0),
      .level(0),

      .vcsr_addr(0),
      .vcsr_width(0),
      .vcsr_offset(0),
      .data(fifo_data),
      .csr_data_out(csr_data_out),
      .have_next(fifo_have_next)
  );
  logic send;
  logic [31:0] sample[4] = {'hDE, 'hAD, 'hBE, 'hEF};
  logic [3:0] ptr;

  initial begin
    clk = 0;
    reset = 1;
    fifo_write_enable_in = 0;
    fifo_data_in = 0;
    #20;
    reset = 0;
    #20;
    fifo_write_enable_in = 1;
    fifo_data_in = 'hDE;
    #20;
        fifo_write_enable_in = 1;
    fifo_data_in = 'hAD;
    #20;
    fifo_write_enable_in = 1;
    fifo_data_in = 'hBE;
    #20;
    fifo_write_enable_in = 1;
    fifo_data_in = 'hEF;
    #20;
    fifo_write_enable_in = 0;
    #100000;
    $finish;
  end
endmodule
