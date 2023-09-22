`timescale 1ns/1ps

module sumador 
#(
    parameter NB_DATA = 3
)
(
    input [NB_DATA-1:0]     i_data1,
    input [NB_DATA-1:0]     i_data2,
    input [1:0]             i_sel,
    input                   i_clk,
    input                   i_rst_n,

    output [2*NB_DATA-1:0]  o_data,
    output                  o_overflow
);

wire [NB_DATA:0] data1;
wire [NB_DATA:0] data2;
wire [NB_DATA:0] data3;

wire [NB_DATA:0] mux_out;

wire [2*NB_DATA:0] sum_out;

reg [2*NB_DATA:0]   sum_reg;

// Internal signals
assign data1 = {1'b0, i_data1};
assign data2 = {1'b0, i_data2};
assign data3 = i_data1 + i_data2;

// Mux 
assign mux_out = i_sel==2'b00 ? data2 : 
                 i_sel==2'b01 ? data3 :
                 i_sel==2'b10 ? data1 : mux_out;

// Adder
assign sum_out = mux_out + sum_reg;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        sum_reg <= 0;
    end
    else begin
        sum_reg <= sum_out;
    end
end

// Output
assign o_overflow   = sum_reg[2*NB_DATA];
assign o_data       = sum_reg[2*NB_DATA-1:0];

endmodule