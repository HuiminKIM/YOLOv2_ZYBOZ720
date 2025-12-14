`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/19 15:23:10
// Design Name: 
// Module Name: mp_pre_processing
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


module mp_pre_processing(
    input clk,
    input rst_n,
    input [8:0] ifm_width,
    input din_up_full0,
    input din_down_full0,
    input din_up_full1,
    input din_down_full1,
    input din_up_next_full0,
    input din_down_next_full0,
    input din_up_next_full1,
    input din_down_next_full1,
    output up0_valid,
    output upnext0_valid,
    output down0_valid,
    output downnext0_valid,
    output up1_valid,
    output upnext1_valid,
    output down1_valid,
    output downnext1_valid,
    input [31:0] up0_data,
    input [31:0] upnext0_data,
    input [31:0] down0_data,
    input [31:0] downnext0_data,
    input [31:0] up1_data,
    input [31:0] upnext1_data,
    input [31:0] down1_data,
    input [31:0] downnext1_data,
    output mp_valid,
    output [15:0] mp_data0,
    output [15:0] mp_data1,
    output [15:0] mp_data2,
    output [15:0] mp_data3
    );
    
    reg out_valid;
    reg [15:0] out_data0;
    reg [15:0] out_data1;
    reg [15:0] out_data2;
    reg [15:0] out_data3;
    
    assign mp_valid = out_valid;
    assign mp_data0 = out_data0;
    assign mp_data1 = out_data1;
    assign mp_data2 = out_data2;
    assign mp_data3 = out_data3;
    
    reg push_flag;
    reg buf_push_flag;
    reg [4:0]r_cnt;
    reg [4:0]r_cnt_finish;
    
    wire data_0_hs = din_up_full0 & din_down_full0 & up0_valid & down0_valid;
    wire data_next_0_hs = din_up_next_full0 & din_down_next_full0 & upnext0_valid & downnext0_valid;
    wire data_1_hs = din_up_full1 & din_down_full1 & up1_valid & down1_valid;
    wire data_next_1_hs = din_up_next_full1 & din_down_next_full1 & upnext1_valid & downnext1_valid;
    
    reg buf_data_0_hs;
    reg buf_data_next_0_hs;
    reg buf_data_1_hs;
    reg buf_data_next_1_hs;
    
    wire is_even = (r_cnt[0] == 0);
    
    assign up0_valid = (!push_flag) & (is_even) & din_down_full0;//
    assign down0_valid = (!push_flag) & (is_even)& din_down_full0;//
    assign upnext0_valid = (!push_flag) & (!is_even) & din_down_next_full0;//
    assign downnext0_valid = (!push_flag) & (!is_even)& din_down_next_full0;//
    
    assign up1_valid = (push_flag ) & (is_even)& din_down_full1;
    assign down1_valid = (push_flag) & (is_even)& din_down_full1;
    assign upnext1_valid = (push_flag) & (!is_even)& din_down_next_full1;
    assign downnext1_valid = (push_flag) & (!is_even)& din_down_next_full1;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            push_flag <=0;
            r_cnt <= 0;
            r_cnt_finish <=0;
        end else begin
            if(ifm_width == 26) r_cnt_finish<=13;
            else r_cnt_finish<=26;
            case(push_flag)
                0:begin
                    if((data_0_hs || data_next_0_hs) & r_cnt == r_cnt_finish-1)begin
                        push_flag <= 1;
                        r_cnt <=0;
                    end else if(data_0_hs || data_next_0_hs)begin
                        r_cnt <= r_cnt+1;
                    end
                end
                1:begin
                    if((data_1_hs || data_next_1_hs) & r_cnt == r_cnt_finish-1)begin
                        push_flag <= 0;
                        r_cnt <=0;
                    end else if(data_1_hs || data_next_1_hs)begin
                        r_cnt <= r_cnt+1;
                    end
                end
            endcase
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            out_valid <=0;
            out_data0 <=0;
            out_data1 <=0;
            out_data2 <=0;
            out_data3 <=0;
            buf_push_flag <= 0;
            buf_data_0_hs <= 0;
            buf_data_next_0_hs <= 0;
            buf_data_1_hs <= 0;
            buf_data_next_1_hs <= 0;
        end else begin
            buf_push_flag <= push_flag;
            buf_data_0_hs <= data_0_hs;
            buf_data_next_0_hs <= data_next_0_hs;
            buf_data_1_hs <= data_1_hs;
            buf_data_next_1_hs <= data_next_1_hs;
            case(buf_push_flag)
                0:begin
                    if(buf_data_0_hs)begin
                        out_valid <=1;
                        out_data0 <= up0_data[15:0];
                        out_data1 <= up0_data[31:16];
                        out_data2 <= down0_data[15:0];
                        out_data3 <= down0_data[31:16];
                    end else if(buf_data_next_0_hs)begin
                        out_valid <=1;
                        out_data0 <= upnext0_data[15:0];
                        out_data1 <= upnext0_data[31:16];
                        out_data2 <= downnext0_data[15:0];
                        out_data3 <= downnext0_data[31:16];
                    end else begin
                        out_valid <= 0;
                    end
                end
                1:begin
                    if(buf_data_1_hs)begin
                        out_valid <=1;
                        out_data0 <= up1_data[15:0];
                        out_data1 <= up1_data[31:16];
                        out_data2 <= down1_data[15:0];
                        out_data3 <= down1_data[31:16];
                    end else if(buf_data_next_1_hs)begin
                        out_valid <=1;
                        out_data0 <= upnext1_data[15:0];
                        out_data1 <= upnext1_data[31:16];
                        out_data2 <= downnext1_data[15:0];
                        out_data3 <= downnext1_data[31:16];
                    end else begin
                        out_valid <=0;
                    end
                end
            endcase
        end
    end
    
endmodule
