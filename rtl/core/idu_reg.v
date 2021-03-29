`include "core.h"

module idu_reg
(
    //form IDU_DEC
    input      wire    [`ADDR_LEN-1:0]         op_1_i,
    input      wire    [`ADDR_LEN-1:0]         op_2_i,
    input      wire    [`ADDR_LEN-1:0]         jmp_1_i,
    input      wire    [`ADDR_LEN-1:0]         jmp_2_i,
    input      wire    [`ISA_LEN-1:0]          inst_i, //指令 
    input      wire    [`ADDR_LEN-1:0]         pc_i, //当前指令的pc  
    input      wire                            jmp_i,
    input      wire    [4:0]                   wb_addr_i,//write back addr
    input      wire                            dec_wr_en_,

    //TO EXU
    output     reg     [`ADDR_LEN-1:0]         op_1_o,
    output     reg     [`ADDR_LEN-1:0]         op_2_o,
    output     reg     [`ADDR_LEN-1:0]         jmp_1_o,
    output     reg     [`ADDR_LEN-1:0]         jmp_2_o,
    output     reg     [`ISA_LEN-1:0]          inst_o, //指令 
    output     reg     [`ADDR_LEN-1:0]         pc_o, //当前指令的pc  
    output     reg                             jmp_o,
    output     reg      [4:0]                  wb_addr_o,//write back addr  
    output     reg                             wr_en_,


    //from ctrlU
    input      wire                            clk,
    input      wire                            flush,
    input      wire                            stall
);


always @(posedge clk) begin
    if(flush == `ENABLE)begin
        //nop命令 TODO:
        inst_o <= `RV32I_INST_NOP;
        op_1_o <= 0;
        op_2_o <= 0;
        jmp_1_o <= 0;
        jmp_2_o <= 0;
        pc_o <= pc_o;
        jmp_o <= 0;
        wb_addr_o <= wb_addr_o;
        wr_en_ <= `DISABLE;
    end
    else if (stall == `ENABLE)begin
        op_1_o <= op_1_o;
        op_2_o <= op_2_o;
        jmp_1_o <= jmp_1_o;
        jmp_2_o <= jmp_2_o;
        inst_o <= inst_o;
        pc_o <= pc_o;
        jmp_o <= jmp_o;
        wb_addr_o <= wb_addr_o;
        wr_en_ <= wr_en_;
    end
    else begin
        op_1_o <= op_1_i;
        op_2_o <= op_2_i;
        jmp_1_o <= jmp_1_i;
        jmp_2_o <= jmp_2_i;
        inst_o <= inst_i;
        pc_o <= pc_i;
        jmp_o <= jmp_i;
        wb_addr_o <= wb_addr_i;
        wr_en_ <= dec_wr_en_;
        
    end
end

endmodule

