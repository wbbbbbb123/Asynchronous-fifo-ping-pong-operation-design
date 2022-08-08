`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/08 10:09:10
// Design Name: 
// Module Name: top_tb
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
`include "define.sv"
class random_data;
    rand bit [`DATA_SIZE-1:0] data;
endclass

class random_gap;
    rand bit [`DEPTH_SIZE-1:0] random_num1;
    rand bit [`DEPTH_SIZE-1:0] random_num2;
    rand bit [`DEPTH_SIZE-1:0] random_num3;
    rand bit [`DEPTH_SIZE-1:0] delay1;
    rand bit [`DEPTH_SIZE-1:0] delay2;
    constraint c_random{
        random_num1 + random_num2 + random_num3 == ((`FULL_THR_EN)?`FULL_THR:`DATA_DEPTH);
        delay1 >200;
        delay1 <800;
        delay2 >200;
        delay2 <800;        
    }
endclass

module top_tb();
random_data ran_d;  
random_gap  rands;

reg                    rst_n          ;                                  
reg                    clk_in         ; 
reg                    clk_out        ; 
reg                    data_in_en     ; 
reg [`DATA_SIZE-1:0]   data_in        ;
reg                    data_out_en    ;
wire                   data_out_ready ;
wire                   data_out_busy  ;
wire [`DATA_SIZE-1:0]  data_out       ;


initial begin
    clk_in=1'b1;
    forever begin
        #(`WR_CLK_PR>>1) clk_in =~clk_in;
    end
end
initial begin
    clk_out=1'b1;
    forever begin
        #(`RD_CLK_PR>>1) clk_out=~clk_out;
    end
end

initial begin
    ran_d = new();
    init();
    #200;
    push_fifo(2400);
    //#2000;
    //$finish;
end  

initial begin
    
    rands = new();
    
    pop_onefifo_empty();
    pop_onefifo_empty();
    pop_onefifo_empty();
    pop_fifo_any_ex();
    #2000;
    $finish;
end 
    
task init;
begin
    data_in     = {`DATA_SIZE{1'b0}};
    data_in_en  = 1'b0;
    data_out_en = 1'b0;
    rst_n       = 1'b0;
    #201
    rst_n=1'b1;
end
endtask

task push_fifo; 
    input [31:0] push_nums;
begin
    @(posedge clk_in);
    repeat(push_nums)begin
         ran_d.randomize();
         repeat(3)@(posedge clk_in); 
         data_in=data_in+1'b1;//data is accumulate
         //data_in=ran_d.data;//data is random
         data_in_en=1'b1;
        @(posedge clk_in);
        data_in_en=1'b0;
    end
end
endtask


task pop_onefifo_empty; 
begin
    @(posedge clk_out); 
    wait(data_out_ready);
        repeat(`FULL_THR_EN?`FULL_THR:`DATA_DEPTH)begin
            @(posedge clk_out); 
            data_out_en=1'b1;
            @(posedge clk_out);
            data_out_en=1'b0;
        end
end
endtask  

//int num1 =100;
//int num2 =200;
//int num3 =212;
task pop_fifo_any_ex;
begin
    rands.randomize();
    wait(data_out_ready);
    pop_fifo_any(rands.random_num1);
    #rands.delay1;
    pop_fifo_any(rands.random_num2);
    #rands.delay2;
    pop_fifo_any(rands.random_num3);
end
endtask

task pop_fifo_any; 
input [31:0] pop_nums;
begin
    @(posedge clk_out); 
    //wait(data_out_ready);
    repeat(pop_nums)begin
        @(posedge clk_out); 
        data_out_en=1'b1;
        @(posedge clk_out);
        data_out_en=1'b0;
    end
end
endtask 




Asyfifo_data_stream_ctr 
#(.DATA_SIZE  (`DATA_SIZE  ), //data width                              
  .DEPTH_SIZE (`DEPTH_SIZE ), //data depth 2^DEPTH_SIZE(10:1024)        
  .FULL_THR   (`FULL_THR   ), //user define full threshold assert value 
  .FULL_THR_EN(`FULL_THR_EN))//0/1:disable/enable user define full threshold assert value 
u_Asyfifo_data_stream_ctr(
.rst_n         (rst_n         ),
.clk_in        (clk_in        ),
.clk_out       (clk_out       ),
.data_in       (data_in       ),
.data_in_en    (data_in_en    ),
.data_out_en   (data_out_en   ),
.data_out_ready(data_out_ready),
.data_out_busy (data_out_busy ),
.data_out      (data_out      )
);




endmodule
