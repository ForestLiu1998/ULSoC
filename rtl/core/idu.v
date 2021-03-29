`include "core.h"
module idu //TODO:没有reset 一开始的pc会产生不定态
(
    //from ctrl
    input       wire                        clk,
    input       wire                        flush,
    input       wire                        stall, //stall由控制器产出
    
    
    //from ifu
    input       wire    [`ISA_LEN-1:0]      inst_i, 
    input       wire    [`ADDR_LEN-1:0]     pc_i,


    //to EXU & BPU
    output     wire     [`ADDR_LEN-1:0]         op_1_o,
    output     wire     [`ADDR_LEN-1:0]         op_2_o,
    output     wire     [`ADDR_LEN-1:0]         jmp_1_o,
    output     wire     [`ADDR_LEN-1:0]         jmp_2_o,
    output     wire     [`ISA_LEN-1:0]          inst_o, //指令 
    output     wire     [`ADDR_LEN-1:0]         pc_o, //当前指令的pc  
    output     wire                             jmp_o,
    output     wire                             wr_en_,
    output     wire     [4:0]                   wb_addr_o,//write back addr

    //from||to REGS32I
    input      wire     [`REG_LENGTH_32I-1:0]    rd_data_0,
    input      wire     [`REG_LENGTH_32I-1:0]    rd_data_1,
    output     wire      [4:0]                   rd_addr_0,
    output     wire      [4:0]                   rd_addr_1,
    
    //to MEM
    output     wire                              mem_rw,
    output     wire                              mem_req_
);

wire    [`ADDR_LEN-1:0]         op_1;
wire    [`ADDR_LEN-1:0]         op_2;
wire    [`ADDR_LEN-1:0]         jmp_1;
wire    [`ADDR_LEN-1:0]         jmp_2;
wire    [`ISA_LEN-1:0]          inst; //指令 
wire    [`ADDR_LEN-1:0]         pc; //当前指令的pc  
wire                            jmp;
wire    [4:0]                   wb_addr;//write back addr
wire                            dec_wr_en_;


idu_reg idu_reg
(
    //form IDU_DEC
    .op_1_i(op_1),
    .op_2_i(op_2),
    .jmp_1_i(jmp_1),
    .jmp_2_i(jmp_2),
    .inst_i(inst), //指令 
    .pc_i(pc), //当前指令的pc  
    .jmp_i(jmp),
    .wb_addr_i(wb_addr),//write back addr
    .dec_wr_en_(dec_wr_en_),


    .op_1_o(op_1_o),
    .op_2_o(op_2_o),
    .jmp_1_o(jmp_1_o),
    .jmp_2_o(jmp_2_o),
    .inst_o(inst_o), //指令 
    .pc_o(pc_o), //当前指令的pc  
    .jmp_o(jmp_o),
    .wb_addr_o(wb_addr_o),//write back addr  
    .wr_en_(wr_en_),



    .clk(clk),
    .flush(flush),
    .stall(stall),
    
);

idu_dec idu_dec
(
    //from IFU
    .inst_i(inst_i), //指令 
    .pc_i(pc_i), //当前指令的pc

    //from||to REGS 只负责读
    .rd_data_0(rd_data_0),
    .rd_data_1(rd_data_1),
    .rd_addr_0(rd_addr_0),
    .rd_addr_1(rd_addr_1),

    //to EXU & BPU
    .op_1_o(op_1),
    .op_2_o(op_2),
    .jmp_1_o(jmp_1),
    .jmp_2_o(jmp_2),
    .inst_o(inst), //指令 
    .pc_o(pc), //当前指令的pc  
    .jmp_o(jmp),
    .wr_en_(dec_wr_en_),
    .wb_addr_o(wb_addr),//write back addr

    
    .mem_rw(mem_rw), //load指令就是读，store指令就是写
    .mem_req_(mem_req_)//请求总线信号
);




endmodule