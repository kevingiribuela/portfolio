module fir_adaptive #(
    parameter NB_DATA   = 16
)(
    input                       i_clk,
    input                       i_rst,

    input signed [NB_DATA-1:0]  i_d,
    input signed [NB_DATA-1:0]  i_x,

    output signed [NB_DATA-1:0] o_err
);


reg signed [NB_DATA-1:0]        x               [1:0];
reg signed [NB_DATA-1:0]        e;

wire signed [NB_DATA-1:0]       h               [2:0];

wire signed [2*NB_DATA-1:0]     partial_prod    [2:0];
wire signed [NB_DATA-1:0]       trunc_prod      [2:0];

wire signed [NB_DATA  :0]       partial_sum     [2:0];
wire signed [NB_DATA-1:0]       trunc_sum       [2:0];

always @(posedge i_clk) begin
    if(i_rst) begin
        e       <= {NB_DATA{1'b0}};
        x[0]    <= {NB_DATA{1'b0}};
        x[1]    <= {NB_DATA{1'b0}};
    end else begin
        e       <= trunc_sum[2];
        x[0]    <= i_x;
        x[1]    <= x[0];
    end
end

assign partial_prod [0]     = i_x * h[0];  // (32,30) = (16,15) * (16,15)
assign partial_prod [1]     = x[0] * h[1];  // (32,30) = (16,15) * (16,15)
assign partial_prod [2]     = x[1] * h[2];  // (32,30) = (16,15) * (16,15)

assign partial_sum[0]       = trunc_prod[0] + trunc_prod[1];    // (17,15) = (16,15) + (16,15)
assign partial_sum[1]       = trunc_prod[2] + trunc_sum[0];     // (17,15) = (16,15) + (16,15)
assign partial_sum[2]       = i_d - trunc_sum[1];               // (17,15) = (16,15) - (16,15)

assign o_err   = e;


lms #(
    .NB_DATA(NB_DATA)
) u_lms (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_error(trunc_sum[2]),

    .i_x0(i_x),
    .i_x1(x[0]),
    .i_x2(x[1]),

    .o_h0(h[0]),
    .o_h1(h[1]),
    .o_h2(h[2])
);

generate
    genvar j;
    for (j=0; j<3; j=j+1) begin
        SatTruncFP #(
            .NB_XI(2*NB_DATA),      // 32
            .NBF_XI((NB_DATA-1)*2), // 30   --> (32,30)

            .NB_XO(NB_DATA),        // 16
            .NBF_XO(NB_DATA-1)      // 15   --> (16,15)
        ) prod_trunc (
            .i_data(partial_prod[j]),
            .o_data(trunc_prod[j])
        );

        SatTruncFP #(
            .NB_XI(NB_DATA+1),       // 17
            .NBF_XI(NB_DATA-1),      // 15   --> (17,15)

            .NB_XO(NB_DATA),         // 16
            .NBF_XO(NB_DATA-1)       // 15   --> (16,15)
        ) sum_trunc1 (
            .i_data(partial_sum[j]),
            .o_data(trunc_sum[j])
        );
    end
endgenerate

endmodule