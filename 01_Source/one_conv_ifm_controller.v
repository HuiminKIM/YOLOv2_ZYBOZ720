`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/31 11:04:29
// Design Name: 
// Module Name: one_conv_ifm_controller
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


module one_conv_ifm_controller(
    input clk,
    input rst_n,
    input is_conv_1,
    input is_maxpooling,
    input [10:0] ifm_channel,
    input [10:0] ofm_channel,
    input [8:0] ifm_width,
    
    input          temp_valid,
    output         temp_hs,
    input [15:0]   temp_data_0, temp_data_1, temp_data_2, temp_data_3, 
                   temp_data_4, temp_data_5, temp_data_6, temp_data_7, 
                   temp_data_8, temp_data_9, temp_data_10, temp_data_11, 
                   temp_data_12, temp_data_13, temp_data_14, temp_data_15,
    
    output reg        conv1_ifm_valid,               
    input             conv1_ifm_weight_hs,
    output reg [15:0]  conv1_ifm_data_0,  conv1_ifm_data_1,  conv1_ifm_data_2,  conv1_ifm_data_3,  conv1_ifm_data_4,  conv1_ifm_data_5,  conv1_ifm_data_6,  conv1_ifm_data_7,  conv1_ifm_data_8,  conv1_ifm_data_9, conv1_ifm_data_10,  conv1_ifm_data_11, conv1_ifm_data_12
    );
    

    
    wire last_col;
    wire conv_1;
    wire [4:0] w_cnt;
    wire [1:0] remain;
    wire [1:0] remain_13;
    wire [4:0] w_finish_cnt;
    wire temp_ready = (conv1_ifm_valid ==0 ||conv1_ifm_weight_hs);
    
    assign temp_hs = temp_ready & temp_valid;
    
     one_conv_ifm_remain one_conv_ifm_remain(
    .clk(clk),
    .rst_n(rst_n),
    .is_conv_1(is_conv_1),
    .conv_1(conv_1),
    .last_col(last_col),
    .w_cnt(w_cnt),
    .remain(remain),
    .remain_13(remain_13),
    .w_finish_cnt(w_finish_cnt),
    .temp_hs(temp_hs),
    .ifm_width(ifm_width),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel)
    );
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            conv1_ifm_valid <= 0;
            conv1_ifm_data_0<= 0; conv1_ifm_data_1<=0; conv1_ifm_data_2<=0;  conv1_ifm_data_3<=0;  conv1_ifm_data_4<=0;  conv1_ifm_data_5<=0;  conv1_ifm_data_6<=0;  conv1_ifm_data_7<=0;  conv1_ifm_data_8<=0; conv1_ifm_data_9<=0; conv1_ifm_data_10<=0; conv1_ifm_data_11<=0; conv1_ifm_data_12<=0;
        end else begin
            if(temp_hs)conv1_ifm_valid <=1;
            else if(conv1_ifm_weight_hs)conv1_ifm_valid <=0;
            
            if(temp_hs & conv_1)begin
                case(ifm_width)
                    default:begin
                        case(remain)
                            0:begin  conv1_ifm_data_0<= temp_data_3; conv1_ifm_data_1<=temp_data_4; conv1_ifm_data_2<=temp_data_5;  conv1_ifm_data_3<=temp_data_6;  conv1_ifm_data_4<=temp_data_7;  conv1_ifm_data_5<=temp_data_8;  conv1_ifm_data_6<=temp_data_9;  conv1_ifm_data_7<=temp_data_10;  conv1_ifm_data_8<=temp_data_11; conv1_ifm_data_9<=temp_data_12; conv1_ifm_data_10<=temp_data_13; conv1_ifm_data_11<=temp_data_14; conv1_ifm_data_12<=temp_data_15; end
                            1:begin  conv1_ifm_data_0<= temp_data_2; conv1_ifm_data_1<=temp_data_3; conv1_ifm_data_2<=temp_data_4;  conv1_ifm_data_3<=temp_data_5;  conv1_ifm_data_4<=temp_data_6;  conv1_ifm_data_5<=temp_data_7;  conv1_ifm_data_6<=temp_data_8;  conv1_ifm_data_7<=temp_data_9;  conv1_ifm_data_8<=temp_data_10; conv1_ifm_data_9<=temp_data_11; conv1_ifm_data_10<=temp_data_12; conv1_ifm_data_11<=temp_data_13; conv1_ifm_data_12<=temp_data_14; end
                            2:begin  conv1_ifm_data_0<= temp_data_1; conv1_ifm_data_1<=temp_data_2; conv1_ifm_data_2<=temp_data_3;  conv1_ifm_data_3<=temp_data_4;  conv1_ifm_data_4<=temp_data_5;  conv1_ifm_data_5<=temp_data_6;  conv1_ifm_data_6<=temp_data_7;  conv1_ifm_data_7<=temp_data_8;  conv1_ifm_data_8<=temp_data_9; conv1_ifm_data_9<=temp_data_10; conv1_ifm_data_10<=temp_data_11; conv1_ifm_data_11<=temp_data_12; conv1_ifm_data_12<=temp_data_13; end
                            3:begin  conv1_ifm_data_0<= temp_data_0; conv1_ifm_data_1<=temp_data_1; conv1_ifm_data_2<=temp_data_2;  conv1_ifm_data_3<=temp_data_3;  conv1_ifm_data_4<=temp_data_4;  conv1_ifm_data_5<=temp_data_5;  conv1_ifm_data_6<=temp_data_6;  conv1_ifm_data_7<=temp_data_7;  conv1_ifm_data_8<=temp_data_8; conv1_ifm_data_9<=temp_data_9; conv1_ifm_data_10<=temp_data_10; conv1_ifm_data_11<=temp_data_11; conv1_ifm_data_12<=temp_data_12; end
                        endcase
                    end
                    13:begin
                        case(remain_13)
                            0:begin  conv1_ifm_data_0<= temp_data_3; conv1_ifm_data_1<=temp_data_4; conv1_ifm_data_2<=temp_data_5;  conv1_ifm_data_3<=temp_data_6;  conv1_ifm_data_4<=temp_data_7;  conv1_ifm_data_5<=temp_data_8;  conv1_ifm_data_6<=temp_data_9;  conv1_ifm_data_7<=temp_data_10;  conv1_ifm_data_8<=temp_data_11; conv1_ifm_data_9<=temp_data_12; conv1_ifm_data_10<=temp_data_13; conv1_ifm_data_11<=temp_data_14; conv1_ifm_data_12<=temp_data_15; end
                            1:begin  conv1_ifm_data_0<= temp_data_2; conv1_ifm_data_1<=temp_data_3; conv1_ifm_data_2<=temp_data_4;  conv1_ifm_data_3<=temp_data_5;  conv1_ifm_data_4<=temp_data_6;  conv1_ifm_data_5<=temp_data_7;  conv1_ifm_data_6<=temp_data_8;  conv1_ifm_data_7<=temp_data_9;  conv1_ifm_data_8<=temp_data_10; conv1_ifm_data_9<=temp_data_11; conv1_ifm_data_10<=temp_data_12; conv1_ifm_data_11<=temp_data_13; conv1_ifm_data_12<=temp_data_14; end
                            2:begin  conv1_ifm_data_0<= temp_data_1; conv1_ifm_data_1<=temp_data_2; conv1_ifm_data_2<=temp_data_3;  conv1_ifm_data_3<=temp_data_4;  conv1_ifm_data_4<=temp_data_5;  conv1_ifm_data_5<=temp_data_6;  conv1_ifm_data_6<=temp_data_7;  conv1_ifm_data_7<=temp_data_8;  conv1_ifm_data_8<=temp_data_9; conv1_ifm_data_9<=temp_data_10; conv1_ifm_data_10<=temp_data_11; conv1_ifm_data_11<=temp_data_12; conv1_ifm_data_12<=temp_data_13; end
                            3:begin  conv1_ifm_data_0<= temp_data_0; conv1_ifm_data_1<=temp_data_1; conv1_ifm_data_2<=temp_data_2;  conv1_ifm_data_3<=temp_data_3;  conv1_ifm_data_4<=temp_data_4;  conv1_ifm_data_5<=temp_data_5;  conv1_ifm_data_6<=temp_data_6;  conv1_ifm_data_7<=temp_data_7;  conv1_ifm_data_8<=temp_data_8; conv1_ifm_data_9<=temp_data_9; conv1_ifm_data_10<=temp_data_10; conv1_ifm_data_11<=temp_data_11; conv1_ifm_data_12<=temp_data_12; end
                        endcase
                    end
                endcase
            end
        end
    end
    
endmodule
