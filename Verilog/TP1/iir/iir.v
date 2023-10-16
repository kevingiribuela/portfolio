`timescale 1ns/1ps 

module iir #(
    parameter NB_DATA = 8
)
(
    input                   i_clk,
    input                   i_rst,
    input [NB_DATA-1:0]     i_data,

    output [NB_DATA-1:0]    o_data
);

wire [NB_DATA-1:0] y0;

reg [NB_DATA-1:0]   x0, x1, x2, x3, y1, y2;

assign y0 = x0 - x1 + x2 + x3 + (y1>>1) + (y2>>2);

always @(posedge i_clk) begin
    if(i_rst) begin
        y1 <= 0;
        y2 <= 0;
    
        x0 <= 0;
        x1 <= 0;
        x2 <= 0;
        x3 <= 0;
    end
    else begin
        y1 <= y0;
        y2 <= y1;

        x0 <= i_data;
        x1 <= x0;
        x2 <= x1;
        x3 <= x2;
        
    end
end

assign o_data = y0;

endmodule