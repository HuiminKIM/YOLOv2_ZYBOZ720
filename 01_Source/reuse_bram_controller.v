`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/27 11:28:06
// Design Name: 
// Module Name: reuse_bram_controller
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


module reuse_bram_controller#(parameter r_flag =1'b0)
(
    input clk,
    input rst_n,
    input read_flag,
    input bram_hs,
    input [23:0] din,
    output [23:0] dout,
    input conv3_reuse,
    input conv3_rowlast,
    input temp_hs,
    input buf_conv3_rowlast
    );
    reg [10:0]r_cnt;
    reg [10:0]w_cnt;
    reg [10:0]addr;
    reg wea;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            r_cnt <=0;
            w_cnt <=0;
        end else begin
            if(r_cnt !=0 & r_cnt == w_cnt)begin //w_cnt-1 & temp_hs ? | bram_hs
                r_cnt <=0;
                w_cnt <=0;
            end else if(!buf_conv3_rowlast & read_flag == r_flag & bram_hs)begin
                r_cnt <= r_cnt+1;
            end else if(read_flag != r_flag & r_cnt!=0 & temp_hs & conv3_reuse)begin
                w_cnt <= w_cnt+1;
            end else if(read_flag != r_flag & r_cnt!=0 & bram_hs & conv3_rowlast)begin
                w_cnt <= w_cnt+1;
            end
        end
    end
    

    always@(*)begin
        if(read_flag ==r_flag & bram_hs)begin
            wea =1;
        end else begin
            wea =0;
        end
        if(read_flag == r_flag)begin
            addr = r_cnt;
        end else begin
            if(temp_hs & conv3_reuse)addr = w_cnt+1;
            else if(bram_hs & conv3_rowlast) addr = w_cnt+1;
            else addr = w_cnt;
        end
    end
    
    reuse_bram reuse_bram(
      .addra(addr),  // Port A address bus, width determined from RAM_DEPTH
      .dina(din),           // Port A RAM input data
      .clka(clk),                           // Clock
      .wea(wea),                            // Port A write enable
      .ena('b1),
      .douta(dout)         // Port A RAM output data
    );
        
endmodule
