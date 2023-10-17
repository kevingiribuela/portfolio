module multiplicador #(
    parameter NB_MANT   = 8,
    parameter NB_EXP    = 4
)
(
    input [NB_MANT-1:0]     MANT_A,
    input [NB_MANT-1:0]     MANT_B,
    input [NB_EXP-1:0]      EXP,

    output reg [NB_MANT-1:0]    MANT_C,
    output reg [NB_EXP-1:0]     EXP_C
);

wire [2*NB_MANT+1:0]    MANT;

assign MANT = {1'b1, MANT_A} * {1'b1, MANT_B};

always @(*) begin
    if(MANT[2*NB_MANT+1]) begin
        MANT_C  = MANT[(2*NB_MANT) -: NB_MANT];
        EXP_C   = EXP + 1;
    end
    else begin
        MANT_C  = MANT[(2*NB_MANT-1) -: NB_MANT];
        EXP_C   = EXP;
    end
end

endmodule