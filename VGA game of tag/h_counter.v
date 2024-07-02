`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Counter for Hsync
//////////////////////////////////////////////////////////////////////////////////


module h_counter(
    input clk,
    output reg v_enable = 0,
    output reg [15:0] h_count = 0
    );
    
    always @(posedge clk)
    begin
        if (h_count < 799) begin
            h_count <= h_count + 1;
            v_enable <= 0;
        end
    else begin
            h_count <= 0;
            v_enable <= 1;
        end
    end
    
endmodule
