    module vga_dirve (input			wire						clk,            //系统时钟
                    input			wire						rst_n,          //复位
                    input			wire		[ 15:0 ]		rgb_data,       //16位RGB对应值
                    output			reg							h_sync,     //行同步信号
                    output			reg							v_sync,     //场同步信号
                    output			reg		[ 11:0 ]				addr_h, //行地址
                    output			reg		[ 11:0 ]				addr_v,  //列地址
                    output			wire		[ 4:0 ]				rgb_r,  //红基色
                    output			wire		[ 5:0 ]				rgb_g,  //绿基色
                    output			wire		[ 4:0 ]				rgb_b  //蓝基色
    );

//1280 * 640 60HZ
localparam	 H_FRONT = 110; // 行同步前沿信号周期长
localparam	 H_SYNC  = 40; // 行同步信号周期长
localparam	 H_BLACK = 220; // 行同步后沿信号周期长
localparam	 H_ACT   = 1280; // 行显示周期长
localparam	 V_FRONT = 5; // 场同步前沿信号周期长
localparam	 V_SYNC  = 5; // 场同步信号周期长
localparam	 V_BLACK = 20; // 场同步后沿信号周期长
localparam	 V_ACT   = 720; // 场显示周期长
// 640 * 480 60HZ
// localparam	 H_FRONT = 16; // 行同步前沿信号周期长
// localparam	 H_SYNC  = 96; // 行同步信号周期长
// localparam	 H_BLACK = 48; // 行同步后沿信号周期长
// localparam	 H_ACT   = 640; // 行显示周期长
// localparam	 V_FRONT = 11; // 场同步前沿信号周期长
// localparam	 V_SYNC  = 2; // 场同步信号周期长
// localparam	 V_BLACK = 31; // 场同步后沿信号周期长
// localparam	 V_ACT   = 480; // 场显示周期长

// 800 * 600 72HZ
// localparam	 H_FRONT = 40; // 行同步前沿信号周期长
// localparam	 H_SYNC  = 120; // 行同步信号周期长
// localparam	 H_BLACK = 88; // 行同步后沿信号周期长
// localparam	 H_ACT   = 800; // 行显示周期长
// localparam	 V_FRONT = 37; // 场同步前沿信号周期长
// localparam	 V_SYNC  = 6; // 场同步信号周期长
// localparam	 V_BLACK = 23; // 场同步后沿信号周期长
// localparam	 V_ACT   = 600; // 场显示周期长


localparam	H_TOTAL = H_FRONT + H_SYNC + H_BLACK + H_ACT; // 行周期
localparam	V_TOTAL = V_FRONT + V_SYNC + V_BLACK + V_ACT; // 列周期

reg			[ 11:0 ]			cnt_h			; // 行计数器
reg			[ 11:0 ]			cnt_v			; // 场计数器
reg			[ 15:0 ]			rgb			; // 对应显示颜色值

// 对应计数器开始、结束、计数信号
wire							flag_enable_cnt_h			;
wire							flag_clear_cnt_h			;
wire							flag_enable_cnt_v			;
wire							flag_clear_cnt_v			;
wire							flag_add_cnt_v  			;
wire							valid_area      			;



// 行计数
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_h <= 0;
    end
    else if ( flag_enable_cnt_h ) begin
        if ( flag_clear_cnt_h ) begin
            cnt_h <= 0;
        end
        else begin
            cnt_h <= cnt_h + 1;
        end
    end
    else begin
        cnt_h <= 0;
    end
end
assign flag_enable_cnt_h = 1;
assign flag_clear_cnt_h  = cnt_h == H_TOTAL - 1;

// 行同步信号
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        h_sync <= 1;
    end
    else if ( cnt_h == H_SYNC - 1 ) begin // 同步周期时为1
        h_sync <= 0;
    end
    else if ( flag_clear_cnt_h ) begin // 其余为0
        h_sync <= 1;
    end
    else begin
        h_sync <= h_sync;
    end
end

// 场计数
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_v <= 0;
    end
    else if ( flag_enable_cnt_v ) begin
        if ( flag_clear_cnt_v ) begin
            cnt_v <= 0;
        end
        else if ( flag_add_cnt_v ) begin
            cnt_v <= cnt_v + 1;
        end
        else begin
            cnt_v <= cnt_v;
        end
    end
    else begin
        cnt_v <= 0;
    end
end
assign flag_enable_cnt_v = flag_enable_cnt_h;
assign flag_clear_cnt_v  = cnt_v == V_TOTAL - 1;
assign flag_add_cnt_v    = flag_clear_cnt_h;

// 场同步信号
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        v_sync <= 1;
    end
    else if ( cnt_v == V_SYNC - 1 ) begin
        v_sync <= 0;
    end
    else if ( flag_clear_cnt_v ) begin
        v_sync <= 1;
    end
end

// 对应有效区域行地址 1-640
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        addr_h <= 0;
    end
    else if ( valid_area ) begin
        addr_h <= cnt_h - H_SYNC - H_BLACK + 1;
    end
    else begin
        addr_h <= 0;
    end
end
// 对应有效区域列地址 1-480
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        addr_v <= 0;
    end
    else if ( valid_area ) begin
        addr_v <= cnt_v -V_SYNC - V_BLACK + 1;
    end
    else begin
        addr_v <= 0;
    end
end
// 有效显示区域
assign valid_area = cnt_h >= H_SYNC + H_BLACK && cnt_h < H_SYNC + H_BLACK + H_ACT && cnt_v >= V_SYNC + V_BLACK && cnt_v < V_SYNC + V_BLACK + V_ACT;


// 显示颜色
always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        rgb <= 16'h0;
    end
    else if ( valid_area ) begin
        rgb <= rgb_data;
    end
    else begin
        rgb <= 16'b0;
    end
end
assign rgb_r = rgb[ 15:11 ];
assign rgb_g = rgb[ 10:5 ];
assign rgb_b = rgb[ 4:0 ];

endmodule // vga_dirve
