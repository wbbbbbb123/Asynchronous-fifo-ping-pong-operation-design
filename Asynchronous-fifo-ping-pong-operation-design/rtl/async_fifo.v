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
    
    input                  rst_n        ,//��λ
    input                  wr_clk       ,//дʱ�� 
    input                  wr_en        ,//д��ʹ��                      
    input [DATA_SIZE-1:0]  din          ,//д������

    input                  rd_clk       ,//��ʱ��                 
    input                  rd_en        ,//����ʹ�� 
    //output sig
    output [DATA_SIZE-1:0] dout         ,//��������
    output                 full         ,//д���ź�
    output                 empty        ,//�����ź� 
    output [DEPTH_SIZE:0]  rd_data_count,//�ɶ�������         
    output [DEPTH_SIZE:0]  wr_data_count,//��д������         
    output                 prog_full     //�ﵽFULL_THR���ź�  
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
       .wr_pointer   (wr_pointer   ),//input      [DEPTH_SIZE-1:0]дָ��
       .rd_fifo_en   (rd_fifo_en   ),//output                     
       .rd_pointer   (rd_pointer   ),//output reg [DEPTH_SIZE-1:0]��ָ��
       .rd_addr      (rd_addr      ),//output     [DEPTH_SIZE-1:0]��fifo��ַ  
       .empty        (empty        ),//output reg                 fifo���ź�
       .rd_data_count(rd_data_count) //output [ADDR_SIZE-1:0]�ɶ�������                 
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
       .din          (din          ),//input  [DATA_SIZE-1 :0]д������ 
       .rd_pointer   (rd_pointer   ),//input  [DEPTH_SIZE-1:0]��ָ��
       .wr_fifo_en   (wr_fifo_en   ),//output                     
       .wr_pointer   (wr_pointer   ),//output [DEPTH_SIZE-1:0]дָ��
       .wr_addr      (wr_addr      ),//output [DEPTH_SIZE-1:0]дfifo��ַ  
       .din_fifo     (din_fifo     ),//output [DATA_SIZE-1 :0]дfifo����
       .full         (full         ),//output  fifo���ź�                
       .prog_full    (prog_full    ),//output  �û��������������ֵ���ź�
       .wr_data_count(wr_data_count) //output [ADDR_SIZE:0]��д������ 
    );   
    
    
fifo_mem    #(.DATA_SIZE(DATA_SIZE ),//data width
              .ADDR_SIZE(DEPTH_SIZE))//user define full threshold assert value
u_fifo_mem  
(
    //input sign  
      .rst_n        (rst_n        ),//input                 
      .wr_clk       (wr_clk       ),//input                 дʱ�� 
      .wr_en        (wr_fifo_en   ),//input                 д��ʹ��  
      .wr_addr      (wr_addr      ),//input  [ADDR_SIZE-1:0]                    
      .din          (din_fifo     ),//input  [DATA_SIZE-1:0]д������
      .rd_clk       (rd_clk       ),//input                 ��ʱ��                 
      .rd_en        (rd_fifo_en   ),//input                 ����ʹ�� 
      .rd_addr      (rd_addr      ),//input  [ADDR_SIZE-1:0]
      .full         (full         ),//input                 д���ź�
      .empty        (empty        ),//input                 �����ź�  
    //output sign 
      .dout         (dout         )//output [DATA_SIZE-1:0]��������
    );  
    
endmodule
