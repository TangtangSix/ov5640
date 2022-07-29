	sdram_interface u0 (
		.avs_port_address       (<connected-to-avs_port_address>),       // avs_port.address
		.avs_port_byteenable_n  (<connected-to-avs_port_byteenable_n>),  //         .byteenable_n
		.avs_port_chipselect    (<connected-to-avs_port_chipselect>),    //         .chipselect
		.avs_port_writedata     (<connected-to-avs_port_writedata>),     //         .writedata
		.avs_port_read_n        (<connected-to-avs_port_read_n>),        //         .read_n
		.avs_port_write_n       (<connected-to-avs_port_write_n>),       //         .write_n
		.avs_port_readdata      (<connected-to-avs_port_readdata>),      //         .readdata
		.avs_port_readdatavalid (<connected-to-avs_port_readdatavalid>), //         .readdatavalid
		.avs_port_waitrequest   (<connected-to-avs_port_waitrequest>),   //         .waitrequest
		.clk_clk                (<connected-to-clk_clk>),                //      clk.clk
		.mem_port_addr          (<connected-to-mem_port_addr>),          // mem_port.addr
		.mem_port_ba            (<connected-to-mem_port_ba>),            //         .ba
		.mem_port_cas_n         (<connected-to-mem_port_cas_n>),         //         .cas_n
		.mem_port_cke           (<connected-to-mem_port_cke>),           //         .cke
		.mem_port_cs_n          (<connected-to-mem_port_cs_n>),          //         .cs_n
		.mem_port_dq            (<connected-to-mem_port_dq>),            //         .dq
		.mem_port_dqm           (<connected-to-mem_port_dqm>),           //         .dqm
		.mem_port_ras_n         (<connected-to-mem_port_ras_n>),         //         .ras_n
		.mem_port_we_n          (<connected-to-mem_port_we_n>),          //         .we_n
		.reset_reset_n          (<connected-to-reset_reset_n>)           //    reset.reset_n
	);

