module top_fir_ROM (
    input   i_clk
);
localparam NB_DATA      = 16;
localparam NB_DEPTH     = 15;
localparam MIC1_PATH    = "/home/kevin/Desktop/Cursos/DDA/Practica/TP_final/src/test/mic1.mem";
localparam MIC2_PATH    = "/home/kevin/Desktop/Cursos/DDA/Practica/TP_final/src/test/mic2.mem";

reg         [NB_DATA-1:0]  MIC1 [2**NB_DEPTH-1:0];
reg         [NB_DATA-1:0]  MIC2 [2**NB_DEPTH-1:0];
reg         [NB_DEPTH-1:0] counter;
reg  signed [NB_DATA-1:0]  x, d;
wire signed [NB_DATA-1:0]  out_data;
wire signed [NB_DATA-1:0]  in_data;
wire rst_from_VIO;

assign in_data = d;



initial begin
    $readmemh(MIC1_PATH, MIC1);
    $readmemh(MIC2_PATH, MIC2);
end

always @(posedge i_clk) begin
    if(rst_from_VIO) begin
        d       <= {NB_DATA{1'b0}};
        x       <= {NB_DATA{1'b0}};
    end else begin
        d       <= MIC1[counter];
        x       <= MIC2[counter];
    end
end

always @(posedge i_clk) begin
    if(rst_from_VIO)
        counter <= {NB_DEPTH{1'b0}};
    else
        counter <= counter + 1'b1;
end


fir_adaptive #(
    .NB_DATA(NB_DATA)
) u_fir (
    .i_clk(i_clk),
    .i_rst(rst_from_VIO),
    
    .i_d(d),
    .i_x(x),

    .o_err(out_data)
);


ila u_ila(
    .clk_0(i_clk),
    .probe0_0(out_data),
    .probe1_0(in_data)
);

vio u_vio(
    .clk_0(i_clk),
    .probe_out0_0(rst_from_VIO)
);
endmodule