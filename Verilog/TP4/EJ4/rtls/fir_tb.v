`timescale 1ns/1ps

`define period_g 10     // 10ns
`define period_G 80     // 10ns*NB_DATA
`define period_G2 90    // 10ns*(NB_DATA+1)

module fir_tb ();

localparam NB_DATA      = 8;
localparam ROM_WIDTH    = 17;
localparam SAMPLES      = 1024;

reg clk_G, clk_G2, clk_g, rst;

reg [$clog2(SAMPLES)-1:0]   sample_counter_unfolded;
reg [$clog2(SAMPLES)-1:0]   sample_counter_folded;
reg [$clog2(NB_DATA)-1:0]   bit_counter_unfolded;
reg [$clog2(NB_DATA+1)-1:0] bit_counter_folded;
reg [NB_DATA-1:0]           sample_in     [SAMPLES-1:0];

reg signed  [NB_DATA-1:0]           xn_unfolded, xn_folded;
wire signed [ROM_WIDTH+NB_DATA-1:0] y_unfolded, y_folded;

initial begin
    $readmemh("input.mem", sample_in);
    clk_G2          = 1;
    clk_G           = 1;
    clk_g           = 1;
    rst             = 1;

    sample_counter_unfolded = 0;
    sample_counter_folded   = 0;

    bit_counter_unfolded    = 7;
    bit_counter_folded      = 8;

    xn_unfolded             = 0;
    xn_folded               = 0;

    # 500;
    rst             = 0;
end

// Bit counter for UNFOLDED FIR
always @(posedge clk_g) begin
    if(~rst) begin
        bit_counter_unfolded <= bit_counter_unfolded +1'b1;
    end
end

// Bit counter for FOLDED FIR
always @(posedge clk_g) begin
    if(~rst) begin
        if(bit_counter_folded == 9'd8) begin
            bit_counter_folded <= 0;
        end
        else begin
            bit_counter_folded <= bit_counter_folded + 1'b1;
        end
    end
end

// New sample for UNFOLDED FIR filter
always @(posedge clk_G) begin
    if(~rst) begin
        xn_unfolded <= sample_in[sample_counter_unfolded];
        sample_counter_unfolded <= sample_counter_unfolded + 1'b1;
     end
end

// New sample for FOLDED FIR filter
always @(posedge clk_G2) begin
    if(~rst) begin
        xn_folded <= sample_in[sample_counter_folded];
        sample_counter_folded <= sample_counter_folded + 1'b1;
     end
end

// Global clock generation
always begin
    # `period_g;
    clk_g = ~clk_g;
end

// Clock generation for UNDOLDED FIR filter
always @(posedge clk_g)begin
    if(~rst) begin
        # `period_G;
        clk_G = ~clk_G;
    end
end

// Clock generation for FOLDED FIR filter
always @(posedge clk_g) begin
    if(~rst) begin
        # 90;
        clk_G2 = 1'b0;
        # 90;
        clk_G2 = 1'b1;
    end
end

// End simulation
always @(*) begin
    if(&sample_counter_unfolded)
        $finish;
end

fir_DA_unfolded #(
    .NB_DATA(NB_DATA),
    .ROM_WIDTH(ROM_WIDTH)
) u_fir_DA_unfolded (
    .i_clk_g(clk_g),
    .i_rst(rst),
    .x(xn_unfolded),
    .counter(bit_counter_unfolded),

    .y(y_unfolded)
);

fir_DA_folded #(
    .NB_DATA(NB_DATA),
    .ROM_WIDTH(ROM_WIDTH)
) u_fir_DA_folded (
    .i_clk_g(clk_g),
    .i_rst(rst),
    .x(xn_folded),
    .counter(bit_counter_folded),

    .y(y_folded)
);

endmodule