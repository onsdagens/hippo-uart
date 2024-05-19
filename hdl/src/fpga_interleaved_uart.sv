// fpga_uart
// example of how the UART can be used to push data over the wire.
`timescale 1ns / 1ps


module fpga_interleaved_uart
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
  logic [31:0] fifo_data_in;
  logic [2:0] fifo_write_width;
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

  fifo_interleaved fifo_i (
      .clk_i  (clk),
      .reset_i(tmp_sw1),

      .write_enable(fifo_write_enable_in),
      .write_data  (fifo_data_in),
      .write_width (fifo_write_width),

      .ack(uart_next),
      .data(fifo_data),
      .have_next(fifo_have_next)
  );
  logic send;
  logic [31:0] sample[4] = {'h000000DE, 'h0000DEAD, 'h00DEADBE, 'hDEADBEEF};
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
          if (r_count[2:0] == 4) begin
            send <= 0;
            fifo_write_enable_in <= 0;
          end 
          else begin
            fifo_data_in <= sample[r_count[1:0]];
            fifo_write_enable_in <= 1;
            fifo_write_width <= r_count[1:0] + 1;
          end
//        fifo_data_in <= sample[r_count[1:0]];
//        fifo_write_enable_in <= 1;
//        fifo_write_width <= r_count[1:0] + 1;
//        if (r_count[1:0] == max_idx) begin
//          send <= 0;
//          max_idx <= max_idx + 1;
//        end
//        fifo_data_in <= 'hDEADBEEF;
//        fifo_write_width <= 4;
//        fifo_write_enable_in <= 1;
//        send <= 0;
      end else begin
        fifo_write_enable_in <= 0;
      end
      r_count <= r_count + 1;
    end
  end
endmodule
