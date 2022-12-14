// sdram_interface.v

// Generated using ACDS version 18.1 625

`timescale 1 ps / 1 ps
module sdram_interface (
		input  wire [23:0] avs_port_address,       // avs_port.address
		input  wire [1:0]  avs_port_byteenable_n,  //         .byteenable_n
		input  wire        avs_port_chipselect,    //         .chipselect
		input  wire [15:0] avs_port_writedata,     //         .writedata
		input  wire        avs_port_read_n,        //         .read_n
		input  wire        avs_port_write_n,       //         .write_n
		output wire [15:0] avs_port_readdata,      //         .readdata
		output wire        avs_port_readdatavalid, //         .readdatavalid
		output wire        avs_port_waitrequest,   //         .waitrequest
		input  wire        clk_clk,                //      clk.clk
		output wire [12:0] mem_port_addr,          // mem_port.addr
		output wire [1:0]  mem_port_ba,            //         .ba
		output wire        mem_port_cas_n,         //         .cas_n
		output wire        mem_port_cke,           //         .cke
		output wire        mem_port_cs_n,          //         .cs_n
		inout  wire [15:0] mem_port_dq,            //         .dq
		output wire [1:0]  mem_port_dqm,           //         .dqm
		output wire        mem_port_ras_n,         //         .ras_n
		output wire        mem_port_we_n,          //         .we_n
		input  wire        reset_reset_n           //    reset.reset_n
	);

	sdram_interface_sdram_interface sdram_interface (
		.clk            (clk_clk),                //   clk.clk
		.reset_n        (reset_reset_n),          // reset.reset_n
		.az_addr        (avs_port_address),       //    s1.address
		.az_be_n        (avs_port_byteenable_n),  //      .byteenable_n
		.az_cs          (avs_port_chipselect),    //      .chipselect
		.az_data        (avs_port_writedata),     //      .writedata
		.az_rd_n        (avs_port_read_n),        //      .read_n
		.az_wr_n        (avs_port_write_n),       //      .write_n
		.za_data        (avs_port_readdata),      //      .readdata
		.za_valid       (avs_port_readdatavalid), //      .readdatavalid
		.za_waitrequest (avs_port_waitrequest),   //      .waitrequest
		.zs_addr        (mem_port_addr),          //  wire.export
		.zs_ba          (mem_port_ba),            //      .export
		.zs_cas_n       (mem_port_cas_n),         //      .export
		.zs_cke         (mem_port_cke),           //      .export
		.zs_cs_n        (mem_port_cs_n),          //      .export
		.zs_dq          (mem_port_dq),            //      .export
		.zs_dqm         (mem_port_dqm),           //      .export
		.zs_ras_n       (mem_port_ras_n),         //      .export
		.zs_we_n        (mem_port_we_n)           //      .export
	);

endmodule
