`timescale 1ns/1ps

module pi #(
    parameter NB_COEF = 16,
    parameter NB_DATA = 16
)
(
    input                       i_clk,
    input                       i_rst,
    input signed [NB_DATA-1:0]  i_data,

    output signed [NB_DATA-1:0]  o_data
);

localparam NB_PARTIAL_PROD  = NB_DATA + NB_COEF;
localparam NB_PARTIAL_SUM   = NB_DATA + 1;

wire signed [NB_COEF-1:0]   Ki;
wire signed [NB_COEF-1:0]   Kp;
wire signed [NB_COEF-1:0]   K;

assign Ki = 16'h0666;
assign Kp = 16'h0CCC;
assign K  = Ki - Kp;

wire signed [NB_PARTIAL_PROD-1:0]   partial_prod_B  [1:0];
wire signed [NB_DATA-1:0]           trunc_prod_B    [1:0];

wire signed [NB_PARTIAL_SUM-1:0]    partial_sum_A;
wire signed [NB_PARTIAL_SUM-1:0]    partial_sum_B;

wire signed [NB_DATA-1:0]           trunc_sum_A;
wire signed [NB_DATA-1:0]           trunc_sum_B;


reg signed [NB_DATA-1:0]    x[1:0];
reg signed [NB_DATA-1:0]    y;


always @(posedge i_clk) begin
    if(i_rst) begin
        x[0] <= {NB_DATA{1'b0}};
        x[1] <= {NB_DATA{1'b0}};
        y <= {NB_DATA{1'b0}};
    end
    else begin
        x[0] <= i_data;
        x[1] <= x[0];
        y <= o_data;
    end
end

// ********************* FORWARD SECTION *********************
assign partial_prod_B[0]    = x[0]*K;                             // (32,30) = (16,15) * (16,15)
assign partial_prod_B[1]    = Kp*x[1];                            // (32,30) = (16,15) * (16,15)

assign partial_sum_B        = trunc_prod_B[0] + trunc_prod_B[1];  // (17,15) = (16,15) + (16,15)

// ********************* FEEDBACK SECTION *********************
assign partial_sum_A        = trunc_sum_B + y;                    // (17,15) = (16,15) + (16,15)

// ********************* OUTPUT *********************
assign o_data = trunc_sum_A;
generate
    genvar i;
    for (i=0; i<2; i=i+1) begin
        SatTruncFP #(
            .NB_XI (NB_PARTIAL_PROD),
            .NBF_XI(NB_PARTIAL_PROD-2),

            .NB_XO (NB_DATA),
            .NBF_XO(NB_DATA-1)
        ) SatProdB (
            .i_data(partial_prod_B[i]),
            .o_data(trunc_prod_B[i])
        );
    end

    SatTruncFP #(
        .NB_XI (NB_PARTIAL_SUM),
        .NBF_XI(NB_PARTIAL_SUM-2),

        .NB_XO (NB_DATA),
        .NBF_XO(NB_DATA-1)
    ) SatSumB (
        .i_data(partial_sum_B),
        .o_data(trunc_sum_B)
    );

    SatTruncFP #(
        .NB_XI (NB_PARTIAL_SUM),
        .NBF_XI(NB_PARTIAL_SUM-2),

        .NB_XO (NB_DATA),
        .NBF_XO(NB_DATA-1)
    ) SatSumA (
        .i_data(partial_sum_A),
        .o_data(trunc_sum_A)
    );
endgenerate

endmodule