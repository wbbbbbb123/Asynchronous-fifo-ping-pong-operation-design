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


module rd_fifo_ctr
#(parameter DATA_SIZE  = 16,//data width
  parameter DEPTH_SIZE = 10 , //data depth 2^DEPTH_SIZE(10:1024)
  parameter FULL_THR    = 512)//user define full threshold assert value

(   
    input                         rst_n        ,
    input                         rd_clk       ,     
    input                         rd_en        , 
    input      [DEPTH_SIZE  :0]   wr_pointer   ,//дָ��
    
    output                        rd_fifo_en   ,
    output reg [DEPTH_SIZE  :0]   rd_pointer   ,//��ָ��
    output     [DEPTH_SIZE-1:0]   rd_addr      ,//��fifo��ַ  

    output reg                    empty        , //fifo���ź�  
    output reg [DEPTH_SIZE  :0]   rd_data_count  //�ɶ�������              
    );
    
    
reg  [DEPTH_SIZE  :0]       rd_addr_cnt    ;
wire [DEPTH_SIZE  :0]       rd_pointer_next;
wire [DEPTH_SIZE  :0]       rd_addr_next   ;
wire                        empty_en       ;

assign rd_fifo_en   = rd_en;
assign rd_addr      = rd_addr_cnt[DEPTH_SIZE-1:0];

assign rd_addr_next    = rd_addr_cnt + (rd_en & ~empty) ;  // ���վ��ö����Ƽ�������һ�����򲻱�
assign rd_pointer_next = (rd_addr_next>>1) ^ rd_addr_next;// ����������Ƽ���ֵ��Ӧ�ĸ��������ֵ

always @(posedge rd_clk or negedge rst_n)begin
    if (!rst_n)begin 
		rd_addr_cnt   <= {(DEPTH_SIZE+1){1'b0}};
		rd_pointer    <= {(DEPTH_SIZE+1){1'b0}};
    end		
    else begin
		rd_addr_cnt   <= rd_addr_next;
		rd_pointer    <= rd_pointer_next;		
	end	
end

assign empty_en = (rd_pointer_next == wr_pointer);// ���� empty �ź�

always @(posedge rd_clk or negedge rst_n)begin
    if (!rst_n) 
		empty <= 1'b1;
    else 
		empty <= empty_en;
end    
    
wire [DEPTH_SIZE  :0] wr_act_addr;
wire [DEPTH_SIZE  :0] rd_act_addr;

gray2bin #(DEPTH_SIZE)u0_gray2bin(wr_pointer,wr_act_addr); 
gray2bin #(DEPTH_SIZE)u1_gray2bin(rd_pointer_next,rd_act_addr);   
  
always @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        rd_data_count <= {(DEPTH_SIZE+1){1'b0}};
    end
    else begin
        rd_data_count <= wr_act_addr - rd_act_addr;
    end
end    
    
    
endmodule
