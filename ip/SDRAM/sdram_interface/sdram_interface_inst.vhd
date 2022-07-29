	component sdram_interface is
		port (
			avs_port_address       : in    std_logic_vector(23 downto 0) := (others => 'X'); -- address
			avs_port_byteenable_n  : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable_n
			avs_port_chipselect    : in    std_logic                     := 'X';             -- chipselect
			avs_port_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			avs_port_read_n        : in    std_logic                     := 'X';             -- read_n
			avs_port_write_n       : in    std_logic                     := 'X';             -- write_n
			avs_port_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
			avs_port_readdatavalid : out   std_logic;                                        -- readdatavalid
			avs_port_waitrequest   : out   std_logic;                                        -- waitrequest
			clk_clk                : in    std_logic                     := 'X';             -- clk
			mem_port_addr          : out   std_logic_vector(12 downto 0);                    -- addr
			mem_port_ba            : out   std_logic_vector(1 downto 0);                     -- ba
			mem_port_cas_n         : out   std_logic;                                        -- cas_n
			mem_port_cke           : out   std_logic;                                        -- cke
			mem_port_cs_n          : out   std_logic;                                        -- cs_n
			mem_port_dq            : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			mem_port_dqm           : out   std_logic_vector(1 downto 0);                     -- dqm
			mem_port_ras_n         : out   std_logic;                                        -- ras_n
			mem_port_we_n          : out   std_logic;                                        -- we_n
			reset_reset_n          : in    std_logic                     := 'X'              -- reset_n
		);
	end component sdram_interface;

	u0 : component sdram_interface
		port map (
			avs_port_address       => CONNECTED_TO_avs_port_address,       -- avs_port.address
			avs_port_byteenable_n  => CONNECTED_TO_avs_port_byteenable_n,  --         .byteenable_n
			avs_port_chipselect    => CONNECTED_TO_avs_port_chipselect,    --         .chipselect
			avs_port_writedata     => CONNECTED_TO_avs_port_writedata,     --         .writedata
			avs_port_read_n        => CONNECTED_TO_avs_port_read_n,        --         .read_n
			avs_port_write_n       => CONNECTED_TO_avs_port_write_n,       --         .write_n
			avs_port_readdata      => CONNECTED_TO_avs_port_readdata,      --         .readdata
			avs_port_readdatavalid => CONNECTED_TO_avs_port_readdatavalid, --         .readdatavalid
			avs_port_waitrequest   => CONNECTED_TO_avs_port_waitrequest,   --         .waitrequest
			clk_clk                => CONNECTED_TO_clk_clk,                --      clk.clk
			mem_port_addr          => CONNECTED_TO_mem_port_addr,          -- mem_port.addr
			mem_port_ba            => CONNECTED_TO_mem_port_ba,            --         .ba
			mem_port_cas_n         => CONNECTED_TO_mem_port_cas_n,         --         .cas_n
			mem_port_cke           => CONNECTED_TO_mem_port_cke,           --         .cke
			mem_port_cs_n          => CONNECTED_TO_mem_port_cs_n,          --         .cs_n
			mem_port_dq            => CONNECTED_TO_mem_port_dq,            --         .dq
			mem_port_dqm           => CONNECTED_TO_mem_port_dqm,           --         .dqm
			mem_port_ras_n         => CONNECTED_TO_mem_port_ras_n,         --         .ras_n
			mem_port_we_n          => CONNECTED_TO_mem_port_we_n,          --         .we_n
			reset_reset_n          => CONNECTED_TO_reset_reset_n           --    reset.reset_n
		);

