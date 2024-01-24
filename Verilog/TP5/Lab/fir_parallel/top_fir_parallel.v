`timescale 1ns/1ps

module top_fir_parallel #(
    parameter NB_DATA = 8
)
(
    input i_clk_G,
    input i_rst,
    input signed [NB_DATA-1:0] x0,
    input signed [NB_DATA-1:0] x1,
    input signed [NB_DATA-1:0] x2,
    input signed [NB_DATA-1:0] x3,

    output reg signed [NB_DATA-1:0] y0,
    output reg signed [NB_DATA-1:0] y1,
    output reg signed [NB_DATA-1:0] y2,
    output reg signed [NB_DATA-1:0] y3
);

localparam NB_COEF = 8;

wire signed [NB_DATA-1:0] regressor_out [6:0];
wire signed [NB_DATA-1:0] y_out         [3:0];

always @(posedge i_clk_G) begin
    if(i_rst) begin
        y0 <= {NB_DATA{1'b0}};
        y1 <= {NB_DATA{1'b0}};
        y2 <= {NB_DATA{1'b0}};
        y3 <= {NB_DATA{1'b0}};
    end
    else begin
        y0 <= y_out[0];
        y1 <= y_out[1];
        y2 <= y_out[2];
        y3 <= y_out[3];
    end
end

regressor #(
    .NB_DATA(NB_DATA)
) u_regressor (
    .i_clk(i_clk_G),
    .i_rst(i_rst),
    .i_x0(x0),
    .i_x1(x1),
    .i_x2(x2),
    .i_x3(x3),

    .o_regressor0(regressor_out[0]),
    .o_regressor1(regressor_out[1]),
    .o_regressor2(regressor_out[2]),
    .o_regressor3(regressor_out[3]),
    .o_regressor4(regressor_out[4]),
    .o_regressor5(regressor_out[5]),
    .o_regressor6(regressor_out[6])
);

fir_parallel #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir0 (
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x0(x0),
    .x1(regressor_out[0]),
    .x2(regressor_out[1]),
    .x3(regressor_out[2]),
    .x4(regressor_out[3]),
    .x5(regressor_out[4]),
    .x6(regressor_out[5]),
    .x7(regressor_out[6]),

    .y(y_out[0])
);

fir_parallel #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir1 (
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x0(x1),
    .x1(x0),
    .x2(regressor_out[0]),
    .x3(regressor_out[1]),
    .x4(regressor_out[2]),
    .x5(regressor_out[3]),
    .x6(regressor_out[4]),
    .x7(regressor_out[5]),

    .y(y_out[1])
);

fir_parallel #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir2 (
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x0(x2),
    .x1(x1),
    .x2(x0),
    .x3(regressor_out[0]),
    .x4(regressor_out[1]),
    .x5(regressor_out[2]),
    .x6(regressor_out[3]),
    .x7(regressor_out[4]),

    .y(y_out[2])
);

fir_parallel #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir3 (
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x0(x3),
    .x1(x2),
    .x2(x1),
    .x3(x0),
    .x4(regressor_out[0]),
    .x5(regressor_out[1]),
    .x6(regressor_out[2]),
    .x7(regressor_out[3]),

    .y(y_out[3])
);

endmodule