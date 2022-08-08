`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/07 15:01:42
// Design Name: 
// Module Name: gray2bin
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


module gray2bin 
#(
parameter  DEPTH_SIZE = 4
 )
(   //system signals
    input   [DEPTH_SIZE:0]   gray,
    output  [DEPTH_SIZE:0]   bin
);

assign  bin[DEPTH_SIZE] = gray[DEPTH_SIZE];//最高位不发生改变
generate
    genvar i;
    for (i = DEPTH_SIZE-1; i >=0; i = i - 1)begin:gray2bin_loop
        assign  bin[i] = bin[i+1] ^ gray[i];
    end
endgenerate
 
endmodule
