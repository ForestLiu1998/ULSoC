`include "core.h"
//解码器 仅负责把inst解码，并且访问寄存器获取寄存器的值，需要链接寄存器
//纯组合电路
module idu_dec
(
    //from IFU
    input       wire    [`ISA_LEN-1:0]      inst_i, //指令 
    input       wire    [`ADDR_LEN-1:0]     pc_i, //当前指令的pc

    //from||to REGS 只负责读
    input      wire     [`REG_LENGTH_32I-1:0]    rd_data_0,
    input      wire     [`REG_LENGTH_32I-1:0]    rd_data_1,
    output     reg      [4:0]                    rd_addr_0,
    output     reg      [4:0]                    rd_addr_1,

    //to EXU & BPU
    output     reg     [`ADDR_LEN-1:0]         op_1_o,
    output     reg     [`ADDR_LEN-1:0]         op_2_o,
    output     reg     [`ADDR_LEN-1:0]         jmp_1_o,
    output     reg     [`ADDR_LEN-1:0]         jmp_2_o,
    output     wire     [`ISA_LEN-1:0]         inst_o, //指令 
    output     wire    [`ADDR_LEN-1:0]         pc_o, //当前指令的pc  
    output     reg                             jmp_o,
    output     reg                             wr_en_,
    output     wire     [4:0]                  wb_addr_o,//write back addr

    //to MEM
    output     reg                             mem_rw, //load指令就是读，store指令就是写
    output     reg                             mem_req_//请求总线信号
);

wire [6:0] opcode = inst_i[6:0];
wire [4:0] rd = inst_i[11:7];
wire [2:0] funct3 = inst_i[14:12];
wire [4:0] rs1 = inst_i[19:15];
wire [4:0] rs2 = inst_i[24:20];
wire [7:0] funct7 = inst_i[31:25];


assign wb_addr_o = rd;
assign pc_o = pc_i;
assign inst_o = inst_i;

always @(*) begin
    //初始化输出
    rd_addr_0 = 0;
    rd_addr_1 = 0;
    op_1_o = 0;
    op_2_o = 0;
    jmp_o = `DISABLE;
    jmp_1_o = 0;
    jmp_2_o = 0;
    wr_en_ = `DISABLE_;

    case(opcode)
        `RV32I_OP_IMM:begin //rs1放在操作1，立即数放在操作2
            case(funct3)
                `RV32I_ADDI,`RV32I_SLTI,`RV32I_SLTIU,`RV32I_XORI,`RV32I_ORI,`RV32I_ANDI,`RV32I_SLLI,`RV32I_SRLI,`RV32I_SRAI:begin
                    rd_addr_0 = rs1;
                    rd_addr_1 = 0;
                    op_1_o = rd_data_0;
                    op_2_o = {{20{inst_i[31]}}, inst_i[31:20]};
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `ENABLE_;
                end
             
                default:begin
                    rd_addr_0 = 0;
                    rd_addr_1 = 0;
                    op_1_o = 0;
                    op_2_o = 0;
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `DISABLE_;
                end
            endcase
            
        end
        `RV32I_OP_MM:begin
            case(funct3)//TODO:区分加减，先进行补码运算？可以减少后续ex阶段的一个减法器使用
                `RV32I_ADD,`RV32I_SUB,`RV32I_SLL,`RV32I_SLT,`RV32I_SLTU,`RV32I_XOR,`RV32I_SRL,`RV32I_SRA,`RV32I_OR,`RV32I_AND:begin
                    rd_addr_0 = rs1;
                    rd_addr_1 = rs2;
                    op_1_o = rd_data_0;
                    op_2_o = rd_data_1;
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `ENABLE_;
                end
                default:begin
                    rd_addr_0 = 0;
                    rd_addr_1 = 0;
                    op_1_o = 0;
                    op_2_o = 0;
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `DISABLE_;
                end
            endcase
        end
        `RV32I_LUI:begin
            rd_addr_0 = rs1;
            rd_addr_1 = 0;
            op_1_o = inst_i[31:12];
            op_2_o = 0;
            jmp_o = `DISABLE;
            jmp_1_o = 0;
            jmp_2_o = 0;
            wr_en_ = `ENABLE_;
        end
        `RV32I_AUIPC:begin
            //TODO:没看懂
            rd_addr_0 = 0;
            rd_addr_1 = 0;
        end
        `RV32I_JAL:begin //跳转指令，jmp操作符里是需要跳转的位置，op操作符是相加后写回
            rd_addr_0 = 0;
            rd_addr_1 = 0;
            op_1_o = pc_i;
            op_2_o = `PC_INC;
            jmp_o = `ENABLE;
            jmp_1_o = pc_i;
            jmp_2_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
            wr_en_ = `ENABLE_;
        end
        `RV32I_JALR:begin
            rd_addr_0 = rs1;
            rd_addr_1 = 0;
            op_1_o = rd_data_0;
            op_2_o = `PC_INC;
            jmp_o = `ENABLE;
            jmp_1_o = pc_i;
            jmp_2_o = {{20{inst_i[31]}}, inst_i[31:20]};
            wr_en_ = `ENABLE_;
        end
        `RV32I_OP_BRANCH:begin //pc相对寻址 立即数寻址
            case (funct3)
                `RV32I_BEQ,`RV32I_BNE,`RV32I_BLT,`RV32I_BGE,`RV32I_BLTU,`RV32I_BGEU:begin
                    rd_addr_0 = rs1;
                    rd_addr_1 = rs2;
                    op_1_o = rd_data_0;
                    op_2_o = rd_data_1;
                    jmp_o = `ENABLE;
                    jmp_1_o = pc_i;
                    jmp_2_o = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                    wr_en_ = `DISABLE_;
                end
                default:begin
                    rd_addr_0 = 0;
                    rd_addr_1 = 0;
                    op_1_o = 0;
                    op_2_o = 0;
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `DISABLE_;
                end
            endcase
        end
        `RV32I_OP_LOAD:begin
            case(funct3)
                `RV32I_LB,`RV32I_LH,`RV32I_LW,`RV32I_LBU,`RV32I_LHU:begin
                    rd_addr_0 = rs1;
                    rd_addr_1 = 0;
                    op_1_o = rd_data_0;
                    op_2_o = {{20{inst_i[31]}}, inst_i[31:20]};
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `ENABLE_;
                end
                default:begin
                    rd_addr_0 = 0;
                    rd_addr_1 = 0;
                    op_1_o = 0;
                    op_2_o = 0;
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `DISABLE_;

                end
            
            endcase
        end
        `RV32I_OP_STORE:begin
            case(funct3)
                `RV32I_SB,`RV32I_SH,`RV32I_SW:begin
                    rd_addr_0 = rs1;
                    rd_addr_1 = rs2;
                    op_1_o = rd_data_0;
                    op_2_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                    jmp_o = `DISABLE;
                    jmp_1_o = rd_data_1;
                    jmp_2_o = 0;
                    wr_en_ = `DISABLE_;
                end
                default:begin
                    rd_addr_0 = 0;
                    rd_addr_1 = 0;
                    op_1_o = 0;
                    op_2_o = 0;
                    jmp_o = `DISABLE;
                    jmp_1_o = 0;
                    jmp_2_o = 0;
                    wr_en_ = `DISABLE_;
                end

            
            endcase
        end
        `RV32I_OP_MISC_MEM:begin
            case(funct3)
                `RV32I_FENCE:begin
                    rd_addr_0 = rs1;
                    rd_addr_1 = rs2;
                    op_1_o = inst_i;
                    op_2_o = 32'h4;
                    //TODO:解决fence的解码
                end
            endcase
        end

        //`RV32I_OP_SYSTEM:begin
            //TODO:system类指令的解码

                
        //end
        default:begin
            rd_addr_0 = 0;
            rd_addr_1 = 0;
            op_1_o = 0;
            op_2_o = 0;
            jmp_o = `DISABLE;
            jmp_1_o = 0;
            jmp_2_o = 0;
            wr_en_ = `DISABLE_;
        end
    endcase
    

end


endmodule