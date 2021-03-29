`ifndef CORE_H_
`define CORE_H_
    `define                 ENABLE                  1'b1
    `define                 DISABLE                 1'b0
    `define                 ENABLE_                 1'b0
    `define                 DISABLE_                1'b1

    `define                 RESET_EDGE              negedge
    `define                 RESET_ENABLE            1'b0

//IF阶段
    `define                 PC_LEN                  32
    `define                 PC_RESET                0
    `define                 PC_INC                  4
    `define                 PC_HINC                 2

    
//ID阶段
    `define                 ISA_LEN                 32

    `define                 WORD_LEN                32
    `define                 HWORD_LEN               16
    `define                 DWORD_LEN               64
    `define                 ADDR_LEN                32



    `define                 REG_LENGTH_32I          32
    `define                 REG_DEPTH_32I           32


//ISA defines
//NOP
    `define                 RV32I_INST_NOP          32'b0000_0000_0000_0000_0000_0000_0001_0011

//OP_IMM
    `define                 RV32I_OP_IMM            7'b0010011
    `define                 RV32I_ADDI              3'b000
    `define                 RV32I_SLTI              3'b010
    `define                 RV32I_SLTIU             3'b011
    `define                 RV32I_XORI              3'b100
    `define                 RV32I_ORI               3'b110
    `define                 RV32I_ANDI              3'b111
    `define                 RV32I_SLLI              3'b001
    `define                 RV32I_SRLI              3'b101
    `define                 RV32I_SRAI              3'b101
//OP_MM
    `define                 RV32I_OP_MM             7'b0110011
    `define                 RV32I_ADD               3'b000
    `define                 RV32I_SUB               3'b000
    `define                 RV32I_SLL               3'b001
    `define                 RV32I_SLT               3'b010
    `define                 RV32I_SLTU              3'b011
    `define                 RV32I_XOR               3'b100
    `define                 RV32I_SRL               3'b101
    `define                 RV32I_SRA               3'b101
    `define                 RV32I_OR                3'b110
    `define                 RV32I_AND               3'b111

//OP_LUI
    `define                 RV32I_LUI               7'b0110111
//OP_AUIPC
    `define                 RV32I_AUIPC             7'b0010111
//OP_JAL
    `define                 RV32I_JAL               7'b1101111
//OP_JALR
    `define                 RV32I_JALR              7'b1100111
//OP_BRANCH
    `define                 RV32I_OP_BRANCH         7'b1100011
    `define                 RV32I_BEQ               3'b000
    `define                 RV32I_BNE               3'b001
    `define                 RV32I_BLT               3'b100
    `define                 RV32I_BGE               3'b101
    `define                 RV32I_BLTU              3'b110
    `define                 RV32I_BGEU              3'b111
//OP_LOAD
    `define                 RV32I_OP_LOAD           7'b0000011
    `define                 RV32I_LB                3'b000
    `define                 RV32I_LH                3'b001
    `define                 RV32I_LW                3'b010
    `define                 RV32I_LBU               3'b100
    `define                 RV32I_LHU               3'b101

//OP_STORE
    `define                 RV32I_OP_STORE          7'b0100011
    `define                 RV32I_SB                3'b000
    `define                 RV32I_SH                3'b001
    `define                 RV32I_SW                3'b010

//OP_MISC_MEM
    `define                 RV32I_OP_MISC_MEM       7'b0001111
    `define                 RV32I_FENCE             3'b000
    `define                 RV32Z_FENCEI            3'b001
//OP_SYSTEM
    `define                 RV32I_OP_SYSTEM         7'b1110011
    `define                 RV32I_ECALL             3'b000
    `define                 RV32I_EBREAK            3'b000
    `define                 RV32Z_CSRRW             3'b001
    `define                 RV32Z_CSRRS             3'b010
    `define                 RV32Z_CSRRC             3'b011
    `define                 RV32Z_CSRRWI            3'b101
    `define                 RV32Z_CSRRCI            3'b111
    



`endif