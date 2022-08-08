`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/06 15:56:47
// Design Name: 
// Module Name: fifo_mem
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


module fifo_mem
#(parameter DATA_SIZE    = 16,//data width
  parameter ADDR_SIZE    = 4)//user define full threshold assert value
(
    //input sign  
    input                       rst_n        ,
    input                       wr_clk       ,//дʱ�� 
    input                       wr_en        ,//д��ʹ��  
    input  [ADDR_SIZE-1:0]      wr_addr      ,                    
    input  [DATA_SIZE-1:0]      din          ,//д������
    input                       rd_clk       ,//��ʱ��                 
    input                       rd_en        ,//����ʹ�� 
    input  [ADDR_SIZE-1:0]      rd_addr      ,
    input                       full         ,//д���ź�
    input                       empty        ,//�����ź�  
    //output sign 
    output reg [DATA_SIZE-1:0]  dout          //��������
    );
    
localparam DEPTH = 1<<ADDR_SIZE;    
reg [DATA_SIZE-1:0] mem [0:DEPTH-1]; // define fifo_mem   

integer i;
always @(posedge wr_clk or negedge rst_n)begin
    if(!rst_n)begin
        //wr_data_count <= {(ADDR_SIZE+1){1'b0}};
        for(i = 0;i < DEPTH;i = i+1)begin:clean_all
            mem[i] = {DATA_SIZE{1'bx}};
        end
    end
    else if (wr_en && !full)begin 
        mem[wr_addr] <= din;
    end
end
       
always @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin//��λʱ���0
        dout          <= {DATA_SIZE{1'b0}};
    end
    else if (rd_en && !empty)begin 
        dout <= mem[rd_addr];
    end
end
   
endmodule
