`timescale 1ns/1ps

module SatTruncFP#(
    parameter	NB_IN  	= 32,
    parameter	NBF_IN	= 30,
    
    parameter	NB_OUT	= 16,
    parameter	NBF_OUT	= 15
)
(
    input [NB_IN-1:0]  	i_data,
    output [NB_OUT-1:0] o_data
);

localparam NBI_IN = NB_IN - NBF_IN;
localparam NBI_OUT = NB_OUT - NBF_OUT;

assign o_data = (i_data[(NB_IN-1) -: (NBI_IN-NBI_OUT+1)] == {(NBI_IN-NBI_OUT+1){i_data[NB_IN-1]}}) ? i_data[NBF_IN-NBF_OUT +: NB_OUT] :
																											 {i_data[(NB_IN-1)],{(NB_OUT-1){~i_data[NB_IN-1]}}};

endmodule
