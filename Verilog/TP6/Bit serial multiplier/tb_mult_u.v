`timescale 1ns/1ps
`define semi_period 10

module tb_mult_u();

localparam NB_DATA = 4;

reg tb_clk, tb_rst;

reg [NB_DATA-1:0] a, b;

wire [2*NB_DATA-1:0]    o_mult;
wire                    mult_done;

initial begin
    tb_rst  = 1;
    tb_clk  = 1;
    a       = 0;
    b       = 0;
    # 1000;
    tb_rst  = 0;
    a       = 4'b0100;  // 4
    b       = 4'b0010;  // 2       --> 8
    while(~mult_done) @(negedge tb_clk);
    @(negedge tb_clk);
    a       = 4'b1100;  // 12
    b       = 4'b0001;  // 1     --> 12
    while(~mult_done) @(negedge tb_clk);
    @(negedge tb_clk);
    a       = 4'b0011;  // 3
    b       = 4'b0100;  // 4   --> 12
    while(~mult_done) @(negedge tb_clk);
    @(negedge tb_clk);
    a       = 4'b0010;  // 2
    b       = 4'b0011;  // 3    --> 6
    while(~mult_done) @(negedge tb_clk);
    @(negedge tb_clk);
    a       = 4'b1100;  // 12
    b       = 4'b0000;  // 8   --> 0
    while(~mult_done) @(negedge tb_clk);
    @(negedge tb_clk)
    a       = 4'b0000;  // 0
    b       = 4'b0111;  // 7   --> 0
    while(~mult_done) @(negedge tb_clk);
    @(negedge tb_clk)
    $finish();
end

always begin
    # `semi_period;
    tb_clk = ~ tb_clk;
end


multiplier_u #(
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