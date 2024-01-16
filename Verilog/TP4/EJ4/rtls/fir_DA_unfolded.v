`timescale 1ns/1ps

module fir_DA_unfolded #(
    parameter NB_DATA = 8,
    parameter ROM_WIDTH = 17
)(
    input i_clk_g,
    input i_rst,
    input signed [NB_DATA-1:0]  x,
    input [$clog2(NB_DATA)-1:0] counter,

    output reg [NB_DATA+ROM_WIDTH-1:0] y
);

reg signed  [NB_DATA+ROM_WIDTH-1:0] accum;
reg signed  [ROM_WIDTH-1:0]         ROM     [2**9-1:0];
reg signed  [NB_DATA-1:0]           xn      [8:0];

reg  signed [NB_DATA+ROM_WIDTH-1:0] sum;
wire signed [ROM_WIDTH-1:0]         rom_out;
wire [8:0]                          address;
wire                                msb;

/* LOAD ROM */
initial begin
    $readmemh("ROM_unfolded.mem", ROM);
end

assign rom_out  = ROM[address]; // Load value from ROM
assign msb      = &counter;     // MSB flag 

always @(*) begin
    if(msb) begin
        sum = accum - {rom_out, {NB_DATA{1'b0}}};
    end
    else begin
        sum = accum + {rom_out, {NB_DATA{1'b0}}};
    end
end

integer j;
always @(posedge i_clk_g) begin
    if(i_rst) begin
        for(j=0; j<9; j=j+1)begin
            xn[j]    <= {NB_DATA{1'b0}};
        end
        accum   <= {NB_DATA+ROM_WIDTH{1'b0}};
        y       <= {NB_DATA+ROM_WIDTH{1'b0}};
    end
    else begin
        if(msb) begin
            xn[0] <= x;
            for(j=1; j<9; j=j+1) begin
                xn[j] <= xn[j-1];
            end
            y       <= sum;
            accum   <= {NB_DATA+ROM_WIDTH{1'b0}};
        end 
        else begin
            y       <= y;
            accum   <= sum>>>1;
        end
    end
end

genvar m;
generate
    for(m=0; m<9; m=m+1) begin // Addres for ROM. Composed by the LSB of registers
        assign address[m] = xn[m][counter];
    end

endgenerate

endmodule