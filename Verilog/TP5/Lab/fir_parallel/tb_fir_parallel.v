`timescale 1ns/1ps
`define period_g 10
`define period_G 40

module tb_fir_parallel ();

localparam SAMPLES = 1024;
localparam NB_DATA = 8;

reg clk_g, clk_G, rst;
reg signed [NB_DATA-1:0]    x   [3:0];
reg signed [NB_DATA-1:0]    x_in;

wire signed [NB_DATA-1:0]   y   [3:0];
reg signed  [NB_DATA-1:0]   y_reg;

reg [NB_DATA-1:0]           ROM [SAMPLES-1:0];
reg [$clog2(SAMPLES)-1:0]   counter_ROM;
reg [$clog2(SAMPLES)-1:0]   counter_in;
reg [1:0]                   counter_out;
reg                         flag, counter_en;


initial begin
    $readmemh("input.mem", ROM);
    clk_G       = 1;
    clk_g       = 1;
    rst         = 1;
    counter_en  = 0;

    x_in        = 0;
    flag        = 0;

    # 160;

    rst         = 0;
    # `period_g;
    counter_en  = 1;
end

always begin
    # `period_g
    clk_g = ~ clk_g;
end

always begin
    # `period_G
    clk_G = ~ clk_G;
end

always @(posedge clk_G) begin
    if(rst) begin
        x[0]    <= 0;
        x[1]    <= 0;
        x[2]    <= 0;
        x[3]    <= 0;
        counter_ROM <= 0;
    end
    else begin
        x[0]    <= ROM[counter_ROM*4];
        x[1]    <= ROM[counter_ROM*4+1];
        x[2]    <= ROM[counter_ROM*4+2];
        x[3]    <= ROM[counter_ROM*4+3];
        counter_ROM <= counter_ROM + 1'b1;
        
        if((4*counter_ROM+3) >= SAMPLES) begin
            $finish();
        end
    end
end

always @(posedge clk_g) begin
    if(rst) begin
        y_reg       <= {NB_DATA{1'b0}};
        counter_out <= 2'b00;
    end
    else begin
        y_reg       <= y[counter_out];
        if(counter_en)
            counter_out <= counter_out + 1'b1;
    end
end

always @(posedge clk_g) begin
    if(rst) begin
        x_in        <= 0;
        counter_in  <= 0;
    end
    else if(~&counter_in && ~flag)begin
        x_in        <= ROM[counter_in];
        counter_in  <= counter_in + 1'b1;
    end
    else if(&counter_in && ~flag) begin
        flag <= 1;
    end
    else begin
        x_in <= x_in;
    end
end

top_fir_parallel #(
    .NB_DATA(NB_DATA)
) fir_parallel (
    .i_clk_G(clk_G),
    .i_rst(rst),

    .x0(x[0]),
    .x1(x[1]),
    .x2(x[2]),
    .x3(x[3]),
    .y0(y[0]),
    .y1(y[1]),
    .y2(y[2]),
    .y3(y[3])
);

endmodule