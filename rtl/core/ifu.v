`include "core.h"

module ifu
(
    input       wire                        clk,
    input       wire                        flush,
    input       wire                        stall,
    input       wire    [`ADDR_LEN-1:0]     jmp_addr_i,
    input       wire    [`ISA_LEN-1:0]      rd_data_i,
    input       wire                        busy_,



    output      wire    [`ISA_LEN-1:0]      inst_o, 
    output      wire    [`ADDR_LEN-1:0]     pc_o,
    output      wire                        wait_//输出到控制模块，用来控制后续停一拍
);

wire [`ADDR_LEN-1:0] pc;
wire [`ADDR_LEN-1:0] pc_next;
wire [`ISA_LEN-1:0]  inst;

ifu_fetch ifu_fetch
(
    .pc_i(pc_next),
    .rd_data_i(rd_data_i),
    .busy_(busy_),

    .inst_o(inst), //如果来不及读就直接输出nop
    .pc_o(pc),
    .wait_(wait_)
);

ifu_reg ifu_reg
(
    .inst_i(inst), //如果来不及读就直接输出nop
    .pc_i(pc),
    .flush(flush),
    .stall(stall),
    .jmp_addr(jmp_addr_i),

    .pc_o(pc_o),
    .inst_o(inst_o),
    .pc_next_o(pc_next)
);
endmodule