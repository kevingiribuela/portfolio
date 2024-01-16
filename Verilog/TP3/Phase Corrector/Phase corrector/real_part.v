`timescale 1ns/1ps

module real_part #(
    parameter NB_DATA = 16
)
(
    input                       i_clk,
    input                       i_rst,
    input signed [NB_DATA-1:0]  i_data,

    output signed [NB_DATA-1:0] o_data
);

wire signed [NB_DATA:0]     partial_sum;
wire signed [NB_DATA-1:0]   trunc_sum;

reg signed [NB_DATA-1:0]    x   [2:0];

always @(posedge i_clk) begin
    if(i_rst) begin
        x[0] <= {NB_DATA{1'b0}};
        x[1] <= {NB_DATA{1'b0}};
        x[2] <= {NB_DATA{1'b0}};
    end
    else begin
        x[0] <= i_data;
        x[1] <= x[0];
        x[2] <= x[1];
    end
end

assign partial_sum = x[2] + x[0];
assign o_data = trunc_sum;

SatTruncFP #(
    .NB_XI (NB_DATA+1),
    .NBF_XI(NB_DATA-1),

    .NB_XO (NB_DATA),
    .NBF_XO(NB_DATA-1)
) sum_sat (
    .i_data(partial_sum),
    .o_data(trunc_sum)
);

endmodule