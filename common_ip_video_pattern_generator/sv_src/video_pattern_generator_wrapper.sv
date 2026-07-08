module video_pattern_generator_wrapper
#
(
    parameter   int     SYS_REG_WIDTH           =	32                                  ,   // Width of setup registers
    parameter   int     OUT_DATA_WIDTH          =	16                                      // Width of the data output
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
    input		logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_v_sync_duration   ,   // Number of ticks to hold vsync active high
    input		logic		[3                 : 0  ]       requested_data_pattern      ,   // Requested pattren type to be generated
    input       logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_level_white       ,   // Requested level of the white color (maximum aka white level)
    input       logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_level_black       ,   // Requested level of the black color (minimum aka black level)
    input       logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_level_intermediate,   // Requested level of the intermediate color (any desired level)
    input       logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_horizontal_step   ,   // Requested step of the generation for rows
    input       logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_vertical_step     ,   // Requested step of the generation for cols

    //Output signals
    output		logic		                                sig_out_vsync               ,   //V-Sync active-high signal for syncronization
    output		logic		                                sig_out_hsync               ,   //H-Sync active-high signal as if valid data flag
    output		logic		                                sig_out_hsync_first         ,   //H-Sync active-high signal as if valid data flag for the first data beat
    output		logic		                                sig_out_hsync_last          ,   //H-Sync active-high signal as if valid data flag for the last data beat
    output		logic		[OUT_DATA_WIDTH - 1 : 0  ] 	    sig_out_data                    //Output data marked with the hsync and first and last data markers
);

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of local signals and parameters section

//Registers to latch to setup the generator
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_cols_gen_reg              ;   // Reg for the requested number of colomns to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_rows_gen_reg              ;   // Reg for the requested number of rows to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_cols_del_before_reg       ;   // Reg for the requested number of colomns to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_rows_del_before_reg       ;   // Reg for the requested number of rows to be generateds
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_cols_del_after_reg        ;   // Reg for the requested number of colomns to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_rows_del_after_reg        ;   // Reg for the requested number of rows to be generateds
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_v_sync_duration_reg       ;   // Reg for the requested number of rows to be generateds
logic [3                 : 0  ]     requested_data_pattern_reg          ;   // Requested pattren type to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_level_white_reg           ;   // Requested level of the color (maximum aka white level)
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_level_black_reg           ;   // Requested level of the color (minimum aka black level)
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_level_intermediate_reg    ;   // Requested level of the intermediate color (any desired level)
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_horizontal_step_reg       ;   // Requested step of the generation for rows
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_vertical_step_reg         ;   // Requested step of the generation for cols


//Enum variable for the pattern types (better readabilty)
enum 	logic 	    [3 : 0] 	    {
                                        ALL_BLACK                       ,
                                        ALL_WHITE                       ,
                                        ALL_INTERMEDIATE                ,
                                        CHECKER_ROWS                    ,
                                        CHECKER_COLS                    ,
                                        CHECKER_IMAGE                   ,
                                        GRADIENT_HORIZONTAL             ,
                                        GRADIENT_VERTICAL               ,
                                        GRADIENT_XORED      
                                    } 
                                        available_patterns_enum         ;

/*
Table of the patterns which can be requested to generate the test video
PATTERN NUMBER      NAME                    DEFINITION
0                   ALL_BLACK               Generate all pixels as black pixels (requested_level_black)
1                   ALL_WHITE               Generate all pixels as white pixels (requested_level_white)
2                   ALL_INTERMEDIATE        Generate all pixels as intermediate level (requested_level_intermediate)
3                   CHECKER_ROWS            Generate rows as black-white-black-white-etc levels with the selected horizontal step
4                   CHECKER_COLS            Generate cols as black-white-black-white-etc levels with the selected vertical step
5                   CHECKER_IMAGE           Generate the checker board with the selected horizontal adn vertical steps for the correlated sizes of the tiles
6                   GRADIENT_HORIZONTAL     Generate horizontal gradient pattern
7                   GRADIENT_VERTICAL       Generate vertical gradient pattern
8                   GRADIENT_XORED          Generate XORed gradient pattern
*/


//Counters to generate patterns
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_cols_gen_cnt              ;   // Counter for the requested number of colomns to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_rows_gen_cnt              ;   // Counter for the requested number of rows to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_v_sync_duration_cnt       ;   // Counter for the requested number of rows to be generated

logic [SYS_REG_WIDTH - 1 : 0  ]     requested_rows_step_counter         ;   // Counter for the requested number of rows to be generated
logic [SYS_REG_WIDTH - 1 : 0  ]     requested_cols_step_counter         ;   // Counter for the requested number of rows to be generated
logic                               requested_rows_step_flag            ;   // Counter for the requested number of rows to be generated
logic                               requested_cols_step_flag            ;   // Counter for the requested number of rows to be generated

//End of local signals and parameters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of checking input parameters secntion section
initial begin
    if(SYS_REG_WIDTH <= 0) begin
        $error("Parameter SYS_REG_WIDTH must NOT be equal or less than 0");
    end

    if(OUT_DATA_WIDTH <= 0) begin
        $error("Parameter OUT_DATA_WIDTH must NOT be equal or less than 0");
    end

    $display("%m setup with parameter SYS_REG_WIDTH         : %d", SYS_REG_WIDTH    );
    $display("%m setup with parameter OUT_DATA_WIDTH        : %d", OUT_DATA_WIDTH   );
end
//End of checking input parameters secntion section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of driving counters section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            requested_cols_gen_reg              <=  requested_cols_gen              ;
            requested_rows_gen_reg              <=  requested_rows_gen              ;
            requested_cols_del_before_reg       <=  requested_cols_del_before       ;
            requested_rows_del_before_reg       <=  requested_rows_del_before       ;
            requested_cols_del_after_reg        <=  requested_cols_del_after        ;
            requested_rows_del_after_reg        <=  requested_rows_del_after        ;
            requested_v_sync_duration_reg       <=  requested_v_sync_duration       ;
            requested_data_pattern_reg          <=  requested_data_pattern          ;
            requested_level_white_reg           <=  requested_level_white           ;
            requested_level_black_reg           <=  requested_level_black           ;
            requested_level_intermediate_reg    <=  requested_level_intermediate    ;
            requested_horizontal_step_reg       <=  requested_horizontal_step       ;
            requested_vertical_step_reg         <=  requested_vertical_step         ;
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
//Begin of driving sig_out_vsync section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            requested_v_sync_duration_cnt <= '0;
            sig_out_vsync <= '0;
        end
    else
        begin
            if(requested_v_sync_duration_cnt == requested_v_sync_duration_reg - 1) begin
                sig_out_vsync <= '0;
            end
            else begin
                sig_out_vsync <= '1;
                requested_v_sync_duration_cnt <= requested_v_sync_duration_cnt + 1;
            end
        end
end
//End of driving sig_out_vsync section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of hsync and related signals section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            sig_out_hsync <= '0;
            sig_out_hsync_first <= '0;
            sig_out_hsync_last <= '0;
        end
    else
        begin
            if ((requested_rows_gen_cnt >= requested_rows_del_before_reg) && 
            (requested_rows_gen_cnt < requested_rows_del_before_reg + requested_rows_gen_reg)) begin
                if((requested_cols_gen_cnt >= requested_cols_del_before_reg) && 
                (requested_cols_gen_cnt < requested_cols_del_before_reg + requested_cols_gen_reg))begin
                    sig_out_hsync <= '1;
                end
                else begin
                    sig_out_hsync <= '0;
                end

                if(requested_cols_gen_cnt == requested_cols_del_before_reg) begin
                    sig_out_hsync_first <= '1;
                end
                else begin
                    sig_out_hsync_first <= '0;
                end

                if(requested_cols_gen_cnt == requested_cols_del_before_reg + requested_cols_gen_reg - 1) begin
                    sig_out_hsync_last <= '1;
                end
                else begin
                    sig_out_hsync_last <= '0;
                end
            end
            else begin
                sig_out_hsync <= '0;
            end
        end
end
//End of hsync section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of driving counters to generate pattern steps etc section

//Horizontal counter
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            requested_rows_step_counter <= '0;
            requested_rows_step_flag    <= '0;
        end
    else
        begin
            if ((requested_rows_gen_cnt >= requested_rows_del_before_reg) && 
                (requested_rows_gen_cnt < requested_rows_del_before_reg + requested_rows_gen_reg)) begin
                    
                    if(requested_cols_gen_cnt == requested_cols_del_before_reg + requested_cols_gen_reg + requested_cols_del_after_reg - 1) begin
                        if (requested_rows_step_counter >= requested_horizontal_step_reg - 1) begin
                            requested_rows_step_counter <= '0;
                            requested_rows_step_flag    <= ~requested_rows_step_flag;
                        end
                        else begin
                            requested_rows_step_counter <= requested_rows_step_counter + 1;
                        end
                    end
            end
            else begin
                requested_rows_step_counter <= '0;
                requested_rows_step_flag    <= '0;
            end
        end
end

//Vertical counter
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            requested_cols_step_counter <= '0;
            requested_cols_step_flag    <= '0;
        end
    else
        begin
            if ((requested_rows_gen_cnt >= requested_rows_del_before_reg) && 
                (requested_rows_gen_cnt < requested_rows_del_before_reg + requested_rows_gen_reg)) begin

                    if((requested_cols_gen_cnt >= requested_cols_del_before_reg) && 
                        (requested_cols_gen_cnt < requested_cols_del_before_reg + requested_cols_gen_reg))begin
                        
                        if(requested_cols_step_counter >= requested_vertical_step_reg - 1) begin
                            requested_cols_step_counter <= '0;
                            requested_cols_step_flag    <= ~requested_cols_step_flag;
                        end
                        else begin
                            requested_cols_step_counter <= requested_cols_step_counter + 1;
                        end
                    end
                    else begin
                        requested_cols_step_counter <= '0;
                        requested_cols_step_flag    <= '0;
                    end
            end
        end
end
//End of driving counters to generate pattern steps etc section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of data pattern generation section
always_ff @(posedge clk)
begin
    if(!enable)
        begin
            sig_out_data <= '0;
        end
    else
        begin
            case (requested_data_pattern_reg)
                ALL_BLACK:          sig_out_data <= requested_level_black_reg                                                                           ;
                ALL_WHITE:          sig_out_data <= requested_level_white_reg                                                                           ;
                ALL_INTERMEDIATE:   sig_out_data <= requested_level_intermediate_reg                                                                    ;
                CHECKER_ROWS:       sig_out_data <= requested_rows_step_flag ? requested_level_white_reg : requested_level_black_reg                    ;
                CHECKER_COLS:       sig_out_data <= requested_cols_step_flag ? requested_level_white_reg : requested_level_black_reg                    ;
                CHECKER_IMAGE:
                    begin
                        if(requested_rows_step_flag)
                            sig_out_data <= requested_cols_step_flag ? requested_level_white_reg : requested_level_black_reg                            ; 
                        else
                            sig_out_data <= requested_cols_step_flag ? requested_level_black_reg : requested_level_white_reg                            ; 
                    end
                GRADIENT_HORIZONTAL: sig_out_data <= requested_cols_step_counter[OUT_DATA_WIDTH-1:0]                                                    ;
                GRADIENT_VERTICAL: sig_out_data <= requested_rows_step_counter[OUT_DATA_WIDTH-1:0]                                                      ;
                GRADIENT_XORED: sig_out_data <= requested_cols_step_counter[OUT_DATA_WIDTH-1:0] ^ requested_rows_step_counter[OUT_DATA_WIDTH-1:0]       ;
                default: //If no corret pattern found - generating black level
                    begin
                        sig_out_data <= requested_level_black_reg                                                                                       ;
                    end
            endcase
        end
end
//End of data pattern generation section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
endmodule