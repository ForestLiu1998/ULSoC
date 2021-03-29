`include "bus.h"
//主对从可读可写，从无法对主做操作
module RHB
(
    input       wire                        clk,
    input       wire                        reset,
    //master 接口
    input       wire    [`ADDR_LEN-1:0]     m0_rd_addr,//操作地址
    input       wire                        m0_req_,//请求信号
    input       wire                        m0_rw,//读写信号
    input       wire                        m0_va_,//地址有效信号
    input       wire    [`DATA_LEN-1:0]     m0_wr_data,//写信息
    input       wire    [`ADDR_LEN-1:0]     m1_wr_addr,
    input       wire                        m1_req_,
    input       wire                        m0_rw,
    input       wire    [`DATA_LEN-1:0]     m1_wr_data,//写信息
    input       wire                        m1_va_,

    output      wire                        m0_grnt,//授权信号
    output      wire                        m1_grnt,  
    output      wire    [`DATA_LEN-1:0]     m0_rd_data,//读信息
    output      wire    [`DATA_LEN-1:0]     m1_rd_data,

    //slave 接口
    input      wire    [`DATA_SIZE-1:0]    s_rd_data,//从读信号
    input       wire                        s0_rw,//读写控制信号
    input       wire                        s1_rw,
    input       wire                        s2_rw

    output      wire    [`ADDR_LEN-1:0]     s_addr,//从地址
    output      wire                        s0_sel_, //选通信号
    output      wire                        s1_sel_,
    output      wire                        s2_sel_,
    output      wire                        s0_va_,//地址有效信号
    output      wire                        s1_va_,
    output      wire                        s2_va_
);
