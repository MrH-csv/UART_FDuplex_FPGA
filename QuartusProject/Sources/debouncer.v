`timescale 1ns / 1ps
// Company: ITESO
// Engineer: Cuauhtemoc Aguilera
//////////////////////////////////////////////////////////////////////////////////
module Debouncer(
    input clk,
    input rst, 
    input sw,
    output one_shot
    );


wire fin_delay_w, rst_out_w;
//wire rst_w;

// assign rst_w = ~nrst;

FSM_Debouncer  fsm (.clk(clk), .rst(rst), .sw(sw), .fin_delay(fin_delay_w),
						  .rst_out(rst_out_w), .one_shot(one_shot)     );

Delayer # (.YY(1_500_000) ) // The width parameter is defined in Delayer code
     delay_30ms (.clk(clk), .rst(rst_out_w), .enable(1'b1), .iguales(fin_delay_w)    );
						  
endmodule
