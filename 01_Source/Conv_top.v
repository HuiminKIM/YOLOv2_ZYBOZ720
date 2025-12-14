`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/23 13:47:00
// Design Name: 
// Module Name: Conv_top
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


module Conv_top#
(parameter Convolution_Width = 16, Convolution_Out_Width = 32,
Ofm_Input_Width = 16, Ofm_Output_Width = 64)
(
	clk, rst_n, conv3_valid, conv1_valid, conv_shift,bias_shift,
	relu_shift, ifm_channel ,ofm_channel, isNL, LT_conv, mp_valid, is_mp,
	
	image_data_0, image_data_1, image_data_2, image_data_3, image_data_4, 
	image_data_5, image_data_6, image_data_7, image_data_8, image_data_9, 
	image_data_10, image_data_11, image_data_12, image_data_13, image_data_14, 
	image_data_15, image_data_16, image_data_17, image_data_18, image_data_19, 
	image_data_20, image_data_21, image_data_22, image_data_23, image_data_24, 
	image_data_25, image_data_26, image_data_27, image_data_28, image_data_29, 
	image_data_30, image_data_31, image_data_32, image_data_33, image_data_34, 
	image_data_35, image_data_36, image_data_37, image_data_38, image_data_39, 
	image_data_40, image_data_41, image_data_42, image_data_43, image_data_44, 
	
	conv1_image_data_0, conv1_image_data_1, conv1_image_data_2, conv1_image_data_3, conv1_image_data_4, 
	conv1_image_data_5, conv1_image_data_6, conv1_image_data_7, conv1_image_data_8, conv1_image_data_9, 
	conv1_image_data_10, conv1_image_data_11, conv1_image_data_12,
	
	mp_image_data_0, mp_image_data_1, mp_image_data_2, mp_image_data_3, 
	
	weight_data_0, weight_data_1, weight_data_2, weight_data_3, weight_data_4, 
	weight_data_5, weight_data_6, weight_data_7, weight_data_8, 
	conv1_weight_data,
	bias_data,
	
    ofm_buffer_data,
    conv_end,
	ofm_buffer_valid
);
input clk, rst_n;
input [10:0] ifm_channel, ofm_channel;
input conv3_valid, conv1_valid, isNL, LT_conv, mp_valid, is_mp; //Get the images and weight data
input [4:0] conv_shift, bias_shift; //Get the images shift data
input [4:0] relu_shift;
input [Convolution_Width -1:0] 	image_data_0, image_data_1, image_data_2, image_data_3, image_data_4, 
	                                    image_data_5, image_data_6, image_data_7, image_data_8, image_data_9, 
	                                    image_data_10, image_data_11, image_data_12, image_data_13, image_data_14, 
	                                    image_data_15, image_data_16, image_data_17, image_data_18, image_data_19, 
	                                    image_data_20, image_data_21, image_data_22, image_data_23, image_data_24, 
	                                    image_data_25, image_data_26, image_data_27, image_data_28, image_data_29, 
	                                    image_data_30, image_data_31, image_data_32, image_data_33, image_data_34, 
	                                    image_data_35, image_data_36, image_data_37, image_data_38, image_data_39, 
	                                    image_data_40, image_data_41, image_data_42, image_data_43, image_data_44,
	                                    
	                                    conv1_image_data_0, conv1_image_data_1, conv1_image_data_2, conv1_image_data_3, conv1_image_data_4, 
                                        conv1_image_data_5, conv1_image_data_6, conv1_image_data_7, conv1_image_data_8, conv1_image_data_9, 
                                        conv1_image_data_10, conv1_image_data_11, conv1_image_data_12,
	                                    
	                                    weight_data_0, weight_data_1, weight_data_2, weight_data_3, weight_data_4, 
	                                    weight_data_5, weight_data_6, weight_data_7, weight_data_8, conv1_weight_data, bias_data;
	                                    
input [Convolution_Width -1:0] mp_image_data_0, mp_image_data_1, mp_image_data_2, mp_image_data_3;

output conv_end, ofm_buffer_valid;

output [Ofm_Output_Width -1:0] ofm_buffer_data;

wire signed  [Convolution_Width -1:0] 	conv3_ifm_0,  conv3_ifm_1,  conv3_ifm_2,  conv3_ifm_3,  conv3_ifm_4,  conv3_ifm_5,  conv3_ifm_6,  conv3_ifm_7,  conv3_ifm_8,  conv3_ifm_9,  conv3_ifm_10,  conv3_ifm_11,  conv3_ifm_12,  conv3_ifm_13,  conv3_ifm_14,
                                        conv3_ifm_15, conv3_ifm_16, conv3_ifm_17, conv3_ifm_18, conv3_ifm_19, conv3_ifm_20, conv3_ifm_21, conv3_ifm_22, conv3_ifm_23, conv3_ifm_24, conv3_ifm_25, conv3_ifm_26, conv3_ifm_27, conv3_ifm_28, conv3_ifm_29,
                                        conv3_ifm_30, conv3_ifm_31, conv3_ifm_32, conv3_ifm_33, conv3_ifm_34, conv3_ifm_35, conv3_ifm_36, conv3_ifm_37, conv3_ifm_38, conv3_ifm_39, conv3_ifm_40, conv3_ifm_41, conv3_ifm_42, conv3_ifm_43, conv3_ifm_44,
                                        
                                        conv3_weight_0, conv3_weight_1, conv3_weight_2,
                                        conv3_weight_3, conv3_weight_4, conv3_weight_5, 
                                        conv3_weight_6, conv3_weight_7, conv3_weight_8,
                                        
                                        conv1_ifm_0,  conv1_ifm_1,  conv1_ifm_2,  conv1_ifm_3,  conv1_ifm_4,  conv1_ifm_5,  conv1_ifm_6,  conv1_ifm_7,  conv1_ifm_8,  conv1_ifm_9, conv1_ifm_10,  conv1_ifm_11, conv1_ifm_12,
                                        conv1_weight,
                                        bias,
                                        mp_data_0, mp_data_1, mp_data_2, mp_data_3;
                                        
assign  conv3_ifm_0 = $signed(image_data_0);    assign  conv3_ifm_1 = $signed(image_data_1);    assign  conv3_ifm_2 = $signed(image_data_2);    assign  conv3_ifm_3 = $signed(image_data_3);    assign  conv3_ifm_4 = $signed(image_data_4);  
assign  conv3_ifm_5 = $signed(image_data_5);    assign  conv3_ifm_6 = $signed(image_data_6);    assign  conv3_ifm_7 = $signed(image_data_7);    assign  conv3_ifm_8 = $signed(image_data_8);    assign  conv3_ifm_9 = $signed(image_data_9);  
assign  conv3_ifm_10 = $signed(image_data_10);  assign  conv3_ifm_11 = $signed(image_data_11);  assign  conv3_ifm_12 = $signed(image_data_12);  assign  conv3_ifm_13 = $signed(image_data_13);  assign  conv3_ifm_14 = $signed(image_data_14);  
assign  conv3_ifm_15 = $signed(image_data_15);  assign  conv3_ifm_16 = $signed(image_data_16);  assign  conv3_ifm_17 = $signed(image_data_17);  assign  conv3_ifm_18 = $signed(image_data_18);  assign  conv3_ifm_19 = $signed(image_data_19);  
assign  conv3_ifm_20 = $signed(image_data_20);  assign  conv3_ifm_21 = $signed(image_data_21);  assign  conv3_ifm_22 = $signed(image_data_22);  assign  conv3_ifm_23 = $signed(image_data_23);  assign  conv3_ifm_24 = $signed(image_data_24);  
assign  conv3_ifm_25 = $signed(image_data_25);  assign  conv3_ifm_26 = $signed(image_data_26);  assign  conv3_ifm_27 = $signed(image_data_27);  assign  conv3_ifm_28 = $signed(image_data_28);  assign  conv3_ifm_29 = $signed(image_data_29);  
assign  conv3_ifm_30 = $signed(image_data_30);  assign  conv3_ifm_31 = $signed(image_data_31);  assign  conv3_ifm_32 = $signed(image_data_32);  assign  conv3_ifm_33 = $signed(image_data_33);  assign  conv3_ifm_34 = $signed(image_data_34);  
assign  conv3_ifm_35 = $signed(image_data_35);  assign  conv3_ifm_36 = $signed(image_data_36);  assign  conv3_ifm_37 = $signed(image_data_37);  assign  conv3_ifm_38 = $signed(image_data_38);  assign  conv3_ifm_39 = $signed(image_data_39);  
assign  conv3_ifm_40 = $signed(image_data_40);  assign  conv3_ifm_41 = $signed(image_data_41);  assign  conv3_ifm_42 = $signed(image_data_42);  assign  conv3_ifm_43 = $signed(image_data_43);  assign  conv3_ifm_44 = $signed(image_data_44);

assign  conv1_ifm_0 = $signed(conv1_image_data_0);    assign  conv1_ifm_1 = $signed(conv1_image_data_1);    assign  conv1_ifm_2 = $signed(conv1_image_data_2);    assign  conv1_ifm_3 = $signed(conv1_image_data_3);  assign  conv1_ifm_4 = $signed(conv1_image_data_4);  
assign  conv1_ifm_5 = $signed(conv1_image_data_5);    assign  conv1_ifm_6 = $signed(conv1_image_data_6);    assign  conv1_ifm_7 = $signed(conv1_image_data_7);    assign  conv1_ifm_8 = $signed(conv1_image_data_8);  assign  conv1_ifm_9 = $signed(conv1_image_data_9);  
assign  conv1_ifm_10 = $signed(conv1_image_data_10);  assign  conv1_ifm_11 = $signed(conv1_image_data_11);  assign  conv1_ifm_12 = $signed(conv1_image_data_12);  assign  conv1_weight = $signed(conv1_weight_data);  assign  bias = $signed(bias_data);

assign conv3_weight_0 = $signed(weight_data_0); assign conv3_weight_1 = $signed(weight_data_1); assign conv3_weight_2 = $signed(weight_data_2);
assign conv3_weight_3 = $signed(weight_data_3); assign conv3_weight_4 = $signed(weight_data_4); assign conv3_weight_5 = $signed(weight_data_5);
assign conv3_weight_6 = $signed(weight_data_6); assign conv3_weight_7 = $signed(weight_data_7); assign conv3_weight_8 = $signed(weight_data_8);

assign conv1_weight = $signed(conv1_weight_data);


assign mp_data_0 = $signed(mp_image_data_0); assign mp_data_1 = $signed(mp_image_data_1); assign mp_data_2 = $signed(mp_image_data_2);  assign mp_data_3 = $signed(mp_image_data_3); 

wire signed [Convolution_Out_Width -1:0] conv_out_0, conv_out_1, conv_out_2, conv_out_3,
                                         conv_out_4, conv_out_5, conv_out_6, conv_out_7,
                                         conv_out_8, conv_out_9, conv_out_10, conv_out_11, conv_out_12;
                                         
wire signed [15:0] relu_out_0, relu_out_1, relu_out_2, relu_out_3, relu_out_4, 
                   relu_out_5, relu_out_6, relu_out_7, relu_out_8, relu_out_9, 
                   relu_out_10, relu_out_11, relu_out_12;
                   
wire signed [15:0] mp_out;
wire conv_valid, wrt_en;
wire mp_out_valid;

    CNN_Conv_3x3 Convolution_Processing_Units (
        .clk(clk), .rst_n(rst_n), .conv3_valid(conv3_valid), .conv1_valid(conv1_valid), .conv_shift(conv_shift), .ifm_channel(ifm_channel),
        
        .conv3_ifm_0(conv3_ifm_0), .conv3_ifm_1(conv3_ifm_1), .conv3_ifm_2(conv3_ifm_2), .conv3_ifm_3(conv3_ifm_3), .conv3_ifm_4(conv3_ifm_4), .conv3_ifm_5(conv3_ifm_5), .conv3_ifm_6(conv3_ifm_6), .conv3_ifm_7(conv3_ifm_7), .conv3_ifm_8(conv3_ifm_8), .conv3_ifm_9(conv3_ifm_9), .conv3_ifm_10(conv3_ifm_10), .conv3_ifm_11(conv3_ifm_11), .conv3_ifm_12(conv3_ifm_12), .conv3_ifm_13(conv3_ifm_13), .conv3_ifm_14(conv3_ifm_14), 
        .conv3_ifm_15(conv3_ifm_15), .conv3_ifm_16(conv3_ifm_16), .conv3_ifm_17(conv3_ifm_17), .conv3_ifm_18(conv3_ifm_18), .conv3_ifm_19(conv3_ifm_19), .conv3_ifm_20(conv3_ifm_20), .conv3_ifm_21(conv3_ifm_21), .conv3_ifm_22(conv3_ifm_22), .conv3_ifm_23(conv3_ifm_23), .conv3_ifm_24(conv3_ifm_24), .conv3_ifm_25(conv3_ifm_25), .conv3_ifm_26(conv3_ifm_26), .conv3_ifm_27(conv3_ifm_27), .conv3_ifm_28(conv3_ifm_28), .conv3_ifm_29(conv3_ifm_29), 
        .conv3_ifm_30(conv3_ifm_30), .conv3_ifm_31(conv3_ifm_31), .conv3_ifm_32(conv3_ifm_32), .conv3_ifm_33(conv3_ifm_33), .conv3_ifm_34(conv3_ifm_34), .conv3_ifm_35(conv3_ifm_35), .conv3_ifm_36(conv3_ifm_36), .conv3_ifm_37(conv3_ifm_37), .conv3_ifm_38(conv3_ifm_38), .conv3_ifm_39(conv3_ifm_39), .conv3_ifm_40(conv3_ifm_40), .conv3_ifm_41(conv3_ifm_41), .conv3_ifm_42(conv3_ifm_42), .conv3_ifm_43(conv3_ifm_43), .conv3_ifm_44(conv3_ifm_44),
        
        .conv3_weight_0(conv3_weight_0), .conv3_weight_1(conv3_weight_1), .conv3_weight_2(conv3_weight_2),
        .conv3_weight_3(conv3_weight_3), .conv3_weight_4(conv3_weight_4), .conv3_weight_5(conv3_weight_5),
        .conv3_weight_6(conv3_weight_6), .conv3_weight_7(conv3_weight_7), .conv3_weight_8(conv3_weight_8),
        
        .conv1_ifm_0(conv1_ifm_0), .conv1_ifm_1(conv1_ifm_1), .conv1_ifm_2(conv1_ifm_2), .conv1_ifm_3(conv1_ifm_3), .conv1_ifm_4(conv1_ifm_4), .conv1_ifm_5(conv1_ifm_5), .conv1_ifm_6(conv1_ifm_6), .conv1_ifm_7(conv1_ifm_7), .conv1_ifm_8(conv1_ifm_8), .conv1_ifm_9(conv1_ifm_9), .conv1_ifm_10(conv1_ifm_10), .conv1_ifm_11(conv1_ifm_11), .conv1_ifm_12(conv1_ifm_12),
        
        .conv1_weight(conv1_weight),
        .bias_data(bias), .bias_shift(bias_shift),
        
        .conv_out_0(conv_out_0), .conv_out_1(conv_out_1), .conv_out_2(conv_out_2), .conv_out_3(conv_out_3), .conv_out_4(conv_out_4),
        .conv_out_5(conv_out_5), .conv_out_6(conv_out_6), .conv_out_7(conv_out_7), .conv_out_8(conv_out_8), .conv_out_9(conv_out_9),
        .conv_out_10(conv_out_10), .conv_out_11(conv_out_11), .conv_out_12(conv_out_12),
        
        .conv_valid(conv_valid), .conv_end(conv_end)
    );


    CNN_Maxpooling Maxpooling_Processing_Unit(
        .clk(clk),
        .rst_n(rst_n),
        .mp_valid(mp_valid), 
        .input_data_0(mp_data_0), .input_data_1(mp_data_1), 
        .input_data_2(mp_data_2), .input_data_3(mp_data_3), 
        .mp_out_0(mp_out), .mp_out_valid(mp_out_valid)
        );
    
    CNN_Leaky_Relu Leaky_Relu_Processing_Unit (
        .clk(clk),
        .rst_n(rst_n),
        .relu_shift(relu_shift),
        .conv_valid(conv_valid),
        .isNL(isNL), 
        .LT_conv(LT_conv),
        .conv_data_0(conv_out_0), .conv_data_1(conv_out_1), .conv_data_2(conv_out_2),
        .conv_data_3(conv_out_3), .conv_data_4(conv_out_4),
        .conv_data_5(conv_out_5), .conv_data_6(conv_out_6),
        .conv_data_7(conv_out_7), .conv_data_8(conv_out_8),
        .conv_data_9(conv_out_9), .conv_data_10(conv_out_10),
        .conv_data_11(conv_out_11), .conv_data_12(conv_out_12),
        .relu_out_0(relu_out_0), .relu_out_1(relu_out_1), .relu_out_2(relu_out_2),
        .relu_out_3(relu_out_3), .relu_out_4(relu_out_4),
        .relu_out_5(relu_out_5), .relu_out_6(relu_out_6),
        .relu_out_7(relu_out_7), .relu_out_8(relu_out_8),
        .relu_out_9(relu_out_9), .relu_out_10(relu_out_10),
        .relu_out_11(relu_out_11), .relu_out_12(relu_out_12), .wrt_en(wrt_en)
    );
    
    ofm_buffer Post_Processing_Unit (
        .clk(clk), 
        .rst_n(rst_n),
        .wrt_en(wrt_en), 
        .mp_wrt_en(mp_out_valid),
        .is_mp(is_mp),
        .conv_data_0(relu_out_0), .conv_data_1(relu_out_1), .conv_data_2(relu_out_2), 
        .conv_data_3(relu_out_3), .conv_data_4(relu_out_4), .conv_data_5(relu_out_5),
        .conv_data_6(relu_out_6), .conv_data_7(relu_out_7), .conv_data_8(relu_out_8), 
        .conv_data_9(relu_out_9), .conv_data_10(relu_out_10),.conv_data_11(relu_out_11),
        .conv_data_12(relu_out_12), 
        .mp_data_0(mp_out),
        .ofm_buffer_data(ofm_buffer_data), .ofm_buffer_valid(ofm_buffer_valid),
        .ofm_channel(ofm_channel)
    );

endmodule
