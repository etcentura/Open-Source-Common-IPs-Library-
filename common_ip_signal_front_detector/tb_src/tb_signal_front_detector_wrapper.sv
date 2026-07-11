`timescale 1ns/1ps

module tb_signal_front_detector_wrapper();

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of declaring local signals and parameters section
parameter   int     SIGNAL_WIDTH    =	16;              // Width of the signals to detect fronts

//Basic signals declaration
logic		                        clk             ;   // Sampling clock
//Input signals
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_in       ;   // Signal in
//Output signals
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_out      ;   // Sampled signal
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_posedge  ;   // Positive fronts
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_negedge  ;   // Negative fronts
//End of declaring local signals and parameters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of instancing dut section
signal_front_detector_wrapper 
#
(
    .SIGNAL_WIDTH   (SIGNAL_WIDTH       )   // Width of the signals to detect fronts
)
signal_front_detector_wrapper
(
    //Basic signals declaration
    .clk             (clk               ),   // Sampling clock

    //Input signals
    .signal_in       (signal_in         ),   // Signal in

    //Output signals
    .signal_out      (signal_out        ),   // Sampled signal
    .signal_posedge  (signal_posedge    ),   // Positive fronts
    .signal_negedge  (signal_negedge    )    // Negative fronts
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
    signal_in <= '0;
    repeat (20) @ (posedge clk);
    signal_in <= '1;
    repeat (20) @ (posedge clk);
    signal_in <= '0;
    repeat (20) @ (posedge clk);
    $display(">>>>> Succsess!");
    $finish();
end
//End of generating main scenario section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
endmodule