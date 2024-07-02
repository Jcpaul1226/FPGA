`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created By Joshua Paul
//Calculator with Multiplication/Subtraction/Division/addition
//////////////////////////////////////////////////////////////////////////////////

module Calculator(
    input CLK100MHZ,
    input [6:0] x,                //First Number
    input [6:0] y,                //Second Number
    input [1:0] SW,               //Mode selector
    output wire [6:0] LED,        //Seven segment Cathodes
    output wire [7:0] Anode       //seven segment anodes
    );
    reg [29:0] result;

    always @(*)
    begin
    case(SW)
    2'b00: begin                    //Addition
    result = x + y;
    end
    2'b01: begin                    //subtraction
    result = x - y;
    end
    2'b10: begin                    //Division
    result = x / y;
    end
    2'b11: begin                    //Multiplication
    result = x * y;
    end
    endcase
    end
    
    Seven_seg seg(
        .clk(CLK100MHZ),            //100Mhz clock on fpga
        .num({result,y,x}),
        .Anode_Activate(Anode),    //Anode signals of 7-segment display
        .LED_out(LED)            //Cathode patterns of 7-segment display
    );
endmodule
