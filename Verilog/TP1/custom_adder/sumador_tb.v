/* El dispositivo bajo testeo tarda 124nS en realizar un overflow.
Considerando un periodo de reloj de 4ns, el tiempo demorado es de 124/4=31 ciclos de reloj.*/

`timescale 1ns/1ps 

module sumador_tb #(
    parameter NB_DATA = 3
);

reg [NB_DATA-1:0]     i_data1;
reg [NB_DATA-1:0]     i_data2;
reg [1:0]             i_sel;
reg                   i_clk;
reg                   i_rst_n;

wire [2*NB_DATA-1:0]  o_data;
wire                  o_overflow;

sumador 
    u_sumador
    (
        .i_data1(i_data1),
        .i_data2(i_data2),
        .i_sel(i_sel),
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
    
        .o_data(o_data),
        .o_overflow(o_overflow)
    );

initial begin
    i_sel   = 1;
    i_data1 = 1;
    i_data2 = 1;
    i_clk   = 0;
    i_rst_n = 0;
    # 10;
    i_rst_n = 1;
    # 300;
    $finish;
end

always begin
    #2; // 4ns period
    i_clk = ~i_clk;
end

endmodule