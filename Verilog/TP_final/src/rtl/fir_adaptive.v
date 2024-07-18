module fir_adaptive #(
    parameter NB_DATA   = 21,
    parameter NBF_DATA  = 20
)(
    input                       i_clk,
    input                       i_rst,

    input signed [NB_DATA-1:0]  i_mic2,
    input signed [NB_DATA-1:0]  i_mic1,
    input signed [NB_DATA-1:0]  i_mu,

    output signed [NB_DATA-1:0] o_filter
);
localparam NBI_DATA     = NB_DATA-NBF_DATA;


localparam NB_PP        = 2*NB_DATA;            // (42,40)
localparam NBF_PP       = 2*NBF_DATA;           

localparam NB_PSUM1     = NB_PP + 1;            // (43,40)

localparam NB_PSUM2     = NB_PSUM1 + 1;         // (44,40)
localparam NBF_PSUM2    = NBF_PP;
localparam NBI_PSUM2    = NB_PSUM2-NBF_PSUM2;

localparam NB_PSUM3     = NB_PSUM2 +1;          // (45,40)
localparam NBF_PSUM3    = NBF_PSUM2;

reg signed [NB_DATA-1:0]    mic1_shift_reg  [3:0];
reg signed [NB_DATA-1:0]    mic2_in;
reg signed [NB_DATA-1:0]    filter_out;

wire signed [NB_DATA-1:0]   filter_coeff    [3:0];

wire signed [NB_PP-1:0]     partial_prod    [3:0];

wire signed [NB_PSUM1-1:0]  partial_sum1    [1:0];
wire signed [NB_PSUM2-1:0]  partial_sum2;
wire signed [NB_PSUM3-1:0]  partial_sum3;
wire signed [NB_DATA-1:0]   trunc_sum3;

wire signed [NB_PSUM2-1:0]  mic2_in_extended;

always @(posedge i_clk) begin
    if(i_rst) begin
        filter_out          <= {NB_DATA{1'b0}};
        mic2_in             <= {NB_DATA{1'b0}};
        mic1_shift_reg[0]   <= {NB_DATA{1'b0}};
        mic1_shift_reg[1]   <= {NB_DATA{1'b0}};
        mic1_shift_reg[2]   <= {NB_DATA{1'b0}};
        mic1_shift_reg[3]   <= {NB_DATA{1'b0}};
    end else begin
        filter_out          <= trunc_sum3;
        mic2_in             <= i_mic2;
        mic1_shift_reg[0]   <= i_mic1;
        mic1_shift_reg[1]   <= mic1_shift_reg[0];
        mic1_shift_reg[2]   <= mic1_shift_reg[1];
        mic1_shift_reg[3]   <= mic1_shift_reg[2];
    end
end

assign partial_prod [0]     = mic1_shift_reg[0] * filter_coeff[0];  // (42,40) = (21,20) * (21,20)
assign partial_prod [1]     = mic1_shift_reg[1] * filter_coeff[1];  // (42,40) = (21,20) * (21,20)
assign partial_prod [2]     = mic1_shift_reg[2] * filter_coeff[2];  // (42,40) = (21,20) * (21,20)
assign partial_prod [3]     = mic1_shift_reg[3] * filter_coeff[3];  // (42,40) = (21,20) * (21,20)

assign partial_sum1[0]      = partial_prod[0] + partial_prod[1];    // (43,40) = (42,40) + (42,40)
assign partial_sum1[1]      = partial_prod[2] + partial_prod[3];    // (43,40) = (42,40) + (42,40)
assign partial_sum2         = partial_sum1[0] + partial_sum1[1];    // (44,40) = (43,40) + (43,40)
assign mic2_in_extended     = $signed({{NBI_PSUM2-NBI_DATA{mic2_in[NB_DATA-1]}}, mic2_in, {NBF_PSUM2-NBF_DATA{1'b0}}});
assign partial_sum3         = mic2_in_extended - partial_sum2;      // (45,40) = (44,40) - (44,40)

assign o_filter   = filter_out;


lms #(
    .NB_DATA(NB_DATA),
    .NBF_DATA(NBF_DATA)
) u_lms (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_error(trunc_sum3),

    .i_mu(i_mu),
    .i_mic1_reg0(mic1_shift_reg[0]),
    .i_mic1_reg1(mic1_shift_reg[1]),
    .i_mic1_reg2(mic1_shift_reg[2]),
    .i_mic1_reg3(mic1_shift_reg[3]),

    .o_filter_coeff0(filter_coeff[0]),
    .o_filter_coeff1(filter_coeff[1]),
    .o_filter_coeff2(filter_coeff[2]),
    .o_filter_coeff3(filter_coeff[3])
);

generate
        SatTruncFP #(
            .NB_IN(NB_PSUM3),   // 45
            .NBF_IN(NBF_PSUM3), // 40   --> (45,40)

            .NB_OUT(NB_DATA),    // 21
            .NBF_OUT(NBF_DATA)   // 20   --> (21,20)
        ) sum_trunc1 (
            .i_data(partial_sum3),
            .o_data(trunc_sum3)
        );
endgenerate

endmodule