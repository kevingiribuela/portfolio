`timescale 1ns/1ps

module fir #(
    parameter NB_DATA = 4
)
(
    input                       i_clk ,
    input                       i_rst ,
    input signed [NB_DATA-1:0]  i_data,

    output                      o_busy,
    output signed [NB_DATA-1:0] o_data
);

reg signed [NB_DATA-1:0]    x           [2:0];
reg signed [NB_DATA-1:0]    y;

wire signed [NB_DATA-1:0]   h           [2:0];

wire signed [NB_DATA-1:0]   prod        [2:0];
wire signed [NB_DATA-1:0]   sum         [1:0];


wire        [2:0]   mult_done;
wire                shift_en;

assign h[0] = 4'h2;
assign h[1] = 4'h3;
assign h[2] = 4'h2;

always @(posedge i_clk) begin
    if(i_rst) begin
        x[0]    <= {NB_DATA{1'b0}};
        x[1]    <= {NB_DATA{1'b0}};
        x[2]    <= {NB_DATA{1'b0}};
        y       <= {NB_DATA{1'b0}};
    end
    else if(shift_en) begin
        x[0]    <= i_data;
        x[1]    <= x[0];
        x[2]    <= x[1];
        y       <= sum[1];
    end
    else begin
        x[0]    <= x[0];
        x[1]    <= x[1];
        x[2]    <= x[2];
        y       <= y;
    end
end

assign sum[0]   = prod[0] + prod[1];    // (4,3) = (4,3) + (4,3) --> Truncated
assign sum[1]   = prod[2] + sum[0];     // (4,3) = (4,3) + (4,3) --> Truncated

assign shift_en = &mult_done    ;
assign o_busy   = ~&mult_done   ;
assign o_data   = y             ;

generate
    genvar j;
    for (j=0;j<3; j=j+1) begin
        multiplier_s #(
            .NB_DATA(NB_DATA)
        ) u_mult (
            .i_clk      (i_clk),
            .i_rst      (i_rst),
            .i_a        (x[j]),
            .i_b        (h[j]),

            .o_mult_done(mult_done[j]),
            .o_mult     (prod[j])
        );
    end
endgenerate

endmodule