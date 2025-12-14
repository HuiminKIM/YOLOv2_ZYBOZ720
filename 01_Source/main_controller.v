`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2024 04:17:09 PM
// Design Name: 
// Module Name: main_controller
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


module main_controller(
    input         clk,
    input         rst_n,
    input  [31:0] k_s_pad_ltype,
    input  [31:0] iofm_num,
    input  [31:0] ifm_w_h,
    input  [31:0] ofm_w_h,
    input  [31:0] en_bits,
    input  [31:0] WeightQ,
    input  [31:0] BetaQ,
    input  [31:0] InputQ,
    input  [31:0] OutputQ,
    input         ap_start,
    
    output reg       is_relu,
    output reg       is_ofm_shift,
    output reg       en_bias,
    output reg       maxpooling,
    output reg       convolution_3,
    output reg       convolution_1,
    
    output reg[10:0] ifm_channel,
    output reg[10:0] ofm_channel,
    output reg[8:0] ifm_width,
    output reg[8:0] ifm_height,
    output reg[8:0] ofm_width,
    output reg[8:0] ofm_height,
    
    output reg[4:0]  bias_shift,
    output reg[4:0]  conv_shift,
    output reg[4:0]  ofm_shift,
    
    output reg [31:0] bias_transferbyte,
    output reg [31:0] weight_transferbyte,
    output reg [31:0] ofm_transferbyte,
    
    output reg [8:0] total_ifm,
    output reg        hp2_ap_start
    );
    
    localparam InterWidth = 5'd19;
    
    reg[1:0]  kernel_size;
    
    reg [3:0] buffer0;
    reg [31:0] buffer1;
    
    reg buf0_hp2_start;
    reg buf1_hp2_start;
    reg buf2_hp2_start;
    
    reg [17:0] buf0_ofm_transferbyte;
    reg [11:0] buf1_ofm_transferbyte;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buffer0 <= 0;
            buffer1 <= 0;
            weight_transferbyte <= 0;
            total_ifm <= 0;
            is_relu <= 0;
            en_bias <= 0;
            maxpooling <= 0;
            convolution_3 <= 0;
            convolution_1 <= 0;
            kernel_size <= 0;
            ifm_channel <= 0;
            ofm_channel <= 0;
            ifm_width <= 0;
            ifm_height <= 0;
            ofm_width <= 0;
            ofm_height <= 0;
            conv_shift <= 0; 
            bias_shift <= 0;
            ofm_shift <= 0;
            bias_transferbyte <= 0;
            is_ofm_shift<=0;
            hp2_ap_start<=0;
            buf0_hp2_start<=0;
            buf1_hp2_start<=0;
            buf2_hp2_start<=0;
            ofm_transferbyte<=0;
            buf0_ofm_transferbyte<=0;
            buf1_ofm_transferbyte<=0;
        end else begin
            is_ofm_shift <=(k_s_pad_ltype[7:0]==0);
            buffer0 <= kernel_size * kernel_size;
            if(ofm_channel == 425) buffer1 <= buffer0 * 850;
            else buffer1 <= buffer0 * bias_transferbyte;
            weight_transferbyte <= buffer1 * ifm_channel; 
            total_ifm <= (~en_bits[0]&&(kernel_size==3))? ifm_w_h [31:16]+'d2 : ifm_w_h [31:16];
            is_relu <= en_bits[2];
            en_bias <= en_bits[1];
            maxpooling <= en_bits[0];
            convolution_3 <= ~en_bits[0]&&(kernel_size=='d3);
            convolution_1 <= ~en_bits[0]&&(kernel_size=='d1);
            kernel_size <= k_s_pad_ltype[25:24];
            ifm_channel <= iofm_num [31:16];
            ofm_channel <= iofm_num [15:0];
            ifm_width <= ifm_w_h [31:16];
            ifm_height <= ifm_w_h [15:0];
            ofm_width <= ofm_w_h [31:16];
            ofm_height <= ofm_w_h [15:0];
            conv_shift <= WeightQ[4:0] + InputQ[4:0] - InterWidth; 
            bias_shift <= InterWidth - BetaQ[4:0];
            ofm_shift <= InterWidth[4:0] - OutputQ[4:0];
            if(ofm_channel == 425) bias_transferbyte <= 856;
            else bias_transferbyte <= ofm_channel*2;
            buf0_hp2_start<= ap_start;
            buf1_hp2_start<= buf0_hp2_start;
            buf2_hp2_start<= buf1_hp2_start;
            hp2_ap_start <= buf2_hp2_start;
            buf0_ofm_transferbyte <= ofm_height*ofm_height;
            buf1_ofm_transferbyte <= 2* ofm_channel;
            if(ofm_channel == 425) ofm_transferbyte <= 143656;
            else ofm_transferbyte <= buf0_ofm_transferbyte * buf1_ofm_transferbyte;
        end
    end
    
    
    
endmodule
