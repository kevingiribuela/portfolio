module SatRoundFP#(
    parameter	NB_XI  	= 20,
    parameter	NBF_XI	= 12,
    
    parameter	NB_XO	= 8,
    parameter	NBF_XO	= 6
)
(
    input [(NB_XI)-1:0]  i_data,
    output [(NB_XO)-1:0] o_data
);

    localparam NBI_XI = NB_XI - NBF_XI;
    localparam NBI_XO = NB_XO - NBF_XO;

    wire [NB_XO-1:0]    aux_sat;
    wire [NBF_XO-1:0]   aux_round;
   
    wire                condicion;
    wire [NB_XO-1:0]    resultado1;
    wire [NB_XO-1:0]    resultado2;

    generate
        if (NBF_XI > NBF_XO) begin // Align and sum of LSB of fractional part
            assign  aux_round = i_data[(NBF_XI-1):(NBF_XI - (NBF_XO+1))] + {{NBF_XO{1'b0}}, 1'b1};
        end else if (NBF_XI == NBF_XO) begin
            assign  aux_round = i_data[(NBF_XI-1):0];
        end else begin              // Zero padded in case NBF_I < NBF_O
            assign  aux_round = {i_data[NBF_XI-1:0],{(NBF_XO - NBF_XI){1'b0}}};
        end

        if (NBI_XI > NBI_XO) begin
            assign  condicion   =   (i_data[(NB_XI-2)-:(NBI_XI-NBI_XO)] == {(NBI_XI-NBI_XO){i_data[NB_XI-1]}}); // Checks that there's sign extension on the input data
            assign  resultado1  =   {i_data[(NB_XI-1)],{(NB_XO-1){~i_data[(NB_XI-1)]}}};        // Saturation
            assign  resultado2  =   {i_data[(NB_XI-1)],i_data[NBF_XI +:NBI_XO-1],aux_round};    // {sign, integer part, fractional part}
            assign  aux_sat	    =   condicion   ?   resultado2  :   resultado1;
        end	else begin
            if (NBI_XO == NBI_XI)
                assign  aux_sat = {i_data[(NB_XI-1)-:NBI_XI],aux_round};
            else
                assign  aux_sat	= {{(NBI_XO - NBI_XI){i_data[NB_XI-1]}},i_data[(NB_XI-1)-:NBI_XI],aux_round};
        end
    endgenerate

    assign  o_data=aux_sat;

endmodule
