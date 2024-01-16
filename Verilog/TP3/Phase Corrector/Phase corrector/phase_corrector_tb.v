`timescale 1ns/1ps

`define semi_period 20
`define period 40
`define system_latency 2

module phase_corrector_tb ();

localparam NB_DATA  = 16;
localparam NB_COEF  = 16;
localparam N_SAMPLES   = 1024*4;

reg tb_clk, tb_rst;
reg signed [NB_DATA-1:0]    real_mem [N_SAMPLES-1:0];
reg signed [NB_DATA-1:0]    imag_mem [N_SAMPLES-1:0];
reg signed [NB_DATA-1:0]    phase_out[N_SAMPLES-1:0];

reg signed [NB_DATA-1:0]    tb_real_in, tb_imag_in, tb_phase;
reg [$clog2(N_SAMPLES)-1:0] sample_counter;

wire signed [NB_DATA-1:0]   tb_out;
reg valid;
wire valid_out;
// wire valid;

initial begin
    $readmemh("real.hex", real_mem);
    $readmemh("imag.hex", imag_mem);
    $readmemh("outs.hex", phase_out);

    tb_real_in = real_mem[0];
    tb_imag_in = imag_mem[0];
    tb_phase   = phase_out[0];
    
    tb_clk     = 1;
    tb_rst     = 1;
    valid      = 0;
    sample_counter  = 0;

    repeat (100) #`period;
    tb_rst          = 0;
    repeat(`system_latency) #`period;
    valid = 1;
end

always begin
    #`semi_period;
    tb_clk = ~tb_clk;
end

always @(posedge tb_clk) begin
    if(tb_rst) begin
        sample_counter <= 0;
    end
    else begin
        sample_counter <= sample_counter + 1'b1;
        if(&sample_counter) begin
            $finish;
        end
    end
end

always @(posedge tb_clk) begin
    if(~tb_rst) begin
        tb_real_in <= real_mem[sample_counter];
        tb_imag_in <= imag_mem[sample_counter];
        tb_phase   <= phase_out[sample_counter];
    end
end

 assign valid_out = ((tb_out == phase_out[sample_counter-1]) && valid) ? 1'b1 : 1'b0;

phase_corrector #(
    .NB_DATA(NB_DATA),
    .NB_COEF(NB_COEF)
) u_phase_corrector (
    .i_clk(tb_clk),
    .i_rst(tb_rst),
    .i_real(tb_real_in),
    .i_imag(tb_imag_in),

    .o_phase_correct(tb_out)
);

endmodule