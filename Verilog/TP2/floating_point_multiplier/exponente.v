module exponente #(
    parameter  NB_EXP  = 4,
    parameter  BIAS    = 7
)
(
    input [NB_EXP-1:0]  EXP_A,
    input [NB_EXP-1:0]  EXP_B,

    output [NB_EXP-1:0] EXP_C
);

assign EXP_C = EXP_A + EXP_B - BIAS;

endmodule