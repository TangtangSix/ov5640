module cmos_top(
    input           clk     ,
    input           rst_n   ,
    
    output          scl     ,
    inout           sda     ,
    output          pwdn    ,
    output          reset   ,

    output          cfg_done

);
//信号定义

    wire            req         ;
    wire    [3:0]   cmd         ;
    wire            done        ;
    wire    [7:0]   dout        ;
    wire            i2c_scl     ; 
    wire            i2c_sda_i   ; 
    wire            i2c_sda_o   ; 
    wire            i2c_sda_oe  ;



//模块例化


 cmos_config u_cfg(
    /*input               */.clk         (clk       ),
    /*input               */.rst_n       (rst_n     ),
    //i2c_master
    /*output              */.req         (req       ),
    /*output      [3:0]   */.cmd         (cmd       ),
    /*output      [7:0]   */.dout        (dout      ),
    /*input               */.done        (done      ),
    /*output              */.config_done (cfg_done  )
);


 i2c_intf u_i2c(
    /*input               */.clk         (clk       ),
    /*input               */.rst_n       (rst_n     ),
    /*input               */.req         (req       ),
    /*input       [3:0]   */.cmd         (cmd       ),
    /*input       [7:0]   */.din         (dout      ),
    /*output      [7:0]   */.dout        (          ),
    /*output              */.done        (done      ),
    /*output              */.slave_ack   (          ),
    /*output              */.i2c_scl     (scl       ),
    /*input               */.i2c_sda_i   (i2c_sda_i ),
    /*output              */.i2c_sda_o   (i2c_sda_o ),
    /*output              */.i2c_sda_oe  (i2c_sda_oe)   
    );

    assign i2c_sda_i = sda;
    assign sda = i2c_sda_oe?i2c_sda_o:1'bz;
    assign pwdn =  1'b0;
    assign reset = 1'b1;


endmodule 

