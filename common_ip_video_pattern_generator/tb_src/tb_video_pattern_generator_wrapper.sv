`timescale 1ns/1ps

module tb_video_pattern_generator_wrapper();

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of declaring local signals and parameters section

parameter   int     SYS_REG_WIDTH           =	32                                  ;   // Width of setup registers
parameter   int     OUT_DATA_WIDTH          =	8                                   ;   // Width of the data output

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

//TB signals and vars
int                                         total_pixels_to_generate                ;
int                                         total_pixels_generated                  ;
bit                                         flag_to_gather_pixels                   ;
string                                      dump_file_paths[]                       ;
int                                         current_file_idx                        ;
int                                         current_file_descriptor                 ;

/*
Table of the patterns which can be requested to generate the test video
PATTERN NUMBER      NAME                    DEFINITION
0                   ALL_BLACK               Generate all pixels as black pixels (requested_level_black)
1                   ALL_WHITE               Generate all pixels as white pixels (requested_level_white)
2                   ALL_INTERMEDIATE        Generate all pixels as intermediate level (requested_level_intermediate)
3                   CHECKER_ROWS            Generate rows as black-white-black-white-etc levels with the selected horizontal step
4                   CHECKER_COLS            Generate cols as black-white-black-white-etc levels with the selected vertical step
5                   CHECKER_IMAGE           Generate the checker board with the selected horizontal adn vertical steps for the correlated sizes of the tiles
*/
assign dump_file_paths = {
                           "../../../../../../tb_dump_data/all_white.data",             // 0
                           "../../../../../../tb_dump_data/all_black.data",             // 1
                           "../../../../../../tb_dump_data/all_intermediate.data",      // 2
                           "../../../../../../tb_dump_data/checker_rows.data",          // 3
                           "../../../../../../tb_dump_data/checker_cols.data",          // 4
                           "../../../../../../tb_dump_data/checker_image.data",         // 5
                           "../../../../../../tb_dump_data/non_existing.data"           // 6
                        };



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
    total_pixels_generated          = 0        ;
    current_file_idx                = 0        ;
    $display(">>> Dump image array size is %d", $size(dump_file_paths));

    for (current_file_idx = 0; current_file_idx < $size(dump_file_paths); current_file_idx++) begin

        requested_data_pattern <= current_file_idx;
        $display(">>> Current file to open %d in the name of %s", current_file_idx, dump_file_paths[current_file_idx]);
        current_file_descriptor = $fopen(dump_file_paths[current_file_idx], "w");
        $display(">>> Current descriptor %d", current_file_descriptor);
        
        repeat(100) @(posedge clk);
        enable <= '1;
        while(1) begin
            @(posedge clk);
            total_pixels_generated = total_pixels_generated + 1;
            if(total_pixels_generated == total_pixels_to_generate - 1) begin
                enable <= '0;
                total_pixels_generated <= 0;
                $fclose(current_file_descriptor);
                break;
            end
        end 
    end
    $display(">>>>> Succsess!");
    $finish();
end
//End of generating main scenario section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of dumping data into the files section
initial begin
    while (1) begin
        @(posedge clk);
        if(enable) begin
            if(current_file_descriptor != 0) begin
                if (sig_out_hsync) begin
                    $fwrite(current_file_descriptor, "%c", sig_out_data);
                end
            end
            else begin
                $fatal("Failed to capture dump file");
                $finish();
            end
        end
        
    end
end
//End of dumping data into the files section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
endmodule