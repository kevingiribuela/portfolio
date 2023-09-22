`timescale 1ns/1ps 

module fir_tb #(
    parameter NB_DATA = 8
);

reg                   i_clk;
reg                   i_rst;
reg [NB_DATA-1:0]     i_data;

wire [NB_DATA-1:0]  o_data;

fir
    u_fir
    (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_data),
    
        .o_data(o_data)
    );

initial begin
    i_data = 1;
    i_clk   = 0;
    i_rst = 1;
    # 10;
    i_rst = 0;
    # 20;
    i_data = 3;
    # 2;
    i_data = 1;
    # 2;
    i_data = 0;
    # 300;
    $finish;
end

always begin
    #2;
    i_clk = ~i_clk;
end

endmodule