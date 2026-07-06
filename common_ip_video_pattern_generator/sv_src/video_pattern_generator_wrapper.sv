module video_pattern_generator_wrapper
#
(
    parameter   int     SYS_REG_WIDTH           =	32                                  ,   // Width of setup registers
    parameter   int     OUT_DATA_WIDTH          =	16                                  ,   // Width of the data output
    parameter   bit     IS_RST_SYNC             =   1'b0                                    // Use comb or seq logic: "1" - sync rst_n, "0" - async

)
(
    //Basic signals declaration 
    input		logic		                                clk                         ,   // Basic clk signal
    
    //Enable signal
    input		logic		                                enable                      ,   // Enable signal to generate pattern, when 0 - generation restarts and registers 

    //Setup signals
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_cols_gen          ,   // Requested number of colomns to be generated
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_gen          ,   // Requested number of rows to be generated
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_cols_del_before   ,   // Requested number of colomns to be delayed
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_del_before   ,   // Requested number of rows to be delayed
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_cols_del_after    ,   // Requested number of colomns to be delayed
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_del_after    ,   // Requested number of rows to be delayed
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_del_after    ,   // Requested number of rows to be delayed

    //Output signals
    output		logic		                                sig_out_vsync               ,   //V-Sync active-high signal for syncronization
    output		logic		                                sig_out_hsync               ,   //H-Sync active-high signal as if valid data flag
    output		logic		                                sig_out_hsync_first         ,   //H-Sync active-high signal as if valid data flag for the first data beat
    output		logic		                                sig_out_hsync_last          ,   //H-Sync active-high signal as if valid data flag for the last data beat
    output		logic		[OUT_DATA_WIDTH - 1 : 0  ] 	    sig_out_data                    //Output data marked with the hsync and first and last data markers
);

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of local signals and parameters section

//Registers to latch
logic [clogb2 (CNT_COLS        ) - 1 : 0]   requested_cols_gen_reg            ;   // Reg for the requested number of colomns to be generated
logic [clogb2 (CNT_ROWS        ) - 1 : 0]   requested_rows_gen_reg            ;   // Reg for the requested number of rows to be generated
logic [clogb2 (CNT_COLS_DEL    ) - 1 : 0]   requested_cols_del_before_reg     ;   // Reg for the requested number of colomns to be generated
logic [clogb2 (CNT_ROWS_DEL    ) - 1 : 0]   requested_rows_del_before_reg     ;   // Reg for the requested number of rows to be generateds
logic [clogb2 (CNT_COLS_DEL    ) - 1 : 0]   requested_cols_del_after_reg      ;   // Reg for the requested number of colomns to be generated
logic [clogb2 (CNT_ROWS_DEL    ) - 1 : 0]   requested_rows_del_after_reg      ;   // Reg for the requested number of rows to be generateds

//Counters to generate patterns
logic [clogb2 (CNT_COLS        ) : 0]       requested_cols_gen_cnt            ;   // Counter for the requested number of colomns to be generated
logic [clogb2 (CNT_ROWS        ) : 0]       requested_rows_gen_cnt            ;   // Counter for the requested number of rows to be generated

//End of local signals and parameters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of checking input parameters secntion section
initial begin
    if(CNT_COLS <= 0) begin
        $error("Parameter CNT_COLS must NOT be equal or less than 0");
    end

    if(CNT_ROWS <= 0) begin
        $error("Parameter CNT_ROWS must NOT be equal or less than 0");
    end

    if(CNT_COLS_DEL_BEFORE == 0) begin
        $warning("CNT_COLS_DEL_BEFORE == 0, no additional pipe will be used for output signal");
    end

    if(CNT_ROWS_DEL_BEFORE == 0) begin
        $warning("CNT_ROWS_DEL_BEFORE == 0, no additional pipe will be used for output signal");
    end

    if(CNT_COLS_DEL_AFTER == 0) begin
        $warning("CNT_COLS_DEL_AFTER == 0, no additional pipe will be used for output signal");
    end

    if(CNT_ROWS_DEL_AFTER == 0) begin
        $warning("CNT_ROWS_DEL_AFTER == 0, no additional pipe will be used for output signal");
    end

    $display("%m setup with parameter CNT_COLS              : %d", CNT_COLS             );
    $display("%m setup with parameter CNT_ROWS              : %d", CNT_ROWS             );
    $display("%m setup with parameter CNT_COLS_DEL_BEFORE   : %d", CNT_COLS_DEL_BEFORE  );
    $display("%m setup with parameter CNT_ROWS_DEL_BEFORE   : %d", CNT_ROWS_DEL_BEFORE  );
    $display("%m setup with parameter CNT_COLS_DEL_AFTER    : %d", CNT_COLS_DEL_AFTER   );
    $display("%m setup with parameter CNT_ROWS_DEL_AFTER    : %d", CNT_ROWS_DEL_AFTER   );
    $display("%m setup with parameter IS_RST_SYNC           : %d", IS_RST_SYNC          );
end
//End of checking input parameters secntion section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of driving counters section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            requested_cols_gen_reg          <=  requested_cols_gen           ;
            requested_rows_gen_reg          <=  requested_rows_gen           ;
            requested_cols_del_before_reg   <=  requested_cols_del_before    ;
            requested_rows_del_before_reg   <=  requested_rows_del_before    ;
            requested_cols_del_after_reg    <=  requested_cols_del_after     ;
            requested_rows_del_after_reg    <=  requested_rows_del_after     ;
        end
end
//End of driving counters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of counters section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            requested_cols_gen_cnt              <= '0;
            requested_rows_gen_cnt              <= '0;
        end
    else begin
        if(requested_cols_gen_cnt == requested_cols_del_before_reg + requested_cols_gen_reg + requested_cols_del_after_reg - 1) begin
            if(requested_rows_gen_cnt == requested_rows_del_before_reg + requested_rows_gen_reg + requested_rows_del_after_reg - 1) begin
                requested_cols_gen_cnt          <= '0;
                requested_rows_gen_cnt          <= '0;
            end
            else begin
                requested_cols_gen_cnt          <= '0;
                requested_rows_gen_cnt          <= requested_rows_gen_cnt + 1;
            end
        end
        else begin
            requested_cols_gen_cnt              <= requested_cols_gen_cnt + 1;
        end
    end
end
//End of counters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of driving section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            
        end
    else
        begin
        
        end
end
//End of driving section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
endmodule