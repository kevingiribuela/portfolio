`timescale 1ns/1ps 
`define T_clock 4
`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

module iir_tb #(
    parameter NB_DATA = 8
);

reg                   i_clk;
reg                   i_rst;
reg [NB_DATA-1:0]     i_data;

wire [NB_DATA-1:0]  o_data;

iir
    u_iir
    (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_data),
    
        .o_data(o_data)
    );

initial begin
    i_data = 1;
    i_clk  = 0;
    i_rst  = 1;
    # 10;
    i_rst  = 0;
    # `T_clock;
    i_data = 2;
    # `T_clock;
    `assert(o_data, 8'd1);
    i_data = 1;
    # `T_clock;
    `assert(o_data, 8'd0);
    i_data = 2;
    # `T_clock;
    `assert(o_data, 8'd4);
    i_data = 1;
    # `T_clock;
    `assert(o_data, 8'd4);
    i_data = 2;
    # `T_clock;
    `assert(o_data, 8'd7);
    i_data = 0;
    # `T_clock;
    `assert(o_data, 8'd5);
    # `T_clock;
    `assert(o_data, 8'd6);
    # `T_clock;
    `assert(o_data, 8'd6);
    # `T_clock;
    `assert(o_data, 8'd4);
    # `T_clock
    `assert(o_data, 8'd3);
    # `T_clock;
    `assert(o_data, 8'd2);
    # `T_clock;
    `assert(o_data, 8'd1);
    # `T_clock;
    `assert(o_data, 8'd0);
    $finish;
end

always begin
    #2;
    i_clk = ~i_clk;
end

endmodule