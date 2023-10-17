module signo(
    input SIGN_A,
    input SIGN_B,

    output SIGN_C
);

assign SIGN_C = SIGN_A ^ SIGN_B;

endmodule