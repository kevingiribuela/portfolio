`timescale 1ns/1ps
//`define DEBUG       // Uncomment to view Chirp signal in the output
`define clock_20MHz 50
`define latency 3

module tb_fir();

localparam NB_DATA   = 21;
localparam NBF_DATA  = 20;
localparam NB_DEPTH  = 14;

localparam MIC1_PATH    = "mic1.mem";
localparam MIC2_PATH    = "mic2.mem";
localparam MU_PATH      = "mu.mem";
localparam OUT_PATH     = "out.mem";

localparam MIC1_PATH_DEBUG = "mic1_debug.mem";
localparam MIC2_PATH_DEBUG = "mic2_debug.mem";
localparam OUT_PATH_DEBUG  = "out_debug.mem";

reg tb_clk, tb_rst;

reg signed [NB_DATA-1:0]    mic1, mic2, out_mem, mu;
wire signed [NB_DATA-1:0]   o_filter;
wire                        valid_out;

reg [NB_DATA-1:0]   MIC1    [2**NB_DEPTH-1:0];
reg [NB_DATA-1:0]   MIC2    [2**NB_DEPTH-1:0];
reg [NB_DATA-1:0]   OUT     [2**NB_DEPTH-1:0];
reg [NB_DATA-1:0]   MU      [2**NB_DEPTH-1:0];
reg [NB_DEPTH-1:0]  counter, counter_compare;
reg                 en_count;

initial begin
`ifdef DEBUG
    $readmemh(MIC1_PATH_DEBUG, MIC1);
    $readmemh(MIC2_PATH_DEBUG, MIC2);
    $readmemh(OUT_PATH_DEBUG,  OUT);
    $readmemh(MU_PATH, MU);
`else
    $readmemh(MIC1_PATH, MIC1);
    $readmemh(MIC2_PATH, MIC2);
    $readmemh(OUT_PATH,  OUT);
    $readmemh(MU_PATH, MU);
`endif
end

initial begin
    tb_clk          = 0;
    tb_rst          = 1;
    en_count        = 0;
    repeat(100) # `clock_20MHz;
    tb_rst          = 0;
    repeat(`latency) @(posedge tb_clk);
    en_count        = 1;
    while(~&counter) @(posedge tb_clk);
    $finish();
end

always begin
    # `clock_20MHz;
    tb_clk = ~tb_clk;
end


always @(posedge tb_clk) begin
    if(tb_rst)
        counter <= {NB_DEPTH{1'b0}};
    else
        counter <= counter + 1'b1;
end

always @(posedge tb_clk) begin
    if(tb_rst)
        counter_compare <= {NB_DEPTH{1'b0}};
    else if(en_count)
        counter_compare <= counter_compare + 1'b1;
    else
        counter_compare <= counter_compare;
end

always @(posedge tb_clk) begin
    if(tb_rst) begin
        mu      <= {NB_DATA{1'b0}};
        mic1    <= {NB_DATA{1'b0}};
        mic2    <= {NB_DATA{1'b0}};
        out_mem <= {NB_DATA{1'b0}};
    end else begin
        mic2    <= MIC1[counter];
        mic1    <= MIC2[counter];
        out_mem <= OUT[counter_compare];
        mu      <= MU[counter];
    end
end

assign valid_out = (out_mem == o_filter);


// Module without memories
fir_adaptive #(
    .NB_DATA(NB_DATA),
    .NBF_DATA(NBF_DATA)
) u_fir (
    .i_clk  (tb_clk  ),
    .i_rst  (tb_rst  ),

    .i_mu(mu),
    .i_mic2 (mic2    ),
    .i_mic1 (mic1    ),

    .o_filter (o_filter)
);

// Wrapper with module and memories inside
top_fir_ROM #(
   .NB_DATA (NB_DATA ),
   .NBF_DATA(NBF_DATA),
   .NB_DEPTH(NB_DEPTH)
) u_fir_v2 (
   .i_clk   (tb_clk  ),
   .i_rst   (tb_rst  )
);

endmodule