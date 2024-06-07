//`define FPGA   // Uncnmment to load to FPGA
//`define DEBUG  // Uncomment to view Chirp signal in the output

module top_fir_ROM #(
    parameter NB_DATA   = 21,
    parameter NBF_DATA  = 20,
    parameter NB_DEPTH  = 14
)(
    `ifndef FPGA
        input   i_rst,
    `endif
    input   i_clk,

    output signed [NB_DATA-1:0] o_filter
);

localparam MU_PATH          = "mu.mem";
localparam MIC1_PATH        = "mic1.mem";
localparam MIC2_PATH        = "mic2.mem";
localparam MIC1_PATH_DEBUG  = "mic1_debug.mem";
localparam MIC2_PATH_DEBUG  = "mic2_debug.mem";

reg  signed [NB_DATA-1:0]  MU   [2**NB_DEPTH-1:0];
reg  signed [NB_DATA-1:0]  MIC1 [2**NB_DEPTH-1:0];
reg  signed [NB_DATA-1:0]  MIC2 [2**NB_DEPTH-1:0];
reg         [NB_DEPTH-1:0] counter;
reg  signed [NB_DATA-1:0]  mic1, mic2, mu;
wire signed [NB_DATA-1:0]  filter_out;
wire global_rst, rst_from_VIO;

assign o_filter = filter_out;

`ifdef FPGA
    assign global_rst   = rst_from_VIO;
`else
    assign global_rst   = i_rst;
`endif

initial begin
`ifdef DEBUG
    $readmemh(MIC1_PATH_DEBUG, MIC1);
    $readmemh(MIC2_PATH_DEBUG, MIC2);
    $readmemh(MU_PATH, MU);
`else
    $readmemh(MU_PATH, MU);
    $readmemh(MIC1_PATH, MIC1);
    $readmemh(MIC2_PATH, MIC2);
`endif
end

always @(posedge i_clk) begin
    if(global_rst) begin
        mu         <= {NB_DATA{1'b0}};
        mic2       <= {NB_DATA{1'b0}};
        mic1       <= {NB_DATA{1'b0}};
    end else begin
        mu         <= MU[counter];
        mic2       <= MIC1[counter];
        mic1       <= MIC2[counter];
    end
end

always @(posedge i_clk) begin
    if(global_rst)
        counter <= {NB_DEPTH{1'b0}};
    else
        counter <= counter + 1'b1;
end


fir_adaptive #(
    .NB_DATA(NB_DATA),
    .NBF_DATA(NBF_DATA)
) u_fir (
    .i_clk  (i_clk       ),
    .i_rst  (global_rst  ),

    .i_mu(mu),
    .i_mic2 (mic2        ),
    .i_mic1 (mic1        ),

    .o_filter (filter_out)
);

`ifdef FPGA
    ila u_ila(
        .clk_0      (i_clk     ),
        .probe0_0   (global_rst),
        .probe1_0   (filter_out)
    );

    vio u_vio(
        .clk_0       (i_clk         ),
        .probe_out0_0(rst_from_VIO  )
    );
`endif
endmodule