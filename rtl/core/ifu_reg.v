`include "core.h"
module ifu_reg
(
    input       wire    [`ISA_LEN-1:0]      inst_i, //如果来不及读就直接输出nop
    input       wire                        clk,
    input       wire    [`ADDR_LEN-1:0]     pc_i,
    input       wire                        flush,
    input       wire                        stall,
    input       wire    [`ADDR_LEN-1:0]     jmp_addr,

    output      reg     [`ADDR_LEN-1:0]     pc_o,
    output      reg     [`ISA_LEN-1:0]      inst_o,
    output      reg     [`ADDR_LEN-1:0]     pc_next_o
);


always @(posedge clk) begin
    if(flush == `ENABLE)begin
        pc_o <= jmp_addr;
        pc_next_o <= jmp_addr + `PC_INC;
        //这里nop一次
        inst_o <= `RV32I_INST_NOP;
    end
    else if(stall == `ENABLE)begin
        pc_o <= pc_o;
        pc_next_o <= pc_o;
        inst_o <= inst_o;
    end
    else begin
        pc_o <= pc_i;
        pc_next_o <= pc_i + `PC_INC;
        inst_o <= inst_i;
    end
end



endmodule

