`include "bus.h"
`define     RESET_ENABLE 0
`define     ENABLE_ 0
`define     DISABLE_ 1
//仲裁器 使用轮询

module RHB_arbit
(
    input       wire                        clk,
    input       wire                        reset,
    //master 接口
    input       wire                        m0_req_,//请求信号
    input       wire                        m1_req_,//请求信号



    output      reg                         m0_grnt_,//授权信号
    output      reg                         m1_grnt_  
 
);
parameter BUS_OWNER_MASTER_0 = 0;
parameter BUS_OWNER_MASTER_1 = 1;

reg [1:0] owner;


/*****************总线使用权*******************/
always @(*) begin
    m0_grnt_ = `DISABLE_;
    m1_grnt_ = `DISABLE_;

    case(owner)
        BUS_OWNER_MASTER_0 : 
            m0_grnt_ = `ENABLE_;

        BUS_OWNER_MASTER_1 : 
            m1_grnt_ = `ENABLE_;

    endcase
end

/*****************状态转移********************/
always @(posedge clk or negedge reset) begin
    if(reset == 0)
        owner <=  BUS_OWNER_MASTER_0;
    else
        case(owner)
            BUS_OWNER_MASTER_0:begin
                if(m0_req_ == `ENABLE_)
                    owner <= BUS_OWNER_MASTER_0;
                else if(m1_req_ == `ENABLE_)
                    owner <= BUS_OWNER_MASTER_1;
            end
            BUS_OWNER_MASTER_1:begin
                if(m1_req_ == `ENABLE_)
                    owner <= BUS_OWNER_MASTER_1;
                else if(m0_req_ == `ENABLE_)
                    owner <= BUS_OWNER_MASTER_0;
            end
    
        endcase
end

endmodule