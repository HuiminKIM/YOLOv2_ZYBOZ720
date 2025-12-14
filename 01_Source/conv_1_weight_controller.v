`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/01 19:37:46
// Design Name: 
// Module Name: conv_1_weght_controller
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


module conv_1_weight_controller(
    input clk,
    input rst_n,
    input [8:0] ifm_width,
    input conv_1_ifm_weight_hs,
    output reg conv_1_weight_valid,
    output reg [15:0] conv_1_weight,
    output conv_1_bram0_valid,
    output conv_1_bram1_valid,
    input conv_1_bram0_full,
    input conv_1_bram1_full,
    input [63:0]conv_1_bram0_data,
    input [63:0]conv_1_bram1_data
    );
    
    reg pushflag;
    wire bram_hs0 = conv_1_bram0_valid & conv_1_bram0_full;
    wire bram_hs1 = conv_1_bram1_valid & conv_1_bram1_full;
    
    reg buf_bram_hs0;
    reg buf_bram_hs1;
    
    reg [63:0] weight_0;
    reg weight_0_full;
    reg buf_weight_0_full;
    reg [63:0] weight_1;
    reg weight_1_full;
    reg buf_weight_1_full;
    
    reg [17:0]conv_end_cnt;
    reg [17:0] conv_cnt;
    
    reg [1:0] w_cnt;
    
    wire conv_end =  (conv_end_cnt == conv_cnt)&((conv_1_ifm_weight_hs&!pushflag) || (conv_1_ifm_weight_hs & pushflag));
    
    assign conv_1_bram0_valid = conv_1_bram0_full &!weight_0_full;
    assign conv_1_bram1_valid = conv_1_bram1_full &!weight_1_full;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_bram_hs0 <=0;
            buf_bram_hs1 <=0;
            conv_end_cnt <=0;
            conv_cnt<=0;
        end else begin
            buf_bram_hs0 <= bram_hs0;
            buf_bram_hs1 <= bram_hs1;
            case(ifm_width)
                104:begin
                    conv_end_cnt <= 106495;
                end
                52:begin
                    conv_end_cnt <= 53247;
                end
                26:begin
                    conv_end_cnt <= 26623;
                end
                13:begin
                    conv_end_cnt <= 13311;
                end
            endcase
            if(conv_end)begin
                conv_cnt<=0;
            end else if(conv_1_ifm_weight_hs)begin
                conv_cnt<=conv_cnt+1;
            end
        end
    end
    

   
    always@(posedge clk)begin
        if(!rst_n)begin
            weight_0<=0;
            weight_1<=0;
            weight_0_full<=0;
            buf_weight_0_full<=0;
            weight_1_full<=0;
            buf_weight_1_full<=0;
            pushflag<=0;
            w_cnt<=0;
        end else begin
            if(w_cnt ==3 & !pushflag & conv_1_ifm_weight_hs)buf_weight_0_full<= 0;
            else buf_weight_0_full<= weight_0_full;
            if(w_cnt ==3 & pushflag & conv_1_ifm_weight_hs)buf_weight_1_full<= 0;
            else buf_weight_1_full<= weight_1_full;
            if(conv_1_ifm_weight_hs) w_cnt <= w_cnt +1;
            if(buf_bram_hs0)weight_0<=conv_1_bram0_data;
            if(buf_bram_hs1)weight_1<=conv_1_bram1_data;
            if(bram_hs0)begin
                weight_0_full <=1;
            end else if(w_cnt ==3 & !pushflag & conv_1_ifm_weight_hs)begin
                weight_0_full <=0;
            end
            if(bram_hs1)begin
                weight_1_full <=1;
            end else if(w_cnt ==3 & pushflag & conv_1_ifm_weight_hs)begin
                weight_1_full <=0;
            end
            case(pushflag)
                0:begin 
                    if(conv_end) pushflag<=1;
                end
                1:begin
                    if(conv_end) pushflag<=0;
                end
            endcase
        end
    end
    
    always@(*)begin
        case(pushflag)
            0:begin
                case(w_cnt)
                0:begin
                    conv_1_weight = weight_0[15:0];
                end
                1:begin
                    conv_1_weight = weight_0[31:16];
                end
                2:begin
                    conv_1_weight = weight_0[47:32];
                end
                3:begin
                    conv_1_weight = weight_0[63:48];
                end
                endcase
            end
            1:begin
                case(w_cnt)
                0:begin
                    conv_1_weight = weight_1[15:0];
                end
                1:begin
                    conv_1_weight = weight_1[31:16];
                end
                2:begin
                    conv_1_weight = weight_1[47:32];
                end
                3:begin
                    conv_1_weight = weight_1[63:48];
                end
                endcase
            end
        endcase
    end
    
    always@(*)begin
        case(pushflag)
            0:begin
                if(!buf_weight_0_full) conv_1_weight_valid = 0;
                else conv_1_weight_valid = 1;
            end
            1:begin
                if(!buf_weight_1_full) conv_1_weight_valid = 0;
                else conv_1_weight_valid = 1;
            end
        endcase
    end
endmodule
