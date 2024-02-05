module fir_adaptive #(
    parameter NB_DATA   = 32
)(
    input                       i_clk,
    input                       i_rst,

    input signed [NB_DATA-1:0]  i_d,
    input signed [NB_DATA-1:0]  i_x,

    output signed [NB_DATA-1:0] o_data
);

localparam PARTIAL_PROD = 64;
localparam PARTIAL_SUM1 = 33;
localparam PARTIAL_SUM2 = 34;

reg signed [NB_DATA-1:0]        x               [2:1];
reg signed [NB_DATA-1:0]        out;

wire signed [NB_DATA-1:0]       h               [2:0];

wire signed [PARTIAL_PROD-1:0]  partial_prod    [2:0];
wire signed [NB_DATA-1:0]       trunc_prod      [2:0];

wire signed [PARTIAL_SUM1-1:0]  partial_sum1    [1:0];

wire signed [PARTIAL_SUM2-1:0]  partial_sum2;
wire signed [NB_DATA-1:0]       trunc_sum2;

wire signed [PARTIAL_SUM1-1:0]  partial_final_sum;
wire signed [NB_DATA-1:0]       trunc_final_sum;

always @(posedge i_clk) begin
    if(i_rst) begin
        x[0]    <= {NB_DATA{1'b0}};
        x[1]    <= {NB_DATA{1'b0}};
        x[2]    <= {NB_DATA{1'b0}};
    end else begin
        x[1]    <= i_d;
        x[2]    <= x[1];

        out     <= trunc_final_sum;
    end
end

assign partial_prod [0]     = i_d  * h[0];
assign partial_prod [1]     = x[1] * h[1];
assign partial_prod [2]     = x[2] * h[2];

assign partial_sum1 [0]     = trunc_prod[0] + trunc_prod[1];
assign partial_sum1 [1]     = trunc_prod[2];        // ojo aca, corregir ancho de palabra
assign partial_sum2         = partial_sum1[0] + partial_sum1[1];
assign partial_final_sum    = i_d - trunc_sum2;

lms #(
    .NB_DATA(NB_DATA)
) u_lms (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_error(trunc_final_sum),

    .i_x0(x[0]),
    .i_x1(x[1]),
    .i_x2(x[2]),

    .o_h0(h[0]),
    .o_h1(h[1]),
    .o_h2(h[2])
);

generate
    genvar j;
    for (j=0; j<3; j=j+1) begin
        SatTruncFP #(
            .NB_XI(PARTIAL_PROD),
            .NBF_XI(NB_DATA),

            .NB_XO(NB_DATA),
            .NBF_XO(NB_DATA/2)
        ) prod_trunc0 (
            .i_data(partial_prod[j]),
            .o_data(trunc_prod[j])
        );
    end
endgenerate


SatTruncFP #(
    .NB_XI(PARTIAL_SUM2),
    .NBF_XI(NB_DATA),

    .NB_XO(NB_DATA),
    .NBF_XO(NB_DATA/2)
) sum_trunc (
    .i_data(partial_sum2),
    .o_data(trunc_sum2)
);

SatTruncFP #(
    .NB_XI(PARTIAL_SUM1),
    .NBF_XI(NB_DATA/2),

    .NB_XO(NB_DATA),
    .NBF_XO(NB_DATA/2)
) final_trunc (
    .i_data(partial_final_sum),
    .o_data(trunc_final_sum)
);
endmodule