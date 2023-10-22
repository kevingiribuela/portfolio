module fir_round #(
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
localparam NB_PARTIAL_PROD  = 16;
localparam TRUNCADORES  = 4;

// Coefs
wire signed [NB_COEF-1:0]   coeff [3:0];

assign coeff[0] = 16'h04F0;
assign coeff[1] = 16'h3B0F;
assign coeff[2] = 16'h3B0F;
assign coeff[3] = 16'h04F0;

// Output data
wire signed [NB_OUTPUT-1:0] y0;

// Registers
reg signed [NB_INPUT-1:0]    x [1:3];

// Partials products & final products   
wire signed [2*NB_PARTIAL_PROD-1 : 0] partial_prod  [3:0];  // (32,30) = (16,15) * (16,15)
wire signed [NB_PARTIAL_PROD-1   : 0] trunc_prod    [3:0];  // (32,30) --> (16,15)

// Sums
wire signed [NB_PARTIAL_PROD-1+1 : 0] sum0, sum1;           // (16,15) + (16,15) = (17,15)
wire signed [NB_PARTIAL_PROD-1+2 : 0] sum2;                 // (17,15) + (17,15) = (18,15)

always @(posedge i_clk) begin: shift_register
integer i;
    if(i_rst) begin
        for(i=1; i<=3; i=i+1) begin
            x[i] <= {NB_INPUT{1'b1}};
        end
        
        o_data <= 0;
    end
    else begin
        x[1] <= i_data;
        for(i=1; i<3; i=i+1) begin
            x[i+1] <= x[i];
        end

        o_data <= y0;
    end
end

assign partial_prod[0] = i_data * coeff[0];     // (32,30) = (16,15) * (16,15)
assign partial_prod[1] = x[1] * coeff[1];       // (32,30) = (16,15) * (16,15)
assign partial_prod[2] = x[2] * coeff[2];       // (32,30) = (16,15) * (16,15)
assign partial_prod[3] = x[3] * coeff[2];       // (32,30) = (16,15) * (16,15)

assign sum0 = trunc_prod[0] + trunc_prod[1];    // (17,15) = (16,15) + (16,15)
assign sum1 = trunc_prod[2] + trunc_prod[3];    // (17,15) = (16,15) + (16,15)
assign sum2 = sum1 + sum0;                      // (18,15) = (17,15) + (17,15)

assign y0 = sum2;


generate
    genvar i;
    for (i = 0; i<TRUNCADORES; i=i+1) begin
        SatRoundFP #(
            .NB_XI  (2*NB_PARTIAL_PROD),    // (32,30)
            .NBF_XI (2*NB_PARTIAL_PROD-2),

            .NB_XO  (NB_PARTIAL_PROD),      // (16,15)
            .NBF_XO (NB_PARTIAL_PROD-1)
        ) sat_round
        (
            .i_data(partial_prod[i]),       // (32,30)
            .o_data(trunc_prod[i])          // (16,15)
        );
    end
endgenerate

endmodule