`include "core.h"
//纯组合电路

module exu_alu
(
    //from idu_dec
    input      wire    [`ADDR_LEN-1:0]         op_1_i,
    input      wire    [`ADDR_LEN-1:0]         op_2_i,
    input      wire    [`ADDR_LEN-1:0]         jmp_1_i,
    input      wire    [`ADDR_LEN-1:0]         jmp_2_i,
    input      wire    [`ISA_LEN-1:0]          inst_i, //指令 
    input      wire    [`ADDR_LEN-1:0]         pc_i, //当前指令的pc  
    input      wire                            jal_i,
    input      wire                            wr_en_,//这一拍允许写
    input      wire     [4:0]                  wb_addr_i,//write back addr 
    input      wire                            mem_rw_i, //load指令就是读，store指令就是写


    //form || to ctrl
    output     wire                            wait_,
    output     wire     [`ADDR_LEN-1:0]        jmp_addr_o,
    output     wire                            jmp_o,
    
    //from || to mem 读写mem
    input      wire    [`WORD_LEN-1:0]         mem_rd_data_i,
    input      wire                            mem_busy_,
    output     wire                            mem_rw_o,
    output     wire    [`WORD_LEN-1:0]         mem_wr_data_o,
    output     wire    [`ADDR_LEN-1:0]         mem_addr_o,
    output     wire    [2:0]                   mem_width,


    //to regs 只写
    output      wire            [4:0]                    wr_addr_o,
    output      wire            [`REG_LENGTH_32I-1:0]    wr_data_o,
    output      wire                                     reg_wr_en_,


    



);
//指令切片
wire [6:0] opcode = inst_i[6:0];
wire [4:0] rd = inst_i[11:7];
wire [2:0] funct3 = inst_i[14:12];
wire [4:0] rs1 = inst_i[19:15];
wire [4:0] rs2 = inst_i[24:20];
wire [7:0] funct7 = inst_i[31:25];


//通用计算器
wire  [`ADDR_LEN-1:0] ops_sll = op_1_i << op_2_i[4:0];
wire  [`ADDR_LEN-1:0] ops_srl = op_1_i >> op_2_i[4:0];
wire  [`ADDR_LEN-1:0] ops_sra = ($signed(op_1_i)) >>> op_2_i[4:0];
wire  [`ADDR_LEN-1:0] ops_add = op_1_i + op_2_i;
wire  [`ADDR_LEN-1:0] ops_and = op_1_i && op_2_i;
wire  [`ADDR_LEN-1:0] ops_or  = op_1_i || op_2_i;
wire  [`ADDR_LEN-1:0] ops_xor = op_1_i ^ op_2_i;
wire                  ops_ge  = $signed(op_1_i) >= $signed(op_2_i); 
wire                  ops_geu = op_1_i >= op_2_i;
wire                  ops_eq  = op_1_i == op_2_i;

//写回控制
assign      reg_wr_en_ = wr_en_;
assign      wr_addr_o =   wb_addr_i;
reg    [`REG_LENGTH_32I-1:0]  wb_data;
assign      wr_data_o = wb_data;

wire  jmps_add = jmp_1_i + jmp_2_i;


always @(*) begin
    //TODO:初始化输出
    

    case(opcode)
        `RV32I_OP_IMM:begin 
            case(funct3)
                `RV32I_ADDI:begin //立即数相加
                    wb_data = ops_add;
                end
                `RV32I_SLTI:begin
                    if(ops_ge == `DISABLE)begin
                        //rs1 < imm 
                        wb_data = op_1_i;
                    end
                    else begin
                        wb_data = 0;
                    end
                end
                `RV32I_SLTIU:begin
                    if(ops_geu == `DISABLE)begin
                        //rs1 < imm 
                        wb_data = op_1_i;
                    end
                    else begin
                        wb_data = 0;
                    end
                end
                `RV32I_XORI:begin
                    wb_data = ops_xor;
                end
                `RV32I_ORI:begin
                    wb_data = ops_or;
                end
                `RV32I_ANDI:begin
                    wb_data = ops_and;
                end
                `RV32I_SLLI:begin
                    wb_data = ops_sll;
                end
                `RV32I_SRLI,`RV32I_SRAI:begin
                    wb_data = (funct7 == 0)?ops_srl : ops_sra;
                end
            endcase
            
        end
        `RV32I_OP_MM:begin
            case(funct3)
                `RV32I_ADD:begin //立即数相加
                    wb_data = ops_add;
                end
                `RV32I_ADD:begin
                    wb_data = op_1_i - op_2_i;
                end
                `RV32I_SLT:begin
                    if(ops_ge == `DISABLE)begin
                        //rs1 < imm 
                        wb_data = op_1_i;
                    end
                    else begin
                        wb_data = 0;
                    end
                end
                `RV32I_SLTU:begin
                    if(ops_geu == `DISABLE)begin
                        //rs1 < imm 
                        wb_data = op_1_i;
                    end
                    else begin
                        wb_data = 0;
                    end
                end
                `RV32I_XOR:begin
                    wb_data = ops_xor;
                end
                `RV32I_OR:begin
                    wb_data = ops_or;
                end
                `RV32I_AND:begin
                    wb_data = ops_and;
                end
                `RV32I_SLL:begin
                    wb_data = ops_sll;
                end
                `RV32I_SRL,`RV32I_SRA:begin
                    wb_data = (funct7 == 0)?ops_srl : ops_sra;
                end

            endcase
        end
        `RV32I_LUI:begin//TODO:
            rd_addr_0 = rs1;
            rd_addr_1 = 0;
            op_1_o = inst_i[31:12];
            op_2_o = 0;
            jal_o = `DISABLE;
            jmp_1_o = 0;
            jmp_2_o = 0;
            wr_en_ = `ENABLE_;
        end
        `RV32I_AUIPC:begin//TODO:
            //TODO:没看懂
            rd_addr_0 = 0;
            rd_addr_1 = 0;
        end
        `RV32I_JAL:begin //跳转指令，jmp操作符里是需要跳转的位置，op操作符是相加后写回
            jmp = `ENABLE;
            wb_data = jmps_add + op_2_i;//将jump过后的pc写入: pc+jmp_imm+inc
            jmp_addr_o = jmps_add;
        end
        `RV32I_JALR:begin
            jmp = `ENABLE;
            wb_data = {jmps_add[31:1],1'b0} + op_2_i;//将jump过后的pc写入: pc+jmp_imm+inc
            jmp_addr_o = {jmps_add[31:1],1'b0};
        end
        `RV32I_OP_BRANCH:begin //pc相对寻址 立即数寻址
            case (funct3)
                `RV32I_BEQ:begin
                    jmp = (ops_eq == `ENABLE)?1'b1:1'b0;
                    jmp_addr_o = jmps_add;
                end
                `RV32I_BNE:begin
                    jmp = (ops_eq == `DISABLE)?1'b1:1'b0;
                    jmp_addr_o = jmps_add;
                end
                `RV32I_BLT:begin
                    jmp = (ops_ge == `DISABLE)?1'b1:1'b0;
                    jmp_addr_o = jmps_add;
                end
                `RV32I_BLTU:begin
                    jmp = (ops_geu == `DISABLE)?1'b1:1'b0;
                    jmp_addr_o = jmps_add;
                end
                `RV32I_BGE:begin
                    jmp = (ops_ge == `ENABLE)?1'b1:1'b0;
                    jmp_addr_o = jmps_add;
                end
                `RV32I_BGEU:begin
                    jmp = (ops_geu == `ENABLE)?1'b1:1'b0;
                    jmp_addr_o = jmps_add;
                end
            endcase
        end
        `RV32I_OP_LOAD:begin//TODO:时序问题 是否需要stall
            case(funct3)
                `RV32I_LB:begin
                    //读8位后进行拓展
                    wb_data = {24'b0,mem_rd_data_i[7:0]};
                end
                `RV32I_LBU:begin
                    wb_data = {24{mem_rd_data_i[7]},mem_rd_data_i[7:0]};
                end
                `RV32I_LH:begin
                    wb_data = {16'b0,mem_rd_data_i[15:0]}; 
                end
                `RV32I_LHU:begin
                    wb_data = {16{mem_rd_data_i[15]},mem_rd_data_i[15:0]};
                end
                `RV32I_LW:begin
                    wb_data = mem_rd_data_i;
                end
            
            endcase
        end
        `RV32I_OP_STORE:begin
            case(funct3)
                `RV32I_SB:begin
                    
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
            jal_o = `DISABLE;
            jmp_1_o = 0;
            jmp_2_o = 0;
            wr_en_ = `DISABLE_;
        end
    endcase
    

end





endmodule