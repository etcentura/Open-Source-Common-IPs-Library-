`timescale 1ns/1ps

module tb_video_pattern_generator_wrapper();

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of declaring local signals and parameters section

parameter   int     SYS_REG_WIDTH           =	32                                  ;   // Width of setup registers
parameter   int     OUT_DATA_WIDTH          =	16                                  ;   // Width of the data output

//Basic signals declaration 
logic		                                clk                                     ;   // Basic clk signal
//Enable signal
logic		                                enable                                  ;   // Enable signal to generate pattern, when 0 - generation restarts and registers 
//Setup signals
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_cols_gen                      ;   // Requested number of colomns to be generated
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_gen                      ;   // Requested number of rows to be generated
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_cols_del_before               ;   // Requested number of colomns to be delayed
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_del_before               ;   // Requested number of rows to be delayed
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_cols_del_after                ;   // Requested number of colomns to be delayed
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_rows_del_after                ;   // Requested number of rows to be delayed
logic		[SYS_REG_WIDTH - 1 : 0  ]       requested_v_sync_duration               ;   // Number of ticks to hold vsync active high
logic		[3                 : 0  ]       requested_data_pattern                  ;   // Requested pattren type to be generated
logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_level_white                   ;   // Requested level of the white color (maximum aka white level)
logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_level_black                   ;   // Requested level of the black color (minimum aka black level)
logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_level_intermediate            ;   // Requested level of the intermediate color (any desired level)
logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_horizontal_step               ;   // Requested step of the generation for rows
logic       [SYS_REG_WIDTH - 1 : 0  ]       requested_vertical_step                 ;   // Requested step of the generation for cols
//Output signals
logic		                                sig_out_vsync                           ;   //V-Sync active-high signal for syncronization
logic		                                sig_out_hsync                           ;   //H-Sync active-high signal as if valid data flag
logic		                                sig_out_hsync_first                     ;   //H-Sync active-high signal as if valid data flag for the first data beat
logic		                                sig_out_hsync_last                      ;   //H-Sync active-high signal as if valid data flag for the last data beat
logic		[OUT_DATA_WIDTH - 1 : 0  ] 	    sig_out_data                            ;   //Output data marked with the hsync and first and last data markers

//TB signals
int                                         total_pixels_to_generate                ;
int                                         total_pixels_generated                  ;
//End of declaring local signals and parameters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of instancing dut section
video_pattern_generator_wrapper 
#
(
    .SYS_REG_WIDTH                  (SYS_REG_WIDTH                  ),  // Width of setup registers
    .OUT_DATA_WIDTH                 (OUT_DATA_WIDTH                 )   // Width of the data output
)
                                    i_video_pattern_generator_wrapper
(
    //Basic signals declaration 
    .clk                            (clk                            ),   // Basic clk signal

    //Enable signal
    .enable                         (enable                         ),   // Enable signal to generate pattern, when 0 - generation restarts and registers 

    //Setup signals
    .requested_cols_gen             (requested_cols_gen             ),   // Requested number of colomns to be generated
    .requested_rows_gen             (requested_rows_gen             ),   // Requested number of rows to be generated
    .requested_cols_del_before      (requested_cols_del_before      ),   // Requested number of colomns to be delayed
    .requested_rows_del_before      (requested_rows_del_before      ),   // Requested number of rows to be delayed
    .requested_cols_del_after       (requested_cols_del_after       ),   // Requested number of colomns to be delayed
    .requested_rows_del_after       (requested_rows_del_after       ),   // Requested number of rows to be delayed
    .requested_v_sync_duration      (requested_v_sync_duration      ),   // Number of ticks to hold vsync active high
    .requested_data_pattern         (requested_data_pattern         ),   // Requested pattren type to be generated
    .requested_level_white          (requested_level_white          ),   // Requested level of the white color (maximum aka white level)
    .requested_level_black          (requested_level_black          ),   // Requested level of the black color (minimum aka black level)
    .requested_level_intermediate   (requested_level_intermediate   ),   // Requested level of the intermediate color (any desired level)
    .requested_horizontal_step      (requested_horizontal_step      ),   // Requested step of the generation for rows
    .requested_vertical_step        (requested_vertical_step        ),   // Requested step of the generation for cols

    //Output signals
    .sig_out_vsync                  (sig_out_vsync                  ),   //V-Sync active-high signal for syncronization
    .sig_out_hsync                  (sig_out_hsync                  ),   //H-Sync active-high signal as if valid data flag
    .sig_out_hsync_first            (sig_out_hsync_first            ),   //H-Sync active-high signal as if valid data flag for the first data beat
    .sig_out_hsync_last             (sig_out_hsync_last             ),   //H-Sync active-high signal as if valid data flag for the last data beat
    .sig_out_data                   (sig_out_data                   )    //Output data marked with the hsync and first and last data markers
);
//End of instancing dut section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of clk generation section

//Assuming these clks are:
initial
begin
    clk = 0;
    forever #20 clk = !clk;
end
//End of clk generation section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of generating main scenario section
initial begin : main
    enable                          = '0       ;
    requested_cols_gen              = 640      ;   // Requested number of colomns to be generated
    requested_rows_gen              = 512      ;   // Requested number of rows to be generated
    requested_cols_del_before       = 30       ;   // Requested number of colomns to be delayed
    requested_rows_del_before       = 5        ;   // Requested number of rows to be delayed
    requested_cols_del_after        = 50       ;   // Requested number of colomns to be delayed
    requested_rows_del_after        = 25       ;   // Requested number of rows to be delayed
    requested_v_sync_duration       = 1000     ;   // Number of ticks to hold vsync active high
    requested_level_white           = 20       ;   // Requested level of the white color (maximum aka white level)
    requested_level_black           = 250      ;   // Requested level of the black color (minimum aka black level)
    requested_level_intermediate    = 125      ;   // Requested level of the intermediate color (any desired level)
    requested_horizontal_step       = 8        ;   // Requested step of the generation for rows
    requested_vertical_step         = 8        ;   // Requested step of the generation for cols
    requested_data_pattern          = 0        ;   // Requested pattren type to be generated
    
    total_pixels_to_generate        = (requested_cols_del_before + requested_cols_del_after + requested_cols_gen) *
                                        (requested_rows_del_before + requested_rows_gen + requested_rows_del_after);
    total_pixels_generated = 0;

    repeat(100) @(posedge clk);
    enable <= '1;
    while(1) begin
        @(posedge clk);
        total_pixels_generated <= total_pixels_generated + 1;
        if(total_pixels_generated == total_pixels_to_generate - 1) begin
            break;
        end
    end
    enable = '0;
    total_pixels_generated = 0;

    $finish();
end
//End of generating main scenario section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
endmodule