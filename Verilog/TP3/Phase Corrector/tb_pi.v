`timescale 1ns/1ps

`define period 10

module tb_pi();

localparam NB_COEFF = 16;
localparam NB_DATA  = 16;
localparam SAMPLES  = 1024;

reg i_clk, i_rst;
reg signed [NB_DATA-1:0] i_data;
reg        [$clog2(SAMPLES)-1:0] sample_count;
reg signed [NB_DATA-1:0] sample_in [SAMPLES-1:0];

wire signed [NB_DATA-1:0] o_data;

initial begin
    sample_count = 0;
    $readmemh("input_pi.mem", sample_in);
    i_rst   = 1;
    i_clk   = 1;
    i_data  = 0;
    # 500;
    i_rst   = 0;
end

always begin
    # `period;
    i_clk = ~i_clk;
end

always @(posedge i_clk) begin
    if(~i_rst) begin
        i_data          <= sample_in[sample_count];
        sample_count    <= sample_count + 1'b1;
        if(&sample_count) begin
            $finish;
        end
    end
end

pi #(
    .NB_COEF(NB_COEFF),
    .NB_DATA(NB_DATA)
) u_pi (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_data),

    .o_data(o_data)
);

endmodule