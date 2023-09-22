`timescale 1ns/1ps 

module operador_tb #(
    parameter NB_DATA = 16
);

reg [NB_DATA-1:0]   i_dataA, i_dataB;
reg [1:0]           i_sel;

wire [NB_DATA-1:0]  o_dataC;

operador
    u_operador
    (
        .i_dataA(i_dataA),
        .i_dataB(i_dataB),
        .i_sel(i_sel),

        .o_dataC(o_dataC)
    );

initial begin
    i_sel   = 0;
    i_dataA = 6;
    i_dataB = 4;
    # 10;
    i_sel   = 1;
    # 10;
    i_sel   = 2;
    # 10;
    i_sel   = 3;
    # 10;
    $finish;
end

endmodule