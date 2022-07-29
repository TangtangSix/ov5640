`include "param.v"
module capture (
    input			wire						clk,
    input			wire						rst_n,
    input			wire						vsync,
    input			wire						href,
    input			wire		[ 7:0 ]		    din,
    input			wire						din_vld,

    output			wire						sop,
    output			wire						eop,
    output			wire						vld,
    output			wire		[ 15:0 ]		pixel	
);
// localparam	red    = 16'd63488;
// localparam	orange = 16'd64384;
// localparam	yellow = 16'd65472;
// localparam	green  = 16'd1024;
// localparam	blue   = 16'd31;
// localparam	indigo = 16'd18448;
// localparam	purple = 16'd32784;
// localparam	white  = 16'd65503;
// localparam	black  = 16'd0;

// reg			[ 15:0 ]			pixel_r			;
// reg			        			cnt		        ;
// reg			[ 11:0 ]			cnt_h			;
// reg			[ 9:0 ]			    cnt_v			;
// reg			[ 1:0 ]				vsync_r		;

// wire							add_cnt_h			;
// wire							end_cnt_h			;
// wire							add_cnt_v			;
// wire							end_cnt_v			;
// wire							vsync_n			;
// reg							    frame			;


// // always @(*) begin
// //     if ( cnt_h == 0 ) begin
// //         pixel_r = black;
// //     end
// //     else if ( cnt_h >0 && cnt_h <256 ) begin
// //         pixel_r = red;
// //     end
// //     else if ( cnt_h >255 && cnt_h <512 ) begin
// //         pixel_r = orange;
// //     end
// //     else if ( cnt_h >511 && cnt_h <768 ) begin
// //         pixel_r = yellow;
// //     end
// //     else if ( cnt_h >767 && cnt_h <1024 ) begin
// //         pixel_r = green;
// //     end
// //     else if ( cnt_h >1023 && cnt_h <1280 ) begin
// //         pixel_r = blue;
// //     end
// //     else if ( cnt_h >1279 && cnt_h <1536 ) begin
// //         pixel_r = indigo;
// //     end
// //     else if ( cnt_h >1535 && cnt_h <1792 ) begin
// //         pixel_r = purple;
// //     end
// //     else if ( cnt_h >1791 && cnt_h <2048 ) begin
// //         pixel_r = white;
// //     end
// //     else begin
// //         pixel_r = black;
// //     end
// // end

// //移位寄存器
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         pixel_r <= 0;
//     end
//     else  begin
//         pixel_r <= {pixel_r[7:0],din};
//     end
// end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         vsync_r <= 0;
//     end
//     else  begin
//         vsync_r <= {vsync_r[0],vsync};
//     end
// end
// //下降沿
// assign vsync_n = vsync_r[1] & ~vsync_r[0];

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         frame <= 0;
//     end
//     else if(vsync_n && din_vld) begin //帧同步下降沿
//         frame <= 1;
//     end
//     else if(end_cnt_v) begin //一帧完
//         frame <= 0;
//     end
// end


// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         cnt_h <= 0;
//     end
//     else if(add_cnt_h) begin
//         if (end_cnt_h) begin
//             cnt_h <= 0;
//         end
//         else begin
//             cnt_h <= cnt_h + 1;
//         end
//     end
// end
// assign add_cnt_h = href && frame;
// assign end_cnt_h = add_cnt_h && cnt_h == (`H_AP << 1)-1;

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         cnt_v <= 0;
//     end
//     else if(add_cnt_v) begin
//         if (end_cnt_v) begin
//             cnt_v <= 0;
//         end
//         else begin
//             cnt_v <= cnt_v + 1;
//         end
//     end
// end

// assign add_cnt_v = end_cnt_h;
// assign end_cnt_v = add_cnt_v && cnt_v == `V_AP-1 ;

// reg								vld_r			;
// reg								sop_r			;
// reg								eop_r			;
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         vld_r <= 0;
//         sop_r <= 0;
//         eop_r <= 0;
//     end
//     else  begin
//         vld_r <= frame & cnt_h[0];
//         sop_r <= add_cnt_h && cnt_v == 0 && cnt_h == 1;
//         eop_r <= end_cnt_v;
//     end
// end

// assign pixel =pixel_r;
// assign vld = vld_r;
// assign sop = sop_r;
// assign eop = eop_r;

//信号定义
    reg     [11:0]      cnt_h       ;
    wire                add_cnt_h   ;
    wire                end_cnt_h   ;
    reg     [9:0]       cnt_v       ;
    wire                add_cnt_v   ;
    wire                end_cnt_v   ;
    
    reg     [1:0]       vsync_r     ;//同步打拍
    wire                vsync_nedge ;//下降沿
    reg                 flag        ;//串并转换标志
    
    reg     [15:0]      data        ;
    reg                 data_vld    ;
    reg                 data_sop    ;
    reg                 data_eop    ;

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
    assign add_cnt_h = flag & href;
    assign end_cnt_h = add_cnt_h  && cnt_h == (`H_AP << 1)-1;
    
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
    assign end_cnt_v = add_cnt_v  && cnt_v == `V_AP-1 ;

//vsync同步打拍
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            vsync_r <= 2'b00;
        end
        else begin
            vsync_r <= {vsync_r[0],vsync};
        end
    end
    assign vsync_nedge = vsync_r[1] & ~vsync_r[0];

    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            flag <= 1'b0;
        end
        else if(din_vld & vsync_nedge)begin  //摄像头配置完成且场同步信号拉低之后开始采集有效数据
            flag <= 1'b1;
        end
        else if(end_cnt_v)begin     //一帧数据采集完拉低
            flag <= 1'b0;   
        end
    end

//data
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            data <= 0;
        end
        else begin
            data <= {data[7:0],din};//左移
        end
    end

//data_sop
    always  @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            data_sop <= 1'b0;
            data_eop <= 1'b0;
            data_vld <= 1'b0;
        end
        else begin
            data_sop <= add_cnt_h && cnt_h == 2-1 && cnt_v == 0;
            data_eop <= end_cnt_v;
            data_vld <= add_cnt_h && cnt_h[0] == 1'b0 ;
        end
    end

    assign pixel = data;
    assign sop = cnt_h == 1 && cnt_v == 0;
    assign eop = data_eop;
    assign vld = cnt_h[0];
    
endmodule //capture