`include "param.v"

module i2c_intf(
    input               clk         ,
    input               rst_n       ,

    input               req         ,
    input       [3:0]   cmd         ,
    input       [7:0]   din         ,

    output      [7:0]   dout        ,
    output              done        ,
    output              slave_ack   ,
    output              i2c_scl     ,
    input               i2c_sda_i   ,
    output              i2c_sda_o   ,
    output              i2c_sda_oe     
    );

//状态机参数定义

    localparam  IDLE  = 7'b000_0001,
                START = 7'b000_0010,
                WRITE = 7'b000_0100,
                RACK  = 7'b000_1000,
                READ  = 7'b001_0000,
                SACK  = 7'b010_0000,
                STOP  = 7'b100_0000;

//信号定义

    reg     [6:0]       state_c     ;
    reg     [6:0]       state_n     ;

    reg     [8:0]       cnt_scl     ;//产生i2c时钟
    wire                add_cnt_scl ;
    wire                end_cnt_scl ;
    reg     [3:0]       cnt_bit     ;//传输数据 bit计数器
    wire                add_cnt_bit ;
    wire                end_cnt_bit ;
    reg     [3:0]       bit_num     ;
    
    reg                 scl         ;//输出寄存器
    reg                 sda_out     ;
    reg                 sda_out_en  ;

    reg     [7:0]       rx_data     ;
    reg                 rx_ack      ;
    reg     [3:0]       command     ;
    reg     [7:0]       tx_data     ;//发送数据

    wire                idle2start  ; 
    wire                idle2write  ; 
    wire                idle2read   ; 
    wire                start2write ; 
    wire                start2read  ; 
    wire                write2rack  ; 
    wire                read2sack   ; 
    wire                rack2stop   ; 
    wire                sack2stop   ; 
    wire                rack2idle   ; 
    wire                sack2idle   ; 
    wire                stop2idle   ; 


//状态机
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            state_c <= IDLE ;
        end
        else begin
            state_c <= state_n;
       end
    end
    
    always @(*) begin 
        case(state_c)  
            IDLE :begin
                if(idle2start)
                    state_n = START ;
                else if(idle2write)
                    state_n = WRITE ;
                else if(idle2read)
                    state_n = READ ;
                else 
                    state_n = state_c ;
            end
            START :begin
                if(start2write)
                    state_n = WRITE ;
                else if(start2read)
                    state_n = READ ;
                else 
                    state_n = state_c ;
            end
            WRITE :begin
                if(write2rack)
                    state_n = RACK ;
                else 
                    state_n = state_c ;
            end
            RACK :begin
                if(rack2stop)
                    state_n = STOP ;
                else if(rack2idle)
                    state_n = IDLE ;
                else 
                    state_n = state_c ;
            end
            READ :begin
                if(read2sack)
                    state_n = SACK ;
                else 
                    state_n = state_c ;
            end
            SACK :begin
                if(sack2stop)
                    state_n = STOP ;
                else if(sack2idle)
                    state_n = IDLE ;
                else 
                    state_n = state_c ;
            end
            STOP :begin
                if(stop2idle)
                    state_n = IDLE ;
                else 
                    state_n = state_c ;
            end
            default : state_n = IDLE ;
        endcase
    end
    
    assign idle2start  = state_c==IDLE  && (req && (cmd&`CMD_START));
    assign idle2write  = state_c==IDLE  && (req && (cmd&`CMD_WRITE));
    assign idle2read   = state_c==IDLE  && (req && (cmd&`CMD_READ ));
    assign start2write = state_c==START && (end_cnt_bit && (command&`CMD_WRITE));
    assign start2read  = state_c==START && (end_cnt_bit && (command&`CMD_READ ));
    assign write2rack  = state_c==WRITE && (end_cnt_bit);
    assign read2sack   = state_c==READ  && (end_cnt_bit);
    assign rack2stop   = state_c==RACK  && (end_cnt_bit && (command&`CMD_STOP ));
    assign sack2stop   = state_c==SACK  && (end_cnt_bit && (command&`CMD_STOP ));
    assign rack2idle   = state_c==RACK  && (end_cnt_bit && (command&`CMD_STOP ) == 0);
    assign sack2idle   = state_c==SACK  && (end_cnt_bit && (command&`CMD_STOP ) == 0);
    assign stop2idle   = state_c==STOP  && (end_cnt_bit );
    
//计数器
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            cnt_scl <= 0; 
        end
        else if(add_cnt_scl) begin
            if(end_cnt_scl)
                cnt_scl <= 0; 
            else
                cnt_scl <= cnt_scl+1 ;
       end
    end
    assign add_cnt_scl = (state_c != IDLE);
    assign end_cnt_scl = add_cnt_scl  && cnt_scl == (`SCL_PERIOD)-1 ;

    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            cnt_bit <= 0; 
        end
        else if(add_cnt_bit) begin
            if(end_cnt_bit)
                cnt_bit <= 0; 
            else
                cnt_bit <= cnt_bit+1 ;
       end
    end
    assign add_cnt_bit = (end_cnt_scl);
    assign end_cnt_bit = add_cnt_bit  && cnt_bit == (bit_num)-1 ;

    always  @(*)begin
        if(state_c == WRITE | state_c == READ) begin
            bit_num = 8;
        end
        else begin 
            bit_num = 1;
        end 
    end
//command
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            command <= 0;
        end
        else if(req)begin
            command <= cmd;
        end
    end

//tx_data
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            tx_data <= 0;
        end
        else if(req)begin
            tx_data <= din;
        end
    end

//scl
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            scl <= 1'b1;
        end
        else if(idle2start | idle2write | idle2read)begin//开始发送时，拉低
            scl <= 1'b0;
        end
        else if(add_cnt_scl && cnt_scl == `SCL_HALF-1)begin 
            scl <= 1'b1;
        end 
        else if(end_cnt_scl && ~stop2idle)begin 
            scl <= 1'b0;
        end 
    end

//sda_out
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sda_out <= 1'b1;
        end
        else if(state_c == START)begin          //发起始位
            if(cnt_scl == `LOW_HLAF)begin       //时钟低电平时拉高sda总线
                sda_out <= 1'b1;
            end
            else if(cnt_scl == `HIGH_HALF)begin    //时钟高电平时拉低sda总线 
                sda_out <= 1'b0;                //保证从机能检测到起始位
            end 
        end 
        else if(state_c == WRITE && cnt_scl == `LOW_HLAF)begin  //scl低电平时发送数据   并串转换
            sda_out <= tx_data[7-cnt_bit];      
        end 
        else if(state_c == SACK && cnt_scl == `LOW_HLAF)begin  //发应答位
            sda_out <= (command&`CMD_STOP)?1'b1:1'b0;
        end 
        else if(state_c == STOP)begin //发停止位
            if(cnt_scl == `LOW_HLAF)begin       //时钟低电平时拉低sda总线
                sda_out <= 1'b0;
            end
            else if(cnt_scl == `HIGH_HALF)begin    //时钟高电平时拉高sda总线 
                sda_out <= 1'b1;                //保证从机能检测到停止位
            end 
        end 
    end

//sda_out_en  总线输出数据使能
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            sda_out_en <= 1'b0;
        end
        else if(idle2start | idle2write | read2sack | rack2stop)begin
            sda_out_en <= 1'b1;
        end
        else if(idle2read | start2read | write2rack | stop2idle)begin 
            sda_out_en <= 1'b0;
        end 
    end

//rx_data       接收读入的数据
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            rx_data <= 0;
        end
        else if(state_c == READ && cnt_scl == `HIGH_HALF)begin
            rx_data[7-cnt_bit] <= i2c_sda_i;    //串并转换
        end
    end

//rx_ack
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            rx_ack <= 1'b1;
        end
        else if(state_c == RACK && cnt_scl == `HIGH_HALF)begin
            rx_ack <= i2c_sda_i;
        end
    end


//输出信号

    assign i2c_scl    = scl         ;
    assign i2c_sda_o  = sda_out     ;
    assign i2c_sda_oe = sda_out_en  ;
   
    assign dout = rx_data;
    assign done = rack2idle | sack2idle | stop2idle;
    assign slave_ack = rx_ack;

endmodule

