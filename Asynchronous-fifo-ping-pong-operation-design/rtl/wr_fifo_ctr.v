`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/06 16:11:41
// Design Name: 
// Module Name: rd_fifo_ctr
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


module wr_fifo_ctr
#(parameter DATA_SIZE   = 16 ,//data width
  parameter DEPTH_SIZE  = 4  , //data depth 2^DEPTH_SIZE(10:1024)
  parameter FULL_THR    = 512,
  parameter FULL_THR_EN = 1  )//user define full threshold assert value

(   
    input                         rst_n        ,
    input                         wr_clk       ,     
    input                         wr_en        , 
    input      [DATA_SIZE-1 :0]   din          ,//д������ 
    input      [DEPTH_SIZE  :0]   rd_pointer   ,//��ָ��
    
    output                        wr_fifo_en   ,
    output reg [DEPTH_SIZE  :0]   wr_pointer   ,//дָ��
    output     [DEPTH_SIZE-1:0]   wr_addr      ,//дfifo��ַ  
    output     [DATA_SIZE-1 :0]   din_fifo     ,//дfifo����
    output reg                    full         ,//fifo���ź�                
    output reg                    prog_full    , //�û��������������ֵ���ź�
    output reg [DEPTH_SIZE  :0]   wr_data_count   //��д������ 
    
    );
    
reg  [DEPTH_SIZE  :0]       wr_addr_cnt    ;  
wire [DEPTH_SIZE  :0]       wr_pointer_next;
wire [DEPTH_SIZE  :0]       wr_addr_next   ; 
wire                        full_en        ;   
assign wr_addr = wr_addr_cnt[DEPTH_SIZE-1:0];
assign wr_fifo_en   = wr_en;
assign wr_addr_next = wr_addr_cnt + (wr_en & ~full);       // ����д��������һ�����򲻱�
assign din_fifo     = din;

assign wr_pointer_next = (wr_addr_next>>1)^ wr_addr_next;    // ��ַ����Ӧ�ĸ��������ֵ��дָ�룩    
assign full_en = (wr_pointer_next=={~rd_pointer[DEPTH_SIZE:DEPTH_SIZE-1],rd_pointer[DEPTH_SIZE-2:0]});// ���� full �ź�

//assign prog_full = (wr_addr_cnt[DEPTH_SIZE-1:0]==FULL_THR);  
  
always @(posedge wr_clk or negedge rst_n)begin
    if (!rst_n)begin 
        wr_addr_cnt    <= {(DEPTH_SIZE+1){1'b0}};
        wr_pointer     <= {(DEPTH_SIZE+1){1'b0}};
    end
    else begin
        wr_addr_cnt    <= wr_addr_next;
        wr_pointer     <= wr_pointer_next;
    end
end
                
always@(posedge wr_clk or negedge rst_n)begin
    if (!rst_n) 
        full <= 1'b1;
    else 
        full <= full_en;
end    
 
wire [DEPTH_SIZE  :0] wr_act_addr;
wire [DEPTH_SIZE  :0] rd_act_addr;

gray2bin #(DEPTH_SIZE)u0_gray2bin(wr_pointer_next,wr_act_addr); 
gray2bin #(DEPTH_SIZE)u1_gray2bin(rd_pointer,rd_act_addr); 
  
always @(posedge wr_clk or negedge rst_n)begin
    if(!rst_n)begin
        wr_data_count <= {(DEPTH_SIZE+1){1'b0}};
        prog_full     <= 1'b0;
    end
    else begin
        wr_data_count <= wr_act_addr - rd_act_addr;
        prog_full     <= FULL_THR_EN?((wr_act_addr - rd_act_addr)>=FULL_THR):1'b0;
    end
end  
    
//specify 
//    (wr_en => wr_fifo_en) = (1);
//endspecify
    
endmodule
