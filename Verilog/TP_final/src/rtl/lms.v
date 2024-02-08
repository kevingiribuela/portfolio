module lms #(
    parameter NB_DATA   =   16
)(
    input i_clk,
    input i_rst,

    input signed [NB_DATA-1:0]  i_error,
    input signed [NB_DATA-1:0]  i_x0,
    input signed [NB_DATA-1:0]  i_x1,
    input signed [NB_DATA-1:0]  i_x2,

    output signed [NB_DATA-1:0] o_h0,
    output signed [NB_DATA-1:0] o_h1,
    output signed [NB_DATA-1:0] o_h2
);

wire signed [NB_DATA-1:0]       u;
assign u = 16'h0666;

wire signed [2*NB_DATA-1:0]     partial_uxe;
wire signed [NB_DATA-1:0]       trunc_uxe;

wire signed [2*NB_DATA-1:0]     partial_prod    [2:0];
wire signed [NB_DATA-1:0]       trunc_prod      [2:0];

wire signed [NB_DATA  :0]       partial_sum     [2:0];
wire signed [NB_DATA-1:0]       trunc_sum       [2:0];

reg signed [NB_DATA-1:0]        h               [2:0];

always @(posedge i_clk) begin
    if(i_rst) begin
        h[0]    <=  {NB_DATA{1'b0}};
        h[1]    <=  {NB_DATA{1'b0}};
        h[2]    <=  {NB_DATA{1'b0}};
    end else begin
        h[0]    <= trunc_sum[0];
        h[1]    <= trunc_sum[1];
        h[2]    <= trunc_sum[2];
    end
end

assign partial_uxe      =   i_error * u;        // (32,30) = (16,15) * (16,15)

assign partial_prod[0]  =   trunc_uxe * i_x0;   // (32,30) = (16,15) * (16,15)
assign partial_prod[1]  =   trunc_uxe * i_x1;   // (32,30) = (16,15) * (16,15)
assign partial_prod[2]  =   trunc_uxe * i_x2;   // (32,30) = (16,15) * (16,15)

assign partial_sum[0]   = trunc_prod[0] + h[0]; // (17,15) = (16,15) + (16,15)
assign partial_sum[1]   = trunc_prod[1] + h[1]; // (17,15) = (16,15) + (16,15)
assign partial_sum[2]   = trunc_prod[2] + h[2]; // (17,15) = (16,15) + (16,15)

assign o_h0 = h[0];
assign o_h1 = h[1];
assign o_h2 = h[2];

generate
    genvar j;
    for (j=0; j<3; j=j+1) begin
        SatTruncFP #(
            .NB_XI(2*NB_DATA),      // 32
            .NBF_XI((NB_DATA-1)*2), // 30   -- > (32,30)

            .NB_XO(NB_DATA),        // 16
            .NBF_XO(NB_DATA-1)      // 15   --> (16,15)
        ) prod_trunc (
            .i_data(partial_prod[j]),
            .o_data(trunc_prod[j])
        );

        SatTruncFP #(
            .NB_XI(NB_DATA+1),      // 17
            .NBF_XI(NB_DATA-1),     // 15   --> (17,15)

            .NB_XO(NB_DATA),        // 16
            .NBF_XO(NB_DATA-1)      // 15   --> (16,15)
        ) sat_sum (
            .i_data(partial_sum[j]),
            .o_data(trunc_sum[j])
        );
    end
endgenerate

SatTruncFP #(
    .NB_XI(2*NB_DATA),      // 32
    .NBF_XI((NB_DATA-1)*2), // 30   --> (32,30)

    .NB_XO(NB_DATA),        // 16
    .NBF_XO(NB_DATA-1)      // 15   --> (16,15)
) sat_uxe (
    .i_data(partial_uxe),
    .o_data(trunc_uxe)
);

endmodule