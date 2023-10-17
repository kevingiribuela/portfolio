module separador #(
    parameter NB_MANT   = 8,
    parameter NB_EXP    = 4,
    parameter NB_TOTAL  = 13
)
(
    input [NB_TOTAL-1:0]    A,
    input [NB_TOTAL-1:0]    B,

    output [NB_MANT-1:0]    MANT_A,
    output [NB_MANT-1:0]    MANT_B,
    output [NB_EXP-1:0]     EXP_A,
    output [NB_EXP-1:0]     EXP_B,
    output                  SIGN_A,
    output                  SIGN_B
);

assign SIGN_A   =   A[NB_TOTAL-1];
assign SIGN_B   =   B[NB_TOTAL-1];

assign EXP_A    =   A[(NB_TOTAL-2) -: NB_EXP];
assign EXP_B    =   B[(NB_TOTAL-2) -: NB_EXP];

assign MANT_A   =   A[0 +: NB_MANT];
assign MANT_B   =   B[0 +: NB_MANT];

endmodule