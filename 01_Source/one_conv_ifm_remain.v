`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/31 11:05:17
// Design Name: 
// Module Name: one_conv_ifm_remain
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


module one_conv_ifm_remain(
    input clk,
    input rst_n,
    input is_conv_1,
    output reg conv_1,
    output last_col,
    output reg [4:0] w_cnt,
    output reg[1:0]remain,
    output reg[1:0]remain_13,
    output reg [4:0] w_finish_cnt,
    input temp_hs,
    input [8:0] ifm_width,
    input [10:0] ifm_channel,
    input wire [10:0] ofm_channel
    );
    
    localparam idle = 2'b00;
    localparam row1 = 2'b01;
    localparam reuse = 2'b10;
    localparam rowlast = 2'b11;
    
    reg [8:0] h_cnt;
    reg [10:0] c_cnt;
    reg [10:0] ofm_cnt;
    
    reg [4:0]last_row_w_cnt;
    reg [10:0]last_row_c_cnt;
    
    assign last_col = (temp_hs & w_cnt == w_finish_cnt & c_cnt == ifm_channel -1);
    
    always@(posedge clk)begin
        if(!rst_n)begin
            w_finish_cnt<=0;
            c_cnt <= 0;
            w_cnt <=0;
            h_cnt<=0;
            conv_1<=0;
            ofm_cnt <=0;
        end else begin
            conv_1<=is_conv_1;
            case(ifm_width)
                416:begin
                    w_finish_cnt <= 31;
                end
                208:begin
                    w_finish_cnt <= 15;
                end
                104:begin
                    w_finish_cnt <= 7;
                end
                52:begin
                    w_finish_cnt <= 3;
                end
                26:begin
                    w_finish_cnt <= 1;
                end
                13:begin
                    w_finish_cnt <= 0;
                end
            endcase
            if(conv_1 & temp_hs & c_cnt == ifm_channel -1)begin
                c_cnt <= 0;
                if(last_col)begin
                    w_cnt <=0;
                    if(h_cnt == ifm_width-1)begin
                        h_cnt<=0;
                        if(ofm_cnt == ofm_channel -1) ofm_cnt<=0;
                        else ofm_cnt<=ofm_cnt+1;
                    end else begin
                        h_cnt <= h_cnt+1;
                    end
                end else begin
                    w_cnt <= w_cnt+1;
                end
            end else if(conv_1 &temp_hs)begin
                c_cnt <= c_cnt + 1;
            end
        end
    end
    
    reg [1:0]save_remain_13;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            remain <=3;
            remain_13 <=3;
            save_remain_13<=2;
        end else begin
            case(ifm_width)
                13:begin
                    if(last_col & h_cnt ==12)begin
                        remain_13 <=3;
                        save_remain_13<=2;
                    end else if(last_col)begin
                            remain_13 <= save_remain_13;
                            save_remain_13 <= save_remain_13 -1;
                    end else if(temp_hs)begin
                        remain_13 <= remain_13 -1;
                    end
                end
                26:begin
                    if(last_col & w_cnt == w_finish_cnt)begin
                        if (h_cnt[0] == 1) remain <=3;
                        else remain <=1;
                    end else if(c_cnt == ifm_channel-1 & temp_hs)begin
                        remain <= remain -1;
                    end
                end
                default:begin
                    if(last_col & w_cnt == w_finish_cnt)begin
                        remain <=3;
                    end else if(c_cnt == ifm_channel-1 & temp_hs)begin
                        remain <= remain -1;
                    end
                end
            endcase
        end
    end
endmodule
