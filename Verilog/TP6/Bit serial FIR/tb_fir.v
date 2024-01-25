`timescale 1ns/1ps
`define semi_period 10

module tb_fir();

localparam NB_DATA = 4;
localparam SAMPLES = 1024;

reg tb_clk, tb_rst;

reg latency;

reg signed  [NB_DATA-1:0]   data_in, data_saved;
wire signed [NB_DATA-1:0]   data_out;

wire busy;
wire valid_data;
reg [$clog2(SAMPLES)-1:0]   counter_in, counter_out;
reg [NB_DATA-1:0]           ROM_IN  [SAMPLES-1:0];
reg [NB_DATA-1:0]           ROM_OUT [SAMPLES-1:0];

initial begin
    tb_rst  = 1;
    tb_clk  = 1;
    latency = 1;
    $readmemh("input.mem", ROM_IN);
    $readmemh("output.mem", ROM_OUT);
    # 1000;
    tb_rst  = 0;
    repeat(24) # `semi_period;  // System latency
    latency = 0;
end

always begin
    # `semi_period;
    tb_clk = ~tb_clk;
end

always @(posedge tb_clk) begin
    if(tb_rst)
        data_in <= {NB_DATA{1'b0}};
    else if(~busy)
        data_in <= ROM_IN[counter_in];
    else
        data_in <= data_in;
end

always @(posedge tb_clk) begin
    if(tb_rst)
        counter_in <= {$clog2(SAMPLES){1'b0}};
    else if (~busy) begin
        counter_in <= counter_in + 1'b1;
        if(&counter_in)
            $finish();
    end
    else
        counter_in <= counter_in;
end

always @(posedge tb_clk) begin
    if(tb_rst)
        counter_out <= {$clog2(SAMPLES){1'b0}};
    else if (~busy && ~latency) begin
        counter_out <= counter_out + 1'b1;
        if(&counter_out)
            $finish();
    end
    else
        counter_out <= counter_out;
end

always @(posedge tb_clk) begin
    if(tb_rst)
        data_saved <= {NB_DATA{1'b0}};
    else if(~busy && ~latency)
        data_saved <= ROM_OUT[counter_out];
    else
        data_saved <= data_saved;
end

assign valid_data = data_saved == data_out;

fir #(
    .NB_DATA(NB_DATA)
)
u_fir
(
    .i_clk(tb_clk   ),
    .i_rst(tb_rst   ),
    .i_data(data_in ),

    .o_busy(busy    ),
    .o_data(data_out)
);

endmodule