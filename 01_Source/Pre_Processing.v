`timescale 1ns / 1ps

module Pre_Processing(
    input clk,
    input rst_n,
    input conv3_weight_valid,
    input conv3_ifm_weight_hs,
    input conv1_ifm_weight_hs,
    input [15:0]  ifm_data_0,  ifm_data_1,  ifm_data_2,  ifm_data_3,  ifm_data_4,  ifm_data_5,  ifm_data_6,  ifm_data_7,  ifm_data_8,  ifm_data_9, ifm_data_10,  ifm_data_11, ifm_data_12, ifm_data_13, ifm_data_14,
                    ifm_data_15, ifm_data_16, ifm_data_17, ifm_data_18, ifm_data_19, ifm_data_20, ifm_data_21, ifm_data_22, ifm_data_23, ifm_data_24, ifm_data_25, ifm_data_26, ifm_data_27, ifm_data_28, ifm_data_29,
                    ifm_data_30, ifm_data_31, ifm_data_32, ifm_data_33, ifm_data_34, ifm_data_35, ifm_data_36, ifm_data_37, ifm_data_38, ifm_data_39, ifm_data_40, ifm_data_41, ifm_data_42, ifm_data_43, ifm_data_44,
    input [15:0]  weight_data_in0, weight_data_in1, weight_data_in2,
                   weight_data_in3, weight_data_in4, weight_data_in5, 
                    weight_data_in6, weight_data_in7, weight_data_in8,
    input [15:0] conv1_ifm_data_0,  conv1_ifm_data_1,  conv1_ifm_data_2,  conv1_ifm_data_3,  conv1_ifm_data_4,  conv1_ifm_data_5,  conv1_ifm_data_6,  conv1_ifm_data_7,  conv1_ifm_data_8,  conv1_ifm_data_9, conv1_ifm_data_10,  conv1_ifm_data_11, conv1_ifm_data_12,
    input [15:0] conv_1_weight,
    
    output reg conv3_valid,
    output reg conv1_valid,
    output reg [15:0]  conv3_ifm_0,  conv3_ifm_1,  conv3_ifm_2,  conv3_ifm_3,  conv3_ifm_4,  conv3_ifm_5,  conv3_ifm_6,  conv3_ifm_7,  conv3_ifm_8,  conv3_ifm_9,  conv3_ifm_10,  conv3_ifm_11,  conv3_ifm_12,  conv3_ifm_13,  conv3_ifm_14,
                       conv3_ifm_15, conv3_ifm_16, conv3_ifm_17, conv3_ifm_18, conv3_ifm_19, conv3_ifm_20, conv3_ifm_21, conv3_ifm_22, conv3_ifm_23, conv3_ifm_24, conv3_ifm_25, conv3_ifm_26, conv3_ifm_27, conv3_ifm_28, conv3_ifm_29,
                       conv3_ifm_30, conv3_ifm_31, conv3_ifm_32, conv3_ifm_33, conv3_ifm_34, conv3_ifm_35, conv3_ifm_36, conv3_ifm_37, conv3_ifm_38, conv3_ifm_39, conv3_ifm_40, conv3_ifm_41, conv3_ifm_42, conv3_ifm_43, conv3_ifm_44,
    output reg [15:0]  conv3_weight_0, conv3_weight_1, conv3_weight_2,
                       conv3_weight_3, conv3_weight_4, conv3_weight_5, 
                       conv3_weight_6, conv3_weight_7, conv3_weight_8,
    output reg [15:0]  conv1_ifm_0,  conv1_ifm_1,  conv1_ifm_2,  conv1_ifm_3,  conv1_ifm_4,  conv1_ifm_5,  conv1_ifm_6,  conv1_ifm_7,  conv1_ifm_8,  conv1_ifm_9, conv1_ifm_10,  conv1_ifm_11, conv1_ifm_12,
    output reg [15:0]  conv1_weight
    );
    reg [15:0] save_weight_data_in0,save_weight_data_in1,save_weight_data_in2,
               save_weight_data_in3,save_weight_data_in4,save_weight_data_in5,
               save_weight_data_in6,save_weight_data_in7,save_weight_data_in8;
               
    reg save_cnt;
    always@(posedge clk)begin
        if(!rst_n)begin
            conv3_valid<=0;
            conv1_valid<=0;
            conv3_ifm_0<=0;  conv3_ifm_1<=0;  conv3_ifm_2<=0;  conv3_ifm_3<=0;  conv3_ifm_4<=0;  conv3_ifm_5<=0;  conv3_ifm_6<=0;  conv3_ifm_7<=0;  conv3_ifm_8<=0;  conv3_ifm_9<=0;  conv3_ifm_10<=0;  conv3_ifm_11<=0;  conv3_ifm_12<=0;  conv3_ifm_13<=0;  conv3_ifm_14<=0;
            conv3_ifm_15<=0; conv3_ifm_16<=0; conv3_ifm_17<=0; conv3_ifm_18<=0; conv3_ifm_19<=0; conv3_ifm_20<=0; conv3_ifm_21<=0; conv3_ifm_22<=0; conv3_ifm_23<=0; conv3_ifm_24<=0; conv3_ifm_25<=0; conv3_ifm_26<=0; conv3_ifm_27<=0; conv3_ifm_28<=0; conv3_ifm_29<=0;
            conv3_ifm_30<=0; conv3_ifm_31<=0; conv3_ifm_32<=0; conv3_ifm_33<=0; conv3_ifm_34<=0; conv3_ifm_35<=0; conv3_ifm_36<=0; conv3_ifm_37<=0; conv3_ifm_38<=0; conv3_ifm_39<=0; conv3_ifm_40<=0; conv3_ifm_41<=0; conv3_ifm_42<=0; conv3_ifm_43<=0; conv3_ifm_44<=0;
            conv3_weight_0<=0; conv3_weight_1<=0; conv3_weight_2<=0;
            conv3_weight_3<=0; conv3_weight_4<=0; conv3_weight_5<=0;
            conv3_weight_6<=0; conv3_weight_7<=0; conv3_weight_8<=0;
            save_cnt <=0;
            save_weight_data_in0<=0; save_weight_data_in1<=0; save_weight_data_in2<=0;
            save_weight_data_in3<=0; save_weight_data_in4<=0; save_weight_data_in5<=0;
            save_weight_data_in6<=0; save_weight_data_in7<=0; save_weight_data_in8<=0;
            conv1_ifm_0<=0;  conv1_ifm_1<=0;  conv1_ifm_2<=0;  conv1_ifm_3<=0;  conv1_ifm_4<=0;  conv1_ifm_5<=0;  conv1_ifm_6<=0;  conv1_ifm_7<=0;  conv1_ifm_8<=0;  conv1_ifm_9<=0; conv1_ifm_10<=0;  conv1_ifm_11<=0; conv1_ifm_12<=0;
            conv1_weight<=0;
        end else begin
            conv3_valid<=conv3_ifm_weight_hs;
            conv1_valid<=conv1_ifm_weight_hs;
            conv3_ifm_0<=ifm_data_0;  conv3_ifm_1<=ifm_data_1;  conv3_ifm_2<=ifm_data_2;  conv3_ifm_3<=ifm_data_3;  conv3_ifm_4<=ifm_data_4;  conv3_ifm_5<=ifm_data_5;  conv3_ifm_6<=ifm_data_6;  conv3_ifm_7<=ifm_data_7;  conv3_ifm_8<=ifm_data_8;  conv3_ifm_9<=ifm_data_9;  conv3_ifm_10<=ifm_data_10;  conv3_ifm_11<=ifm_data_11;  conv3_ifm_12<=ifm_data_12;  conv3_ifm_13<=ifm_data_13;  conv3_ifm_14<=ifm_data_14;
            conv3_ifm_15<=ifm_data_15; conv3_ifm_16<=ifm_data_16; conv3_ifm_17<=ifm_data_17; conv3_ifm_18<=ifm_data_18; conv3_ifm_19<=ifm_data_19; conv3_ifm_20<=ifm_data_20; conv3_ifm_21<=ifm_data_21; conv3_ifm_22<=ifm_data_22; conv3_ifm_23<=ifm_data_23; conv3_ifm_24<=ifm_data_24; conv3_ifm_25<=ifm_data_25; conv3_ifm_26<=ifm_data_26; conv3_ifm_27<=ifm_data_27; conv3_ifm_28<=ifm_data_28; conv3_ifm_29<=ifm_data_29;
            conv3_ifm_30<=ifm_data_30; conv3_ifm_31<=ifm_data_31; conv3_ifm_32<=ifm_data_32; conv3_ifm_33<=ifm_data_33; conv3_ifm_34<=ifm_data_34; conv3_ifm_35<=ifm_data_35; conv3_ifm_36<=ifm_data_36; conv3_ifm_37<=ifm_data_37; conv3_ifm_38<=ifm_data_38; conv3_ifm_39<=ifm_data_39; conv3_ifm_40<=ifm_data_40; conv3_ifm_41<=ifm_data_41; conv3_ifm_42<=ifm_data_42; conv3_ifm_43<=ifm_data_43; conv3_ifm_44<=ifm_data_44;
            
            conv1_ifm_0<=conv1_ifm_data_0;  conv1_ifm_1<=conv1_ifm_data_1;  conv1_ifm_2<=conv1_ifm_data_2;  conv1_ifm_3<=conv1_ifm_data_3;  conv1_ifm_4<=conv1_ifm_data_4;  conv1_ifm_5<=conv1_ifm_data_5;  conv1_ifm_6<=conv1_ifm_data_6;  conv1_ifm_7<=conv1_ifm_data_7;  conv1_ifm_8<=conv1_ifm_data_8;  conv1_ifm_9<=conv1_ifm_data_9; conv1_ifm_10<=conv1_ifm_data_10;  conv1_ifm_11<=conv1_ifm_data_11; conv1_ifm_12<=conv1_ifm_data_12;
            conv1_weight<=conv_1_weight;
            if(conv3_ifm_weight_hs)begin
                save_cnt <=0;
            end else if(conv3_weight_valid & save_cnt ==0)begin
                save_weight_data_in0<=weight_data_in0; save_weight_data_in1<=weight_data_in1; save_weight_data_in2<=weight_data_in2;
                save_weight_data_in3<=weight_data_in3; save_weight_data_in4<=weight_data_in4; save_weight_data_in5<=weight_data_in5;
                save_weight_data_in6<=weight_data_in6; save_weight_data_in7<=weight_data_in7; save_weight_data_in8<=weight_data_in8;
                save_cnt <=1;
            end
            if(save_cnt ==0)begin
                conv3_weight_0<=weight_data_in0; conv3_weight_1<=weight_data_in1; conv3_weight_2<=weight_data_in2;
                conv3_weight_3<=weight_data_in3; conv3_weight_4<=weight_data_in4; conv3_weight_5<=weight_data_in5;
                conv3_weight_6<=weight_data_in6; conv3_weight_7<=weight_data_in7; conv3_weight_8<=weight_data_in8;
            end else begin
                conv3_weight_0<=save_weight_data_in0; conv3_weight_1<=save_weight_data_in1; conv3_weight_2<=save_weight_data_in2;
                conv3_weight_3<=save_weight_data_in3; conv3_weight_4<=save_weight_data_in4; conv3_weight_5<=save_weight_data_in5;
                conv3_weight_6<=save_weight_data_in6; conv3_weight_7<=save_weight_data_in7; conv3_weight_8<=save_weight_data_in8;
            end
        end
    end
endmodule