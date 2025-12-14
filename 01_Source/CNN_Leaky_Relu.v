`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 16:47:05
// Design Name: 
// Module Name: CNN_Leaky_Relu
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


module CNN_Leaky_Relu#(parameter Relu_Width = 32, Relu_Out_Width = 16)(
    clk, rst_n, relu_shift, conv_valid, isNL, LT_conv,
    conv_data_0, conv_data_1, conv_data_2, conv_data_3, conv_data_4,
    conv_data_5, conv_data_6, conv_data_7, conv_data_8, conv_data_9,
    conv_data_10, conv_data_11, conv_data_12,
    relu_out_0, relu_out_1, relu_out_2, relu_out_3, relu_out_4, 
    relu_out_5, relu_out_6, relu_out_7, relu_out_8, relu_out_9, 
    relu_out_10, relu_out_11, relu_out_12,
    wrt_en
    );
input clk, rst_n, conv_valid, isNL, LT_conv;
input signed [4:0] relu_shift;
input signed [Relu_Width -1:0] conv_data_0, conv_data_1, conv_data_2, conv_data_3, conv_data_4,
                                   conv_data_5, conv_data_6, conv_data_7, conv_data_8, conv_data_9,
                                   conv_data_10, conv_data_11, conv_data_12;
output signed [Relu_Out_Width -1:0] relu_out_0, relu_out_1, relu_out_2, relu_out_3, relu_out_4, 
                                    relu_out_5, relu_out_6, relu_out_7, relu_out_8, relu_out_9, 
                                    relu_out_10, relu_out_11, relu_out_12;
output reg  wrt_en;
reg relu_valid;
reg signed [63:0] relu_reg_0, relu_reg_1, relu_reg_2, relu_reg_3, relu_reg_4, 
                             relu_reg_5, relu_reg_6, relu_reg_7, relu_reg_8, relu_reg_9, 
                             relu_reg_10, relu_reg_11, relu_reg_12;
                             
reg signed [Relu_Out_Width -1:0] buf_relu_reg_0, buf_relu_reg_1, buf_relu_reg_2, buf_relu_reg_3, buf_relu_reg_4, 
                             buf_relu_reg_5, buf_relu_reg_6, buf_relu_reg_7, buf_relu_reg_8, buf_relu_reg_9, 
                             buf_relu_reg_10, buf_relu_reg_11, buf_relu_reg_12;
                             
assign relu_out_0 = buf_relu_reg_0;
assign relu_out_1 = buf_relu_reg_1;
assign relu_out_2 = buf_relu_reg_2;
assign relu_out_3 = buf_relu_reg_3;
assign relu_out_4 = buf_relu_reg_4;
assign relu_out_5 = buf_relu_reg_5;
assign relu_out_6 = buf_relu_reg_6;
assign relu_out_7 = buf_relu_reg_7;
assign relu_out_8 = buf_relu_reg_8;
assign relu_out_9 = buf_relu_reg_9;
assign relu_out_10 = buf_relu_reg_10;
assign relu_out_11 = buf_relu_reg_11;
assign relu_out_12 = buf_relu_reg_12;
                             
always@(posedge clk)begin
    if(!rst_n)begin
        relu_reg_0 <= 0;
        relu_reg_1 <= 0;
        relu_reg_2 <= 0;
        relu_reg_3 <= 0;
        relu_reg_4 <= 0;
        relu_reg_5 <= 0;
        relu_reg_6 <= 0;
        relu_reg_7 <= 0;
        relu_reg_8 <= 0;
        relu_reg_9 <= 0;
        relu_reg_10 <= 0;
        relu_reg_11 <= 0;
        relu_reg_12 <= 0;
        buf_relu_reg_0 <= 0;
        buf_relu_reg_1 <= 0;
        buf_relu_reg_2 <= 0;
        buf_relu_reg_3 <= 0;
        buf_relu_reg_4 <= 0;
        buf_relu_reg_5 <= 0;
        buf_relu_reg_6 <= 0;
        buf_relu_reg_7 <= 0;
        buf_relu_reg_8 <= 0;
        buf_relu_reg_9 <= 0;
        buf_relu_reg_10 <= 0;
        buf_relu_reg_11 <= 0;
        buf_relu_reg_12 <= 0;
        relu_valid <= 0;
        wrt_en <= 0;
        
    end
    else begin
        if(conv_valid )begin
            relu_valid <= 1;
            
            if(conv_data_0 < 0 & isNL) relu_reg_0 <= (conv_data_0 * 16'sh0ccc)>>>15;
            else relu_reg_0 <= conv_data_0;
            
            if(conv_data_1 < 0 & isNL) relu_reg_1 <= (conv_data_1 * 16'sh0ccc)>>>15;
            else relu_reg_1 <= conv_data_1;
            
            if(conv_data_2 < 0 & isNL) relu_reg_2 <= (conv_data_2 * 16'sh0ccc)>>>15;
            else relu_reg_2 <= conv_data_2;
            
            if(conv_data_3 < 0 & isNL) relu_reg_3 <= (conv_data_3 * 16'sh0ccc)>>>15;
            else relu_reg_3 <= conv_data_3;
            
            if(conv_data_4 < 0 & isNL) relu_reg_4 <= (conv_data_4 * 16'sh0ccc)>>>15;
            else relu_reg_4 <= conv_data_4;
            
            if(conv_data_5 < 0 & isNL) relu_reg_5 <= (conv_data_5 * 16'sh0ccc)>>>15;
            else relu_reg_5 <= conv_data_5;
            
            if(conv_data_6 < 0 & isNL) relu_reg_6 <= (conv_data_6 * 16'sh0ccc)>>>15;
            else relu_reg_6 <= conv_data_6;
            
            if(conv_data_7 < 0 & isNL) relu_reg_7 <= (conv_data_7 * 16'sh0ccc)>>>15;
            else relu_reg_7 <= conv_data_7;
            
            if(conv_data_8 < 0 & isNL) relu_reg_8 <= (conv_data_8 * 16'sh0ccc)>>>15;
            else relu_reg_8 <= conv_data_8;
            
            if(conv_data_9 < 0 & isNL) relu_reg_9 <= (conv_data_9 * 16'sh0ccc)>>>15;
            else relu_reg_9 <= conv_data_9;
            
            if(conv_data_10 < 0 & isNL) relu_reg_10 <= (conv_data_10 * 16'sh0ccc)>>>15;
            else relu_reg_10 <= conv_data_10;
            
            if(conv_data_11 < 0 & isNL) relu_reg_11 <= (conv_data_11 * 16'sh0ccc)>>>15;
            else relu_reg_11 <= conv_data_11;
            
            if(conv_data_12 < 0 & isNL) relu_reg_12 <= (conv_data_12 * 16'sh0ccc)>>>15;
            else relu_reg_12 <= conv_data_12;
                
        end else begin
            relu_valid <= 0;
        end
        
        if(relu_valid)begin
            wrt_en <= 1;
            if(LT_conv)begin
                buf_relu_reg_0 <= relu_reg_0 >>> relu_shift;
                buf_relu_reg_1 <= relu_reg_1 >>> relu_shift;
                buf_relu_reg_2 <= relu_reg_2 >>> relu_shift;
                buf_relu_reg_3 <= relu_reg_3 >>> relu_shift;
                buf_relu_reg_4 <= relu_reg_4 >>> relu_shift;
                buf_relu_reg_5 <= relu_reg_5 >>> relu_shift;
                buf_relu_reg_6 <= relu_reg_6 >>> relu_shift;
                buf_relu_reg_7 <= relu_reg_7 >>> relu_shift;
                buf_relu_reg_8 <= relu_reg_8 >>> relu_shift;
                buf_relu_reg_9 <= relu_reg_9 >>> relu_shift;
                buf_relu_reg_10 <= relu_reg_10 >>> relu_shift;
                buf_relu_reg_11 <= relu_reg_11 >>> relu_shift;
                buf_relu_reg_12 <= relu_reg_12 >>> relu_shift;
            end else begin
                buf_relu_reg_0 <= relu_reg_0;
                buf_relu_reg_1 <= relu_reg_1;
                buf_relu_reg_2 <= relu_reg_2;
                buf_relu_reg_3 <= relu_reg_3;
                buf_relu_reg_4 <= relu_reg_4;
                buf_relu_reg_5 <= relu_reg_5;
                buf_relu_reg_6 <= relu_reg_6;
                buf_relu_reg_7 <= relu_reg_7;
                buf_relu_reg_8 <= relu_reg_8;
                buf_relu_reg_9 <= relu_reg_9;
                buf_relu_reg_10 <= relu_reg_10;
                buf_relu_reg_11 <= relu_reg_11;
                buf_relu_reg_12 <= relu_reg_12;
            end
        end else begin
            wrt_en <= 0;
        end
    end
end

endmodule
