`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created By Joshua Paul
//Counter Controlled by clock speed and an enable switch
//////////////////////////////////////////////////////////////////////////////////
module Counter_6(
input clock,
input [2:0] in,
input  enable,
output reg [2:0] num =0,
output reg en = 0                         //enable switch for next counter
    );
    

    always @(posedge clock)    
    begin                      
        en <=0;                 //ensure next enable is off
    if (enable != 1)            // when enable is off, time is being adjusted
        num <= in;
        else if (num >= 3'd5 && enable)      //Reset when 5 is reached
            num <= 3'd0;                
        else if (enable)        //count when enable is on
        begin
        if (num >= 3'd4) begin  //signal next counter to count
                en <= 1; 
                num <= num +1;
        end
        else num <= num +1;
        end
        else num <= num;
        end      
endmodule
