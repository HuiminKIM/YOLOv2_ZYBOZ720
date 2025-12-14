`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/05 19:15:02
// Design Name: 
// Module Name: cnn_conv
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


module CNN_Conv_3x3 #
(parameter Convolution_Width = 16, Convolution_Out_Width = 32)
(
	clk, rst_n, conv3_valid, conv1_valid, conv_shift, ifm_channel,
	
	conv3_ifm_0,  conv3_ifm_1,  conv3_ifm_2,  conv3_ifm_3,  conv3_ifm_4,  conv3_ifm_5,  conv3_ifm_6,  conv3_ifm_7,  conv3_ifm_8,  conv3_ifm_9,  conv3_ifm_10,  conv3_ifm_11,  conv3_ifm_12,  conv3_ifm_13,  conv3_ifm_14,
    conv3_ifm_15, conv3_ifm_16, conv3_ifm_17, conv3_ifm_18, conv3_ifm_19, conv3_ifm_20, conv3_ifm_21, conv3_ifm_22, conv3_ifm_23, conv3_ifm_24, conv3_ifm_25, conv3_ifm_26, conv3_ifm_27, conv3_ifm_28, conv3_ifm_29,
    conv3_ifm_30, conv3_ifm_31, conv3_ifm_32, conv3_ifm_33, conv3_ifm_34, conv3_ifm_35, conv3_ifm_36, conv3_ifm_37, conv3_ifm_38, conv3_ifm_39, conv3_ifm_40, conv3_ifm_41, conv3_ifm_42, conv3_ifm_43, conv3_ifm_44,
	
	conv3_weight_0, conv3_weight_1, conv3_weight_2,
    conv3_weight_3, conv3_weight_4, conv3_weight_5, 
    conv3_weight_6, conv3_weight_7, conv3_weight_8,
    
    conv1_ifm_0,  conv1_ifm_1,  conv1_ifm_2,  conv1_ifm_3,  conv1_ifm_4,  conv1_ifm_5,  conv1_ifm_6,  conv1_ifm_7,  conv1_ifm_8,  conv1_ifm_9, conv1_ifm_10,  conv1_ifm_11, conv1_ifm_12,
    conv1_weight,
	bias_data, bias_shift,
	
	conv_out_0, conv_out_1, conv_out_2, conv_out_3, conv_out_4,
	conv_out_5, conv_out_6, conv_out_7, conv_out_8, conv_out_9,
	conv_out_10, conv_out_11, conv_out_12,
    conv_valid, conv_end
);
input clk, rst_n;
input conv3_valid, conv1_valid; //Get the images and weight data
input [4:0] conv_shift,bias_shift; //Get the images shift data
input [10:0] ifm_channel; //Number of channels to perform the operation
input signed [Convolution_Width -1:0] 	conv3_ifm_0,  conv3_ifm_1,  conv3_ifm_2,  conv3_ifm_3,  conv3_ifm_4,  conv3_ifm_5,  conv3_ifm_6,  conv3_ifm_7,  conv3_ifm_8,  conv3_ifm_9,  conv3_ifm_10,  conv3_ifm_11,  conv3_ifm_12,  conv3_ifm_13,  conv3_ifm_14,
                                        conv3_ifm_15, conv3_ifm_16, conv3_ifm_17, conv3_ifm_18, conv3_ifm_19, conv3_ifm_20, conv3_ifm_21, conv3_ifm_22, conv3_ifm_23, conv3_ifm_24, conv3_ifm_25, conv3_ifm_26, conv3_ifm_27, conv3_ifm_28, conv3_ifm_29,
                                        conv3_ifm_30, conv3_ifm_31, conv3_ifm_32, conv3_ifm_33, conv3_ifm_34, conv3_ifm_35, conv3_ifm_36, conv3_ifm_37, conv3_ifm_38, conv3_ifm_39, conv3_ifm_40, conv3_ifm_41, conv3_ifm_42, conv3_ifm_43, conv3_ifm_44,
	                                    
	                                    conv3_weight_0, conv3_weight_1, conv3_weight_2,
                                        conv3_weight_3, conv3_weight_4, conv3_weight_5, 
                                        conv3_weight_6, conv3_weight_7, conv3_weight_8,
                                        
                                        conv1_ifm_0,  conv1_ifm_1,  conv1_ifm_2,  conv1_ifm_3,  conv1_ifm_4,  conv1_ifm_5,  conv1_ifm_6,  conv1_ifm_7,  conv1_ifm_8,  conv1_ifm_9, conv1_ifm_10,  conv1_ifm_11, conv1_ifm_12,
                                        conv1_weight,
                                        
                                        bias_data;

output reg conv_valid, conv_end;

output reg signed [Convolution_Out_Width -1:0] conv_out_0, conv_out_1, conv_out_2, conv_out_3,
                                               conv_out_4, conv_out_5, conv_out_6, conv_out_7,
                                               conv_out_8, conv_out_9, conv_out_10, conv_out_11, conv_out_12;

reg signed [Convolution_Out_Width -1:0] shifted_bias_data;

reg signed [Convolution_Out_Width - 1:0] conv_cal_0, conv_cal_1, conv_cal_2, conv_cal_3,
                                        conv_cal_4, conv_cal_5, conv_cal_6, conv_cal_7,
                                        conv_cal_8, conv_cal_9, conv_cal_10, conv_cal_11, conv_cal_12;
                                        
reg signed [Convolution_Out_Width -1:0] conv_cal_0_0, conv_cal_0_1, conv_cal_0_2, conv_cal_0_3, conv_cal_0_4, conv_cal_0_5, conv_cal_0_6, conv_cal_0_7, conv_cal_0_8,
                                        conv_cal_1_0, conv_cal_1_1, conv_cal_1_2, conv_cal_1_3, conv_cal_1_4, conv_cal_1_5, conv_cal_1_6, conv_cal_1_7, conv_cal_1_8,
                                        conv_cal_2_0, conv_cal_2_1, conv_cal_2_2, conv_cal_2_3, conv_cal_2_4, conv_cal_2_5, conv_cal_2_6, conv_cal_2_7, conv_cal_2_8,
                                        conv_cal_3_0, conv_cal_3_1, conv_cal_3_2, conv_cal_3_3, conv_cal_3_4, conv_cal_3_5, conv_cal_3_6, conv_cal_3_7, conv_cal_3_8,
                                        conv_cal_4_0, conv_cal_4_1, conv_cal_4_2, conv_cal_4_3, conv_cal_4_4, conv_cal_4_5, conv_cal_4_6, conv_cal_4_7, conv_cal_4_8,
                                        conv_cal_5_0, conv_cal_5_1, conv_cal_5_2, conv_cal_5_3, conv_cal_5_4, conv_cal_5_5, conv_cal_5_6, conv_cal_5_7, conv_cal_5_8,
                                        conv_cal_6_0, conv_cal_6_1, conv_cal_6_2, conv_cal_6_3, conv_cal_6_4, conv_cal_6_5, conv_cal_6_6, conv_cal_6_7, conv_cal_6_8,
                                        conv_cal_7_0, conv_cal_7_1, conv_cal_7_2, conv_cal_7_3, conv_cal_7_4, conv_cal_7_5, conv_cal_7_6, conv_cal_7_7, conv_cal_7_8,
                                        conv_cal_8_0, conv_cal_8_1, conv_cal_8_2, conv_cal_8_3, conv_cal_8_4, conv_cal_8_5, conv_cal_8_6, conv_cal_8_7, conv_cal_8_8,
                                        conv_cal_9_0, conv_cal_9_1, conv_cal_9_2, conv_cal_9_3, conv_cal_9_4, conv_cal_9_5, conv_cal_9_6, conv_cal_9_7, conv_cal_9_8,
                                        conv_cal_10_0, conv_cal_10_1, conv_cal_10_2, conv_cal_10_3, conv_cal_10_4, conv_cal_10_5, conv_cal_10_6, conv_cal_10_7, conv_cal_10_8,
                                        conv_cal_11_0, conv_cal_11_1, conv_cal_11_2, conv_cal_11_3, conv_cal_11_4, conv_cal_11_5, conv_cal_11_6, conv_cal_11_7, conv_cal_11_8,
                                        conv_cal_12_0, conv_cal_12_1, conv_cal_12_2, conv_cal_12_3, conv_cal_12_4, conv_cal_12_5, conv_cal_12_6, conv_cal_12_7, conv_cal_12_8;
                                        

reg signed [63:0] buf_conv_cal_0_0, buf_conv_cal_0_1, buf_conv_cal_0_2,
                                         buf_conv_cal_1_0, buf_conv_cal_1_1, buf_conv_cal_1_2,
                                         buf_conv_cal_2_0, buf_conv_cal_2_1, buf_conv_cal_2_2,
                                         buf_conv_cal_3_0, buf_conv_cal_3_1, buf_conv_cal_3_2,
                                         buf_conv_cal_4_0, buf_conv_cal_4_1, buf_conv_cal_4_2,
                                         buf_conv_cal_5_0, buf_conv_cal_5_1, buf_conv_cal_5_2,
                                         buf_conv_cal_6_0, buf_conv_cal_6_1, buf_conv_cal_6_2,
                                         buf_conv_cal_7_0, buf_conv_cal_7_1, buf_conv_cal_7_2,
                                         buf_conv_cal_8_0, buf_conv_cal_8_1, buf_conv_cal_8_2,
                                         buf_conv_cal_9_0, buf_conv_cal_9_1, buf_conv_cal_9_2,
                                         buf_conv_cal_10_0, buf_conv_cal_10_1, buf_conv_cal_10_2,
                                         buf_conv_cal_11_0, buf_conv_cal_11_1, buf_conv_cal_11_2,
                                         buf_conv_cal_12_0, buf_conv_cal_12_1, buf_conv_cal_12_2;


reg signed [63:0] conv_mem_0, conv_mem_1, conv_mem_2, conv_mem_3,
                                        conv_mem_4, conv_mem_5, conv_mem_6, conv_mem_7,
                                        conv_mem_8, conv_mem_9, conv_mem_10, conv_mem_11, conv_mem_12;
                                        
reg signed [63:0] save_conv_mem_0, save_conv_mem_1, save_conv_mem_2, save_conv_mem_3,
                                        save_conv_mem_4, save_conv_mem_5, save_conv_mem_6, save_conv_mem_7,
                                        save_conv_mem_8, save_conv_mem_9, save_conv_mem_10, save_conv_mem_11, save_conv_mem_12;
                                        
reg [10:0] conv_end_cnt;


reg buf_conv_cal_valid;
reg buf_buf_conv_cal_valid;
reg buf_buf_buf_conv_cal_valid;

always@(posedge clk)begin
    if(!rst_n)begin
        shifted_bias_data <= 0;
        buf_conv_cal_valid <= 0;
        buf_buf_conv_cal_valid <= 0;
        buf_buf_buf_conv_cal_valid <= 0;
        conv_cal_0  <= 0;
        conv_cal_1  <= 0;
        conv_cal_2  <= 0;
        conv_cal_3  <= 0;
        conv_cal_4  <= 0;
        conv_cal_5  <= 0;
        conv_cal_6  <= 0;
        conv_cal_7  <= 0;
        conv_cal_8  <= 0;
        conv_cal_9  <= 0;
        conv_cal_10 <= 0;
        conv_cal_11 <= 0;
        conv_cal_12 <= 0;
        conv_end_cnt <= 0;
        conv_end <= 0;
        save_conv_mem_0 <= 0;
        save_conv_mem_1 <= 0;
        save_conv_mem_2 <= 0;
        save_conv_mem_3 <= 0;
        save_conv_mem_4 <= 0;
        save_conv_mem_5 <= 0;
        save_conv_mem_6 <= 0;
        save_conv_mem_7 <= 0;
        save_conv_mem_8 <= 0;
        save_conv_mem_9 <= 0;
        save_conv_mem_10 <= 0;
        save_conv_mem_11 <= 0;
        save_conv_mem_12 <= 0;
        conv_mem_0 <= 0;
        conv_mem_1 <= 0;
        conv_mem_2 <= 0;
        conv_mem_3 <= 0;
        conv_mem_4 <= 0;
        conv_mem_5 <= 0;
        conv_mem_6 <= 0;
        conv_mem_7 <= 0;
        conv_mem_8 <= 0;
        conv_mem_9 <= 0;
        conv_mem_10 <= 0;
        conv_mem_11 <= 0;
        conv_mem_12 <= 0;
        conv_valid <= 0;
        conv_out_0 <= 0;
        conv_out_1 <= 0;
        conv_out_2 <= 0;
        conv_out_3 <= 0;
        conv_out_4 <= 0;
        conv_out_5 <= 0;
        conv_out_6 <= 0;
        conv_out_7 <= 0;
        conv_out_8 <= 0;
        conv_out_9 <= 0;
        conv_out_10 <= 0;
        conv_out_11 <= 0;
        conv_out_12 <= 0;
    end else begin
        buf_conv_cal_valid <= (conv3_valid || conv1_valid);
        buf_buf_conv_cal_valid <= buf_conv_cal_valid;
        buf_buf_buf_conv_cal_valid <= buf_buf_conv_cal_valid;
        if(conv3_valid)begin
            conv_cal_0_0 <= conv3_ifm_0 * conv3_weight_0;
            conv_cal_0_1 <= conv3_ifm_1 * conv3_weight_1;
            conv_cal_0_2 <= conv3_ifm_2 * conv3_weight_2;
            conv_cal_0_3 <= conv3_ifm_15 * conv3_weight_3;
            conv_cal_0_4 <= conv3_ifm_16 * conv3_weight_4;
            conv_cal_0_5 <= conv3_ifm_17 * conv3_weight_5;
            conv_cal_0_6 <= conv3_ifm_30 * conv3_weight_6;
            conv_cal_0_7 <= conv3_ifm_31 * conv3_weight_7;
            conv_cal_0_8 <= conv3_ifm_32 * conv3_weight_8;
            
            conv_cal_1_0 <=  conv3_ifm_1 * conv3_weight_0;
            conv_cal_1_1 <=  conv3_ifm_2 * conv3_weight_1;
            conv_cal_1_2 <=  conv3_ifm_3 * conv3_weight_2;
            conv_cal_1_3 <=  conv3_ifm_16 * conv3_weight_3;
            conv_cal_1_4 <=  conv3_ifm_17 * conv3_weight_4;
            conv_cal_1_5 <=  conv3_ifm_18 * conv3_weight_5;
            conv_cal_1_6 <=  conv3_ifm_31 * conv3_weight_6;
            conv_cal_1_7 <=  conv3_ifm_32 * conv3_weight_7;
            conv_cal_1_8 <=  conv3_ifm_33 * conv3_weight_8;
            
            conv_cal_2_0 <=  conv3_ifm_2 * conv3_weight_0;
            conv_cal_2_1 <=  conv3_ifm_3 * conv3_weight_1;
            conv_cal_2_2 <=  conv3_ifm_4 * conv3_weight_2;
            conv_cal_2_3 <=  conv3_ifm_17 * conv3_weight_3;
            conv_cal_2_4 <=  conv3_ifm_18 * conv3_weight_4;
            conv_cal_2_5 <=  conv3_ifm_19 * conv3_weight_5;
            conv_cal_2_6 <=  conv3_ifm_32 * conv3_weight_6;
            conv_cal_2_7 <=  conv3_ifm_33 * conv3_weight_7;
            conv_cal_2_8 <=  conv3_ifm_34 * conv3_weight_8;
            
            conv_cal_3_0 <=  conv3_ifm_3 * conv3_weight_0;
            conv_cal_3_1 <=  conv3_ifm_4 * conv3_weight_1;
            conv_cal_3_2 <=  conv3_ifm_5 * conv3_weight_2;
            conv_cal_3_3 <=  conv3_ifm_18 * conv3_weight_3;
            conv_cal_3_4 <=  conv3_ifm_19 * conv3_weight_4;
            conv_cal_3_5 <=  conv3_ifm_20 * conv3_weight_5;
            conv_cal_3_6 <=  conv3_ifm_33 * conv3_weight_6;
            conv_cal_3_7 <=  conv3_ifm_34 * conv3_weight_7;
            conv_cal_3_8 <=  conv3_ifm_35 * conv3_weight_8;
            
            conv_cal_4_0 <=  conv3_ifm_4 * conv3_weight_0;
            conv_cal_4_1 <=  conv3_ifm_5 * conv3_weight_1;
            conv_cal_4_2 <=  conv3_ifm_6 * conv3_weight_2;
            conv_cal_4_3 <=  conv3_ifm_19 * conv3_weight_3;
            conv_cal_4_4 <=  conv3_ifm_20 * conv3_weight_4;
            conv_cal_4_5 <=  conv3_ifm_21 * conv3_weight_5;
            conv_cal_4_6 <=  conv3_ifm_34 * conv3_weight_6;
            conv_cal_4_7 <=  conv3_ifm_35 * conv3_weight_7;
            conv_cal_4_8 <=  conv3_ifm_36 * conv3_weight_8;
            
            conv_cal_5_0 <=  conv3_ifm_5 * conv3_weight_0;
            conv_cal_5_1 <=  conv3_ifm_6 * conv3_weight_1;
            conv_cal_5_2 <=  conv3_ifm_7 * conv3_weight_2;
            conv_cal_5_3 <=  conv3_ifm_20 * conv3_weight_3;
            conv_cal_5_4 <=  conv3_ifm_21 * conv3_weight_4;
            conv_cal_5_5 <=  conv3_ifm_22 * conv3_weight_5;
            conv_cal_5_6 <=  conv3_ifm_35 * conv3_weight_6;
            conv_cal_5_7 <=  conv3_ifm_36 * conv3_weight_7;
            conv_cal_5_8 <=  conv3_ifm_37 * conv3_weight_8;
            
            conv_cal_6_0 <=  conv3_ifm_6 * conv3_weight_0;
            conv_cal_6_1 <=  conv3_ifm_7 * conv3_weight_1;
            conv_cal_6_2 <=  conv3_ifm_8 * conv3_weight_2;
            conv_cal_6_3 <=  conv3_ifm_21 * conv3_weight_3;
            conv_cal_6_4 <=  conv3_ifm_22 * conv3_weight_4;
            conv_cal_6_5 <=  conv3_ifm_23 * conv3_weight_5;
            conv_cal_6_6 <=  conv3_ifm_36 * conv3_weight_6;
            conv_cal_6_7 <=  conv3_ifm_37 * conv3_weight_7;
            conv_cal_6_8 <=  conv3_ifm_38 * conv3_weight_8;
            
            conv_cal_7_0 <=  conv3_ifm_7 * conv3_weight_0;
            conv_cal_7_1 <=  conv3_ifm_8 * conv3_weight_1;
            conv_cal_7_2 <=  conv3_ifm_9 * conv3_weight_2;
            conv_cal_7_3 <=  conv3_ifm_22 * conv3_weight_3;
            conv_cal_7_4 <=  conv3_ifm_23 * conv3_weight_4;
            conv_cal_7_5 <=  conv3_ifm_24 * conv3_weight_5;
            conv_cal_7_6 <=  conv3_ifm_37 * conv3_weight_6;
            conv_cal_7_7 <=  conv3_ifm_38 * conv3_weight_7;
            conv_cal_7_8 <=  conv3_ifm_39 * conv3_weight_8;
            
            conv_cal_8_0 <=  conv3_ifm_8 * conv3_weight_0;
            conv_cal_8_1 <=  conv3_ifm_9 * conv3_weight_1;
            conv_cal_8_2 <=  conv3_ifm_10 * conv3_weight_2;
            conv_cal_8_3 <=  conv3_ifm_23 * conv3_weight_3;
            conv_cal_8_4 <=  conv3_ifm_24 * conv3_weight_4;
            conv_cal_8_5 <=  conv3_ifm_25 * conv3_weight_5;
            conv_cal_8_6 <=  conv3_ifm_38 * conv3_weight_6;
            conv_cal_8_7 <=  conv3_ifm_39 * conv3_weight_7;
            conv_cal_8_8 <=  conv3_ifm_40 * conv3_weight_8;
            
            conv_cal_9_0 <=  conv3_ifm_9 * conv3_weight_0;
            conv_cal_9_1 <=  conv3_ifm_10 * conv3_weight_1;
            conv_cal_9_2 <=  conv3_ifm_11 * conv3_weight_2;
            conv_cal_9_3 <=  conv3_ifm_24 * conv3_weight_3;
            conv_cal_9_4 <=  conv3_ifm_25 * conv3_weight_4;
            conv_cal_9_5 <=  conv3_ifm_26 * conv3_weight_5;
            conv_cal_9_6 <=  conv3_ifm_39 * conv3_weight_6;
            conv_cal_9_7 <=  conv3_ifm_40 * conv3_weight_7;
            conv_cal_9_8 <=  conv3_ifm_41 * conv3_weight_8;
            
            conv_cal_10_0 <=  conv3_ifm_10 * conv3_weight_0;
            conv_cal_10_1 <=  conv3_ifm_11 * conv3_weight_1;
            conv_cal_10_2 <=  conv3_ifm_12 * conv3_weight_2;
            conv_cal_10_3 <=  conv3_ifm_25 * conv3_weight_3;
            conv_cal_10_4 <=  conv3_ifm_26 * conv3_weight_4;
            conv_cal_10_5 <=  conv3_ifm_27 * conv3_weight_5;
            conv_cal_10_6 <=  conv3_ifm_40 * conv3_weight_6;
            conv_cal_10_7 <=  conv3_ifm_41 * conv3_weight_7;
            conv_cal_10_8 <=  conv3_ifm_42 * conv3_weight_8;
            
            conv_cal_11_0 <=  conv3_ifm_11 * conv3_weight_0;
            conv_cal_11_1 <=  conv3_ifm_12 * conv3_weight_1;
            conv_cal_11_2 <=  conv3_ifm_13 * conv3_weight_2;
            conv_cal_11_3 <=  conv3_ifm_26 * conv3_weight_3;
            conv_cal_11_4 <=  conv3_ifm_27 * conv3_weight_4;
            conv_cal_11_5 <=  conv3_ifm_28 * conv3_weight_5;
            conv_cal_11_6 <=  conv3_ifm_41 * conv3_weight_6;
            conv_cal_11_7 <=  conv3_ifm_42 * conv3_weight_7;
            conv_cal_11_8 <=  conv3_ifm_43 * conv3_weight_8;
            
            conv_cal_12_0 <=  conv3_ifm_12 * conv3_weight_0;
            conv_cal_12_1 <=  conv3_ifm_13 * conv3_weight_1;
            conv_cal_12_2 <=  conv3_ifm_14 * conv3_weight_2;
            conv_cal_12_3 <=  conv3_ifm_27 * conv3_weight_3;
            conv_cal_12_4 <=  conv3_ifm_28 * conv3_weight_4;
            conv_cal_12_5 <=  conv3_ifm_29 * conv3_weight_5;
            conv_cal_12_6 <=  conv3_ifm_42 * conv3_weight_6;
            conv_cal_12_7 <=  conv3_ifm_43 * conv3_weight_7;
            conv_cal_12_8 <=  conv3_ifm_44 * conv3_weight_8;
            
        end else if(conv1_valid) begin
            conv_cal_0_0  <= conv1_ifm_0 * conv1_weight;
            conv_cal_0_1  <= 0;
            conv_cal_0_2 <=  0;
            conv_cal_0_3 <=  0;
            conv_cal_0_4 <=  0;
            conv_cal_0_5 <=  0;
            conv_cal_0_6 <=  0;
            conv_cal_0_7 <=  0;
            conv_cal_0_8 <=  0;
            conv_cal_1_0  <= conv1_ifm_1 * conv1_weight;
            conv_cal_1_1  <= 0;
            conv_cal_1_2 <=  0;
            conv_cal_1_3 <=  0;
            conv_cal_1_4 <=  0;
            conv_cal_1_5 <=  0;
            conv_cal_1_6 <=  0;
            conv_cal_1_7 <=  0;
            conv_cal_1_8 <=  0;
            conv_cal_2_0  <= conv1_ifm_2 * conv1_weight;
            conv_cal_2_1  <= 0;
            conv_cal_2_2 <=  0;
            conv_cal_2_3 <=  0;
            conv_cal_2_4 <=  0;
            conv_cal_2_5 <=  0;
            conv_cal_2_6 <=  0;
            conv_cal_2_7 <=  0;
            conv_cal_2_8 <=  0;
            conv_cal_3_0  <= conv1_ifm_3 * conv1_weight;
            conv_cal_3_1  <= 0;
            conv_cal_3_2 <=  0;
            conv_cal_3_3 <=  0;
            conv_cal_3_4 <=  0;
            conv_cal_3_5 <=  0;
            conv_cal_3_6 <=  0;
            conv_cal_3_7 <=  0;
            conv_cal_3_8 <=  0;
            conv_cal_4_0  <= conv1_ifm_4 * conv1_weight;
            conv_cal_4_1  <= 0;
            conv_cal_4_2 <=  0;
            conv_cal_4_3 <=  0;
            conv_cal_4_4 <=  0;
            conv_cal_4_5 <=  0;
            conv_cal_4_6 <=  0;
            conv_cal_4_7 <=  0;
            conv_cal_4_8 <= 0;
            conv_cal_5_0  <= conv1_ifm_5 * conv1_weight;
            conv_cal_5_1  <= 0;
            conv_cal_5_2 <=  0;
            conv_cal_5_3 <=  0;
            conv_cal_5_4 <=  0;
            conv_cal_5_5 <=  0;
            conv_cal_5_6 <=  0;
            conv_cal_5_7 <=  0;
            conv_cal_5_8 <=  0;
            conv_cal_6_0  <= conv1_ifm_6 * conv1_weight;
            conv_cal_6_1  <= 0;
            conv_cal_6_2 <=  0;
            conv_cal_6_3 <=  0;
            conv_cal_6_4 <=  0;
            conv_cal_6_5 <=  0;
            conv_cal_6_6 <=  0;
            conv_cal_6_7 <=  0;
            conv_cal_6_8 <=  0;
            conv_cal_7_0  <= conv1_ifm_7 * conv1_weight;
            conv_cal_7_1  <= 0;
            conv_cal_7_2 <=  0;
            conv_cal_7_3 <=  0;
            conv_cal_7_4 <=  0;
            conv_cal_7_5 <=  0;
            conv_cal_7_6 <=  0;
            conv_cal_7_7 <=  0;
            conv_cal_7_8 <=  0;
            conv_cal_8_0  <= conv1_ifm_8 * conv1_weight;
            conv_cal_8_1  <= 0;
            conv_cal_8_2 <=  0;
            conv_cal_8_3 <=  0;
            conv_cal_8_4 <=  0;
            conv_cal_8_5 <=  0;
            conv_cal_8_6 <=  0;
            conv_cal_8_7 <=  0;
            conv_cal_8_8 <=  0;
            conv_cal_9_0  <= conv1_ifm_9 * conv1_weight;
            conv_cal_9_1  <= 0;
            conv_cal_9_2 <=  0;
            conv_cal_9_3 <=  0;
            conv_cal_9_4 <=  0;
            conv_cal_9_5 <=  0;
            conv_cal_9_6 <=  0;
            conv_cal_9_7 <=  0;
            conv_cal_9_8 <=  0;
            conv_cal_10_0 <= conv1_ifm_10 * conv1_weight;
            conv_cal_10_1  <= 0;
            conv_cal_10_2 <=  0;
            conv_cal_10_3 <=  0;
            conv_cal_10_4 <=  0;
            conv_cal_10_5 <=  0;
            conv_cal_10_6 <=  0;
            conv_cal_10_7 <=  0;
            conv_cal_10_8 <= 0;
            conv_cal_11_0 <= conv1_ifm_11 * conv1_weight;
            conv_cal_11_1  <= 0;
            conv_cal_11_2 <=  0;
            conv_cal_11_3 <=  0;
            conv_cal_11_4 <=  0;
            conv_cal_11_5 <=  0;
            conv_cal_11_6 <=  0;
            conv_cal_11_7 <=  0;
            conv_cal_11_8 <=  0;
            conv_cal_12_0 <= conv1_ifm_12 * conv1_weight;
            conv_cal_12_1  <= 0;
            conv_cal_12_2 <=  0;
            conv_cal_12_3 <=  0;
            conv_cal_12_4 <=  0;
            conv_cal_12_5 <=  0;
            conv_cal_12_6 <=  0;
            conv_cal_12_7 <=  0;
            conv_cal_12_8 <=  0;
        end
        
        buf_conv_cal_0_0 <= conv_cal_0_0 + conv_cal_0_1 + conv_cal_0_2;
        buf_conv_cal_0_1 <= conv_cal_0_3 + conv_cal_0_4 + conv_cal_0_5;
        buf_conv_cal_0_2 <= conv_cal_0_6 + conv_cal_0_7 + conv_cal_0_8;
        
        buf_conv_cal_1_0 <= conv_cal_1_0 + conv_cal_1_1 + conv_cal_1_2;
        buf_conv_cal_1_1 <= conv_cal_1_3 + conv_cal_1_4 + conv_cal_1_5;
        buf_conv_cal_1_2 <= conv_cal_1_6 + conv_cal_1_7 + conv_cal_1_8;
        
        buf_conv_cal_2_0 <= conv_cal_2_0 + conv_cal_2_1 + conv_cal_2_2;
        buf_conv_cal_2_1 <= conv_cal_2_3 + conv_cal_2_4 + conv_cal_2_5;
        buf_conv_cal_2_2 <= conv_cal_2_6 + conv_cal_2_7 + conv_cal_2_8;
        
        buf_conv_cal_3_0 <= conv_cal_3_0 + conv_cal_3_1 + conv_cal_3_2;
        buf_conv_cal_3_1 <= conv_cal_3_3 + conv_cal_3_4 + conv_cal_3_5;
        buf_conv_cal_3_2 <= conv_cal_3_6 + conv_cal_3_7 + conv_cal_3_8;
        
        buf_conv_cal_4_0 <= conv_cal_4_0 + conv_cal_4_1 + conv_cal_4_2;
        buf_conv_cal_4_1 <= conv_cal_4_3 + conv_cal_4_4 + conv_cal_4_5;
        buf_conv_cal_4_2 <= conv_cal_4_6 + conv_cal_4_7 + conv_cal_4_8;
        
        buf_conv_cal_5_0 <= conv_cal_5_0 + conv_cal_5_1 + conv_cal_5_2;
        buf_conv_cal_5_1 <= conv_cal_5_3 + conv_cal_5_4 + conv_cal_5_5;
        buf_conv_cal_5_2 <= conv_cal_5_6 + conv_cal_5_7 + conv_cal_5_8;
        
        buf_conv_cal_6_0 <= conv_cal_6_0 + conv_cal_6_1 + conv_cal_6_2;
        buf_conv_cal_6_1 <= conv_cal_6_3 + conv_cal_6_4 + conv_cal_6_5;
        buf_conv_cal_6_2 <= conv_cal_6_6 + conv_cal_6_7 + conv_cal_6_8;
        
        buf_conv_cal_7_0 <= conv_cal_7_0 + conv_cal_7_1 + conv_cal_7_2;
        buf_conv_cal_7_1 <= conv_cal_7_3 + conv_cal_7_4 + conv_cal_7_5;
        buf_conv_cal_7_2 <= conv_cal_7_6 + conv_cal_7_7 + conv_cal_7_8;
        
        buf_conv_cal_8_0 <= conv_cal_8_0 + conv_cal_8_1 + conv_cal_8_2;
        buf_conv_cal_8_1 <= conv_cal_8_3 + conv_cal_8_4 + conv_cal_8_5;
        buf_conv_cal_8_2 <= conv_cal_8_6 + conv_cal_8_7 + conv_cal_8_8;
        
        buf_conv_cal_9_0 <= conv_cal_9_0 + conv_cal_9_1 + conv_cal_9_2;
        buf_conv_cal_9_1 <= conv_cal_9_3 + conv_cal_9_4 + conv_cal_9_5;
        buf_conv_cal_9_2 <= conv_cal_9_6 + conv_cal_9_7 + conv_cal_9_8;
        
        buf_conv_cal_10_0 <= conv_cal_10_0 + conv_cal_10_1 + conv_cal_10_2;
        buf_conv_cal_10_1 <= conv_cal_10_3 + conv_cal_10_4 + conv_cal_10_5;
        buf_conv_cal_10_2 <= conv_cal_10_6 + conv_cal_10_7 + conv_cal_10_8;
        
        buf_conv_cal_11_0 <= conv_cal_11_0 + conv_cal_11_1 + conv_cal_11_2;
        buf_conv_cal_11_1 <= conv_cal_11_3 + conv_cal_11_4 + conv_cal_11_5;
        buf_conv_cal_11_2 <= conv_cal_11_6 + conv_cal_11_7 + conv_cal_11_8;
        
        buf_conv_cal_12_0 <= conv_cal_12_0 + conv_cal_12_1 + conv_cal_12_2;
        buf_conv_cal_12_1 <= conv_cal_12_3 + conv_cal_12_4 + conv_cal_12_5;
        buf_conv_cal_12_2 <= conv_cal_12_6 + conv_cal_12_7 + conv_cal_12_8;
        
        conv_cal_0 <= buf_conv_cal_0_0 + buf_conv_cal_0_1 + buf_conv_cal_0_2;
        conv_cal_1 <= buf_conv_cal_1_0 + buf_conv_cal_1_1 + buf_conv_cal_1_2;
        conv_cal_2 <= buf_conv_cal_2_0 + buf_conv_cal_2_1 + buf_conv_cal_2_2;
        conv_cal_3 <= buf_conv_cal_3_0 + buf_conv_cal_3_1 + buf_conv_cal_3_2;
        conv_cal_4 <= buf_conv_cal_4_0 + buf_conv_cal_4_1 + buf_conv_cal_4_2;
        conv_cal_5 <= buf_conv_cal_5_0 + buf_conv_cal_5_1 + buf_conv_cal_5_2;
        conv_cal_6 <= buf_conv_cal_6_0 + buf_conv_cal_6_1 + buf_conv_cal_6_2;
        conv_cal_7 <= buf_conv_cal_7_0 + buf_conv_cal_7_1 + buf_conv_cal_7_2;
        conv_cal_8 <= buf_conv_cal_8_0 + buf_conv_cal_8_1 + buf_conv_cal_8_2;
        conv_cal_9 <= buf_conv_cal_9_0 + buf_conv_cal_9_1 + buf_conv_cal_9_2;
        conv_cal_10 <= buf_conv_cal_10_0 + buf_conv_cal_10_1 + buf_conv_cal_10_2;
        conv_cal_11 <= buf_conv_cal_11_0 + buf_conv_cal_11_1 + buf_conv_cal_11_2;
        conv_cal_12 <= buf_conv_cal_12_0 + buf_conv_cal_12_1 + buf_conv_cal_12_2;
        
        if(buf_buf_buf_conv_cal_valid)begin
            if(conv_end_cnt == ifm_channel -1)begin
                conv_end_cnt <= 0;
                conv_end <= 1;
                save_conv_mem_0 <= conv_mem_0 + conv_cal_0;
                save_conv_mem_1 <= conv_mem_1 + conv_cal_1;
                save_conv_mem_2 <= conv_mem_2 + conv_cal_2;
                save_conv_mem_3 <= conv_mem_3 + conv_cal_3;
                save_conv_mem_4 <= conv_mem_4 + conv_cal_4;
                save_conv_mem_5 <= conv_mem_5 + conv_cal_5;
                save_conv_mem_6 <= conv_mem_6 + conv_cal_6;
                save_conv_mem_7 <= conv_mem_7 + conv_cal_7;
                save_conv_mem_8 <= conv_mem_8 + conv_cal_8;
                save_conv_mem_9 <= conv_mem_9 + conv_cal_9;
                save_conv_mem_10 <= conv_mem_10 + conv_cal_10;
                save_conv_mem_11 <= conv_mem_11 + conv_cal_11;
                save_conv_mem_12 <= conv_mem_12 + conv_cal_12;
                conv_mem_0 <= 0;
                conv_mem_1 <= 0;
                conv_mem_2 <= 0;
                conv_mem_3 <= 0;
                conv_mem_4 <= 0;
                conv_mem_5 <= 0;
                conv_mem_6 <= 0;
                conv_mem_7 <= 0;
                conv_mem_8 <= 0;
                conv_mem_9 <= 0;
                conv_mem_10 <= 0;
                conv_mem_11 <= 0;
                conv_mem_12 <= 0;
                shifted_bias_data <= (bias_data <<< bias_shift);
            end else begin
                conv_end_cnt <= conv_end_cnt + 1;
                conv_end <= 0;
                conv_mem_0 <= conv_mem_0 + conv_cal_0;
                conv_mem_1 <= conv_mem_1 + conv_cal_1;
                conv_mem_2 <= conv_mem_2 + conv_cal_2;
                conv_mem_3 <= conv_mem_3 + conv_cal_3;
                conv_mem_4 <= conv_mem_4 + conv_cal_4;
                conv_mem_5 <= conv_mem_5 + conv_cal_5;
                conv_mem_6 <= conv_mem_6 + conv_cal_6;
                conv_mem_7 <= conv_mem_7 + conv_cal_7;
                conv_mem_8 <= conv_mem_8 + conv_cal_8;
                conv_mem_9 <= conv_mem_9 + conv_cal_9;
                conv_mem_10 <= conv_mem_10 + conv_cal_10;
                conv_mem_11 <= conv_mem_11 + conv_cal_11;
                conv_mem_12 <= conv_mem_12 + conv_cal_12;
            end
        end else begin
            conv_end <= 0;
        end
        
        if(conv_end)begin
            conv_valid <= 1;
            conv_out_0 <= (save_conv_mem_0 >>> conv_shift) + shifted_bias_data;
            conv_out_1 <= (save_conv_mem_1 >>> conv_shift) + shifted_bias_data;
            conv_out_2 <= (save_conv_mem_2 >>> conv_shift) + shifted_bias_data;
            conv_out_3 <= (save_conv_mem_3 >>> conv_shift) + shifted_bias_data;
            conv_out_4 <= (save_conv_mem_4 >>> conv_shift) + shifted_bias_data;
            conv_out_5 <= (save_conv_mem_5 >>> conv_shift) + shifted_bias_data;
            conv_out_6 <= (save_conv_mem_6 >>> conv_shift) + shifted_bias_data;
            conv_out_7 <= (save_conv_mem_7 >>> conv_shift) + shifted_bias_data;
            conv_out_8 <= (save_conv_mem_8 >>> conv_shift) + shifted_bias_data;
            conv_out_9 <= (save_conv_mem_9 >>> conv_shift) + shifted_bias_data;
            conv_out_10 <= (save_conv_mem_10 >>> conv_shift) + shifted_bias_data;
            conv_out_11 <= (save_conv_mem_11 >>> conv_shift) + shifted_bias_data;
            conv_out_12 <= (save_conv_mem_12 >>> conv_shift) + shifted_bias_data;
        end else begin
            conv_valid <= 0;
        end
    end
end

endmodule
