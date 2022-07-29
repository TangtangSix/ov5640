module vga_control (
    input			wire						clk,
    input			wire						rst_n,
    input			wire		[ 15:0 ]		din,
    input			wire						din_vld,
    input			wire		[ 11:0 ]		addr_h,
    input			wire		[ 11:0 ]		addr_v,
    output			wire						rd_req,
    output			wire		[ 15:0 ]		rgb_data
);
localparam	red    = 16'd63488;
localparam	orange = 16'd64384;
localparam	yellow = 16'd65472;
localparam	green  = 16'd1024;
localparam	blue   = 16'd31;
localparam	indigo = 16'd18448;
localparam	purple = 16'd32784;
localparam	white  = 16'd65503;
localparam	black  = 16'd0;

    wire                rdreq       ; 
    wire                wrreq       ; 
    wire                empty       ; 
    wire                full        ; 
    wire    [15:0]      q_out       ; 
    wire    [6:0]       usedw       ; 


// reg		[ 15:0 ]			tmp_data			;
// always @(*) begin
//     if ( addr_h == 0 ) begin
//         tmp_data = black;
//     end
//     else if ( addr_h >0 && addr_h <128 ) begin
//         tmp_data = red;
//     end
//     else if ( addr_h >127 && addr_h <256 ) begin
//         tmp_data = orange;
//     end
//     else if ( addr_h >255 && addr_h <384 ) begin
//         tmp_data = yellow;
//     end
//     else if ( addr_h >383 && addr_h <512 ) begin
//         tmp_data = green;
//     end
//     else if ( addr_h >511 && addr_h <640 ) begin
//         tmp_data = blue;
//     end
//     else if ( addr_h >639 && addr_h <768 ) begin
//         tmp_data = indigo;
//     end
//     else if ( addr_h >767 && addr_h <896 ) begin
//         tmp_data = purple;
//     end
//     else if ( addr_h >898 && addr_h <1024 ) begin
//         tmp_data = white;
//     end
//     else begin
//         tmp_data = black;
//     end
// end

reg								rd_req_r			;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_req_r <= 0;
    end
    else if(usedw < 20) begin
        rd_req_r <= 1;
    end
    else if(usedw > 60) begin
        rd_req_r <= 0;
    end
end

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
assign rdreq = ~empty && addr_h && addr_v;
assign rd_req = rd_req_r;
assign rgb_data = rdreq?q_out:0;
endmodule //vga_control