`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/02 16:43:03
// Design Name: 
// Module Name: conv_1_weight_bram_controller
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


module conv_1_weight_bram_controller(
    input clk,
    input rst_n,
    input bram_en,
    input [63:0] din,
    input conv_1_bram_valid,
    output [63:0] dout,
    output reg bram_full,
    input [10:0] ifm_channel,
    input [8:0] ifm_width
    );
    
    reg [10:0] w_cnt;
    reg [8:0] addr_w_cnt;
    reg [10:0] r_cnt;
    reg [8:0] addr_r_cnt;
    reg [9:0] ofm_cnt;
    reg [9:0] ofm_finish_cnt;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            ofm_finish_cnt <=0;
        end else begin
            case(ifm_width)
                104:begin
                    ofm_finish_cnt <= 831;
                end
                52:begin
                    ofm_finish_cnt <= 207;
                end
                26:begin
                    ofm_finish_cnt <= 51;
                end
                13:begin
                    ofm_finish_cnt <= 12;
                end
            endcase
        end
    end
    
    wire w_hs = !bram_full & bram_en; 
    wire r_hs = bram_full & conv_1_bram_valid;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            ofm_cnt<=0;
            w_cnt <=0;
            r_cnt <=0;
            bram_full <=0;
            addr_w_cnt <=0;
            addr_r_cnt<=0;
        end else begin
            if(r_hs & r_cnt == ifm_channel-4)begin
                if(ofm_cnt == ofm_finish_cnt)begin
                    bram_full <=0;
                    ofm_cnt<=0;
                end else begin
                    ofm_cnt <= ofm_cnt+1;
                end
            end else if(w_hs & w_cnt == ifm_channel-4)begin
                bram_full <=1;
            end
            
            if(r_hs & r_cnt == ifm_channel-4 & ofm_cnt == ofm_finish_cnt)begin
                w_cnt <= 0;
                addr_w_cnt <=0;
            end else if(w_hs)begin
                w_cnt <= w_cnt+4;
                addr_w_cnt <=addr_w_cnt+1;
            end
            
            if(r_hs & r_cnt == ifm_channel-4)begin
                r_cnt <= 0;
                addr_r_cnt<=0;
            end else if(r_hs)begin
                r_cnt <= r_cnt+4;
                addr_r_cnt <= addr_r_cnt+1;
            end
        end
    end
    
    wire wea = !bram_full;
    wire [8:0]addra = (bram_full)? addr_r_cnt: addr_w_cnt;

    true_sync_dpbram  #(
    .DWIDTH (64),
    .MEM_SIZE (320)
    )
    BRAM_weight(
    .clk(clk),
    .addr(addra),
    .ce('b1),
    .we(wea),
    .dout(dout),
    .din(din)
    );
endmodule
