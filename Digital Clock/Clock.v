`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Created by Joshua Paul
//clock that you can adjust the time using on board buttons 
//////////////////////////////////////////////////////////////////////////////////

module Clock(
input CLK100MHZ,
input BTNC,
input BTNU,
input BTND,
input BTNR,
input BTNL,
input on,
output [7:0]Anode,
output [6:0]LED
    );
    
    wire [17:0] tfinal;
    wire [3:0] oseconds,ominutes,hours ;
    wire [2:0] tseconds, tminutes;
    wire en1,en2,en3,en4,en5,one;
    wire U, D, C, L, R;
reg u_prev,d_prev,c_prev,l_prev,r_prev;     //delays state of button by one clock cycle
reg u_sync, d_sync,c_sync,l_sync,r_sync;    //holds previous state by one clock cycle
wire u_edge,d_edge,rst,l_edge,r_edge;
reg u_sync_f,d_sync_f,c_sync_f,l_sync_f,r_sync_f;
reg [2:0] x = 6'b0;
reg [3:0] o_sec= 0,o_min=0,hour=0;
reg [2:0] t_sec=0, t_min=0;



assign tfinal = {hours,tminutes,ominutes,tseconds,oseconds};

always @(posedge CLK100MHZ)         //time adjust
begin
    if (rst) begin                  // reset values when center button is pressed
        o_sec <= 0;
        t_sec <= 0;
        o_min <= 0;
        t_min <= 0;
        hour <= 0;
    end
    else if (on)                    //when the clock is on have the values equal counter values
        begin
            o_sec <= oseconds;
            t_sec <= tseconds;
            o_min <= ominutes;
            t_min <= tminutes;
            hour <= hours;
        end
    else if (u_edge == 1 && x == 3'b000 && on != 1)     //increase time by one second
    begin
        if(o_sec >= 9)
              o_sec <= 0;
        else
            o_sec <= o_sec + 1;  
        end
    else if (d_edge == 1 && x == 3'b000 && on != 1)    //decrease time by one second
        begin
            if(o_sec <= 0)
                o_sec <= 9;
        else
            o_sec <= o_sec - 1;  
        end
    else if (u_edge == 1 && x == 3'b001 && on != 1)    //increase time by 10 seconds
    begin
        if(t_sec >= 5)
              t_sec <= 0;
        else
            t_sec <= t_sec + 1;  
        end
    else if (d_edge == 1 && x == 3'b001 && on != 1)    //decrease time by 10 seconds
        begin
            if(t_sec <= 0)
              t_sec <= 5;
        else
            t_sec <= t_sec - 1;  
        end
    else if (u_edge == 1 && x == 3'b010 && on != 1)    //increase time by 1 minute
        begin
            if(o_min >= 9)
              o_min <= 0;
            else
                o_min <= o_min + 1;  
        end
    else if (d_edge == 1 && x == 3'b010 && on != 1)    //decrease time by 1 minute
        begin
            if(o_min <= 0)
              o_min <= 9;
            else
                o_min <= o_min - 1;  
        end
    else if (u_edge == 1 && x == 3'b011 && on != 1)    //increase time by 10 minutes
        begin
            if(t_min >= 5)
              t_min <= 0;
            else
            t_min <= t_min + 1;  
        end
    else if (d_edge == 1 && x == 3'b011 && on != 1)    //decrease time by 10 minutes
        begin
            if(t_min <= 0)
              t_min <= 5;
            else
            t_min <= t_min - 1;  
        end
    else if (u_edge == 1 && x == 3'b100 && on != 1)    //increase time by 1 hour
    begin
        if(hour >= 12)
              hour <= 0;
        else
            hour <= hour + 1;  
        end 
    else if (d_edge == 1 && x == 3'b100 && on != 1)    //increase time by 1 hour
    begin
        if(hour <= 0)
              hour <= 12;
        else
            hour <= hour - 1;  
        end 
end

always @(posedge CLK100MHZ)
begin
    if (rst)              //set state to 0 when reset
        x <= 0;
    else if (l_edge == 1 && on != 1)    //cycle left what time you are adjusting
    begin
        if (x >= 3'b100)
            x <= 3'b000;
        else 
            x <= x + 3'b1;
        end
     else if (r_edge == 1 && on != 1)   //cycle right what time you are adjusting
    begin
        if (x <= 3'b000)
            x <= 3'b100;
        else 
            x <= x - 3'b1;
     end
     else x <= x;
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

assign u_edge = u_sync & ~u_sync_f;
assign d_edge = d_sync & ~d_sync_f;
assign rst = c_sync & ~c_sync_f;
assign l_edge = l_sync & ~l_sync_f;
assign r_edge = r_sync & ~r_sync_f;


    button_debouncer up(
    .pb_1(BTNU),
    .clk(CLK100MHZ),
    .pb_out(U)
    );
    button_debouncer down(
    .pb_1(BTND),
    .clk(CLK100MHZ),
    .pb_out(D)
    );
    button_debouncer center(
    .pb_1(BTNC),
    .clk(CLK100MHZ),
    .pb_out(C)
    );
    button_debouncer left(
    .pb_1(BTNL),
    .clk(CLK100MHZ),
    .pb_out(L)
    );
    button_debouncer right(
    .pb_1(BTNR),
    .clk(CLK100MHZ),
    .pb_out(R)
    );
    
    
Clock_divider one_sec(
    .clock_in(CLK100MHZ),         //input clock on FPGA
    .divide(100000000), //100MHZ/200000 = 500Hz = 500/1s = 1/.002s = 2ms
    //.divide(27'd02),
    .clock_out(one)  //output clock
    );

    
    Counter_10 osec(
    .clock(one),
    .in(o_sec),
    .enable(on),
    .num(oseconds),
    .en(en1)
    );
    Counter_6 tsec(
    .clock(one),
    .in(t_sec),
    .enable(en1),
    .num(tseconds),
    .en(en2)
    );   
    Counter_10 omin(
    .clock(one),
    .in(o_min),
    .enable(en2),
    .num(ominutes),
    .en(en3)
    );
    Counter_6 tmin(
    .clock(one),
    .in(t_min),
    .enable(en3),
    .num(tminutes),
    .en(en4)
    );
    Counter_12 hr(
    .clock(one),
    .in(hour),
    .enable(en4),
    .num(hours),
    .en(en5)
    );
        
    Seven_seg seg(
        .clk(CLK100MHZ),            //100Mhz clock on fpga
        .num(tfinal),
        .Anode_Activate(Anode),    //Anode signals of 7-segment display
        .LED_out(LED)            //Cathode patterns of 7-segment display
    );
    
endmodule
