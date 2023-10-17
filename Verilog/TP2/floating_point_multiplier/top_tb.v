`timescale 1ns/1ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module testbench ();

localparam NB_EXP = 4;
localparam NB_MANT = 5;
localparam NB_TOTAL = 10;

wire    [NB_TOTAL-1:0] C;
reg     [NB_TOTAL-1:0] A,B;

initial begin
    A = {NB_TOTAL{1'b0}};
    B = {NB_TOTAL{1'b0}};
    # 2;
    A = 13'b0_1001_01000;           // A = 5
    B = 13'b0_1010_01000;           // B = 10
    # 1;
    `assert(C, 13'b0_1100_10010);   // C = 50
    # 2;
    A = 13'b0_0110_00000;           // A = 0.5
    # 1;
    `assert(C, 13'b0_1001_01000);   // C = 5
    # 2;
    A = 13'b0_1000_01100;           // A = 2.75
    B = 13'b1_1000_10110;           // B = -3.375
    # 1;
    `assert(C, 13'b1_1010_00101);   // C = -9.25
end

top #(
        .NB_MANT(NB_MANT),
        .NB_EXP(NB_EXP),
        .NB_TOTAL(NB_TOTAL)
    ) u_top(
        .A(A),
        .B(B),

        .C(C)
    );

endmodule
