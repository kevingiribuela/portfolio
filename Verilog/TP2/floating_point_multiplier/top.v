module top #(
    parameter NB_MANT   = 8,
    parameter NB_EXP    = 4,
    parameter NB_TOTAL  = 13
)
(
    input [NB_TOTAL-1:0] A,
    input [NB_TOTAL-1:0] B,

    output [NB_TOTAL-1:0] C
);

localparam BIAS = 7;

wire [NB_MANT-1:0]  MANT_A, MANT_B, MANT_C;
wire [NB_EXP-1:0]   EXP_A, EXP_B, EXP, EXP_C;
wire                SIGN_A, SIGN_B, SIGN_C;


separador #(
        .NB_MANT    (NB_MANT)   ,
        .NB_EXP     (NB_EXP)    ,
        .NB_TOTAL   (NB_TOTAL)
    )
    u_separador(
        .A(A)           ,
        .B(B)           ,

        .MANT_A(MANT_A) ,
        .MANT_B(MANT_B) ,
        
        .EXP_A(EXP_A)   ,
        .EXP_B(EXP_B)   ,

        .SIGN_A(SIGN_A) ,
        .SIGN_B(SIGN_B)
    );

exponente #(
        .NB_EXP(NB_EXP) ,
        .BIAS(BIAS)
    ) u_exponente(
        .EXP_A(EXP_A)   ,
        .EXP_B(EXP_B)   ,

        .EXP_C(EXP)
    );

multiplicador #(
        .NB_MANT(NB_MANT),
        .NB_EXP(NB_EXP)
    ) u_multiplicador(
        .MANT_A(MANT_A) ,
        .MANT_B(MANT_B) ,
        .EXP(EXP)       ,

        .EXP_C(EXP_C)   ,

        .MANT_C(MANT_C)
    );

signo #() u_signo(
        .SIGN_A(SIGN_A) ,
        .SIGN_B(SIGN_B) ,

        .SIGN_C(SIGN_C)
    );

assign C = {SIGN_C, EXP_C, MANT_C};


endmodule