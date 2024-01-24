`timescale 1ns/1ps

module fir_parallel_pipelined #(
    parameter NB_DATA = 8,
    parameter NB_COEF = 8
)
(
    input i_clk_G,
    input i_rst,
    input signed [NB_DATA-1:0] x0,
    input signed [NB_DATA-1:0] x1,
    input signed [NB_DATA-1:0] x2,
    input signed [NB_DATA-1:0] x3,
    input signed [NB_DATA-1:0] x4,
    input signed [NB_DATA-1:0] x5,
    input signed [NB_DATA-1:0] x6,
    input signed [NB_DATA-1:0] x7,
    
    output reg signed [NB_DATA-1:0] y
);

localparam NB_PROD = NB_DATA + NB_COEF; // 16
localparam NB_SUM1 = NB_PROD + 1;       // 17
localparam NB_SUM2 = NB_PROD + 2;       // 18
localparam NB_SUM3 = NB_PROD + 3;       // 19


wire signed [NB_COEF-1:0] h [7:0];

wire signed [NB_PROD-1:0] partial_prod      [7:0];
wire signed [NB_SUM1-1:0] partial_sum1      [3:0];
reg signed  [NB_SUM1-1:0] partial_sum1_reg  [3:0];
wire signed [NB_SUM2-1:0] partial_sum2      [1:0];
wire signed [NB_SUM3-1:0] partial_sum3;
wire signed [NB_DATA-1:0] partial_sum3_trunc;


assign h[0] = 8'd0;
assign h[1] = 8'd229;
assign h[2] = 8'd0;
assign h[3] = 8'd81;
assign h[4] = 8'd127;
assign h[5] = 8'd81;
assign h[6] = 8'd0;
assign h[7] = 8'd229;

assign partial_prod[0] = x0 * h[0];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[1] = x1 * h[1];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[2] = x2 * h[2];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[3] = x3 * h[3];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[4] = x4 * h[4];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[5] = x5 * h[5];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[6] = x6 * h[6];                         // (16,14) = (8,7) * (8,7)
assign partial_prod[7] = x7 * h[7];                         // (16,14) = (8,7) * (8,7)

assign partial_sum1[0] = partial_prod[0] + partial_prod[1]; // (17,14) = (16,14) + (16,14)
assign partial_sum1[1] = partial_prod[2] + partial_prod[3]; // (17,14) = (16,14) + (16,14)
assign partial_sum1[2] = partial_prod[4] + partial_prod[5]; // (17,14) = (16,14) + (16,14)
assign partial_sum1[3] = partial_prod[6] + partial_prod[7]; // (17,14) = (16,14) + (16,14)

assign partial_sum2[0] = partial_sum1_reg[0] + partial_sum1_reg[1]; // (18,14) = (17,14) + (17,14)
assign partial_sum2[1] = partial_sum1_reg[2] + partial_sum1_reg[3]; // (18,14) = (17,14) + (17,14)

assign partial_sum3    = partial_sum2[0] + partial_sum2[1]; // (19,14) = (18,14) + (18,14)

always @(posedge i_clk_G) begin
    if(i_rst) begin
        y <= 0;
    end
    else begin
        y <= partial_sum3_trunc;                            // (19,14) --> (8,7)
    end
end

// Pipeline registers
integer j;
always @(posedge i_clk_G) begin
    if(i_rst) begin
        for(j=0; j<4; j=j+1) begin
            partial_sum1_reg[j] <= {NB_SUM1{1'b0}};
        end
    end
    else begin
        for(j=0; j<4; j=j+1) begin
            partial_sum1_reg[j] <= partial_sum1[j];
        end
    end
end

SatTruncFP #(
    .NB_XI(NB_SUM3),
    .NBF_XI(NB_PROD-2),

    .NB_XO(NB_DATA),
    .NBF_XO(NB_DATA-1)
) trunc_partial_sum (
    .i_data(partial_sum3),
    .o_data(partial_sum3_trunc)
);

endmodule