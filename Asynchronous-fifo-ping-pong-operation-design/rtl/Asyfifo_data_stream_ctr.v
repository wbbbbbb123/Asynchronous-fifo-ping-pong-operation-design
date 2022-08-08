`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/07 15:54:12
// Design Name: 
// Module Name: Asyfifo_data_stream_ctr
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


module Asyfifo_data_stream_ctr
#(parameter DATA_SIZE  = 16 ,//data width                                                                
  parameter DEPTH_SIZE = 10 ,//data depth 2^DEPTH_SIZE(10:1024)                                          
  parameter FULL_THR   = 512,//user define full threshold assert value                                   
  parameter FULL_THR_EN= 1  ,//0/1:disable/enable user define full threshold assert value                
  parameter WR_CLK_PR  = 20 ,                                                                              
  parameter RD_CLK_PR  = 8                                                                                
)
(   //input sign
    input                       rst_n          ,
    //push data in ctr
    input                       clk_in         ,
    input     [DATA_SIZE-1:0]   data_in        ,
    input                       data_in_en     , 
    //pop data out ctr         
    input                       clk_out        ,
    input                       data_out_en    ,//data out requst
    //output sign
    output reg                  data_out_ready ,//any fifoN had full or prog_full   
    output reg                  data_out_busy  ,  
    output reg [DATA_SIZE-1:0]  data_out       
    );
 
//localparam  DATA_DEPTH = 1024;    
localparam  DATA_DEPTH =  2**DEPTH_SIZE;  

//fifo1 and fifo2 port define
reg                   data1_in_en   ; 
reg                   data2_in_en   ;    
reg                   data1_out_en  ; 
reg                   data2_out_en  ; 
wire [DATA_SIZE-1:0]  data1_out     ;
wire [DATA_SIZE-1:0]  data2_out     ; 
wire                  fifo1_full    ;
wire                  fifo2_full    ;  
wire                  fifo1_empty   ;
wire                  fifo2_empty   ;
wire [DEPTH_SIZE:0]   rd_data1_count;  
wire [DEPTH_SIZE:0]   rd_data2_count;
wire [DEPTH_SIZE:0]   wr_data1_count;
wire [DEPTH_SIZE:0]   wr_data2_count;   
wire                  prog1_full    ;
wire                  prog2_full    ;






//data push into fifo 
localparam st_push_idle        = 5'b00001;
localparam st_push_fifo1       = 5'b00010;
localparam st_push_fifo2_wait  = 5'b00100;//wait fifo2 had pop
localparam st_push_fifo2       = 5'b01000;
localparam st_push_fifo1_wait  = 5'b10000;//wait fifo1 had pop

reg [4:0] cur_push_state;
reg [4:0] nex_push_state;


//data pop from fifo
localparam st_pop_idle   = 3'b001;
localparam st_pop_fifo1  = 3'b010;
localparam st_pop_fifo2  = 3'b100;
reg [2:0] cur_pop_state;
reg [2:0] nex_pop_state;



always@(*)begin
    if(!rst_n)begin
        data_out = {DATA_SIZE{1'b0}};
    end
    if(data_out_busy)begin
        if(cur_pop_state==st_pop_fifo1)begin
            data_out = data1_out;
        end
        else if(cur_pop_state==st_pop_fifo2)begin
            data_out = data2_out;
        end
        else begin
            data_out = data_out;
        end  
    end  
    else begin
        data_out = {DATA_SIZE{1'b0}};
    end
end
//assign data_out = (((cur_pop_state == st_pop_fifo1)||(cur_pop_state == st_pop_fifo2))&&(data_out_busy))? ((cur_pop_state == st_pop_fifo1)? data1_out:data2_out):{DATA_SIZE{1'b0}};
//assign data_out = (((cur_pop_state == st_pop_fifo1)||(cur_pop_state == st_pop_fifo2)))? ((cur_pop_state == st_pop_fifo1)? data1_out:data2_out):{DATA_SIZE{1'b0}};
//data push into fifo(State transitions) 
always@(*)begin
    if(!rst_n)begin
        cur_push_state <= st_push_idle  ;    
    end
    else begin
       cur_push_state  <= nex_push_state;  
    end
end

always@(posedge clk_in or negedge rst_n)begin
    if(!rst_n)begin
      nex_push_state <=  st_push_idle;
      data1_in_en    <=  1'b0; 
      data2_in_en    <=  1'b0;   
    end
    else begin
        data1_in_en    <=  1'b0;
        data2_in_en    <=  1'b0;
        case(cur_push_state)
            st_push_idle:begin
                    nex_push_state <= st_push_fifo1;
            end
            st_push_fifo1:begin
                if((FULL_THR_EN&&prog1_full)|fifo1_full)begin
                    nex_push_state <= st_push_fifo2_wait;
                end    
                else begin
                    nex_push_state <= st_push_fifo1;
                    if(data_in_en)
                        data1_in_en    <=  1'b1;          
                end
            end    
            st_push_fifo2_wait:begin
                if(fifo2_empty)begin
                    nex_push_state <= st_push_fifo2;
                    if(data_in_en)//连续读时钟信号
                        data2_in_en    <=  1'b1;            
                end    
                else begin
                    nex_push_state <= st_push_fifo2_wait;
                end
            end 
            st_push_fifo2:begin
                if((FULL_THR_EN&&prog2_full)|fifo2_full)begin
                    nex_push_state <= st_push_fifo1_wait;
                end    
                else begin
                    nex_push_state <= st_push_fifo2;
                    if(data_in_en)
                        data2_in_en    <=  1'b1;          
                end
            end    
            st_push_fifo1_wait:begin
                if(fifo1_empty)begin
                    if(data_in_en)//连续读时钟信号
                        data1_in_en    <=  1'b1;            
                    nex_push_state <= st_push_fifo1;
                end    
                else begin
                    nex_push_state <= st_push_fifo1_wait;
                end
            end
            default:begin
                nex_push_state <= st_push_idle;
            end         
        endcase
    end
end

//data pop into fifo(State transitions) 
always@(*)begin
    if(!rst_n)begin
        cur_pop_state  <= st_pop_idle  ;    
    end
    else begin
        cur_pop_state  <= nex_pop_state;  
    end
end

always@(posedge clk_out or negedge rst_n)begin
    if(!rst_n)begin
      nex_pop_state <= st_pop_idle;
      data1_out_en  <=  1'b0;
      data2_out_en  <=  1'b0;    
    end
    else begin
        data1_out_en  <=  1'b0;
        data2_out_en  <=  1'b0;    
        case(cur_pop_state)
            st_pop_idle:begin
                if(prog1_full|fifo1_full)begin          
                    nex_pop_state <= st_pop_fifo1;
                end
                else if(prog2_full|fifo2_full)begin        
                    nex_pop_state <= st_pop_fifo2;
                end    
                else
                    nex_pop_state <= st_pop_idle;     
            end
            st_pop_fifo1:begin
                if(!fifo1_empty)begin
                    nex_pop_state <= st_pop_fifo1;
                    if(data_out_en)
                        data1_out_en    <=  1'b1;
                end    
                else begin
                    nex_pop_state <= st_pop_idle;
                end
            end  
            st_pop_fifo2:begin
                if(!fifo2_empty)begin
                    nex_pop_state <= st_pop_fifo2;
                    if(data_out_en)
                        data2_out_en    <=  1'b1;
                end    
                else begin
                    nex_pop_state <= st_pop_idle;
                end
            end 
            default:begin
                nex_pop_state <= st_pop_idle;
            end 
        endcase
    end
end

always@(posedge clk_out or negedge rst_n)begin
    if(!rst_n)
        data_out_ready <= 1'b0;
    else if(((wr_data1_count==FULL_THR)&prog1_full)|((wr_data2_count==FULL_THR)&prog2_full)
            |((wr_data1_count==DATA_DEPTH)&fifo1_full)|((wr_data2_count==DATA_DEPTH)&fifo2_full))
        data_out_ready <= 1'b1;
    else    
        data_out_ready <= 1'b0;
end

//data_out_busy
reg data_out_busy_en;
always@(posedge clk_out or negedge rst_n)begin
    if(!rst_n)begin
        data_out_busy    <= 1'b0;
        data_out_busy_en <= 1'b0;
    end
    else begin
        if((cur_pop_state==st_pop_fifo1)|(cur_pop_state==st_pop_fifo2))begin
            if(data_out_en)begin
                data_out_busy_en <= 1'b1;
                //data_out_busy <= 1'b1;
            end
            if(data_out_busy_en)
                data_out_busy <= 1'b1;
        end
        else begin
            data_out_busy <= 1'b0;   
            data_out_busy_en <= 1'b0;
        end 
    end
end

async_fifo 
#(.DATA_SIZE  (DATA_SIZE  ),//data width
  .DEPTH_SIZE (DEPTH_SIZE ),//data depth 2^DEPTH_SIZE(10:1024)
  .FULL_THR   (FULL_THR   ),//user define full threshold assert value
  .FULL_THR_EN(FULL_THR_EN))//0/1:disable/enable user define full threshold assert value 
u0_async_fifo(
    //input sign  
     .rst_n        (rst_n         ),//input                复位
     .wr_clk       (clk_in        ),//input                写时钟 
     .wr_en        (data1_in_en   ),//input                写入使能                      
     .din          (data_in       ),//input [DATA_SIZE-1:0]写入数据
     .rd_clk       (clk_out       ),//input                读时钟                 
     .rd_en        (data1_out_en  ),//input                读出使能 
    //output sign
     .dout         (data1_out     ),//output [DATA_SIZE-1:0]读出数据
     .full         (fifo1_full    ),//output                写满信号
     .empty        (fifo1_empty   ),//output                读空信号   
     .rd_data_count(rd_data1_count),//output [DEPTH_SIZE:0] 可读数据数        
     .wr_data_count(wr_data1_count),//output [DEPTH_SIZE:0] 已写数据数        
     .prog_full    (prog1_full    ) //output                达到FULL_THR满信号
    );    
    
async_fifo 
#(.DATA_SIZE  (DATA_SIZE  ),//data width
  .DEPTH_SIZE (DEPTH_SIZE ),//data depth 2^DEPTH_SIZE(10:1024)
  .FULL_THR   (FULL_THR   ),//user define full threshold assert value
  .FULL_THR_EN(FULL_THR_EN))//0/1:disable/enable user define full threshold assert value 
u1_async_fifo(
    //input sign  
     .rst_n        (rst_n         ),//input                复位
     .wr_clk       (clk_in        ),//input                写时钟 
     .wr_en        (data2_in_en   ),//input                写入使能                      
     .din          (data_in       ),//input [DATA_SIZE-1:0]写入数据
     .rd_clk       (clk_out       ),//input                读时钟                 
     .rd_en        (data2_out_en  ),//input                读出使能 
    //output sign
     .dout         (data2_out     ),//output [DATA_SIZE-1:0]读出数据
     .full         (fifo2_full    ),//output                写满信号
     .empty        (fifo2_empty   ), //output                读空信号 
     .rd_data_count(rd_data2_count),//output [DEPTH_SIZE:0] 可读数据数        
     .wr_data_count(wr_data2_count),//output [DEPTH_SIZE:0] 已写数据数        
     .prog_full    (prog2_full    ) //output                达到FULL_THR满信号
    );     

    
endmodule
