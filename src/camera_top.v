module camera_top (
    input			wire						clk,
    input			wire						rst_n,
    /* 配置寄存器 */
    output			wire						cmos_pwdn,
    output			wire						cmos_reset,
    output			wire						cmos_sioc,
    output			wire						cmos_siod,
    output			wire						cmos_xclk,

    input			wire						cmos_pclk,
    input			wire						cmos_vsync,
    input			wire						cmos_href,
    input			wire		[7:0]			cmos_din,

    output                                      sdram_clk       ,
    output                                      sdram_cke       ,   
    output                                      sdram_csn       ,   
    output                                      sdram_rasn      ,   
    output                                      sdram_casn      ,   
    output                                      sdram_wen       ,   
    output                      [1:0 ]          sdram_bank      ,   
    output                      [12:0]          sdram_addr      ,   
    inout                       [15:0]          sdram_dq        ,   
    output                      [1: 0]          sdram_dqm       ,

    //vga
    output			wire						h_sync,
    output			wire						v_sync,
    output			wire		[15:0]			vga_rgb

);

wire							clk_24			;
wire							clk_50			;
wire							clk_75			;
wire							clk_100			;
wire							clk_84			;
wire							clk_100_s			;
wire							clk_150			;
wire							clk_200			;
wire							pclk			;
wire							has_config			;
wire							rd_req			;
wire		[ 15:0 ]			dout			;
wire							sop			;
wire							eop			;
wire							vld			;
wire		[ 15:0 ]			data			;
wire							dout_vld			;
wire		[ 11:0 ]			addr_h			;
wire		[ 11:0 ]			addr_v			;
wire		[ 15:0 ]			rgb_data			;

//PLL
    pll	pll_inst (
	.areset ( ~rst_n ),
	.inclk0 ( clk ),
	.c0 ( clk_50 ),//50M
	.c1 ( clk_24 ),//24M
	.c2 ( clk_75 ),//75M
	.c3 ( clk_100 ),//100M
    .c4 ( clk_84 )
	);

    pll1	pll1_inst (
        .areset ( ~rst_n ),
        .inclk0 ( clk ),
        .c0 ( clk_100_s ),
        .c1 ( clk_150 ),
        .c2 ( clk_200 )
        );

    iobuf u_iobuf(
	.datain     (cmos_pclk  ),
    .dataout    (pclk       )
    );

    assign sdram_clk = clk_100_s;
    assign cmos_xclk = clk_24;

    cmos_top u_cmos_top(
        .clk        ( clk           ),
        .rst_n      ( rst_n         ),
        .scl        ( cmos_sioc      ),
        .sda        (  cmos_siod     ),
        .pwdn       ( cmos_pwdn      ),
        .reset      ( cmos_reset      ),
        .cfg_done   ( has_config    )
    );
    // camera_config_drive u_camera_config_drive(
    //     .clk   ( clk   ),
    //     .rst_n ( rst_n ),
    //     .pwdn  ( cmos_pwdn  ),
    //     .reset ( cmos_reset ),
    //     .sioc  ( cmos_sioc  ),
    //     .siod  ( cmos_siod  ),
    //     .done  ( has_config )
    // );

    capture u_capture(
        .clk   ( pclk   ),
        .rst_n ( rst_n ),
        .vsync ( cmos_vsync ),
        .href  ( cmos_href  ),
        .din   ( cmos_din   ),
        .din_vld(has_config),
        .sop   ( sop   ),
        .eop   ( eop   ),
        .vld   ( vld   ),
        .pixel  ( data  )
    );


    sdram_controller u_sdram_controller(
        .clk            ( clk_100       ),
        .clk_in         ( pclk          ),
        .clk_out        ( clk_75        ),
        .rst_n          ( rst_n          ),
        .sop            ( sop            ),
        .eop            ( eop            ),
        .din            ( data            ),
        .din_vld        ( vld           ),
        .rd_req         ( rd_req         ),
        .dout           ( dout           ),
        .dout_vld       ( dout_vld       ),
        .mem_cke            (sdram_cke     ),
        .mem_csn            (sdram_csn     ),
        .mem_rasn           (sdram_rasn    ),
        .mem_casn           (sdram_casn    ),
        .mem_wen            (sdram_wen     ),
        .mem_bank           (sdram_bank    ),
        .mem_addr           (sdram_addr    ),
        .mem_dq             (sdram_dq      ),
        .mem_dqm            (sdram_dqm     )  
    );

    vga_control u_vga_control(
        .clk    ( clk_75  ),
        .rst_n  ( rst_n  ),
        .din    ( dout   ),
        .din_vld ( dout_vld ),
        .addr_h ( addr_h ),
        .addr_v ( addr_v ),
        .rd_req ( rd_req ),
        .rgb_data  ( rgb_data  )
    );
    vga_dirve u_vga_dirve(
        .clk      ( clk_75    ),
        .rst_n    ( rst_n    ),
        .rgb_data ( rgb_data ),
        .h_sync   ( h_sync   ),
        .v_sync   ( v_sync   ),
        .addr_h   ( addr_h   ),
        .addr_v   ( addr_v   ),
        .rgb_r    ( rgb_r    ),
        .rgb_g    ( rgb_g    ),
        .rgb_b    ( rgb_b    )
    );
    // vga_interface u_vga(
    // /*input           */.clk      (clk_75   ),
    // /*input           */.rst_n    (rst_n ),
    // /*input   [15:0]  */.din      (dout      ),
    // /*input           */.din_vld  (dout_vld  ),
    // /*output          */.rdy      (rd_req    ),
    // /*output  [15:0]  */.vga_rgb  (rgb_data   ),
    // /*output          */.vga_hsync(h_sync ),
    // /*output          */.vga_vsync(v_sync )
    // );
    assign vga_rgb = rgb_data;
endmodule //camera_top