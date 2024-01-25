`timescale 1ns/1ps
`define semi_period 10

module tb_mult_s();

localparam NB_DATA = 4;

reg tb_clk, tb_rst;

reg signed [NB_DATA-1:0]    a, b;

wire signed [NB_DATA-1:0]   o_mult;
wire                        mult_done;

initial begin
    tb_rst  = 1;
    tb_clk  = 1;
    a       = 0;
    b       = 0;
    # 1000;
    tb_rst  = 0;
    a       = 4'b0100;  // 0.5
    b       = 4'b1000;  // -1       --> -0.5
    @(posedge tb_clk);
    while(~mult_done) @(posedge tb_clk);
    a       = 4'b1100;  // -0.5
    b       = 4'b1100;  // -0.5     --> 0.25
    @(posedge tb_clk);
    while(~mult_done) @(posedge tb_clk);
    a       = 4'b1110;  // -0.25
    b       = 4'b1001;  // -0.875   --> 0.125
    @(posedge tb_clk);
    while(~mult_done) @(posedge tb_clk);
    a       = 4'b0001;  // 0.125
    b       = 4'b1100;  // -0.5     --> -0.125
    @(posedge tb_clk);
    while(~mult_done) @(posedge tb_clk);
    a       = 4'b1100;  // -0.5
    b       = 4'b1001;  // -0.875   --> 0.375
    @(posedge tb_clk);
    while(~mult_done) @(posedge tb_clk);
    a       = 4'b0100;  // 0.5
    b       = 4'b0111;  // 0.875   --> 0.375
    @(posedge tb_clk);
    while(~mult_done) @(posedge tb_clk);
    $finish();
end

always begin
    # `semi_period;
    tb_clk = ~ tb_clk;
end

multiplier_s #(
    .NB_DATA(NB_DATA)
) u_mult (
    .i_clk      (tb_clk ),
    .i_rst      (tb_rst ),
    .i_a        (a      ),
    .i_b        (b      ),

    .o_mult_done(mult_done  ),
    .o_mult     (o_mult     )
);

endmodule