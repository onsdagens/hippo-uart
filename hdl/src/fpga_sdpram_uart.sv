// fpga_uart
// example of how the UART can be used to push data over the wire.
`timescale 1ns / 1ps


module fpga_sdpram_uart
  import decoder_pkg::*;
(
    input sysclk,
    input logic [1:0] sw,
    output logic rx  // host
);

  logic clk;
  logic tmp_sw1;
  logic locked;
  assign tmp_sw1 = sw[1];
  clk_wiz_0 clk_gen (
      // Clock in ports
      .clk_in1(sysclk),
      // Clock out ports
      .clk_out1(clk),
      // Status and control signals
      .reset(tmp_sw1),
      .locked
  );

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
      .reset_i  (tmp_sw1),
      .prescaler(prescaler),       // this can be a config register, for now just wire it to a 0
      .d_in     (fifo_data),       // data in from fifo
      .rts      (fifo_have_next),  // queue ready signal
      //input logic cmp,
      .tx       (rx),              // the tx pin of the UART
      .next     (uart_next)        // next word request to the fifo
  );

  fifo_spram fifo_i (
      .clk_i(clk),
      .reset_i(tmp_sw1),
      .next(uart_next),
      .csr_enable(fifo_write_enable_in),
      .csr_addr(FifoByteCsrAddr),
      .rs1_zimm(0),
      .rs1_data(31'(fifo_data_in)),
      .csr_op(0),
      .level(0),

      .vcsr_addr(0),
      .vcsr_width(0),
      .vcsr_offset(0),
      .data(fifo_data),
      .csr_data_out(0),
      .have_next(fifo_have_next)
  );
  logic send;
  logic [31:0] sample[4] = {'hDE, 'hAD, 'hBE, 'hEF};
  logic [3:0] ptr;
  always_ff @(posedge clk) begin
    if (r_count[25] == 1) begin
      //fifo_data_in <= 'h42;
      //fifo_write_enable_in <= 1;
      send <= 1;
      r_count <= 0;
    end else begin
      if (send == 1) begin
        fifo_data_in <= sample[r_count[1:0]];
        fifo_write_enable_in <= 1;
        if (r_count[1:0] == 3) begin
          send <= 0;
        end
      end else begin
        fifo_write_enable_in <= 0;
      end
      r_count <= r_count + 1;
    end
  end
endmodule
