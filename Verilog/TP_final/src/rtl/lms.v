module lms #(
    parameter NB_DATA   = 21,
    parameter NBF_DATA  = 20
)(
    input i_clk,
    input i_rst,

    input signed [NB_DATA-1:0]  i_error,
    input signed [NB_DATA-1:0]  i_mic1_reg0,
    input signed [NB_DATA-1:0]  i_mic1_reg1,
    input signed [NB_DATA-1:0]  i_mic1_reg2,
    input signed [NB_DATA-1:0]  i_mic1_reg3,
    input signed [NB_DATA-1:0]  i_mu,

    output signed [NB_DATA-1:0] o_filter_coeff0,
    output signed [NB_DATA-1:0] o_filter_coeff1,
    output signed [NB_DATA-1:0] o_filter_coeff2,
    output signed [NB_DATA-1:0] o_filter_coeff3
);
localparam NBI_DATA = NB_DATA-NBF_DATA;

localparam NB_UXE   = 2*NB_DATA;        // (42,40)

localparam NB_PP    = 3*NB_DATA;        // (63,60)
localparam NBF_PP   = 3*NBF_DATA;
localparam NBI_PP   = NB_PP - NBF_PP;

localparam NB_PSUM  = NB_PP + 1;        // (64,60)
localparam NBF_PSUM = NBF_PP;
localparam NBI_PSUM = NB_PSUM-NBF_PSUM;

// wire signed [NB_DATA-1:0]    u;
// assign u = $signed(21'b0_0000_1100_1100_1100_1100);

wire signed [NB_UXE-1:0]     uxe;

wire signed [NB_PP-1:0]     partial_prod    [3:0];

wire signed [NB_PSUM-1:0]   partial_sum     [3:0];
wire signed [NB_DATA-1:0]   trunc_sum       [3:0];

wire signed [NB_PP-1:0]     h_extended_sig  [3:0];
reg signed  [NB_DATA-1:0]   h               [3:0];

integer ii;
always @(posedge i_clk) begin
    if(i_rst) begin
        for(ii=0; ii<4; ii=ii+1)
            h[ii] <= {NB_DATA{1'b0}};
    end else begin
        for(ii=0; ii<4; ii=ii+1)
            h[ii]    <= trunc_sum[ii];
    end
end

assign uxe              = i_error * i_mu;  // (42,40) = (21,20) * (21,20)

assign partial_prod[0]  = uxe * i_mic1_reg0;   // (63,60) = (42,40) * (21,20)
assign partial_prod[1]  = uxe * i_mic1_reg1;   // (63,60) = (42,40) * (21,20)
assign partial_prod[2]  = uxe * i_mic1_reg2;   // (63,60) = (42,40) * (21,20)
assign partial_prod[3]  = uxe * i_mic1_reg3;   // (63,60) = (42,40) * (21,20)


assign partial_sum[0]   = partial_prod[0] + h_extended_sig[0]; // (64,60) = (63,60) + (63,60)
assign partial_sum[1]   = partial_prod[1] + h_extended_sig[1]; // (64,60) = (63,60) + (63,60)
assign partial_sum[2]   = partial_prod[2] + h_extended_sig[2]; // (64,60) = (63,60) + (63,60)
assign partial_sum[3]   = partial_prod[3] + h_extended_sig[3]; // (64,60) = (63,60) + (63,60)

assign o_filter_coeff0 = h[0];
assign o_filter_coeff1 = h[1];
assign o_filter_coeff2 = h[2];
assign o_filter_coeff3 = h[3];

generate
    genvar jj;
    for (jj=0; jj<4; jj=jj+1) begin
        assign h_extended_sig[jj] = $signed({{NBI_PP-NBI_DATA{h[jj][NB_DATA-1]}}, h[jj], {NBF_PP-NBF_DATA{1'b0}}});

        SatTruncFP #(
            .NB_IN(NB_PSUM),    // 64
            .NBF_IN(NBF_PSUM),  // 60   --> (64,60)

            .NB_OUT(NB_DATA),    // 21
            .NBF_OUT(NBF_DATA)   // 20   --> (21,20)
        ) sat_sum (
            .i_data(partial_sum[jj]),
            .o_data(trunc_sum[jj])
        );
    end
endgenerate

endmodule