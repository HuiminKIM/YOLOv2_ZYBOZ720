`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/21 00:51:59
// Design Name: 
// Module Name: ofm_buffer
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


module ofm_buffer#(parameter Ofm_Input_Width = 16, Ofm_Output_Width = 64)(
    clk, rst_n, wrt_en, mp_wrt_en, is_mp, 
    conv_data_0, conv_data_1, conv_data_2, conv_data_3, conv_data_4, 
    conv_data_5, conv_data_6, conv_data_7, conv_data_8, conv_data_9, 
    conv_data_10, conv_data_11, conv_data_12, 
    mp_data_0,
    ofm_buffer_data, ofm_buffer_valid, ofm_channel
    );
    input clk, rst_n, wrt_en, mp_wrt_en ,is_mp;
    input [10:0] ofm_channel;
    input signed [Ofm_Input_Width -1:0] conv_data_0, conv_data_1, conv_data_2, conv_data_3, conv_data_4, 
                                        conv_data_5, conv_data_6, conv_data_7, conv_data_8, conv_data_9, 
                                        conv_data_10, conv_data_11, conv_data_12;
    input signed [Ofm_Input_Width -1:0] mp_data_0;
    output reg signed [Ofm_Output_Width -1:0] ofm_buffer_data;
    output reg ofm_buffer_valid;
    
    localparam is_425 = 4'd13;
    
    reg [3:0] w_flag_cnt;
    reg [1:0] r_flag_cnt;
    reg out_flag_0, out_flag_1, out_flag_2, out_flag_3;
    reg out3_valid_0, out3_valid_1, out3_valid_2, out4_valid;
    reg signed [Ofm_Output_Width -1:0] out_reg_0_0, out_reg_0_1, out_reg_0_2, out_reg_0_3;
    reg signed [Ofm_Output_Width -1:0] out_reg_1_0, out_reg_1_1, out_reg_1_2, out_reg_1_3;
    reg signed [Ofm_Output_Width -1:0] out_reg_2_0, out_reg_2_1, out_reg_2_2, out_reg_2_3;
    reg signed [Ofm_Output_Width -1:0] out_reg_3_0, out_reg_3_1, out_reg_3_2, out_reg_3_3;
    reg signed [Ofm_Output_Width -1:0] mp_reg_0, mp_reg_1, mp_reg_2, mp_reg_3;
    reg mp_out;
    
    reg [13:0] r_cnt;
    wire finish_425 =(ofm_channel == 425) && ((wrt_en && r_cnt == 5524)||r_cnt == 5525);
    

    always@(posedge clk)begin
        if(!rst_n)begin
            w_flag_cnt <= 0;
            r_flag_cnt <= 0;
            out3_valid_0 <= 0;
            out3_valid_1 <= 0;
            out3_valid_2 <= 0;
            out4_valid <= 0;
            mp_out <= 0;
            out_reg_0_0 <= 0;
            out_reg_0_1 <= 0;
            out_reg_0_2 <= 0;
            out_reg_0_3 <= 0;
            out_reg_1_0 <= 0;
            out_reg_1_1 <= 0;
            out_reg_1_2 <= 0;
            out_reg_1_3 <= 0;
            out_reg_2_0 <= 0;
            out_reg_2_1 <= 0;
            out_reg_2_2 <= 0;
            out_reg_2_3 <= 0;
            out_reg_3_0 <= 0;
            out_reg_3_1 <= 0;
            out_reg_3_2 <= 0;
            out_reg_3_3 <= 0;
            out_flag_0 <= 0;
            out_flag_1 <= 0;
            out_flag_2 <= 0;
            out_flag_3 <= 0;
            mp_reg_0 <= 0;
            mp_reg_1 <= 0;
            ofm_buffer_valid <= 0;
            ofm_buffer_data <=0;
            r_cnt <=0;
        end else begin
            if(ofm_channel == 425 && wrt_en)begin
                r_cnt <= r_cnt + 1;
            end else if(w_flag_cnt == is_425)begin
                r_cnt <= 0;
            end
            // READ
            if(wrt_en)begin
                case(r_flag_cnt)
                    0:begin
                        out_reg_0_0 <= {conv_data_3[15:0], conv_data_2[15:0], conv_data_1[15:0], conv_data_0[15:0]};
                        out_reg_0_1 <= {conv_data_7[15:0], conv_data_6[15:0], conv_data_5[15:0], conv_data_4[15:0]};
                        out_reg_0_2 <= {conv_data_11[15:0], conv_data_10[15:0], conv_data_9[15:0], conv_data_8[15:0]};
                        out_reg_0_3 <= {48'b0, conv_data_12[15:0]};
                        if(finish_425)r_flag_cnt <= 0;
                        else r_flag_cnt <= r_flag_cnt + 1;
                    end
                    1:begin
                        out_reg_1_0 <= {conv_data_2[15:0], conv_data_1[15:0], conv_data_0[15:0], out_reg_0_3[15:0]};
                        out_reg_1_1 <= {conv_data_6[15:0], conv_data_5[15:0], conv_data_4[15:0], conv_data_3[15:0]};
                        out_reg_1_2 <= {conv_data_10[15:0], conv_data_9[15:0], conv_data_8[15:0], conv_data_7[15:0]};
                        out_reg_1_3 <= {32'b0, conv_data_12[15:0], conv_data_11[15:0]};
                        r_flag_cnt <= r_flag_cnt + 1;
                    end
                    2:begin
                        out_reg_2_0 <= {conv_data_1[15:0], conv_data_0[15:0], out_reg_1_3[31:0]};
                        out_reg_2_1 <= {conv_data_5[15:0], conv_data_4[15:0], conv_data_3[15:0], conv_data_2[15:0]};
                        out_reg_2_2 <= {conv_data_9[15:0], conv_data_8[15:0], conv_data_7[15:0], conv_data_6[15:0]};
                        out_reg_2_3 <= {16'b0, conv_data_12[15:0], conv_data_11[15:0], conv_data_10[15:0]};
                        r_flag_cnt <= r_flag_cnt + 1;
                    end
                    3:begin
                        out_reg_3_0 <= {conv_data_0[15:0], out_reg_2_3[47:0]};
                        out_reg_3_1 <= {conv_data_4[15:0], conv_data_3[15:0], conv_data_2[15:0], conv_data_1[15:0]};
                        out_reg_3_2 <= {conv_data_8[15:0], conv_data_7[15:0], conv_data_6[15:0], conv_data_5[15:0]};
                        out_reg_3_3 <= {conv_data_12[15:0], conv_data_11[15:0], conv_data_10[15:0], conv_data_9[15:0]};
                        r_flag_cnt <= 0;
                    end
                endcase
            end else if(mp_wrt_en)begin
                case(r_flag_cnt)
                    0:begin
                        mp_reg_0 <= {48'b0, mp_data_0[15:0]};
                        mp_out <= 0;
                        r_flag_cnt <= r_flag_cnt + 1;
                    end
                    1:begin
                        mp_reg_1 <= {32'b0, mp_data_0[15:0], mp_reg_0[15:0]};
                        mp_out <= 0;
                        r_flag_cnt <= r_flag_cnt + 1;
                    end
                    2:begin
                        mp_reg_2 <= {16'b0, mp_data_0[15:0], mp_reg_1[31:0]};
                        mp_out <= 0;
                        r_flag_cnt <= r_flag_cnt + 1;
                    end
                    3:begin
                        mp_reg_3 <= {mp_data_0[15:0], mp_reg_2[47:0]};
                        mp_out <= 1;
                        r_flag_cnt <= 0;
                    end
                endcase
            end else begin
                mp_out <= 0;
            end
            
            if(!is_mp)begin
                if(r_flag_cnt == 0 & wrt_en)begin
                    out3_valid_0 <=1;
                end else if(w_flag_cnt ==1 || w_flag_cnt == is_425 )begin
                    out3_valid_0 <=0;
                end
                if(r_flag_cnt == 1 & wrt_en)begin
                    out3_valid_1 <=1;
                end else if(w_flag_cnt == 4)begin
                    out3_valid_1 <=0;
                end
                if(r_flag_cnt == 2 & wrt_en)begin
                    out3_valid_2 <=1;
                end else if(w_flag_cnt ==7)begin
                    out3_valid_2 <=0;
                end
                if(r_flag_cnt == 3 & wrt_en)begin
                    out4_valid <=1;
                end else if(w_flag_cnt ==10)begin
                    out4_valid <=0;
                end
            end
            
            // WRITE
            if(!is_mp)begin
                case(w_flag_cnt)
                    0:begin
                        if(out3_valid_0)begin
                            w_flag_cnt <= w_flag_cnt + 1;
                            ofm_buffer_data <= out_reg_0_0;
                            ofm_buffer_valid <= 1;
                        end else begin
                            ofm_buffer_valid <= 0;
                        end
                    end
                    1:begin
                        w_flag_cnt <= w_flag_cnt + 1;
                        ofm_buffer_data <= out_reg_0_1;
                    end
                    2:begin
                        if(finish_425) w_flag_cnt <= is_425;
                        else w_flag_cnt <= w_flag_cnt + 1;
                        ofm_buffer_data <= out_reg_0_2;
                    end
                    3:begin
                        if(out3_valid_1)begin
                            w_flag_cnt <= w_flag_cnt + 1;
                            ofm_buffer_valid <= 1;
                            ofm_buffer_data <= out_reg_1_0;
                        end else begin
                            ofm_buffer_valid <= 0;
                        end
                    end
                    4:begin
                        w_flag_cnt <= w_flag_cnt + 1;
                        ofm_buffer_data <= out_reg_1_1;
                    end
                    5:begin
                        w_flag_cnt <= w_flag_cnt + 1;
                        ofm_buffer_data <= out_reg_1_2;
                    end
                    6:begin
                        if(out3_valid_2)begin
                            w_flag_cnt <= w_flag_cnt + 1;
                            ofm_buffer_valid <= 1;
                            ofm_buffer_data <= out_reg_2_0;
                        end else begin
                            ofm_buffer_valid <= 0;
                        end
                    end
                    7:begin
                        w_flag_cnt <= w_flag_cnt + 1;
                        ofm_buffer_data <= out_reg_2_1;
                    end
                    8:begin
                        w_flag_cnt <= w_flag_cnt + 1;
                        ofm_buffer_data <= out_reg_2_2;
                    end
                    9:begin
                        if(out4_valid)begin
                            w_flag_cnt <= w_flag_cnt + 1;
                            ofm_buffer_valid <= 1;
                            ofm_buffer_data <= out_reg_3_0;
                        end else begin
                            ofm_buffer_valid <= 0;
                        end
                    end
                    10:begin
                            w_flag_cnt <= w_flag_cnt + 1;
                            ofm_buffer_data <= out_reg_3_1;
                    end
                    11:begin
                            w_flag_cnt <= w_flag_cnt + 1;
                            ofm_buffer_data <= out_reg_3_2;
                    end
                    12:begin
                            w_flag_cnt <= 0;
                            ofm_buffer_data <= out_reg_3_3;
                    end
                    is_425 : begin
                            w_flag_cnt <= 0;
                            ofm_buffer_data <= out_reg_0_3;
                    end
                endcase
            end else begin
                if(mp_out)begin
                    ofm_buffer_data <= mp_reg_3;
                    ofm_buffer_valid <= 1;
                end else begin
                    ofm_buffer_valid <= 0;
                end
            end
        end
    end
endmodule
