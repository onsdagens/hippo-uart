// fifo_spram
`timescale 1ns / 1ps

import decoder_pkg::*;
import config_pkg::*;
module fifo_spram (
    input logic clk_i,
    input logic reset_i,
    input logic next,
    input logic csr_enable,
    input CsrAddrT csr_addr,
    input r rs1_zimm,
    input word rs1_data,
    input csr_op_t csr_op,
    input PrioT level,

    input CsrAddrT vcsr_addr,
    input vcsr_width_t vcsr_width,
    input vcsr_offset_t vcsr_offset,
    output logic [7:0] data,
    output word csr_data_out,
    output logic have_next
);
  logic spram_we;
  logic [7:0] spram_din;
  logic [7:0] buffer[2];
  FifoPtrT in_ptr;
  FifoPtrT out_ptr;
  FifoPtrT mem_in_ptr;
  FifoPtrT mem_out_ptr;
  FifoPtrT spram_addr;
  logic [7:0] data_in;
  logic [1:0] buffer_in_ptr;
  logic [7:0] spram_dout;
  logic read_on_next;
  logic spram_read_addr;
  logic spram_write_addr;
  sdpram_block #(
      .DMemSizeBits(FifoQueueSize * 8)
  ) block_0 (
      .clk(clk_i),
      .reset(reset_i),
      .address_read(mem_out_ptr),
      .address_write(mem_in_ptr),
      .write_enable(spram_we),
      .data_in(spram_din),
      .data_out(spram_dout)
  );
  always_comb begin
    data = buffer[0];
    // spram_din = 8'(rs1_data);
    data_in = 8'(rs1_data);
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      spram_we <= 0;
      mem_in_ptr <= -1;
      mem_out_ptr <= 0;
      in_ptr <= 0;
      out_ptr <= 0;
      buffer_in_ptr <= 0;
      buffer <= '{default: 0};
      read_on_next <= 0;
    end else begin
      if (read_on_next == 1) begin
        buffer[1] <= spram_dout;
        read_on_next <= 0;
        mem_out_ptr <= mem_out_ptr + 1;
      end
      read_on_next <= 0;
      spram_we <= 0;
      if (csr_enable == 1 && csr_addr == FifoByteCsrAddr) begin
        if (buffer_in_ptr < 2) begin
          buffer[buffer_in_ptr] <= data_in;
          buffer_in_ptr <= buffer_in_ptr + 1;
        end else begin
          spram_we   <= 1;
          spram_din  <= 8'(rs1_data);
          mem_in_ptr <= mem_in_ptr + 1;
        end
      end
    end
    if (buffer_in_ptr != 0) begin
      have_next <= 1;
    end else begin
      have_next <= 0;
    end
    if (next) begin
      if (mem_in_ptr != mem_out_ptr) begin
        buffer[0] <= buffer[1];
        buffer[1] <= spram_dout;
        read_on_next <= 1;
      end else begin
        buffer[0] <= buffer[1];
        buffer[1] <= spram_dout;
        buffer_in_ptr -= 1;
      end
    end


  end

endmodule
