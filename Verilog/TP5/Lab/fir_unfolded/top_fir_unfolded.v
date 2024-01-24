`timescale 1ns/1ps

module top_fir_unfolded #(
    parameter NB_DATA = 8,
    parameter NB_COEF = 8
)
(
    input i_clk_G,
    input i_rst,
    input signed [NB_DATA-1:0] x0,
    input signed [NB_DATA-1:0] x1,
    input signed [NB_DATA-1:0] x2,
    input signed [NB_DATA-1:0] x3,

    output reg signed [NB_DATA-1:0] y0,
    output reg signed [NB_DATA-1:0] y1,
    output reg signed [NB_DATA-1:0] y2,
    output reg signed [NB_DATA-1:0] y3
);

localparam NB_PROD = NB_DATA + NB_COEF;

wire signed [NB_DATA-1:0] y_out [3:0];
reg signed  [NB_PROD-1:0] x     [6:0];

wire signed [NB_PROD-1:0] A     [3:0];
wire signed [NB_PROD-1:0] B     [3:0];
wire signed [NB_PROD-1:0] C     [3:0];
wire signed [NB_PROD-1:0] D     [3:0];
wire signed [NB_PROD-1:0] E     [3:0];
wire signed [NB_PROD-1:0] F     [3:0];
wire signed [NB_PROD-1:0] G     [3:0];
wire signed [NB_PROD-1:0] H     [3:0];
wire signed [NB_PROD-1:0] I     [3:0];
wire signed [NB_PROD-1:0] J     [3:0];
wire signed [NB_PROD-1:0] K     [3:0];
wire signed [NB_PROD-1:0] L     [3:0];
wire signed [NB_PROD-1:0] M     [3:0];
wire signed [NB_PROD-1:0] N     [3:0];

always @(posedge i_clk_G) begin
    if(i_rst) begin
        y0 <= {NB_DATA{1'b0}};
        y1 <= {NB_DATA{1'b0}};
        y2 <= {NB_DATA{1'b0}};
        y3 <= {NB_DATA{1'b0}};
    end
    else begin
        y0 <= y_out[0];
        y1 <= y_out[1];
        y2 <= y_out[2];
        y3 <= y_out[3];
    end
end

integer i;
always @(posedge i_clk_G) begin
    if(i_rst) begin
        for(i=0; i<7; i=i+1) begin
            x[i] <= {NB_PROD{1'b0}};
        end
    end
    else begin
        x[0] <= M[3];
        x[1] <= K[3];
        x[2] <= I[3];
        x[3] <= G[3];
        x[4] <= E[3];
        x[5] <= C[3];
        x[6] <= A[3];
    end
end

assign B[0] = x[6];
assign D[0] = x[5];
assign F[0] = x[4];
assign H[0] = x[3];
assign J[0] = x[2];
assign L[0] = x[1];
assign N[0] = x[0];

fir_unfolded #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir0(
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x(x0),

    .B(B[0]),
    .D(D[0]),
    .F(F[0]),
    .H(H[0]),
    .J(J[0]),
    .L(L[0]),
    .N(N[0]),

    .A(A[0]),
    .C(C[0]),
    .E(E[0]),
    .G(G[0]),
    .I(I[0]),
    .K(K[0]),
    .M(M[0]),

    .y(y_out[0])
);

fir_unfolded #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir1(
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x(x1),

    .B(A[0]),
    .D(C[0]),
    .F(E[0]),
    .H(G[0]),
    .J(I[0]),
    .L(K[0]),
    .N(M[0]),

    .A(A[1]),
    .C(C[1]),
    .E(E[1]),
    .G(G[1]),
    .I(I[1]),
    .K(K[1]),
    .M(M[1]),

    .y(y_out[1])
);

fir_unfolded #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir2(
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x(x2),

    .B(A[1]),
    .D(C[1]),
    .F(E[1]),
    .H(G[1]),
    .J(I[1]),
    .L(K[1]),
    .N(M[1]),

    .A(A[2]),
    .C(C[2]),
    .E(E[2]),
    .G(G[2]),
    .I(I[2]),
    .K(K[2]),
    .M(M[2]),

    .y(y_out[2])
);

fir_unfolded #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_fir3(
    .i_clk_G(i_clk_G),
    .i_rst(i_rst),
    .x(x3),

    .B(A[2]),
    .D(C[2]),
    .F(E[2]),
    .H(G[2]),
    .J(I[2]),
    .L(K[2]),
    .N(M[2]),

    .A(A[3]),
    .C(C[3]),
    .E(E[3]),
    .G(G[3]),
    .I(I[3]),
    .K(K[3]),
    .M(M[3]),

    .y(y_out[3])
);


endmodule