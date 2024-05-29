// fpga_n_cobs
// N COBS example
`timescale 1ns / 1ps


module fpga_n_cobs
  import decoder_pkg::*;
(
    input sysclk,
    input logic [1:0] sw,
    output logic rx,  // host
    output logic led_r
);

  logic clk;
  logic tmp_sw1;
  logic locked;
  assign tmp_sw1 = sw[1];
  word r_count;
  logic reset;
  assign reset = sw[0];
  logic[1:0] level_sig;
  logic ack;
  logic csr_enable;
  logic fifo_have_next;
  logic [7:0] fifo_data;
  word rs1_data;
  logic [FifoEntryWidthSize:0] enc_write_width;
  logic [FifoEntryWidthBits-1:0] enc_write_data;
  logic enc_write_enable;
  logic send;
  word sample[4] = {'h00000013, 'h00000000, 'h00000037, 'h000000DE};
  logic [1:0] max_idx;
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
      .reset_i(reset),
      .csr_enable(csr_enable),
      .csr_addr('h51),
      .timer('h12000078),

      .rs1_data(rs1_data),

      .level(level_sig),
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


      .ack(ack),
      .data(fifo_data),
      .have_next(fifo_have_next)
  );

  uart uart_i (
      .clk_i    (clk),
      .reset_i  (reset),
      .prescaler(0),       // this can be a config register, for now just wire it to a 0
      .d_in     (fifo_data),       // data in from fifo
      .rts      (fifo_have_next),  // queue ready signal
      //input logic cmp,
      .tx       (rx),              // the tx pin of the UART
      .next     (ack)              // next word request to the fifo
  );
 
  always_ff @(posedge clk) begin
    if (reset) begin
        r_count <= 0;
        led_r <= 0;
        rs1_data <= 0;
        level_sig <= 2;
        //rs1_data   <= sample[r_count[0]];
        //csr_enable <= 1;
        csr_enable <= 0;
    end 
    else if (r_count[25] == 1) begin
      level_sig <= 1;
      send <= 1;
      led_r <= ~led_r;
      r_count <= 0;
    end else begin
      if (send == 1) begin
        if (r_count[3:0] == 8) begin
          send <= 0;
          csr_enable <= 0;
          level_sig <= 1;
        end else begin
          //simulate preemption
          if (r_count[2:0] == 7) begin
            level_sig <= 0;
          end
          rs1_data   <= sample[r_count[1:0]];
          csr_enable <= 1;
        end
      end else begin
        level_sig <= 2;
        csr_enable <= 0;
      end
      r_count <= r_count + 1;
    end
  end
endmodule
