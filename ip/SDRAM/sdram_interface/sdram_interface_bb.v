
module sdram_interface (
	avs_port_address,
	avs_port_byteenable_n,
	avs_port_chipselect,
	avs_port_writedata,
	avs_port_read_n,
	avs_port_write_n,
	avs_port_readdata,
	avs_port_readdatavalid,
	avs_port_waitrequest,
	clk_clk,
	mem_port_addr,
	mem_port_ba,
	mem_port_cas_n,
	mem_port_cke,
	mem_port_cs_n,
	mem_port_dq,
	mem_port_dqm,
	mem_port_ras_n,
	mem_port_we_n,
	reset_reset_n);	

	input	[23:0]	avs_port_address;
	input	[1:0]	avs_port_byteenable_n;
	input		avs_port_chipselect;
	input	[15:0]	avs_port_writedata;
	input		avs_port_read_n;
	input		avs_port_write_n;
	output	[15:0]	avs_port_readdata;
	output		avs_port_readdatavalid;
	output		avs_port_waitrequest;
	input		clk_clk;
	output	[12:0]	mem_port_addr;
	output	[1:0]	mem_port_ba;
	output		mem_port_cas_n;
	output		mem_port_cke;
	output		mem_port_cs_n;
	inout	[15:0]	mem_port_dq;
	output	[1:0]	mem_port_dqm;
	output		mem_port_ras_n;
	output		mem_port_we_n;
	input		reset_reset_n;
endmodule
