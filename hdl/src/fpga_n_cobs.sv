// fpga_n_cobs
// N COBS example
`timescale 1ns / 1ps


module fpga_n_cobs
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

  n_cobs_encoder enc (
      .clk_i(clk),
      .reset_i(tmp_sw1),
      .csr_enable(csr_enable),
      .csr_addr('h51),
      .timer('h670089),

      .rs1_data(rs1_data),

      .level(level),
      .write_data(enc_write_data),
      .write_width(enc_write_width),
      .write_enable(enc_write_enable)
  );


  fifo_interleaved dut (
      .clk_i  (clk),
      .reset_i(tmp_sw1),

      .write_enable(enc_write_enable),
      .write_data  (enc_write_data),
      .write_width (enc_write_width),


      .ack(ack),
      .data(fifo_data),
      .have_next(fifo_have_next)
  );

  uart uart_i (
      .clk_i    (clk),
      .reset_i  (tmp_sw1),
      .prescaler(prescaler),       // this can be a config register, for now just wire it to a 0
      .d_in     (fifo_data),       // data in from fifo
      .rts      (fifo_have_next),  // queue ready signal
      //input logic cmp,
      .tx       (rx),              // the tx pin of the UART
      .next     (ack)              // next word request to the fifo
  );
  word r_count;
  PrioT level = 2;
  logic ack;
  logic csr_enable;
  logic fifo_have_next;
  logic [7:0] fifo_data;
  logic [FifoEntryWidthBits-1:0] rs1_data;
  logic [FifoEntryWidthSize:0] enc_write_width;
  word enc_write_data;
  logic enc_write_enable;
  logic send;
  logic [FifoEntryWidthBits-1:0] sample[4] = {'h00000013, 'h00000000, 'h00000037, 'hDE};
  logic [1:0] max_idx;
  always_ff @(posedge clk) begin
    if (r_count[25] == 1) begin
      level <= 1;
      send <= 1;
      r_count <= 0;
    end else begin
      if (send == 1) begin
        if (r_count[2:0] == 4) begin
          send <= 0;
          csr_enable <= 0;
          level <= 1;
        end else begin
          //simulate preemption
          if (r_count[2:0] == 3) begin
            level <= 0;
          end
          rs1_data   <= sample[r_count[1:0]];
          csr_enable <= 1;
        end
      end else begin
        level <= 2;
        csr_enable <= 0;
      end
      r_count <= r_count + 1;
    end
  end
endmodule
