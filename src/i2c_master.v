`include "param.v"

module i2c_master (
    input               clk     ,
    input               rst_n   ,
    
    input       [23:0]   din     ,
    input               din_vld ,
    output              req     ,
    output      [3:0]   cmd     ,
    output      [7:0]   data    ,
    input               done    , //传输完成标志
    output			    send_done);


//状态机参数
    localparam      IDLE    = 6'b00_0001    ,
                    WR_REQ  = 6'b00_0010    ,//写传输 发送请求、命令、数据
                    WAIT_WR = 6'b00_0100    ,//等待一个字节传完
                    RD_REQ  = 6'b00_1000    ,//读传输 发送请求、命令、数据
                    WAIT_RD = 6'b01_0000    ,//等待一个自己传完
                    DONE    = 6'b10_0000    ;//一次读或写完成
//信号定义
    reg     [5:0]   state_c         ;
    reg     [5:0]   state_n         ;

    reg     [7:0]   cnt_byte        ;//数据传输 字节计数器
    wire            add_cnt_byte    ;
    wire            end_cnt_byte    ;

    reg             tx_req          ;//请求
    reg     [3:0]   tx_cmd          ;
    reg     [7:0]   tx_data         ;
    
    // reg     [8:0]   wr_addr         ;//写eeprom地址
    // reg     [8:0]   rd_addr         ;//读eeprom地址
    
    // reg     [7:0]   user_data       ;
    // reg             user_data_vld   ;

    wire            idle2wr_req     ; 
    wire            wr_req2wait_wr  ;
    wire            wait_wr2wr_req  ;
    wire            wait_wr2done    ;
    wire            idle2rd_req     ;
    wire            rd_req2wait_rd  ;
    wire            wait_rd2rd_req  ;
    wire            wait_rd2done    ;
    wire            done2idle       ;

//状态机设计
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
                if(idle2wr_req)
                    state_n = WR_REQ ;
                else if(idle2rd_req)
                    state_n = RD_REQ ;
                else 
                    state_n = state_c ;
            end
            WR_REQ :begin
                if(wr_req2wait_wr)
                    state_n = WAIT_WR ;
                else 
                    state_n = state_c ;
            end
            WAIT_WR :begin
                if(wait_wr2wr_req)
                    state_n = WR_REQ ;
                else if(wait_wr2done)
                    state_n = DONE ;
                else 
                    state_n = state_c ;
            end
            RD_REQ :begin
                if(rd_req2wait_rd)
                    state_n = WAIT_RD ;
                else 
                    state_n = state_c ;
            end
            WAIT_RD :begin
                if(wait_rd2rd_req)
                    state_n = RD_REQ ;
                else if(wait_rd2done)
                    state_n = DONE ;
                else 
                    state_n = state_c ;
            end
            DONE :begin
                if(done2idle)
                    state_n = IDLE ;
                else 
                    state_n = state_c ;
            end
            default : state_n = IDLE ;
        endcase
    end

    assign idle2wr_req      = state_c==IDLE     && din_vld;
    assign wr_req2wait_wr   = state_c==WR_REQ   && (1'b1);
    assign wait_wr2wr_req   = state_c==WAIT_WR  && (done & cnt_byte < 3);
    assign wait_wr2done     = state_c==WAIT_WR  && (end_cnt_byte);
    assign idle2rd_req      = state_c==IDLE     && (0);
    assign rd_req2wait_rd   = state_c==RD_REQ   && (1'b1);
    assign wait_rd2rd_req   = state_c==WAIT_RD  && 0;
    assign wait_rd2done     = state_c==WAIT_RD  && (end_cnt_byte);
    assign done2idle        = state_c==DONE     ;
    
//cnt_byte  
   
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            cnt_byte <= 0; 
        end
        else if(add_cnt_byte) begin
            if(end_cnt_byte)
                cnt_byte <= 0; 
            else
                cnt_byte <= cnt_byte+1 ;
       end
    end
    assign add_cnt_byte = (state_c==WAIT_WR | state_c==WAIT_RD) & done;
    assign end_cnt_byte = add_cnt_byte  && cnt_byte == 3;
//输出

    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            TX(1'b0,4'd0,8'd0);
        end
        else if(state_c==WR_REQ)begin
            case(cnt_byte)
                0           :TX(1'b1,{`CMD_START | `CMD_WRITE},`I2C_ADR);//发起始位、写控制字
                1           :TX(1'b1,{`CMD_WRITE },din[23:16]);  //发高位地址
                2           :TX(1'b1,{`CMD_WRITE },din[15:8]);  //发低位地址
                3           :TX(1'b1,{`CMD_WRITE | `CMD_STOP},din[7:0]);  //发数据,结束位
                default     :TX(1'b0,tx_cmd,tx_data);
            endcase 
        end
        else begin 
             TX(1'b0,tx_cmd,tx_data);
        end 
    end
//用task发送请求、命令、数据（地址+数据）
    task TX;   
        input                   req     ;
        input       [3:0]       command ;
        input       [7:0]       data    ;
        begin 
            tx_req  = req;
            tx_cmd  = command;
            tx_data = data;
        end 
    endtask   
//输出

    assign req     = tx_req ; 
    assign cmd     = tx_cmd ; 
    assign data    = tx_data; 
    assign send_done = done2idle;



endmodule //camera_config_ctrl