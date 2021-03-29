`ifndef BUS_H_
`define BUS_H_



    `define     DATA_LEN        32
    `define     ADDR_LEN        32  
    `define     MASTER_SIZE     2
    `define     SLAVE_SIZE      3

    `define     SLAVE_0_BEGIN   `DATA_LEN'h00_00_00_00;
    `define     SLAVE_0_END     `DATA_LEN'h00_00_FF_FF;
    `define     SLAVE_1_BEGIN   `DATA_LEN'h00_01_00_00;
    `define     SLAVE_1_END     `DATA_LEN'h00_FF_FF_FF;
    `define     SLAVE_2_BEGIN   `DATA_LEN'h01_00_00_00;
    `define     SLAVE_2_END     `DATA_LEN'hFF_FF_FF_FF;

`endif