module operador #(
    parameter NB_DATA = 16
)
(
    input [1:0]             i_sel,
    input [NB_DATA-1:0]     i_dataA,
    input [NB_DATA-1:0]     i_dataB,

    output [NB_DATA-1:0]    o_dataC
);

reg [NB_DATA-1:0]  out;

assign o_dataC = out;

always @(*) begin
    out = (i_sel == 2'b00) ? (i_dataA + i_dataB) :
          (i_sel == 2'b01) ? (i_dataA - i_dataB) :
          (i_sel == 2'b10) ? (i_dataA & i_dataB) : (i_dataA | i_dataB);
end

endmodule