`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//VGA project to play a game of tag
//red square (player) moves according to whichever button is pressed.
//Blue square (bot) will move randomly whenever the player also moves.
//green square is the starting area
//VGA dimensions are 480x640p
//////////////////////////////////////////////////////////////////////////////////


module vga(
    input CLK100MHZ,
    input BTNL,
    input BTNR,
    input BTND,
    input BTNU,
    input BTNC,
    output Hsync,
    output Vsync,
    output [3:0] Red,
    output [3:0] Green,
    output [3:0] Blue
    );
    
    wire clk25;
    wire enable_v;
    wire e;
    wire caught;
    reg [15:0] H_mod1 = 16'd474;
    reg [15:0] H_mod2 = 16'd484;
    reg [15:0] V_mod1 = 16'd274;
    reg [15:0] V_mod2 = 16'd284;
    reg [15:0] leftr = 16'd444;
    reg [15:0] rightr = 16'd454;
    reg [15:0] upr = 16'd304;
    reg [15:0] downr = 16'd294;
    wire [15:0] H_count, V_count;
    wire [2:0] r_num;
    reg u_prev,d_prev,c_prev,l_prev,r_prev;     //delays state of button by one clock cycle
    reg u_sync, d_sync,c_sync,l_sync,r_sync;    //holds previous state by one clock cycle
    wire u_edge,d_edge,rst,l_edge,r_edge;
    reg u_sync_f,d_sync_f,c_sync_f,l_sync_f,r_sync_f;
    
    Clock_divider vga_clk( CLK100MHZ, 27'd4,clk25);
    h_counter h(clk25, enable_v,H_count);
    v_counter v(clk25,enable_v,V_count);
    LSFR #(3) rand(CLK100MHZ,e,r_num);          //Will produce pseudorandom numbers from 0-6
    
    //outputs
    assign Hsync = (H_count <96) ? 1'b1:1'b0;
    assign Vsync = (V_count <2) ? 1'b1:1'b0;
    //colors
    assign Red = ( H_count < H_mod2 && H_count > H_mod1  && V_count < V_mod2 && V_count > V_mod1 ) ? 4'hf:4'h0;
    assign Green = ( H_count > 474 && H_count < 484   && V_count > 274 && V_count < 284 ) ? 4'hf:4'h0;
    assign Blue = (H_count < rightr && H_count > leftr  &&  V_count < upr && V_count > downr ) ? 4'hf:4'h0;
   
   
   //Bot moves whenever the player moves, and moves randomly up,down,left right depending on LFSR
   always @(posedge CLK100MHZ  && e)begin                   
    if(rst == 1 || caught == 1)       //reset when you press center button or if you catch the bot
    begin
        leftr <= 16'd444; 
        rightr <= 16'd454;
        upr<= 16'd304;   
        downr <= 16'd294; 
    end
    else if (r_num == 0 || r_num == 4 )begin     //move left if random number is 0 or 4
        if(leftr <= 234)                        //if at the left edge of map, move to the right edge
        begin
            leftr <= 16'd784;
            rightr <= 16'd794;
        end
     else begin
        leftr <= leftr - 4'd10;
        rightr <= rightr -  4'd10; 
        end
    end
    else if (r_num == 1)begin                   // move right if random number is 1
        if(rightr >= 784)                       //if at right edge of map, move to the left.
        begin
            leftr <= 16'd234;
            rightr <= 16'd244;
        end 
        else begin
        rightr <= rightr+ 4'd10;
        leftr <= leftr + 4'd10;
        end
    end
    else if (r_num == 2 || r_num == 6)begin     //move up if random number is 2 or 6
     if (upr <= 34)                            //if at top of map, move to the bottom
        begin
            downr <= 16'd505;
            upr <= 16'd515;
        end
        else begin
            upr <= upr - 4'd10;
            downr <= downr - 4'd10;
        end
    end
    else if (r_num == 3 || r_num == 5)begin     //bot moves down if random number is 3 or 5
     if (downr >= 515)                           //if at bottom of map, move to the top.
        begin
            downr <= 16'd34;
            upr <= 16'd44;
        end
     else   begin
        downr <= downr + 4'd10;
        upr <= upr + 4'd10;
        end
    end
   end
  

  always @(posedge CLK100MHZ)               //Move the character around using push buttons
  begin
    if (rst == 1 || caught == 1) begin
        H_mod1 = 16'd474;
        H_mod2 = 16'd484;
        V_mod1 = 16'd274;
        V_mod2 = 16'd284;
    end
    else if (d_edge == 1)             //Move player down when you press the down button
        begin
          if (V_mod1 >= 515)              //if at the bottom, move player to top of the map
            begin
                V_mod1 <= 16'd34;
                V_mod2 <= 16'd44;
            end
     else
        begin
            V_mod1 <= V_mod1 + 4'd10;
            V_mod2 <= V_mod2 + 4'd10;
        end 
     end
     else if (u_edge == 1) begin        //move player down when down button is pressed
        if (V_mod2 <= 34) begin        //if at the top, move player to bottom of map
              V_mod1 <= 16'd505;
              V_mod2 <= 16'd515;
            end
        else begin
            V_mod1 <= V_mod1 - 4'd10;
            V_mod2 <= V_mod2 - 4'd10;
        end
    end
    else if (l_edge == 1) begin         //move player left when left button is pressed
            if(H_mod1 <= 234) begin     //if at the left edge, move player to right of the map
                H_mod1 <= 16'd784;
                H_mod2 <= 16'd794;
        end
     else
     begin
        H_mod1 <= H_mod1 - 4'd10;
        H_mod2 <= H_mod2 - 4'd10;
    end
    end
    else if (r_edge == 1) begin         //move player to right when right button is pressed
        if(H_mod2 >= 794)               //if at the right edge of the map, move player to the left of the map
            begin
                H_mod1 <= 16'd234;
                H_mod2 <= 16'd244;
            end
        begin
            H_mod1 <= H_mod1 + 4'd10;
            H_mod2 <= H_mod2 + 4'd10;
        end
    end
  end
  
  always @(posedge CLK100MHZ)         //delay change in state to avoid metastability
    begin
        u_prev <= U;
        u_sync <= u_prev;

        d_prev <= D;
        d_sync <= d_prev;
        
        c_prev <= C;
        c_sync <= c_prev;
        
        l_prev <= L;
        l_sync <= l_prev;
        
        r_prev <= R;
        r_sync <= r_prev;

end

always @(posedge CLK100MHZ)     //create an edge trigger when stablized button goes from low to high
begin
    if(rst)begin
        u_sync_f <= 0;
        d_sync_f <= 0;
        l_sync_f <= 0;
        r_sync_f <= 0;
        c_sync_f <= 0;
    end
    else begin
        u_sync_f <= u_sync;
        d_sync_f <= d_sync;
        c_sync_f <= c_sync;
        l_sync_f <= l_sync;
        r_sync_f <= r_sync;
    end    
end

//Create a register that is high when the button goes from low to high, edge triggered
assign u_edge = u_sync & ~u_sync_f;
assign d_edge = d_sync & ~d_sync_f;
assign rst = c_sync & ~c_sync_f;
assign l_edge = l_sync & ~l_sync_f;
assign r_edge = r_sync & ~r_sync_f;

assign e = u_edge || d_edge || l_edge || r_edge || rst;  //Whenever a button is pressed, move the bot
assign caught = ( H_mod2 == rightr && H_mod1 == leftr  &&  V_mod2 == upr && V_mod1 == downr ) ? 1:0; //when player and bot are equal you win

//Button debouncers to produce a solid signal when pressing a button
button_debouncer up(BTNU,CLK100MHZ,U);
button_debouncer down(BTND,CLK100MHZ,D);
button_debouncer center(BTNC,CLK100MHZ,C);
button_debouncer left(BTNL,CLK100MHZ,L);
button_debouncer right(BTNR,CLK100MHZ,R);
endmodule
