module fir #(
    parameter unsigned integer NB_DATA = 16
)
(
    input                         i_clk,
    input                         i_rst,
    input signed [NB_DATA-1:0]  i_data,

    output signed [NB_DATA-1:0] o_data
);

localparam h0 = 16'h03;
localparam h1 = 16'h04;
localparam h2 = 16'h05;
localparam h3 = 16'h06;

// Output data
wire signed [NB_DATA-1:0] y0;

// Registers
reg signed [NB_DATA-1:0]    x [1:3];

// Partials products & final products   
wire signed [2*NB_DATA-1:0] partial_prod    [4];
wire signed [NB_DATA-1:0]   trunc_prod      [4]; 

// Sums
wire signed [NB_DATA:0]   sum0, sum1;
wire signed [NB_DATA+1:0] sum2;

// Continous assignment
assign x0 = i_data;

always @(posedge i_clk) begin : shift_register
    if(i_rst) begin
        for(int i=1; i<=3; i=i+1) begin
            x[i] <= {1'b0{NB_DATA}};
        end
        
        o_data <= 0;
    end
    else begin
        x[1] <= i_data;
        for(int i=1; i<3; i=i+1) begin
            x[i+1] <= x[i];
        end

        o_data <= y0;
    end
end

assign partial_prod[0] = i_data * h0;
assign partial_prod[1] = x[1] * h1;
assign partial_prod[2] = x[2] * h2;
assign partial_prod[3] = x[3] * h3;

assign trunc_prod[0] = (~|partial_prod[0][2*NB_DATA-1:2*NB_DATA-2] || &partial_prod[0][2*NB_DATA-1:2*NB_DATA-2]) ? partial_prod[0][2*NB_DATA-1 -: NB_DATA] :
                        partial_prod[0][2*NB_DATA-1] ? {1'b1,NB_DATA-1{1'b0}} : {1'b0,NB_DATA-1{1'b1}};

assign trunc_prod[1] = (~|partial_prod[1][2*NB_DATA-1:2*NB_DATA-2] || &partial_prod[1][2*NB_DATA-1:2*NB_DATA-2]) ? partial_prod[1][2*NB_DATA-1 -: NB_DATA] :
                        partial_prod[1][2*NB_DATA-1] ? {1'b1,NB_DATA-1{1'b0}} : {1'b0,NB_DATA-1{1'b1}};

assign trunc_prod[2] = (~|partial_prod[2][2*NB_DATA-1:2*NB_DATA-2] || &partial_prod[2][2*NB_DATA-1:2*NB_DATA-2]) ? partial_prod[2][2*NB_DATA-1 -: NB_DATA] :
                        partial_prod[2][2*NB_DATA-1] ? {1'b1,NB_DATA-1{1'b0}} : {1'b0,NB_DATA-1{1'b1}};

assign trunc_prod[3] = (~|partial_prod[3][2*NB_DATA-1:2*NB_DATA-2] || &partial_prod[3][2*NB_DATA-1:2*NB_DATA-2]) ? partial_prod[3][2*NB_DATA-1 -: NB_DATA] :
                        partial_prod[3][2*NB_DATA-1] ? {1'b1,NB_DATA-1{1'b0}} : {1'b0,NB_DATA-1{1'b1}};

assign sum0 = trunc_prod[0] + trunc_prod[1];
assign sum1 = trunc_prod[2] + trunc_prod[3];
assign sum2 = sum1 + sum0;

assign y0   = (~|sum2[NB_DATA+1:NB_DATA] || &sum2[NB_DATA+1:NB_DATA]) ? sum2[NB_DATA-1:0] :
                sum2[NB_DATA+1] ? {1'b1,NB_DATA-1{1'b0}} : {1'b0, NB_DATA-1{1'b1}};


endmodule