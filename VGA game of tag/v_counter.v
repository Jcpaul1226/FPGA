`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2024 08:52:33 AM
// Design Name: 
// Module Name: v_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module v_counter(
    input clk,
    input enable,
    output reg [15:0] v_count = 0
    );
    always @(posedge clk)
    begin
    if ( enable == 1) begin
        if (v_count < 524) begin
            v_count <= v_count + 1;
        end
        else
            v_count <= 0;
    end
    end
endmodule
