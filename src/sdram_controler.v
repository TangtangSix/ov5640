module  sdram_controller (
    input               clk         ,//100M
    input               clk_in      ,//数据输入时钟
    input               clk_out     ,//数据输出时钟
    input               rst_n       ,

    //应用层接口
    input			wire						sop,
    input			wire						eop,
    input			wire		[ 15:0 ]		din,
    input			wire						din_vld,
    input			wire						rd_req,
    output			wire		[ 15:0 ]		dout,
    output			wire						dout_vld,
    //存储器侧接口
    output              mem_cke     ,
    output              mem_csn     ,
    output              mem_rasn    ,
    output              mem_casn    ,
    output              mem_wen     ,
    output      [1:0]   mem_bank    ,    
    output      [12:0]  mem_addr    ,
    inout       [15:0]  mem_dq      ,
    output      [1:0]   mem_dqm     
    );

//信号定义

    wire                avs_waitrequest     ; 
    wire    [15:0]      avs_readdata        ;
    wire                avs_readdata_vld    ;
    wire    [23:0]      avm_addr            ;
    wire                avm_write           ;
    wire    [15:0]      avm_writedata       ;
    wire                avm_read            ;


//模块例化

    sdram_ctrl u_sdram_ctrl(
        .clk             ( clk             ),
        .clk_in          ( clk_in          ),
        .clk_out         ( clk_out         ),
        .rst_n           ( rst_n           ),
        .din             ( din             ),
        .din_sop         ( sop         ),
        .din_eop         ( eop         ),
        .din_vld         ( din_vld         ),
        .rdreq           ( rd_req           ),
        .dout            ( dout            ),
        .dout_vld        ( dout_vld        ),
        .avm_write       ( avm_write       ),
        .avm_read        ( avm_read        ),
        .avm_addr        ( avm_addr        ),
        .avm_wrdata      ( avm_writedata      ),
        .avs_rddata      ( avs_readdata      ),
        .avs_rddata_vld  ( avs_readdata_vld  ),
        .avs_waitrequest  ( avs_waitrequest  )
    );

    // sdram_ctrl#(.BURST_LEN (512)) u_sdram_ctrl(
    // .clk               ( clk               ),
    // .clk_in            ( clk_in            ),
    // .clk_out           ( clk_out           ),
    // .rst_n             ( rst_n             ),
    // .sop               ( sop               ),
    // .eop               ( eop               ),
    // .din               ( din               ),
    // .din_vld           ( din_vld           ),
    // .rd_req            ( rd_req            ),
    // .dout              ( dout              ),
    // .dout_vld          ( dout_vld          ),
    // .avs_waitrequest   ( avs_waitrequest   ),
    // .avs_readdata      ( avs_readdata      ),
    // .avs_readdata_vld  ( avs_readdata_vld  ),
    // .avm_addr          ( avm_addr          ),
    // .avm_write         ( avm_write         ),
    // .avm_writedata     ( avm_writedata     ),
    // .avm_read          ( avm_read          )
    // );

    sdram_interface u0 (
    .clk_clk                (clk                ),                //      clk.clk
    .reset_reset_n          (rst_n              ),           //    reset.reset_n
    //avalon-mm slave
    .avs_port_address       (avm_addr           ),       // avs_port.address
    .avs_port_byteenable_n  (2'b00              ),  //         .byteenable_n
    .avs_port_chipselect    (1'b1               ),    //         .chipselect
    .avs_port_writedata     (avm_writedata      ),     //         .writedata
    .avs_port_read_n        (avm_read           ),        //         .read_n
    .avs_port_write_n       (avm_write          ),       //         .write_n
    .avs_port_readdata      (avs_readdata       ),      //         .readdata
    .avs_port_readdatavalid (avs_readdata_vld   ), //         .readdatavalid
    .avs_port_waitrequest   (avs_waitrequest    ),   //         .waitrequest
    //conduit 连接到片外存储器
    .mem_port_addr          (mem_addr           ),          // mem_port.addr
    .mem_port_ba            (mem_bank           ),            //         .ba
    .mem_port_cas_n         (mem_casn           ),         //         .cas_n
    .mem_port_cke           (mem_cke            ),           //         .cke
    .mem_port_cs_n          (mem_csn            ),          //         .cs_n
    .mem_port_dq            (mem_dq             ),            //         .dq
    .mem_port_dqm           (mem_dqm            ),           //         .dqm
    .mem_port_ras_n         (mem_rasn           ),         //         .ras_n
    .mem_port_we_n          (mem_wen            )          //         .we_n
       
    );

endmodule 

