`include "param.v"

module rw_control #(parameter BURST_LEN = 5,BURST_MAX = 24'he1000)(
    input               clk                ,//100M
    input               clk_in             ,//84
    input               clk_out            ,//75
    input               rst_n              ,
    //应用层接口
    input			wire						sop,
    input			wire						eop,
    input			wire		[ 15:0 ]		din,
    input			wire						din_vld,
    input			wire						rd_req,
    output			wire		[ 15:0 ]		dout,
    output			wire						dout_vld,
    //avalon-mm master
    input               avs_waitrequest    ,
    input   [15:0]      avs_readdata       ,
    input               avs_readdata_vld   ,
    output  [23:0]      avm_addr           ,
    output              avm_write          ,//低电平有效
    output  [15:0]      avm_writedata      ,
    output              avm_read        ,

    output			wire						test        
    );

//参数定义
    localparam  IDLE  = 3'b001,
                WRITE = 3'b010,
                READ  = 3'b100;


//信号定义
    
    reg     [2:0]       state_c         ;
    reg     [2:0]       state_n         ;
    reg     [10:0]      cnt_burst       ;//读写状态下突发计数器
    wire                add_cnt_burst   ;
    wire                end_cnt_burst   ;
    reg     [23:0]      wr_addr         ;//写地址 bank[1:0] + row[12:0] + col[8:0]
    wire                add_wr_addr     ;
    wire                end_wr_addr     ;
    reg     [23:0]      rd_addr         ;//读地址 bank[1:0] + row[12:0] + col[8:0]
    wire                add_rd_addr     ;
    wire                end_rd_addr     ;

    reg                 prior_flag      ;//读写优先级标志
    reg                 wr_flag         ;//突发写标志
    reg                 rd_flag         ;//突发读标志
    reg                 flag_sel        ;//表示上一次执行的操作类型
    
    reg     [15:0]      tx_data         ;
    reg                 tx_data_vld     ;

    wire                idle2write      ; 
    wire                idle2read       ; 
    wire                write2idle      ; 
    wire                read2idle       ; 

    wire        [15:0]  wfifo_data      ;
    wire                wfifo_rdreq     ;
    wire                wfifo_wrreq     ;
    wire        [15:0]  wfifo_q         ;
    wire                wfifo_empty     ;
    wire        [10:0]   wfifo_usedw     ; 
    wire                wfifo_full      ;
    
    wire        [15:0]  rfifo_data      ;
    wire                rfifo_rdreq     ;
    wire                rfifo_wrreq     ;
    wire        [15:0]  rfifo_q         ;
    wire        [10:0]  rfifo_usedw     ;
    wire                rfifo_empty     ;
    wire                rfifo_full      ;
   
    reg			[1:0]			        bank			;
    reg							    change_bank			;
    reg								can_write			;
    reg							    w_finsh			;
    reg							    r_finsh			;
    reg			[ 19:0 ]			cnt_pix_w			;
    reg			[ 19:0 ]			cnt_pix_r			;

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
                if(idle2write)
                    state_n = WRITE ;
                else if(idle2read)
                    state_n = READ ;
                else 
                    state_n = state_c ;
            end
            WRITE :begin
                if(write2idle)
                    state_n = IDLE ;
                else 
                    state_n = state_c ;
            end
            READ :begin
                if(read2idle)
                    state_n = IDLE ;
                else 
                    state_n = state_c ;
            end
            default : state_n = IDLE ;
        endcase
    end
    
    assign idle2write = state_c==IDLE  && (~prior_flag && wr_flag);
    assign idle2read  = state_c==IDLE  && (prior_flag && rd_flag );
    assign write2idle = state_c==WRITE && (end_cnt_burst);
    assign read2idle  = state_c==READ  && (end_cnt_burst);

/************************ 读写优先级仲裁 *************************/

    //wr_flag 写请求
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            wr_flag <= 1'b0;
        end
        else if(wfifo_usedw < `WFIFO_MIN_NUM)begin //当低于最小阈值不写
            wr_flag <= 1'b0;
        end
        else if(wfifo_usedw >`WFIFO_MAX_NUM || ~r_finsh || ~wfifo_full)begin //当超过写fifo最大阈值请求写
            wr_flag <= 1'b1;
        end

    end
    
    //rd_flag  读请求  
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            rd_flag <= 1'b0;
        end
        else if(rfifo_usedw > `RFIFO_MAX_NUM)begin //大于最大阈值不读
            rd_flag <= 1'b0;
        end 
        else if(rfifo_usedw < `RFIFO_MIN_NUM || ~w_finsh || ~wfifo_full)begin //小于读fifo最小阈值发起读请求
            rd_flag <= 1'b1;
        end

    end

    //flag_sel 表示上一次执行的操作类型 0：上一次执行的写 1：上一次执行的读
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            flag_sel <= 1'b1;   
        end
        else if(write2idle)begin
            flag_sel <= 1'b0;   //上一次执行的写
        end
        else if(read2idle)begin
            flag_sel <= 1'b1;   //上一次执行的读
        end
    end

    //prior_flag    0：表示突发写优先级高   1：表示突发读优先级高
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            prior_flag <= 1'b0;
        end
        else if(wr_flag && (flag_sel || ~rd_flag))begin     //突发写优先级高        
            prior_flag <= 1'b0;
        end
        else if(rd_flag && (~flag_sel || ~wr_flag))begin    //突发读优先级高     
            prior_flag <= 1'b1;
        end
    end

/*****************************************************************/

//计数器        读写状态下突发传输 BURST_LEN 个数据
    
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            cnt_burst <= 0; 
        end
        else if(add_cnt_burst) begin
            if(end_cnt_burst)
                cnt_burst <= 0; 
            else
                cnt_burst <= cnt_burst+1 ;
       end
    end
    assign add_cnt_burst = (state_c==WRITE || state_c==READ) && ~avs_waitrequest;
    assign end_cnt_burst = add_cnt_burst  && cnt_burst == (BURST_LEN)-1 ;

//地址计数器
    
    always @(posedge clk or negedge rst_n) begin //写地址计数器
        if (rst_n==0) begin
            wr_addr <= 0; 
        end
        else if(add_wr_addr) begin
            if(end_wr_addr)
                wr_addr <= 0; 
            else
                wr_addr <= wr_addr+1 ;
       end
    end
    assign add_wr_addr = state_c==WRITE && ~avs_waitrequest ;
    assign end_wr_addr = add_wr_addr  && wr_addr == BURST_MAX-1 ;

    always @(posedge clk or negedge rst_n) begin //读地址计数器
        if (rst_n==0) begin
            rd_addr <= 0; 
        end
        else if(add_rd_addr) begin
            if(end_rd_addr)
                rd_addr <= 0; 
            else
                rd_addr <= rd_addr+1 ;
       end
    end
    assign add_rd_addr = state_c==READ && ~avs_waitrequest;
    assign end_rd_addr = add_rd_addr  && rd_addr == BURST_MAX-1 ;


    //eop_r延迟一个时钟,保证最后一个数据写入
    reg			    			eop_r			;
    always @(posedge clk_in or negedge rst_n) begin
        if(!rst_n) begin
            eop_r <= 0;
        end
        else  begin
            eop_r <= eop;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            can_write = 1;
        end
        else if(sop && change_bank) begin//一帧开始
            can_write = 1;
        end
        else if(eop_r) begin//一帧结束
            can_write = 0;
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            w_finsh <= 0;
        end
        else if(change_bank) begin
            w_finsh <= 0;
        end
        // else if(cnt_pix_w == 24'he1000-1) begin
        //     w_finsh <= 1;
        // end
        else if(end_wr_addr) begin
            w_finsh <= 1;
        end

    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_finsh <= 0;
        end
        else if(change_bank) begin
            r_finsh <= 0; 
        end
        // else if(cnt_pix_r == 24'he1000-1) begin
        //     r_finsh <= 1;
        // end
        else if(end_rd_addr) begin
            r_finsh <= 1;
        end
    end
    always @(posedge change_bank or negedge rst_n) begin//chang_bank作为触发条件
        if(!rst_n) begin
            bank <= 2'b0;
        end
        else if(change_bank) begin
            bank <= ~bank;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            change_bank <= 0;
        end
        else if(can_write) begin //重新开始读一帧的时候拉低
            change_bank <= 0;
        end
        else if(w_finsh && r_finsh) begin //同时写完一帧和读完一帧拉高
            change_bank <= 1;
        end
    end
    assign avm_writedata = wfifo_q[15:0];
    assign avm_write  = ~(state_c == WRITE && ~avs_waitrequest);
    assign avm_read   = ~(state_c == READ && ~avs_waitrequest);
    assign avm_addr  = (state_c==WRITE)?{bank[1],wr_addr[21:9],bank[0],wr_addr[8:0]}
                                       :{~bank[1],rd_addr[21:9],~bank[0],rd_addr[8:0]};

    always  @(posedge clk_out or negedge rst_n)begin
        if(~rst_n)begin
            tx_data <= 0;
            tx_data_vld <= 1'b0;
        end
        else begin
            tx_data <= rfifo_q;
            tx_data_vld <= rfifo_rdreq; 
        end
    end

                                       
    assign dout = tx_data;
    assign dout_vld = tx_data_vld;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_pix_w <= 0;
        end
        else if(cnt_pix_w == 24'he1000-1) begin
            cnt_pix_w <= 0;
        end
        else if(wfifo_rdreq)begin
            cnt_pix_w <= cnt_pix_w + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_pix_r <= 0;
        end
        else if(cnt_pix_w == 24'he1000-1) begin
            cnt_pix_r <= 0;
        end
        else if(rfifo_wrreq)begin
            cnt_pix_r <= cnt_pix_r + 1;
        end
    end

    assign test = cnt_pix_r && cnt_pix_w;
//wrfifo例化

    wfifo	wfifo_inst (
	.aclr   (~rst_n     ),
	.data   (wfifo_data ),
	.rdclk  (clk        ),
	.rdreq  (wfifo_rdreq),
	.wrclk  (clk_in     ),
	.wrreq  (wfifo_wrreq),
	.q      (wfifo_q    ),
	.rdempty(wfifo_empty),
	.rdusedw(wfifo_usedw),  
	.wrfull (wfifo_full )
	);

    assign wfifo_data  = din ;
    assign wfifo_wrreq = din_vld && ~wfifo_full && (can_write );//数据有效,fifo没满,一帧没结束且一帧没写完
    assign wfifo_rdreq = ~wfifo_empty && state_c == WRITE && ~avs_waitrequest;

//rdfifo例化
    rfifo	rfifo_inst (
    .aclr   (~rst_n     ),
	.data   (rfifo_data ),
	.rdclk  (clk_out    ),
	.rdreq  (rfifo_rdreq),
	.wrclk  (clk        ),
	.wrreq  (rfifo_wrreq),
	.q      (rfifo_q    ),
	.rdempty(rfifo_empty),
	.wrfull (rfifo_full ),
    .wrusedw ( rfifo_usedw )
    );


    assign rfifo_data  = avs_readdata;
    assign rfifo_wrreq = ~rfifo_full && avs_readdata_vld ;
    assign rfifo_rdreq = ~rfifo_empty && rd_req;

endmodule 
