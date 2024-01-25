`timescale 1ns/1ps

module multiplier_s #(
    parameter NB_DATA = 4
)
(
    input                       i_clk      ,
    input                       i_rst      ,
    input signed [NB_DATA-1:0]  i_a        ,
    input signed [NB_DATA-1:0]  i_b        ,
    
    output                      o_mult_done,
    output signed [NB_DATA-1:0] o_mult
);

wire signed [NB_DATA-1:0]  sum_out;
wire signed [NB_DATA-1:0]  mux_out;

reg signed  [NB_DATA-1:0]   reg_b_L, reg_b_H;
reg signed  [NB_DATA-1:0]   reg_a;


// Wires to connect the FSM
wire shift_fsm;
wire load_fsm;
wire mult_done_fsm;
wire add_fsm;

always @(posedge i_clk) begin
    if (i_rst || load_fsm) begin
        reg_b_H <= {NB_DATA{1'b0}};
        reg_b_L <= i_b;
        reg_a   <= i_a;
    end
    else if (shift_fsm) begin
        reg_b_H <= (sum_out >>> 1);
        reg_b_L <= {sum_out[0], reg_b_L[1 +: NB_DATA-1]};
    end
    else begin
        reg_b_H <= reg_b_H;
        reg_b_L <= reg_b_L;
    end
end

assign sum_out      = add_fsm ? reg_b_H + mux_out : reg_b_H - mux_out;
assign o_mult       = {reg_b_H[2:0], reg_b_L[3]};
assign o_mult_done  = mult_done_fsm;

generate
    assign mux_out = reg_b_L[0] ? reg_a : {NB_DATA{1'b0}};
endgenerate

fsm #(
    .NB_DATA(NB_DATA)
) u_fsm (
    .i_clk          (i_clk          ),
    .i_rst          (i_rst          ),
    
    .o_add          (add_fsm        ),
    .o_mult_done    (mult_done_fsm  ),
    .o_shift_fsm    (shift_fsm      ),
    .o_load_fsm     (load_fsm       )
);

endmodule