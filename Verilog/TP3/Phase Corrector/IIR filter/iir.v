`timescale 1ns/1ps

module iir #(
    parameter NB_COEF   = 16,
    parameter NB_DATA   = 16
)
(
    input                       i_clk,
    input                       i_rst,
    input signed [NB_DATA-1:0]  i_data,

    output signed [NB_DATA-1:0]  o_data
);

localparam NB_PARTIAL_PROD  = NB_DATA + NB_COEF;
localparam NB_PARTIAL_SUM   = NB_DATA + 1;

wire signed [NB_COEF-1:0] b   [2:0];
wire signed [NB_COEF-1:0] a   [2:1];

assign b[0] = 16'h27AE;
assign b[1] = 16'h4666;
assign b[2] = 16'h3333;

assign a[1] = 16'h0666;
assign a[2] = 16'h1FDF;

wire signed [NB_PARTIAL_PROD-1:0]   partial_prod_B  [2:0];
wire signed [NB_PARTIAL_PROD-1:0]   partial_prod_A  [2:1];
wire signed [NB_DATA-1:0]           trunc_prod_B    [2:0];
wire signed [NB_DATA-1:0]           trunc_prod_A    [2:1];

wire signed [NB_PARTIAL_SUM-1:0]    partial_sum_B   [1:0];
wire signed [NB_PARTIAL_SUM-1:0]    partial_sum_A   [1:0];
wire signed [NB_DATA-1:0]           trunc_sum_B     [1:0];
wire signed [NB_DATA-1:0]           trunc_sum_A     [1:0];

reg signed [NB_DATA-1:0]            x               [2:0];
reg signed [NB_DATA-1:0]            y               [2:1];

always @(posedge i_clk) begin
    if(i_rst) begin
        x[0] <= {NB_DATA{1'b0}};
        x[1] <= {NB_DATA{1'b0}};
        x[2] <= {NB_DATA{1'b0}};
        y[1] <= {NB_DATA{1'b0}};
        y[2] <= {NB_DATA{1'b0}};
    end
    else begin
        x[0] <= i_data;
        x[1] <= x[0];
        x[2] <= x[1];
        y[1] <= o_data;
        y[2] <= y[1];
    end
end

// ********************* FORWARD SECTION *********************
assign partial_prod_B[0] = b[0] * x[0];                       // (32,30) = (16,15) * (16,15)
assign partial_prod_B[1] = b[1] * x[1];                         // (32,30) = (16,15) * (16,15)
assign partial_prod_B[2] = b[2] * x[2];                         // (32,30) = (16,15) * (16,15)

assign partial_sum_B[1]  = trunc_prod_B[2] + trunc_prod_B[1];   // (17,15) = (16,15) + (16,15)
assign partial_sum_B[0]  = trunc_prod_B[0] + trunc_sum_B[1];    // (17,15) = (16,15) + (16,15)

// ********************* FEEDBACK SECTION *********************
assign partial_prod_A[1] = (-1) * a[1] * y[1];
assign partial_prod_A[2] = (-1) * a[2] * y[2];

assign partial_sum_A[1]  = trunc_prod_A[2] + trunc_prod_A[1];   // (17,15) = (16,15) + (16,15)
assign partial_sum_A[0]  = trunc_sum_B[0]  + trunc_sum_A[1];    // (17,15) = (16,15) + (16,15)

// ********************* OUTPUT *********************
assign o_data = trunc_sum_A[0];                                 // (16,15)

// ============ TRUNCATION - FORWARD SECTION ================
generate
    for(genvar i=0; i<3; i=i+1) begin : partial_prod_forward
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
    for(genvar i=0; i<2; i=i+1) begin : partial_sum_forward
        SatTruncFP #(
            .NB_XI (NB_PARTIAL_SUM),
            .NBF_XI(NB_PARTIAL_SUM-2),

            .NB_XO (NB_DATA),
            .NBF_XO(NB_DATA-1)
        ) SatSumB (
            .i_data(partial_sum_B[i]),
            .o_data(trunc_sum_B[i])
        );
    end
endgenerate

// ============ TRUNCATION - FEEDBACK SECITON ================
generate
    for(genvar j=1; j<3; j=j+1) begin : partial_prod_sum_feedback
        SatTruncFP #(
            .NB_XI (NB_PARTIAL_PROD),
            .NBF_XI(NB_PARTIAL_PROD-2),

            .NB_XO (NB_DATA),
            .NBF_XO(NB_DATA-1)
        ) SatProdA (
            .i_data(partial_prod_A[j]),
            .o_data(trunc_prod_A[j])
        );
        SatTruncFP #(
            .NB_XI (NB_PARTIAL_SUM),
            .NBF_XI(NB_PARTIAL_SUM-2),

            .NB_XO (NB_DATA),
            .NBF_XO(NB_DATA-1)
        ) SatSumA (
                .i_data(partial_sum_A[j-1]),
                .o_data(trunc_sum_A[j-1])
        );
    end
endgenerate

endmodule