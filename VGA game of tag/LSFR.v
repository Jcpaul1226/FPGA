`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Linear Feedback Shift register, creates pseudo-random data
//LSFR will pulse everytime the enable bit is high
//LSFR will create data with size equaling the bits
// When using XNOR all 1 can not be produced
//////////////////////////////////////////////////////////////////////////////////


module LSFR #(parameter bits = 3)(
    input clk,
    input enable,
    output reg [bits - 1:0] out
    );
    
    reg [bits:1] r_LFSR = 0;
    reg r_XNOR;
    wire [bits-1:0] outpu;
    reg [bits - 1:0] num = 0;
    
    always @(posedge clk)
    begin
        if(enable)
            r_LFSR <= {r_LFSR[bits-1:1],r_XNOR}; 
    end
    
    always @(*)
    begin
    r_XNOR = r_LFSR[bits] ^~ r_LFSR[bits -1];
    if (enable ==0)
    out = r_LFSR[bits:1];
    end
    
    
endmodule
