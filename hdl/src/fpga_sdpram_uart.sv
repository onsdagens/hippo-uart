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
      .ack(uart_next),
      .write_enable(fifo_write_enable_in),
      .write_data(fifo_data_in),

      .data(fifo_data),
      .have_next(fifo_have_next)
  );
  logic send;
  logic [31:0] sample[4] = {'hDE, 'hAD, 'hBE, 'hEF};
  // try different lengths of comms to catch different edge cases.
  logic [1:0] max_idx;
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
        if (r_count[1:0] == max_idx) begin
          send <= 0;
          max_idx <= max_idx + 1;
        end
      end else begin
        fifo_write_enable_in <= 0;
      end
      r_count <= r_count + 1;
    end
  end
endmodule
