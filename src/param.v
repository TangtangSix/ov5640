//i2c时钟参数
`define  SCL_PERIOD  250
`define  SCL_HALF    125
`define  LOW_HLAF    65 
`define  HIGH_HALF   190

//i2c命令参数
`define CMD_START   4'b0001
`define CMD_WRITE   4'b0010
`define CMD_READ    4'b0100
`define CMD_STOP    4'b1000

//SDRAM读写FIFO阈值
`define RFIFO_MAX_NUM  1600
`define RFIFO_MIN_NUM  800
`define WFIFO_MAX_NUM  1600
`define WFIFO_MIN_NUM  800 
//sdram参数定义
`define     USER_BL     512
`define     RD_UT       1500
`define     RD_LT       600
`define     BURST_MAX   `H_AP * `V_AP
//SDRAM读写FIFO阈值 debug
// `define RFIFO_MAX_NUM  8
// `define RFIFO_MIN_NUM  4
// `define WFIFO_MAX_NUM  8
// `define WFIFO_MIN_NUM  4 
//I2C外设地址参数定义



//从机ID定义
`define WR_ID 8'h78
`define RD_ID 8'h79

//配置寄存器个数
`define REG_NUM     254
// `define     REG_NUM     252
`define     I2C_ADR 8'h78  //SCCB_ID地址
`define     WR_BIT  1'b0    //bit0
`define     RD_BIT  1'b1    //bit0

`ifdef  RANDOM_READ
    `define RD_BYTE 4
`elsif  SEQU_READ
    `define RD_BYTE 19
`endif 

//串口参数定义

`define  BAUD_9600   5208
`define  BAUD_19200  2604
`define  BAUD_38400  1302
`define  BAUD_115200 434

`define STOP_BIT  1'b1
`define START_BIT 1'b0



//vga时序参数

`define     H_SW    40      //行同步脉冲
`define     H_BP    220     //行后沿
`define     H_AP    1280    //行有效显示区域
`define     H_FP    110     //行前沿
`define     H_START `H_SW + `H_BP 
`define     H_END   `H_TP - `H_FP
`define     H_TP    1650


`define     V_SW    5       //场同步脉冲
`define     V_BP    20      //场后沿
`define     V_AP    720     //场有效显示区域
`define     V_FP    5       //场前沿
`define     V_START `V_SW + `V_BP 
`define     V_END   `V_TP - `V_FP
`define     V_TP    750