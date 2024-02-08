`timescale 1ns/1ps

module SatTruncFP#(
    parameter	NB_XI  	= 32,
    parameter	NBF_XI	= 30,
    
    parameter	NB_XO	= 16,
    parameter	NBF_XO	= 15
)
(
    input [NB_XI-1:0]  i_data,
    output [NB_XO-1:0] o_data
);

    localparam NBI_XI = NB_XI - NBF_XI;
    localparam NBI_XO = NB_XO - NBF_XO;

    wire [NB_XO-1:0]    aux_sat;
    wire [NBF_XO-1:0]   aux_trunc;
   
    wire                condition;
    wire [NB_XO-1:0]    result1;
    wire [NB_XO-1:0]    result2;

    generate
		if (NBF_XI >= NBF_XO) begin
			assign	aux_trunc = i_data[(NBF_XI-1) -: NBF_XO];					// From comma, take the first NBF_XO bits to the right
		end else begin
			assign	aux_trunc = {i_data[NBF_XI-1:0],{(NBF_XO - NBF_XI){1'b0}}};	// Zero padded in case NBF_I < NBF_O
		end
		
		if (NBI_XI > NBI_XO) begin
			assign	condition	=	(i_data[(NB_XI-1) -: (NBI_XI-NBI_XO+1)] == {(NBI_XI-NBI_XO+1){i_data[NB_XI-1]}});	// Checks that there's sign extension on the input data
			assign	result1		=	{i_data[(NB_XI-1)],{(NB_XO-1){~i_data[NB_XI-1]}}};	// Saturation
			assign	result2		=	{i_data[NBF_XI +: NBI_XO], aux_trunc};				// {sign, integer part, fractional part}
			assign	aux_sat		=	condition	?	result2	:	result1;				// If ok->result2, else->sat
		end	else if (NBI_XO == NBI_XI) begin
			assign  aux_sat = {i_data[(NB_XI-1)-:NBI_XI],aux_trunc};					// {sign + integer part, fractional part}
		end else begin
			assign  aux_sat	= {{(NBI_XO - NBI_XI){i_data[NB_XI-1]}},i_data[(NB_XI-1)-:NBI_XI],aux_trunc};
		end
	endgenerate

    assign  o_data=aux_sat;

endmodule
