module fir_unfolded #(
    parameter NB_DATA = 8,
    parameter NB_COEF = 8
)
(
    input i_clk_G,
    input i_rst,
    input signed [NB_DATA-1:0] x,

    input signed [NB_DATA+NB_COEF-1:0] B,
    input signed [NB_DATA+NB_COEF-1:0] D,
    input signed [NB_DATA+NB_COEF-1:0] F,
    input signed [NB_DATA+NB_COEF-1:0] H,
    input signed [NB_DATA+NB_COEF-1:0] J,
    input signed [NB_DATA+NB_COEF-1:0] L,
    input signed [NB_DATA+NB_COEF-1:0] N,

    output signed [NB_DATA+NB_COEF-1:0] A,
    output signed [NB_DATA+NB_COEF-1:0] C,
    output signed [NB_DATA+NB_COEF-1:0] E,
    output signed [NB_DATA+NB_COEF-1:0] G,
    output signed [NB_DATA+NB_COEF-1:0] I,
    output signed [NB_DATA+NB_COEF-1:0] K,
    output signed [NB_DATA+NB_COEF-1:0] M,
    
    output reg signed [NB_DATA-1:0] y
);

localparam NB_PROD = NB_DATA + NB_COEF;

wire signed [NB_COEF-1:0]   h           [7:0];
wire signed [NB_PROD-1:0]   partial_prod[7:0];
wire signed [NB_PROD+0:0]   partial_sum [6:0];
wire signed [NB_PROD-1:0]   trunc_sum   [7:1];
wire signed [NB_DATA-1:0]   final_sum;


assign h[0] = 8'd0;
assign h[1] = 8'd229;
assign h[2] = 8'd0;
assign h[3] = 8'd81;
assign h[4] = 8'd127;
assign h[5] = 8'd81;
assign h[6] = 8'd0;
assign h[7] = 8'd229;

assign partial_prod[0] = x * h[0];              // (16,14) = (8,7) * (8,7)
assign partial_prod[1] = x * h[1];              // (16,14) = (8,7) * (8,7)
assign partial_prod[2] = x * h[2];              // (16,14) = (8,7) * (8,7)
assign partial_prod[3] = x * h[3];              // (16,14) = (8,7) * (8,7)
assign partial_prod[4] = x * h[4];              // (16,14) = (8,7) * (8,7)
assign partial_prod[5] = x * h[5];              // (16,14) = (8,7) * (8,7)
assign partial_prod[6] = x * h[6];              // (16,14) = (8,7) * (8,7)
assign partial_prod[7] = x * h[7];              // (16,14) = (8,7) * (8,7)

assign partial_sum[0] = partial_prod[0] + N;    // (17,14) = (16,14) + (16,14)
assign partial_sum[1] = partial_prod[1] + L;    // (17,14) = (16,14) + (16,14)
assign partial_sum[2] = partial_prod[2] + J;    // (17,14) = (16,14) + (16,14)
assign partial_sum[3] = partial_prod[3] + H;    // (17,14) = (16,14) + (16,14)
assign partial_sum[4] = partial_prod[4] + F;    // (17,14) = (16,14) + (16,14)
assign partial_sum[5] = partial_prod[5] + D;    // (17,14) = (16,14) + (16,14)
assign partial_sum[6] = partial_prod[6] + B;    // (17,14) = (16,14) + (16,14)

assign trunc_sum[7] = partial_prod[7];          // (16,14)

assign A = trunc_sum[7];
assign C = trunc_sum[6];
assign E = trunc_sum[5];
assign G = trunc_sum[4];
assign I = trunc_sum[3];
assign K = trunc_sum[2];
assign M = trunc_sum[1];

always @(posedge i_clk_G) begin
    if(i_rst) begin
        y <= {NB_DATA{1'b0}};
    end
    else begin
        y <= final_sum;
    end
end

generate
    genvar j;

    SatTruncFP #(
        .NB_XI(NB_PROD+1),
        .NBF_XI(NB_PROD-2),

        .NB_XO(NB_DATA),
        .NBF_XO(NB_DATA-1)
    ) sat_trunc_out (
        .i_data(partial_sum[0]),
        .o_data(final_sum)
    );

    for (j=1; j<7; j=j+1) begin
        SatTruncFP #(
            .NB_XI(NB_PROD+1),
            .NBF_XI(NB_PROD-2),
    
            .NB_XO(NB_PROD),
            .NBF_XO(NB_PROD-2)
        ) sat_trunc (
            .i_data(partial_sum[j]),
            .o_data(trunc_sum[j])
        );
    end
endgenerate

endmodule