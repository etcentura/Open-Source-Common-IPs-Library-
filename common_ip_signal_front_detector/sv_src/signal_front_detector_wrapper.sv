module signal_front_detector_wrapper
#
(
    parameter   int     SIGNAL_WIDTH    =	16              // Width of the signals to detect fronts
)

(
    //Basic signals declaration
    input		logic		                        clk             ,   // Sampling clock

    //Input signals
    input		logic		[SIGNAL_WIDTH - 1 : 0] 	signal_in       ,   // Signal in

    //Output signals
    output		logic		[SIGNAL_WIDTH - 1 : 0] 	signal_out      ,   // Sampled signal
    output		logic		[SIGNAL_WIDTH - 1 : 0] 	signal_posedge  ,   // Positive fronts
    output		logic		[SIGNAL_WIDTH - 1 : 0] 	signal_negedge      // Negative fronts
);

//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of local signals and parameters section
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_reg;
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_pos;
logic		[SIGNAL_WIDTH - 1 : 0] 	signal_neg;
//End of local signals and parameters section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of checking input parameters secntion section
initial begin
    if(SIGNAL_WIDTH <= 0) begin
        $error("Parameter SIGNAL_WIDTH must NOT be equal or less than 0");
    end
    $display("%m setup with parameter SIGNAL_WIDTH         : %d", SIGNAL_WIDTH    );
end
//End of checking input parameters secntion section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of main signal processing section
always_ff @(posedge clk)
begin
    for (int i = 0; i < SIGNAL_WIDTH; i++)
        begin
            signal_reg[i]  <= signal_in[i];
        end
end

always_comb
begin
   for (int i = 0; i < SIGNAL_WIDTH; i++)
    begin
        signal_pos[i]	=	~signal_reg[i] & signal_in[i];
        signal_neg[i]	=	signal_reg[i] & ~signal_in[i];
    end 
end
//End of main signal processing section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//Begin of outputting singals section
always_comb
begin
    for (int i = 0; i < SIGNAL_WIDTH; i++)
        begin
            signal_out    [i]  = signal_reg[i];
            signal_posedge[i]  = signal_pos[i];
            signal_negedge[i]  = signal_neg[i];
        end
end
//End of outputting singals section
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
endmodule