`timescale 1ns/1ps
`define semi_period 10

module tb_fir();

localparam NB_DATA   = 32;
localparam NB_DEPTH  = 15;

reg tb_clk, tb_rst;

reg signed [NB_DATA-1:0]    x, d, out;
wire signed [NB_DATA-1:0]   e;
wire                        valid_out;

reg [NB_DATA-1:0]   MIC1    [2**NB_DEPTH-1:0];
reg [NB_DATA-1:0]   MIC2    [2**NB_DEPTH-1:0];
reg [NB_DATA-1:0]   OUT     [2**NB_DEPTH-1:0];
reg [NB_DEPTH-1:0]  counter;


initial begin
    $readmemh("out.mem", OUT);
    $readmemh("mic1.mem", MIC1);
    $readmemh("mic2.mem", MIC2);
end

initial begin
    tb_clk = 1;
    tb_rst = 1;
    repeat(100) # `semi_period;
    tb_rst = 0;
     
    while(~&counter) @(posedge tb_clk);
    $finish();
end

always begin
    # `semi_period;
    tb_clk = ~tb_clk;
end

always @(posedge tb_clk) begin
    if(tb_rst)
        counter <= {NB_DEPTH{1'b0}};
    else
        counter <= counter + 1'b1;
end

always @(tb_clk) begin
    if(tb_rst) begin
        x   <= {NB_DATA{1'b0}};
        d   <= {NB_DATA{1'b0}};
        out <= {NB_DATA{1'b0}};
    end else begin
        d   <= MIC1[counter];
        x   <= MIC2[counter];
        out <= OUT[counter];
    end
end

assign valid_out = (out == e);

fir_adaptive #(
    .NB_DATA(NB_DATA)
) u_fir (
    .i_clk(tb_clk),
    .i_rst(tb_rst),

    .i_d(d),
    .i_x(x),

    .o_data(e)
);
endmodule