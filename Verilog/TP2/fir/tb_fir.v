module tb_fir();
// Localparam
localparam NB_OUTPUT = 18;
localparam NB_INPUT  = 16;

// Internal vars
reg                     i_clk;
reg                     i_rst;

wire [NB_INPUT-1:0]     signal;
wire [NB_OUTPUT-1:0]    filtered_signal;
wire [NB_OUTPUT-1:0]    filtered_signal_round;
wire [NB_OUTPUT-1:0]    filtered_signal_folded;
wire [NB_OUTPUT-1:0]    filtered_signal_folded_round;


always #20 i_clk = ~i_clk;

initial begin
    i_clk = 0;
    i_rst = 1;
    # 100;
    i_rst = 0;
    # 8000;
    $finish();
end

fir #(
    .NB_INPUT(NB_INPUT),
    .NB_OUTPUT(NB_OUTPUT)
)
    u_fir(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(signal),

        .o_data(filtered_signal)
    );

fir_round #(
       .NB_INPUT(NB_INPUT),
       .NB_OUTPUT(NB_OUTPUT)
)
   u_fir_round(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(signal),

       .o_data(filtered_signal_round)
   );


fir_folded #(
   .NB_INPUT(NB_INPUT),
   .NB_OUTPUT(NB_OUTPUT)
)
   u_fir_folded(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(signal),

       .o_data(filtered_signal_folded)
   );

fir_folded_round #(
   .NB_INPUT(NB_INPUT),
   .NB_OUTPUT(NB_OUTPUT)
)
   u_fir_folded_round(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(signal),

       .o_data(filtered_signal_folded_round)
   );

signal_generator #(
    .NB_DATA(NB_INPUT)
)
    u_signal_generator (
        .i_clock(i_clk),
        .i_reset(i_rst),
        .o_signal(signal)
    );

endmodule