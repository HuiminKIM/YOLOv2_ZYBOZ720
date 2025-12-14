`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2024 07:31:58 PM
// Design Name: 
// Module Name: bias_controller
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


module bias_controller(
    input clk,
    input rst_n,
    input ap_done,
    input bias_bram_full,
    output reg bias_reg_read_en,
    input [63:0] bias_reg_din,
    
    output reg [15:0]bias_data,
    output reg bias_valid,
    
    input [8:0] total_ifm,
    
    input cnn_conv_end, // maybe need buffer depend on cnn latency if cnn need 4cycle, you need to add 4 cycle buffer.
    
    output [14:0] repeat_ifm
    );
    
    
    reg buf_read_en;
    
    reg [15:0] reg_buf_bias_0 [0:3];
    reg [15:0] reg_buf_bias_1 [0:3];
    
    reg bias_0_full;
    reg bias_1_full;
    
    reg [1:0] w_cnt0;
    
    reg [1:0] w_cnt1;
    
    reg r_buf_flag;
    reg w_buf_flag;
    
    
    reg [5:0] buf_repeat_channel0;
    reg [8:0] buf_repeat_channel1;
    reg [14:0] repeat_channel;
    reg [14:0] repeat_cnt;
    
    reg next_bias;
    
    
    reg[2:0] r_save_cnt;
    reg[2:0] save_cnt;
    reg[1:0] r_cnt;
    
    assign repeat_ifm = repeat_channel;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            r_buf_flag <= 'b0;
            bias_0_full <= 'b0;
            bias_1_full <= 'b0;
            buf_read_en <= 'b0;
            buf_repeat_channel0 <= 'b0;
            buf_repeat_channel1 <= 'b0;
            repeat_channel <= 'b0;
            repeat_cnt <= 'b0;
            w_cnt0 <= 'b0;
            w_cnt1 <= 'b0;
            next_bias <= 'b0;
            r_cnt <= 'b0;
            r_save_cnt <= 'd0;
            bias_reg_read_en <= 0;
            w_buf_flag <= 'b0;
        end else begin
            if(ap_done)begin
                r_buf_flag <= 'b0;
                bias_0_full <= 'b0;
                bias_1_full <= 'b0;
                buf_read_en <= 'b0;
                buf_repeat_channel0 <= 'b0;
                buf_repeat_channel1 <= 'b0;
                repeat_channel <= 'b0;
                repeat_cnt <= 'b0;
                w_cnt0 <= 'b0;
                w_cnt1 <= 'b0;
                next_bias <= 'b0;
                r_cnt <= 'b0;
                r_save_cnt <= 'd0;
                bias_reg_read_en <= 0;
                w_buf_flag <= 'b0;
            end else begin
                if(!bias_0_full && next_bias)w_buf_flag <= 'b1;
                else if(!bias_1_full && next_bias)w_buf_flag <= 'b0;
                else w_buf_flag <= w_buf_flag;
                next_bias <= (cnn_conv_end && repeat_channel == repeat_cnt);
                case(total_ifm)
                    418:begin
                        buf_repeat_channel0<=32;
                        buf_repeat_channel1 <= (total_ifm-2);
                    end
                    210:begin 
                        buf_repeat_channel0<=16;
                        buf_repeat_channel1 <= (total_ifm-2);
                    end
                    106:begin 
                        buf_repeat_channel0<=8;
                        buf_repeat_channel1 <= (total_ifm-2);
                    end
                    104:begin 
                        buf_repeat_channel0<=8;
                        buf_repeat_channel1 <= total_ifm;
                    end
                    54: begin 
                        buf_repeat_channel0<=4;
                        buf_repeat_channel1 <= (total_ifm-2);
                    end
                    52: begin 
                        buf_repeat_channel0<=4;
                        buf_repeat_channel1 <= total_ifm;
                    end
                    28: begin 
                        buf_repeat_channel0<=2;
                        buf_repeat_channel1 <= (total_ifm-2);
                    end
                    26: begin 
                        buf_repeat_channel0<=2;
                        buf_repeat_channel1 <= total_ifm;
                    end
                    15: begin 
                        buf_repeat_channel0<=1;
                        buf_repeat_channel1 <= (total_ifm-2);
                    end
                    13: begin 
                        buf_repeat_channel0<=1;
                        buf_repeat_channel1 <= total_ifm;
                    end
                    default:begin buf_repeat_channel0<=0;
                        buf_repeat_channel1 <= 0;
                    end
                endcase
                //buf_repeat_channel0 <= (total_ifm/13);
                
                repeat_channel <=  buf_repeat_channel0 *buf_repeat_channel1-1;
    
                buf_read_en <= bias_reg_read_en;
                
                r_save_cnt <= save_cnt;
                if(save_cnt==1 || save_cnt==2) bias_reg_read_en <= 1;
                else bias_reg_read_en <=0 ;
                
                if( (r_buf_flag == 0) && !bias_0_full && buf_read_en )begin
                    r_buf_flag <= 'b1;
                    reg_buf_bias_0 [0] <= bias_reg_din[15:0];
                    reg_buf_bias_0 [1] <= bias_reg_din[31:16];
                    reg_buf_bias_0 [2] <= bias_reg_din[47:32];
                    reg_buf_bias_0 [3] <= bias_reg_din[63:48];
                    bias_0_full <= 'b1;
                end
                if( (r_buf_flag == 1) && !bias_1_full && buf_read_en )begin
                    r_buf_flag <= 'b0;
                    reg_buf_bias_1 [0] <= bias_reg_din[15:0];
                    reg_buf_bias_1 [1] <= bias_reg_din[31:16];
                    reg_buf_bias_1 [2] <= bias_reg_din[47:32];
                    reg_buf_bias_1 [3] <= bias_reg_din[63:48];
                    bias_1_full <= 'b1;
                end
                
                if( bias_0_full && w_buf_flag == 'b0 && cnn_conv_end ) begin
                    if(repeat_channel == repeat_cnt)begin
                        w_cnt0 <= w_cnt0 + 'd1;
                        repeat_cnt <= 0;
                    end else begin
                        w_cnt0 <= w_cnt0;
                        repeat_cnt <= repeat_cnt + 'd1;
                    end
                end else if (bias_1_full && w_buf_flag == 'b1 && cnn_conv_end) begin
                    if(repeat_channel == repeat_cnt)begin
                        w_cnt1 <= w_cnt1 + 'd1;
                        repeat_cnt <= 0;
                    end else begin
                        w_cnt1 <= w_cnt1;
                        repeat_cnt <= repeat_cnt + 'd1;
                    end
                end
                
                if(bias_0_full && w_buf_flag == 'b0 && cnn_conv_end && repeat_channel == repeat_cnt && w_cnt0 == 'd3)begin
                    bias_0_full <= 'b0;
                end else if(bias_1_full && w_buf_flag == 'b1 &&cnn_conv_end && repeat_channel == repeat_cnt && w_cnt1 == 'd3 )begin
                    bias_1_full <= 'b0;
                end
            end
        end
    end
    
    always@(*)begin
        if(ap_done)begin
            bias_valid = 'b0;
            save_cnt=0;
            bias_data =0;
        end else begin
            save_cnt = r_save_cnt;
            case(r_save_cnt)
                0: if(bias_bram_full) save_cnt =1;
                1: save_cnt=2;
                2: save_cnt=3;
                3: save_cnt=4;
                4: if(bias_bram_full&& (!bias_0_full || !bias_1_full)) save_cnt =2;
            endcase
            if(bias_0_full && w_buf_flag == 'b0)begin
                if(w_cnt0 == 'd0)     begin bias_data = reg_buf_bias_0 [0]; bias_valid = 'b1; end
                else if(w_cnt0 == 'd1)begin bias_data = reg_buf_bias_0 [1]; bias_valid = 'b1; end
                else if(w_cnt0 == 'd2)begin bias_data = reg_buf_bias_0 [2]; bias_valid = 'b1; end
                else                  begin bias_data = reg_buf_bias_0 [3]; bias_valid = 'b1; end
            end else if(bias_1_full && w_buf_flag == 'b1)begin
                if(w_cnt1 == 'd0)     begin bias_data = reg_buf_bias_1 [0]; bias_valid = 'b1; end
                else if(w_cnt1 == 'd1)begin bias_data = reg_buf_bias_1 [1]; bias_valid = 'b1; end
                else if(w_cnt1 == 'd2)begin bias_data = reg_buf_bias_1 [2]; bias_valid = 'b1; end
                else                  begin bias_data = reg_buf_bias_1 [3]; bias_valid = 'b1; end
            end else begin
                bias_valid = 'b0;
                bias_data = 0;
            end
        end
    end
endmodule
