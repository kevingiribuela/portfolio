`timescale 1ns/1ps

module fsm #(
    parameter NB_DATA =  4
)
(
    input                       i_clk      ,
    input                       i_rst      ,
    
    output                      o_add      ,
    output                      o_mult_done,
    output                      o_shift_fsm,
    output                      o_load_fsm
);

reg mult_done;
reg [$clog2(NB_DATA)-1:0]   counter;

// FSM variables
localparam  LOAD = 1'b0,
            MULT = 1'b1;

reg next_state, current_state;

always @(*) begin
    if(i_rst) begin
        next_state = LOAD;
    end
    else begin
        case(current_state)
            LOAD:
                next_state = MULT;
            MULT:
                if(&counter)
                    next_state = LOAD;
                else
                    next_state = MULT;
        endcase
    end
end

always @(posedge i_clk) begin
    if(i_rst)
        current_state <= 0;
    else
        current_state <= next_state;
end

always @(posedge i_clk) begin
    if(i_rst || o_load_fsm)
        counter <= {$clog2(NB_DATA){1'b0}};
    else if (o_shift_fsm)
        counter <= counter + 1'b1;
    else
        counter <= counter;
end

always @(posedge i_clk) begin
    if(i_rst)
        mult_done <= 0;
    else if (current_state == MULT && next_state == LOAD)
        mult_done <= 1;
    else
        mult_done <= 0;
end

assign o_mult_done  = mult_done;
assign o_shift_fsm  = (current_state == MULT)   ? 1'b1 : 1'b0;
assign o_load_fsm   = (current_state == LOAD)   ? 1'b1 : 1'b0;
assign o_add        = ~&counter;

endmodule