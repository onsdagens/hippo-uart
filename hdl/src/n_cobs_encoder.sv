// n_cobs_encoder
`timescale 1ns / 1ps

module n_cobs_encoder
  import config_pkg::*;
  import decoder_pkg::*;
(
    input logic clk_i,
    input logic reset_i,

    // 1 byte for writing
    // fill rest with timer
    input [FifoEntryWidthBits-8-1:0] timer,

    input logic csr_enable,
    input CsrAddrT csr_addr,

    input word rs1_data,

    input PrioT level,

    output word write_data,
    output [FifoEntryWidthSize-1:0] write_width,
    output write_enable
);

  PrioT                           old_level;

  word                            tmp_data;
  word                            write_data;

  logic    [FifoEntryWidthSize:0] tmp_write_width;
  logic    [FifoEntryWidthSize:0] write_width;
  logic                           write_enable;
  logic                           is_zero;
  // Byte

  word                            byte_out;
  word                            tmp_data;
  FifoPtrT                        tmp_in_ptr;
  FifoPtrT                        sentinel_ptr;


  FifoPtrT                        tmp_length;
  // stack
  logic                           has_zero        [PrioNum];
  FifoPtrT                        length          [PrioNum];

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      old_level <= PrioT'(PrioNum - 1);
      has_zero <= '{default: 0};  // not strictly needed
      length <= '{default: 0};  // not strictly needed
    end else begin
      tmp_write_width = 0;
      tmp_data = 0;
      tmp_length = length[level];
      is_zero = 0;
      if (level < old_level) begin
        // push frame
        has_zero[level] <= 0;
        is_zero = 0;
        tmp_length = 0;
        for (integer i = 0; i < FifoEntryWidth - 1; i++) begin
          if (8'(timer >> ((FifoEntryWidth - 2 - i) * 8)) == 0) begin
            tmp_data = (tmp_data << 8) | 8'((is_zero) ? tmp_length : -tmp_length - 1);
            has_zero[level] <= 1;
            length[level]   <= 1;
            is_zero = 1;
            tmp_length = 1;
            tmp_write_width = tmp_write_width + 1;
          end else begin
            tmp_data = (tmp_data << 8) | 8'(timer >> ((FifoEntryWidth - 2 - i) * 8));
            tmp_length = FifoPtrT'(tmp_length + 1);
            tmp_write_width = tmp_write_width + 1;
          end
        end
      end else if (level > old_level) begin
        // pop frame
        // package length
        tmp_data = ((has_zero[old_level]) ? length[old_level] : -length[old_level] - 1) << 8; // shift by 8, essentially inserting a 0 package delimiter.
        tmp_write_width = 2;
      end
      if (csr_enable == 1 && csr_addr == FifoByteCsrAddr) begin
        // write byte
        if (rs1_data[7:0] == 0) begin
          tmp_data = (tmp_data << 8) | ((has_zero[level]) ? length[level] : -length[level] - 1);
          tmp_write_width = tmp_write_width + 1;
          length[level] <= 1;
          tmp_length = 1;
          has_zero[level] <= 1;
        end else begin
          tmp_data = (tmp_data << 8) | rs1_data;
          tmp_length = FifoPtrT'(tmp_length + 1);
          tmp_write_width = tmp_write_width + 1;
        end
      end
      old_level <= level;
      // update tmp
      write_width <= tmp_write_width;
      write_data <= tmp_data;
      write_enable <= tmp_write_width != 0;

      length[level] <= tmp_length;
    end
  end
endmodule
