`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/06 15:33:41
// Design Name: 
// Module Name: async_fifo
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


module async_fifo
#(parameter DATA_SIZE  = 16,  //data width
  parameter DEPTH_SIZE = 10 , //data depth 2^DEPTH_SIZE(10:1024)
  parameter FULL_THR   = 512,
  parameter FULL_THR_EN= 1  ) //user define full threshold assert value
(
    //input sign  
    
    input                  rst_n        ,//复位
    input                  wr_clk       ,//写时钟 
    input                  wr_en        ,//写入使能                      
    input [DATA_SIZE-1:0]  din          ,//写入数据

    input                  rd_clk       ,//读时钟                 
    input                  rd_en        ,//读出使能 
    //output sig
    output [DATA_SIZE-1:0] dout         ,//读出数据
    output                 full         ,//写满信号
    output                 empty        ,//读空信号 
    output [DEPTH_SIZE:0]  rd_data_count,//可读数据数         
    output [DEPTH_SIZE:0]  wr_data_count,//已写数据数         
    output                 prog_full     //达到FULL_THR满信号  
    );
  
 
wire [DEPTH_SIZE  :0]   wr_pointer    ;
wire [DEPTH_SIZE  :0]   rd_pointer    ;
wire                    wr_fifo_en    ;
wire                    rd_fifo_en    ;
wire [DATA_SIZE-1 : 0]  din_fifo      ;
wire [DEPTH_SIZE-1:0]   wr_addr       ;
wire [DEPTH_SIZE-1:0]   rd_addr       ;
  

rd_fifo_ctr  #(.DATA_SIZE  (DATA_SIZE ),//data width
               .DEPTH_SIZE (DEPTH_SIZE), //data depth 2^DEPTH_SIZE(10:1024)
               .FULL_THR   (FULL_THR  ))//user define full threshold assert value
u_rd_fifo_ctr(   
       .rst_n        (rst_n        ),//input                      
       .rd_clk       (rd_clk       ),//input                           
       .rd_en        (rd_en        ),//input                       
       .wr_pointer   (wr_pointer   ),//input      [DEPTH_SIZE-1:0]写指针
       .rd_fifo_en   (rd_fifo_en   ),//output                     
       .rd_pointer   (rd_pointer   ),//output reg [DEPTH_SIZE-1:0]读指针
       .rd_addr      (rd_addr      ),//output     [DEPTH_SIZE-1:0]读fifo地址  
       .empty        (empty        ),//output reg                 fifo空信号
       .rd_data_count(rd_data_count) //output [ADDR_SIZE-1:0]可读数据数                 
    );   
    
    
    
wr_fifo_ctr
    #(.DATA_SIZE  (DATA_SIZE   ),//data width
      .DEPTH_SIZE (DEPTH_SIZE  ), //data depth 2^DEPTH_SIZE(10:1024)
      .FULL_THR   (FULL_THR    ),
      .FULL_THR_EN(FULL_THR_EN))//user define full threshold assert value
u_wr_fifo_ctr
(   
       .rst_n        (rst_n        ),//input                      
       .wr_clk       (wr_clk       ),//input                           
       .wr_en        (wr_en        ),//input                       
       .din          (din          ),//input  [DATA_SIZE-1 :0]写入数据 
       .rd_pointer   (rd_pointer   ),//input  [DEPTH_SIZE-1:0]读指针
       .wr_fifo_en   (wr_fifo_en   ),//output                     
       .wr_pointer   (wr_pointer   ),//output [DEPTH_SIZE-1:0]写指针
       .wr_addr      (wr_addr      ),//output [DEPTH_SIZE-1:0]写fifo地址  
       .din_fifo     (din_fifo     ),//output [DATA_SIZE-1 :0]写fifo数据
       .full         (full         ),//output  fifo满信号                
       .prog_full    (prog_full    ),//output  用户定义数据深度阈值满信号
       .wr_data_count(wr_data_count) //output [ADDR_SIZE:0]已写数据数 
    );   
    
    
fifo_mem    #(.DATA_SIZE(DATA_SIZE ),//data width
              .ADDR_SIZE(DEPTH_SIZE))//user define full threshold assert value
u_fifo_mem  
(
    //input sign  
      .rst_n        (rst_n        ),//input                 
      .wr_clk       (wr_clk       ),//input                 写时钟 
      .wr_en        (wr_fifo_en   ),//input                 写入使能  
      .wr_addr      (wr_addr      ),//input  [ADDR_SIZE-1:0]                    
      .din          (din_fifo     ),//input  [DATA_SIZE-1:0]写入数据
      .rd_clk       (rd_clk       ),//input                 读时钟                 
      .rd_en        (rd_fifo_en   ),//input                 读出使能 
      .rd_addr      (rd_addr      ),//input  [ADDR_SIZE-1:0]
      .full         (full         ),//input                 写满信号
      .empty        (empty        ),//input                 读空信号  
    //output sign 
      .dout         (dout         )//output [DATA_SIZE-1:0]读出数据
    );  
    
endmodule
