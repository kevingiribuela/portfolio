`timescale 1ns/1ps

module phase_corrector #(
    parameter NB_DATA = 16,
    parameter NB_COEF = 16
)
(
    input                       i_clk,
    input                       i_rst,
    input signed [NB_DATA-1:0]  i_real,
    input signed [NB_DATA-1:0]  i_imag,

    output signed [NB_DATA-1:0] o_phase_correct
);

localparam NB_PARTIAL_PROD  = NB_DATA + NB_COEF;
localparam INITIAL_VALUE    = 16'h0CCC;


// IIR filters wires 
wire signed [NB_PARTIAL_PROD-1:0]   iir1_in_partial,    iir2_in_partial;
wire signed [NB_DATA-1:0]           iir1_in_trunc,      iir2_in_trunc;
wire signed [NB_DATA-1:0]           iir1_out,           iir2_out;


// Real part operation wires
wire signed [NB_DATA-1:0]           real_part1_in,  real_part2_in;
wire signed [NB_DATA-1:0]           real_part1_out, real_part2_out;

// PI wires
wire signed [NB_DATA  :0]           pi_in_partial;
wire signed [NB_DATA-1:0]           pi_in_trunc;
wire signed [NB_DATA-1:0]           pi_out;

// Accumulator wires
wire signed [NB_DATA-1:0]           accum_in;
reg signed [NB_DATA-1:0]            accum_out;

wire signed [NB_DATA-1:0]           accum_trunc;

// Inputs to the IIR filters
assign iir1_in_partial = accum_trunc * i_imag * (-1);
assign iir2_in_partial = accum_trunc * i_real;

// Inputs to the real part operation module
assign real_part1_in = iir1_out;
assign real_part2_in = iir2_out;


// Inputs to the PI controller
assign pi_in_partial = real_part1_out - real_part2_out;

// Corrected phase out
assign o_phase_correct = pi_out;

// Input to the accumulator
assign accum_in = pi_out;

// Input to the accumulator
always @(posedge i_clk) begin
    if(i_rst) begin
        accum_out <= INITIAL_VALUE;
    end
    else begin
        accum_out <= accum_in;
    end
end

// Accumulator output with overflow
assign accum_trunc = accum_out+accum_in;

iir #(
    .NB_COEF(NB_COEF),
    .NB_DATA (NB_DATA)
) u_iir1 (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_data(iir1_in_trunc),

    .o_data(iir1_out)
);

iir #(
    .NB_COEF(NB_COEF),
    .NB_DATA (NB_DATA)
) u_iir2 (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_data(iir2_in_trunc),

    .o_data(iir2_out)
);

real_part #(
    .NB_DATA(NB_DATA)
) u_real_part1 (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_data(real_part1_in),

    .o_data(real_part1_out)
);

real_part #(
    .NB_DATA(NB_DATA)
) u_real_part2 (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_data(real_part2_in),

    .o_data(real_part2_out)
);

pi #(
    .NB_DATA(NB_DATA)
) u_pi (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_data(pi_in_trunc),

    .o_data(pi_out)
);

// ********************* IIR FILTERS TRUNCATION *********************
SatTruncFP #(
    .NB_XI (NB_PARTIAL_PROD),
    .NBF_XI(NB_PARTIAL_PROD-2),

    .NB_XO (NB_DATA),
    .NBF_XO(NB_DATA-1)
) iir_in1 (
    .i_data(iir1_in_partial),
    .o_data(iir1_in_trunc)
);

SatTruncFP #(
    .NB_XI (NB_PARTIAL_PROD),
    .NBF_XI(NB_PARTIAL_PROD-2),

    .NB_XO (NB_DATA),
    .NBF_XO(NB_DATA-1)
) iir_in2 (
    .i_data(iir2_in_partial),
    .o_data(iir2_in_trunc)
);

// ********************* PI FILTER TRUNCATION *********************
SatTruncFP #(
    .NB_XI (NB_DATA+1),
    .NBF_XI(NB_DATA-1),

    .NB_XO (NB_DATA),
    .NBF_XO(NB_DATA-1)
) pi_in (
    .i_data(pi_in_partial),
    .o_data(pi_in_trunc)
);
// // ********************* ACCUMULATOR TRUNCATION *********************
// SatTruncFP #(
//     .NB_XI (NB_DATA+1),
//     .NBF_XI(NB_DATA-1),

//     .NB_XO (NB_DATA),
//     .NBF_XO(NB_DATA-1)
// ) accumulator (
//     .i_data(accum_partial),
//     .o_data(accum_trunc)
// );

endmodule