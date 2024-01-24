module regressor #(
    parameter NB_DATA = 8
)
(
    input i_clk,
    input i_rst,
    input signed [NB_DATA-1:0] i_x0,
    input signed [NB_DATA-1:0] i_x1,
    input signed [NB_DATA-1:0] i_x2,
    input signed [NB_DATA-1:0] i_x3,

    output signed [NB_DATA-1:0] o_regressor0,
    output signed [NB_DATA-1:0] o_regressor1,
    output signed [NB_DATA-1:0] o_regressor2,
    output signed [NB_DATA-1:0] o_regressor3,
    output signed [NB_DATA-1:0] o_regressor4,
    output signed [NB_DATA-1:0] o_regressor5,
    output signed [NB_DATA-1:0] o_regressor6
);

reg signed [NB_DATA-1:0] x_row3 [1:0];
reg signed [NB_DATA-1:0] x_row2 [1:0];
reg signed [NB_DATA-1:0] x_row1 [1:0];
reg signed [NB_DATA-1:0] x_row0;


always @(posedge i_clk) begin 
    if(i_rst) begin
        x_row3[1]   <= {NB_DATA{1'b0}};
        x_row3[0]   <= {NB_DATA{1'b0}};

        x_row2[1]   <= {NB_DATA{1'b0}};
        x_row2[0]   <= {NB_DATA{1'b0}};

        x_row1[1]   <= {NB_DATA{1'b0}};
        x_row1[0]   <= {NB_DATA{1'b0}};

        x_row0      <= {NB_DATA{1'b0}};
    end
    else begin
        x_row3[0]   <= i_x3;
        x_row3[1]   <= x_row3[0];

        x_row2[0]   <= i_x2;
        x_row2[1]   <= x_row2[0];
        
        x_row1[0]   <= i_x1;
        x_row1[1]   <= x_row1[0];

        x_row0      <= i_x0;
    end
end

assign o_regressor0   = x_row3[0];
assign o_regressor1   = x_row2[0];
assign o_regressor2   = x_row1[0];
assign o_regressor3   = x_row0;
assign o_regressor4   = x_row3[1];
assign o_regressor5   = x_row2[1];
assign o_regressor6   = x_row1[1];

endmodule