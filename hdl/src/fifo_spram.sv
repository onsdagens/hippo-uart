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
  FifoPtrT mem_in_ptr;
  FifoPtrT mem_out_ptr;
  FifoPtrT spram_addr;
  logic [7:0] data_in;
  logic [1:0] buffer_in_ptr;
  logic [7:0] spram_dout;
  logic read_on_next;
  logic spram_read_addr;
  logic spram_write_addr;
  logic memory_written;
  logic read_next;
  logic [2:0] read_from_memory;
  logic [2:0] some_signal;
  sdpram_block #(
      .FifoSizeBits(FifoQueueSize * 8)
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
    data_in = 8'(rs1_data);
    spram_read_addr = mem_out_ptr;
    spram_write_addr = mem_in_ptr;
  end

  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      spram_we <= 0;
      mem_in_ptr <= 0;
      mem_out_ptr <= 0;
      buffer_in_ptr <= 0;
      buffer <= '{default: 0};
      memory_written <= 0;
      read_next <= 0;
      read_from_memory <= 0;
      some_signal <= 3;
    end else begin
      some_signal <= 3;
      spram_we <= 0;
      // delay incrementing the in pointer until the write is finished
      if (memory_written) begin
        memory_written <= 0;
        mem_in_ptr <= mem_in_ptr + 1;
      end
      // delay pop from memory until we are sure that any readwrites are finished
      if (read_from_memory > 1) begin
        read_from_memory <= read_from_memory - 1;
      end else if (read_from_memory == 1) begin
        mem_out_ptr <= mem_out_ptr + 1;
        buffer[1] <= spram_dout;
        read_from_memory <= 0;
        // the mem_out_ptr change does not take effect until next cycle, do an
        // ugly...
        if (mem_in_ptr != (mem_out_ptr + 1)) begin
          buffer_in_ptr <= buffer_in_ptr + 1;
        end
      end
      if (csr_enable == 1 && csr_addr == FifoByteCsrAddr) begin
        if ((buffer_in_ptr < 2) && (read_from_memory == 0)) begin
          buffer[buffer_in_ptr] <= rs1_data;
          buffer_in_ptr <= buffer_in_ptr + 1;
        end else begin
          spram_we <= 1;
          spram_din <= rs1_data;
          memory_written <= 1;
        end
      end
      if (buffer_in_ptr > 0) begin
        have_next <= 1;
      end else begin
        have_next <= 0;
      end
      if (next) begin
        buffer[0] <= buffer[1];
        if ((mem_in_ptr != mem_out_ptr) || (csr_enable == 1 && csr_addr == FifoByteCsrAddr && buffer_in_ptr >= 2)) begin
          buffer_in_ptr <= buffer_in_ptr - 1;
          read_from_memory <= 3;
        end else begin
          buffer_in_ptr <= buffer_in_ptr - 1;
        end
      end

    end
  end

endmodule
