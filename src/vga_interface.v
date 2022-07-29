`include "param.v"

module   vga_interface (    //1280*720
    input           clk      ,//75MHz
    input           rst_n    ,
    input   [15:0]  din      ,
    input           din_vld  ,
    output          rdy      ,
    output  [15:0]  vga_rgb  ,
    output          vga_hsync,
    output          vga_vsync
);

//信号定义

    reg     [10:0]      cnt_h       ;
    wire                add_cnt_h   ;
    wire                end_cnt_h   ;
    reg     [9:0]       cnt_v       ;
    wire                add_cnt_v   ;
    wire                end_cnt_v   ;

    reg                 h_vld       ;
    reg                 v_vld       ;
    
    reg                 hsync       ;
    reg                 vsync       ;
    reg                 rd_req      ;         

    wire                rdreq       ; 
    wire                wrreq       ; 
    wire                empty       ; 
    wire                full        ; 
    wire    [15:0]      q_out       ; 
    wire    [6:0]       usedw       ; 



//计数器
    
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            cnt_h <= 0; 
        end
        else if(add_cnt_h) begin
            if(end_cnt_h)
                cnt_h <= 0; 
            else
                cnt_h <= cnt_h+1 ;
       end
    end
    assign add_cnt_h = 1;
    assign end_cnt_h = add_cnt_h  && cnt_h == `H_TP-1 ;
    
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n==0) begin
            cnt_v <= 0; 
        end
        else if(add_cnt_v) begin
            if(end_cnt_v)
                cnt_v <= 0; 
            else
                cnt_v <= cnt_v+1 ;
       end
    end
    assign add_cnt_v = end_cnt_h;
    assign end_cnt_v = add_cnt_v  && cnt_v == `V_TP-1 ;

//h_vld 
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            h_vld <= 1'b0;
        end
        else if(cnt_h == `H_START-1)begin
            h_vld <= 1'b1;
        end
        else if(cnt_h == `H_END-1)begin 
            h_vld <= 1'b0;
        end 
    end

//v_vld
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            v_vld <= 1'b0;
        end
        else if(end_cnt_h && cnt_v == `V_START)begin
            v_vld <= 1'b1;
        end
        else if(end_cnt_h && cnt_v == `V_END)begin
            v_vld <= 1'b0;
        end
    end

//rd_req
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            rd_req <= 1'b0;
        end
        else if(usedw < 20)begin
            rd_req <= 1'b1;
        end
        else if(usedw > 60)begin
            rd_req <= 1'b0;
        end
    end
//hsync
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            hsync <= 0;
        end
        else if(add_cnt_h && cnt_h == `H_SW-1)begin
            hsync <= 1'b1;
        end
        else if(add_cnt_h && cnt_h == `H_TP-1)begin 
            hsync <= 1'b0;
        end     
    end
//vsync
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            vsync <= 1'b0;
        end
        else if(add_cnt_v && cnt_v == `V_SW-1)begin
            vsync <= 1'b1;
        end
        else if(add_cnt_v && cnt_v == `V_TP-1)begin
            vsync <= 1'b0;
        end
    end

// //FIFO例化
// vga_fifo	vga_fifo_inst (
// 	.aclr ( aclr_sig ),
// 	.clock ( clock_sig ),
// 	.data ( data_sig ),
// 	.rdreq ( rdreq_sig ),
// 	.wrreq ( wrreq_sig ),
// 	.empty ( empty_sig ),
// 	.full ( full_sig ),
// 	.q ( q_sig ),
// 	.usedw ( usedw_sig )
// 	);

vga_fifo vga_fifo_inst(
	.aclr       (~rst_n     ),
	.clock      (clk        ),
	.data       (din        ),
	.rdreq      (rdreq      ),
	.wrreq      (wrreq      ),
	.empty      (empty      ),
	.full       (full       ),
	.q          (q_out      ),
	.usedw      (usedw      )
);

    assign wrreq = ~full && din_vld;
    assign rdreq = ~empty && h_vld && v_vld;

//输出
    assign rdy = rd_req;
    assign vga_rgb = din_vld?din:0;
    assign vga_hsync = hsync;
    assign vga_vsync = vsync;


endmodule 

