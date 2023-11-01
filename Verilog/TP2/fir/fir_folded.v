/* FIR filter using coefficients simmetry and cut-off frequency of 10kHz*/

module fir_folded #(
    parameter NB_INPUT     = 16,
    parameter NB_OUTPUT    = 18
)
(
    input                           i_clk,
    input                           i_rst,
    input signed [NB_INPUT-1:0]     i_data,

    output reg signed [NB_OUTPUT-1:0]   o_data
);

localparam NB_COEF          = 16;
localparam NB_PARTIAL_PROD  = 33;
localparam NB_TRUNC_PROD    = 17;

localparam NB_PARTIAL_SUM   = 18;

localparam TRUNCADORES      = 2;

// Coefs
wire signed [NB_COEF-1:0]   coeff [1:0];

assign coeff[0] = 16'h04F0;
assign coeff[1] = 16'h3B0F;
// assign coeff[2] = 16'h3B0F;
// assign coeff[3] = 16'h04F0;

// Output data
wire signed [NB_OUTPUT-1:0] y0;

// Registers
reg signed [NB_INPUT-1:0]    x [1:3];

// Partials products & final products   
wire signed [NB_PARTIAL_PROD-1  : 0] partial_prod  [1:0];  // (33,30) = (17,15) * (16,15)
wire signed [NB_TRUNC_PROD  -1  : 0] trunc_prod    [1:0];  // (33,30) --> (17,15)

// Sums
wire signed [NB_PARTIAL_SUM -1  : 0] sum[2:0];             // (17,15) = (16,15) + (16,15) -- sum[2:0] = 18 bits

always @(posedge i_clk) begin: shift_register
integer i;
    if(i_rst) begin
        for(i=1; i<=3; i=i+1) begin
            x[i] <= {NB_INPUT{1'b0}};
        end
        
        o_data <= {NB_OUTPUT{1'b0}};
    end
    else begin
        x[1] <= i_data;
        for(i=1; i<3; i=i+1) begin
            x[i+1] <= x[i];
        end

        o_data <= y0;
    end
end

assign sum[0] = i_data + x[3];                    // (17,15) = (16,15) + (16,15) -- sum[0] = 18 bits
assign sum[1] = x[1]   + x[2];                    // (17,15) = (16,15) + (16,15) -- sum[1] = 18 bits
assign sum[2] = trunc_prod[0] + trunc_prod[1];    // (18,15) = (17,15) + (17,15) -- sum[2] = 18 bits

assign partial_prod[0] = sum[0] * coeff[0];       // (33,30) = (17,15) * (16,15) -- The MSB of (17,15) is always 0 because the previous sum
assign partial_prod[1] = sum[1] * coeff[1];       // (33,30) = (17,15) * (16,15) -- The MSB of (17,15) is always 0 because the previous sum

assign y0 = sum[2];


generate
    genvar i;
    for (i = 0; i<TRUNCADORES; i=i+1) begin
        SatTruncFP #(
            .NB_XI  (NB_PARTIAL_PROD    ),  // (33,30)
            .NBF_XI (NB_PARTIAL_PROD-3  ),

            .NB_XO  (NB_TRUNC_PROD  ),      // (17,15)
            .NBF_XO (NB_TRUNC_PROD-2)
        ) sat_trunc
        (
            .i_data(partial_prod[i]),       // (33,30)
            .o_data(trunc_prod[i])          // (17,15)
        );
    end
endgenerate

endmodule