`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/27 17:23:23
// Design Name: 
// Module Name: ifm_remain_controller
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


module ifm_remain_controller(
    input clk,
    input rst_n,
    input is_conv_3,
    output last_col,
    output conv3_row1,
    output conv3_reuse,
    output conv3_rowlast,
    output reg [4:0] w_cnt,
    output reg[1:0]remain,
    output reg[1:0]remain_13,
    output reg [4:0] w_finish_cnt,
    input temp_hs,
    input [8:0] ifm_width,
    input [10:0] ifm_channel,
    input [10:0] ofm_channel,
    input bram_hs
    );
    localparam idle = 2'b00;
    localparam row1 = 2'b01;
    localparam reuse = 2'b10;
    localparam rowlast = 2'b11;
    
    reg [8:0] h_cnt;
    reg [10:0] c_cnt;
    reg [10:0] ofm_cnt;
    
    reg [1:0] c_state;
    reg [1:0] n_state;
    
    assign conv3_row1 = (c_state == row1);
    assign conv3_reuse = (c_state == reuse);
    assign conv3_rowlast = (c_state == rowlast);
    
    always@(posedge clk)begin
        if(!rst_n)begin
            c_state<= idle;
        end else begin
            c_state <= n_state;
        end
    end
    
    reg [4:0]last_row_w_cnt;
    reg [10:0]last_row_c_cnt;
    reg buf_conv3_rowlast;
    
    assign last_col = (temp_hs & w_cnt == w_finish_cnt & c_cnt == ifm_channel -1);
    wire row_last_col = (bram_hs & last_row_w_cnt == w_finish_cnt & last_row_c_cnt == ifm_channel -1);

    always@(*)begin
        n_state = c_state;
        case(c_state)
            idle:begin
                n_state = row1;
            end
            row1:begin
                if(last_col & temp_hs) n_state = reuse;
            end
            reuse:begin
                if(last_col & h_cnt == ifm_width-1 & temp_hs) n_state = rowlast;
            end
            rowlast:begin
                if(row_last_col & ofm_cnt == ofm_channel -1 & bram_hs) n_state = idle;
                else if(row_last_col & bram_hs) n_state = row1;
            end
        endcase
    end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_conv3_rowlast <=0;
            w_finish_cnt<=0;
            c_cnt <= 0;
            w_cnt <=0;
            h_cnt<=0;
        end else begin
            buf_conv3_rowlast<=conv3_rowlast;
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
            if(is_conv_3 & temp_hs & c_cnt == ifm_channel -1)begin
                c_cnt <= 0;
                if(last_col)begin
                    w_cnt <=0;
                    if(conv3_row1) h_cnt <= h_cnt+2;
                    else if(h_cnt == ifm_width-1) h_cnt<=0;
                    else h_cnt <= h_cnt+1;
                end else begin
                    w_cnt <= w_cnt+1;
                end
            end else if(is_conv_3 &temp_hs)begin
                c_cnt <= c_cnt + 1;
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            last_row_w_cnt <=0;
            last_row_c_cnt <=0;
            ofm_cnt <=0;
        end else begin
            if(buf_conv3_rowlast & bram_hs & last_row_c_cnt == ifm_channel -1)begin
                last_row_c_cnt<=0;
                if(row_last_col)begin
                    last_row_w_cnt <= 0;
                end else begin
                    last_row_w_cnt <= last_row_w_cnt+1;
                end
            end else if(buf_conv3_rowlast & bram_hs)begin
                last_row_c_cnt <= last_row_c_cnt+1;
            end
            if(row_last_col)begin
                if(ofm_cnt == ofm_channel -1) ofm_cnt<=0;
                else ofm_cnt<=ofm_cnt+1;
            end
        end
    end
    reg [1:0]save_remain_13;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            remain <=2;
            remain_13 <=3;
            save_remain_13<=2;
        end else begin
            case(ifm_width)
                13:begin
                    if(last_col & h_cnt ==12)begin
                        remain_13 <=3;
                        save_remain_13<=2;
                    end else if(last_col)begin
                        if(conv3_row1)begin
                            remain_13 <= save_remain_13 -1;
                            save_remain_13 <= save_remain_13 -2;
                        end else begin
                            remain_13 <= save_remain_13;
                            save_remain_13 <= save_remain_13 -1;
                        end
                    end else if(temp_hs)begin
                        remain_13 <= remain_13 -1;
                    end
                end
                26:begin
                    if(last_col &h_cnt[0] == 0 & !conv3_row1)begin
                        remain <=0;
                    end else if(last_col & &h_cnt[0] == 1)begin
                        remain <=2;
                    end
                end
                default:begin
                    if(last_col & w_cnt == w_finish_cnt)begin
                        remain <=2;
                    end else if(c_cnt == ifm_channel-1 & w_cnt == w_finish_cnt -1 & temp_hs)begin
                        remain <=0;
                    end else if(c_cnt == ifm_channel-1 & temp_hs)begin
                        remain <= remain -1;
                    end
                end
            endcase
        end
    end
    
endmodule
