`include "core.h"
module regs_32I
(
    input       wire            [4:0]                    rd_addr_0,
    input       wire            [4:0]                    rd_addr_1,
    input       wire            [4:0]                    wr_addr,
    input       wire            [`REG_LENGTH_32I-1:0]    wr_data,
    input       wire                                     reset,
    input       wire                                     clk,
    input       wire                                     wr_en_,

    output      wire            [`REG_LENGTH_32I-1:0]    rd_data_0,
    output      wire            [`REG_LENGTH_32I-1:0]    rd_data_1
);

reg [`REG_LENGTH_32I-1:0] regs [`REG_DEPTH_32I];


assign rd_data_0 = (rd_addr_0 == wr_addr && wr_en_ == `ENABLE_) ? wr_data:
                    (rd_addr_0 == 0)?0:regs[rd_addr_0];

assign rd_data_1 = (rd_addr_1 == wr_addr && wr_en_ == `ENABLE_) ? wr_data:
                    (rd_addr_1 == 0)?0:regs[rd_addr_1];

integer i;
always @(posedge clk or `RESET_EDGE reset) begin
    if(reset == `RESET_ENABLE)begin
        //初始化所有寄存器
        for(i = 0;i < `REG_DEPTH_32I ;i = i+1)begin
            regs[i] <= 0;
        end
    end
    else if(wr_en_ == `ENABLE_ && wr_addr != 0)begin
            regs[wr_addr] <= wr_data;
    end
    
end


endmodule