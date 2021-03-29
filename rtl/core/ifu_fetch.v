`include "core.h"
//全组合电路,将if总线作为该模块的子模块
module ifu_fetch
(
    input       wire    [`ADDR_LEN-1:0]     pc_i,
    input       wire    [`ISA_LEN-1:0]      rd_data_i,
    input       wire                        busy_,

    output      wire    [`ISA_LEN-1:0]      inst_o, //如果来不及读就直接输出nop
    output      wire    [`ADDR_LEN-1:0]     pc_o,
    output      wire                        wait_
);

assign inst_o = rd_data_i;
assign pc_o = pc_i;
assign wait_ = busy_;



//TODO: 总线接口,这里使用rom直接读取？







endmodule