`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2024 02:39:23 PM
// Design Name: 
// Module Name: weight_controller
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


module weight_controller(
    input  wire [10:0] ifm_channel,
    input  wire [10:0] ofm_channel,
    input  wire [8:0] total_ifm,
    input  wire        ap_done,
    input  wire        clk,
    input  wire        rst_n,
    
    input  wire [14:0] repeat_ifm,
    
    output reg [10:0] con_ifm_channel,

    input  wire        weight0_bram_full,
    output reg         weight0_reg_read_en,
    input  wire [63:0] weight0_reg_din,
    input  wire        out_next0,
    input  wire [1:0]  remain0,

    input  wire        weight1_bram_full,
    output reg         weight1_reg_read_en,
    input  wire [63:0] weight1_reg_din,
    input  wire        out_next1,
    input  wire [1:0]  remain1,

    input  wire        weight2_bram_full,
    output reg        weight2_reg_read_en,
    input  wire [63:0] weight2_reg_din,
    input  wire        out_next2,
    input  wire [1:0]  remain2,

    input  wire        weight3_bram_full,
    output reg         weight3_reg_read_en,
    input  wire [63:0] weight3_reg_din,
    input  wire        out_next3,
    input  wire [1:0]  remain3,

    input  wire        weight4_bram_full,
    output reg         weight4_reg_read_en,
    input  wire [63:0] weight4_reg_din,
    input  wire        out_next4,
    input  wire [1:0]  remain4,

    input  wire        weight5_bram_full,
    output reg         weight5_reg_read_en,
    input  wire [63:0] weight5_reg_din,
    input  wire        out_next5,
    input  wire [1:0]  remain5,

    input  wire        weight6_bram_full,
    output reg         weight6_reg_read_en,
    input  wire [63:0] weight6_reg_din,
    input  wire        out_next6,
    input  wire [1:0]  remain6,

    input  wire        weight7_bram_full,
    output reg         weight7_reg_read_en,
    input  wire [63:0] weight7_reg_din,
    input  wire        out_next7,
    input  wire [1:0]  remain7,

    input  wire        weight8_bram_full,
    output reg         weight8_reg_read_en,
    input  wire [63:0] weight8_reg_din,
    input  wire        out_next8,
    input  wire [1:0]  remain8,

    input  wire        weight9_bram_full,
    output reg         weight9_reg_read_en,
    input  wire [63:0] weight9_reg_din,
    input  wire        out_next9,
    input  wire [1:0]  remain9,

    input  wire        weight10_bram_full,
    output reg         weight10_reg_read_en,
    input  wire [63:0] weight10_reg_din,
    input  wire        out_next10,
    input  wire [1:0]  remain10,

    input  wire        weight11_bram_full,
    output reg         weight11_reg_read_en,
    input  wire [63:0] weight11_reg_din,
    input  wire        out_next11,
    input  wire [1:0]  remain11,

    input  wire        weight12_bram_full,
    output reg        weight12_reg_read_en,
    input  wire [63:0] weight12_reg_din,
    input  wire        out_next12,
    input  wire [1:0]  remain12,

    input  wire        weight13_bram_full,
    output reg         weight13_reg_read_en,
    input  wire [63:0] weight13_reg_din,
    input  wire        out_next13,
    input  wire [1:0]  remain13,
    
    input  wire        weight14_bram_full,
    output reg         weight14_reg_read_en,
    input  wire [63:0] weight14_reg_din,
    input  wire        out_next14,
    input  wire [1:0]  remain14,

    input  wire        weight15_bram_full,
    output reg         weight15_reg_read_en,
    input  wire [63:0] weight15_reg_din,
    input  wire        out_next15,
    input  wire [1:0]  remain15,
    
    output reg [15:0]  weight_data_in0,
    output reg [15:0]  weight_data_in1,
    output reg [15:0]  weight_data_in2,
    output reg [15:0]  weight_data_in3,
    output reg [15:0]  weight_data_in4,
    output reg [15:0]  weight_data_in5,
    output reg [15:0]  weight_data_in6,
    output reg [15:0]  weight_data_in7,
    output reg [15:0]  weight_data_in8,
    
    output reg         weight_valid,
    input  wire        ifm_valid,
    input  wire        w_full
    //output wire [31:0] ila_no_weight_valid
    );
    
    integer i;
    
    reg [1:0] buf_read_flag;
    reg [1:0] buf_write_flag;

    reg [4:0] save_state;
    reg [4:0] read_state;
    reg [4:0] num;
    
    reg [11:0] next_con_ifm;
    reg [11:0] prev_ifm;
    reg [11:0] next_ifm;
    reg [11:0] buf_next_ifm0;
    reg [11:0] buf_next_ifm1;
    reg [11:0] buf_next_ifm2;
    
    reg [15:0] hs_next_con_ifm0;
    reg [15:0] hs_next_con_ifm1;
    
    reg [15:0] weight_reg_buf0 [0:8];
    reg [15:0] weight_reg_buf1 [0:8];
    reg [15:0] weight_reg_buf2 [0:8];
    
    reg weight_buf0_full;
    reg weight_buf1_full;
    reg weight_buf2_full;
    
    reg [11:0]r_next_cnt;
    reg [1:0] r_rcnt;
    reg [11:0] r_con_cnt;
    reg [3:0] r_con_num;
    
    reg read_en;
    reg buf_read_en;
    
    reg [1:0] remain;
    
    reg next=0;
    reg r_next;
    
    wire out_next;
    
    reg [63:0] weight_reg_din;
    
    reg [1:0]r_processing;
    
    wire ifm_weight_hs;
    
    reg buf_weight_buf0_full;
    reg buf_weight_buf1_full;
    reg buf_weight_buf2_full;
    
    reg buf_out_next0;
    reg buf_out_next1;
    reg buf_out_next2;
    reg buf_out_next3;
    reg buf_out_next4;
    reg buf_out_next5;
    reg buf_out_next6;
    reg buf_out_next7;
    reg buf_out_next8;
    reg buf_out_next9;
    reg buf_out_next10;
    reg buf_out_next11;
    reg buf_out_next12;
    reg buf_out_next13;
    reg buf_out_next14;
    reg buf_out_next15;
    
    reg full_en_hs0;
    reg full_en_hs1;
    
    
    reg [10:0]now_ok_cnt0;
    reg [10:0]now_ok_cnt1;
    
    reg now_ok0;
    reg now_ok1;
    
    reg [15:0]  A_low, B_low;
    reg [31:0]  part;
    
    reg [31:0] buf_no_weight_valid;
    reg [15:0] buf_no_weight_valid1;
    reg [15:0] buf_no_weight_valid2;
    reg [15:0] buf_no_weight_valid3;
    reg [31:0] no_weight_valid;
    reg [31:0] no_weight_valid1;
    reg [31:0] no_weight_valid2;
    reg [31:0] no_weight_valid3;
    
    //assign ila_no_weight_valid = no_weight_valid;
    
    reg [31:0] hs_cnt;
    reg [31:0] c_cnt;
    
    reg [31:0] c_cnt_finish;
    reg [15:0] buf_cnt_finish0;
    reg [3:0]ifm_channel_shift;
    
    
    reg buf_next;
    
    reg[15:0] hs_next_con_ifm0_hs;
    reg[15:0] hs_next_con_ifm1_hs;
    
    wire w_full_en_hs0;
    wire w_full_en_hs1;
    
    wire control;
    reg limit_80;
    
    assign w_full_en_hs0 = (weight0_bram_full & weight0_reg_read_en) || (weight2_bram_full & weight2_reg_read_en) || (weight4_bram_full & weight4_reg_read_en)
                           || (weight6_bram_full & weight6_reg_read_en)|| (weight8_bram_full & weight8_reg_read_en)|| (weight10_bram_full & weight10_reg_read_en)
                           || (weight12_bram_full & weight12_reg_read_en)|| (weight14_bram_full & weight14_reg_read_en)?1:0;
    
    assign w_full_en_hs1 = (weight1_bram_full & weight1_reg_read_en) || (weight3_bram_full & weight3_reg_read_en) || (weight5_bram_full & weight5_reg_read_en)
                           || (weight7_bram_full & weight7_reg_read_en)|| (weight9_bram_full & weight9_reg_read_en)|| (weight11_bram_full & weight11_reg_read_en)
                           || (weight13_bram_full & weight13_reg_read_en)|| (weight15_bram_full & weight15_reg_read_en)?1:0;
    
    assign ifm_weight_hs = weight_valid & ifm_valid & !w_full; //
    
    assign out_next = (out_next0 || out_next1 || out_next2 || out_next3 || out_next4 || out_next5 || out_next6 || out_next7
                 || out_next8 || out_next9 || out_next10 || out_next11 || out_next12 || out_next13 || out_next14 || out_next15);
    
    wire tick = next & (~buf_next);
    
    assign control = (r_next_cnt-80*r_con_num ==0 && r_next_cnt!=0);
    
    always@(*)begin
        if     (ifm_channel == 32)  ifm_channel_shift = 5 ;
        else if(ifm_channel == 64)  ifm_channel_shift = 6 ;
        else if(ifm_channel == 128) ifm_channel_shift = 7 ;
        else if(ifm_channel == 256) ifm_channel_shift = 8 ;
        else if(ifm_channel == 512) ifm_channel_shift = 9 ;
        else if(ifm_channel == 1024)ifm_channel_shift = 10;
        else                        ifm_channel_shift = 0;
    end
    
    always@(posedge clk)begin
        if(!rst_n || ap_done)begin
            next_con_ifm <= 0;
            prev_ifm <= 0;
            next_ifm <= 0;
            r_next_cnt <=0;
            r_rcnt <= 0;
            buf_write_flag <= 0 ;
            buf_read_flag <= 0;
            r_processing <= 0;
            weight_buf0_full <= 0;
            weight_buf1_full <= 0;
            weight_buf2_full <= 0;
            num <= 16;
            hs_cnt <=0 ;
            hs_next_con_ifm0 <= 0;
            hs_next_con_ifm1 <= 0;
            full_en_hs0 <= 0;
            full_en_hs1 <= 0;
            now_ok_cnt0 <= 0;
            now_ok_cnt1 <= 0;
            r_next <= 0;
            c_cnt<= 0;
            buf_cnt_finish0<=0;
            c_cnt_finish<=0;
            buf_next <= 0;
            next <= 0;
            buf_next_ifm0 <= 0;
            buf_next_ifm1 <= 0;
            buf_next_ifm2 <= 0;
            r_con_num<=0;
            r_con_cnt<=0;
            buf_no_weight_valid1<=0;
            buf_no_weight_valid2<=0;
            buf_no_weight_valid3<=0;
            no_weight_valid1<=0;
            no_weight_valid2<=0;
            hs_next_con_ifm0_hs<=0;
            hs_next_con_ifm1_hs<=0;
            A_low <=0;
            B_low <=0;
            part <=0;
            limit_80 <=0;
            buf_no_weight_valid <=0;
            buf_read_en <= 0;
            
            buf_weight_buf0_full <= 0;
            buf_weight_buf1_full <= 0;
            buf_weight_buf2_full <= 0;
            no_weight_valid <= 0;
            
            weight_reg_buf0[0] <=0; weight_reg_buf0[1] <=0; weight_reg_buf0[2] <=0; weight_reg_buf0[3] <=0; weight_reg_buf0[4] <=0; weight_reg_buf0[5] <=0; weight_reg_buf0[6] <=0; weight_reg_buf0[7] <=0; weight_reg_buf0[8] <=0;
            weight_reg_buf1[0] <=0; weight_reg_buf1[1] <=0; weight_reg_buf1[2] <=0; weight_reg_buf1[3] <=0; weight_reg_buf1[4] <=0; weight_reg_buf1[5] <=0; weight_reg_buf1[6] <=0; weight_reg_buf1[7] <=0; weight_reg_buf1[8] <=0;
            weight_reg_buf2[0] <=0; weight_reg_buf2[1] <=0; weight_reg_buf2[2] <=0; weight_reg_buf2[3] <=0; weight_reg_buf2[4] <=0; weight_reg_buf2[5] <=0; weight_reg_buf2[6] <=0; weight_reg_buf2[7] <=0; weight_reg_buf2[8] <=0;
        end else begin
            A_low <= repeat_ifm+1;
            B_low <= ifm_channel;
            part <= A_low * B_low;

            buf_no_weight_valid <= part;
            
            buf_no_weight_valid1 <= buf_no_weight_valid[31:16];
            buf_no_weight_valid2 <= buf_no_weight_valid[15:0];
            buf_no_weight_valid3 <= ofm_channel;
            
            //no_weight_valid1 <= buf_no_weight_valid1 * 0;
            no_weight_valid2 <= buf_no_weight_valid1 * buf_no_weight_valid3;
            no_weight_valid3 <= buf_no_weight_valid2 * buf_no_weight_valid3;
            
            //no_weight_valid <= (no_weight_valid1 << 32) + (no_weight_valid2 << 16) + no_weight_valid3;
            no_weight_valid <= (no_weight_valid2 << 16) + no_weight_valid3;
    
            if(next==1 && next_con_ifm==0) r_next <=0;
            else r_next <= next;
            
            case(total_ifm)
                418: c_cnt_finish <= 13311;
                210: c_cnt_finish <= 3327;
                106: c_cnt_finish <= 831;
                54: c_cnt_finish <= 207;
                28: c_cnt_finish <= 51;
                15: c_cnt_finish <= 12;
                default: c_cnt_finish <= 0;
            endcase
            buf_next<=next;
            if( next == 1 && ((r_next_cnt == next_ifm-1&&r_rcnt==2)||next_con_ifm ==0))begin
                next <= 0;
            end else if(out_next)begin
                next<= 1;
            end else begin
                next<=next;
            end
            if(tick)begin
                c_cnt<=c_cnt+1;
            end else begin
                if((r_next_cnt == next_ifm||next_con_ifm==0) && c_cnt_finish+1 ==c_cnt && c_cnt_finish !=0)begin
                    c_cnt <= 0;
                end else begin
                    c_cnt<=c_cnt;
                end
            end
            
            limit_80 <= (r_next_cnt == next_ifm-1 && r_rcnt ==1&&c_cnt_finish+1 !=c_cnt);
            
            if(prev_ifm ==0)begin
                case (ifm_channel)
                    default: next_ifm <= 0;
                    3: next_ifm <= 1;
                    32: next_ifm <= 16;
                    64: next_ifm <= 48;
                    128: next_ifm <= 48;
                    256: next_ifm <= 176;
                    512: next_ifm <= 432;
                    1024: next_ifm <= 944;
                    1280: next_ifm <= 1200; 
                endcase
            end else begin
                buf_next_ifm0 <= (80 -prev_ifm);
                buf_next_ifm1 <= buf_next_ifm0 >> ifm_channel_shift;
                buf_next_ifm2 <= buf_next_ifm0 - (buf_next_ifm1 << ifm_channel_shift);
                next_ifm <= ifm_channel - buf_next_ifm2;
            end
            
            if(next_ifm>80&& r_next_cnt!=0)begin
                if(r_next_cnt-80*r_con_num ==0 )begin
                    r_con_cnt <= r_con_cnt+1;
                    r_con_num <= r_con_num+1;
                end else begin
                    r_con_cnt <= r_con_cnt;
                    r_con_num <= r_con_num;
                end
                next_con_ifm <= next_ifm - 80 * r_con_cnt;
            end else begin
                r_con_cnt <= 0;
                r_con_num <= 1;
                if (next_ifm == ifm_channel)next_con_ifm<=0;
                else next_con_ifm <= next_ifm;
            end
            
            if (r_next_cnt == next_ifm&&c_cnt_finish+1 ==c_cnt && c_cnt_finish !=0 && next_con_ifm==80 )begin
                prev_ifm <=0;
            end else if((r_next_cnt == next_ifm||next_con_ifm==0) && c_cnt_finish+1 ==c_cnt && c_cnt_finish !=0)begin
                prev_ifm <= next_con_ifm;
            end else begin
                prev_ifm <= prev_ifm;
            end
            
            num <= read_state;
            
            if(r_next==1&&r_next_cnt == next_ifm&&save_state!=num)begin buf_read_en <= 0; end
            else buf_read_en <= read_en;
            
            if(full_en_hs0)begin
                hs_next_con_ifm0 <= next_ifm;
                hs_next_con_ifm0_hs <= next_ifm*3-1;
            end else begin
                hs_next_con_ifm0 <= hs_next_con_ifm0;
            end
            
            if(full_en_hs1)begin
                hs_next_con_ifm1 <= next_ifm;
                hs_next_con_ifm1_hs <= next_ifm*3-1;
            end else begin
                hs_next_con_ifm1 <= hs_next_con_ifm1;
            end
            
            if(now_ok0 ==1)begin
                now_ok_cnt0 <= now_ok_cnt0+1;
            end else begin
                now_ok_cnt0 <= 0;
            end
            
            if(now_ok1 ==1)begin
                now_ok_cnt1 <= now_ok_cnt1+1;
            end else begin
                now_ok_cnt1 <= 0;
            end
            
            //buf read_en fix plz -> if read_sate is change buf_read_en have to go 0 1 clk(after 1clk, rise up.)
            buf_weight_buf0_full <= weight_buf0_full;
            buf_weight_buf1_full <= weight_buf1_full;
            buf_weight_buf2_full <= weight_buf2_full;
            
            buf_out_next0 <= out_next0;
            buf_out_next1 <= out_next1;
            buf_out_next2 <= out_next2;
            buf_out_next3 <= out_next3;
            buf_out_next4 <= out_next4;
            buf_out_next5 <= out_next5;
            buf_out_next6 <= out_next6;
            buf_out_next7 <= out_next7;
            buf_out_next8 <= out_next8;
            buf_out_next9 <= out_next9;
            buf_out_next10 <= out_next10;
            buf_out_next11 <= out_next11;
            buf_out_next12 <= out_next12;
            buf_out_next13 <= out_next13;
            buf_out_next14 <= out_next14;
            buf_out_next15 <= out_next15;
            
            full_en_hs0 <= w_full_en_hs0;
            full_en_hs1 <= w_full_en_hs1;
            
            
            if(next ==1)begin
                if (r_rcnt ==2 && read_en)begin
                    r_rcnt <=0;
                    r_next_cnt <= r_next_cnt +1;
                end else if( (num== read_state||!out_next)&&r_rcnt !=2 && read_en)begin
                    r_rcnt <= r_rcnt+1;
                end else begin
                    r_rcnt <= r_rcnt;
                end
            end else begin
                r_next_cnt <=0;
                r_rcnt <= 0;
            end
            //read to bram state define
            if(buf_read_en)begin
                case(buf_read_flag)
                    0:begin
                        case(remain)
                            0:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 4; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[i * 16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 4; i < 8; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i - 4) * 16 +: 16];
                                        end
                                        r_processing <= 2;
                                        if (read_en) weight_buf0_full <= 1;
                                    end
                                    2: begin
                                        weight_reg_buf0[8] <= weight_reg_din[0 +: 16];
                                        buf_read_flag <= 1;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            3:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 3; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i + 1) * 16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 3; i < 7; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i - 3) * 16 +: 16];
                                        end
                                        r_processing <= 2;
                                        if (read_en) weight_buf0_full <= 1;
                                    end
                                    2: begin
                                        weight_reg_buf0[7] <= weight_reg_din[0 +: 16];
                                        weight_reg_buf0[8] <= weight_reg_din[16 +: 16];
                                        buf_read_flag <= 1;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            2:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 2; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i + 2) * 16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 2; i < 6; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i - 2) * 16 +: 16];
                                        end
                                        r_processing <= 2;
                                        if (read_en) weight_buf0_full <= 1;
                                    end
                                    2: begin
                                        weight_reg_buf0[6] <= weight_reg_din[0 +: 16];
                                        weight_reg_buf0[7] <= weight_reg_din[16 +: 16];
                                        weight_reg_buf0[8] <= weight_reg_din[32 +: 16];
                                        buf_read_flag <= 1;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            1:begin
                                case(r_processing)
                                    0: begin
                                        weight_reg_buf0[0] <= weight_reg_din[48 +: 16];
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 1; i < 5; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i-1)*16 +: 16];
                                        end
                                        r_processing <= 2;
                                        if(read_en) weight_buf0_full <= 1;
                                    end
                                    2: begin
                                        for (i = 5; i < 9; i = i + 1) begin
                                            weight_reg_buf0[i] <= weight_reg_din[(i-5)*16 +: 16];
                                        end
                                        buf_read_flag <= 1;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                        endcase
                      end
                    1:begin
                        case(remain)
                            0:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 4; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[i*16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 4; i < 8; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i-4)*16 +: 16];
                                        end
                                        if(read_en) weight_buf1_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        weight_reg_buf1[8] <= weight_reg_din[0 +: 16];
                                        buf_read_flag <= 2;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            3:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 3; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i+1)*16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 3; i < 7; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i-3)*16 +: 16];
                                        end
                                        if(read_en) weight_buf1_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        weight_reg_buf1[7] <= weight_reg_din[0 +: 16];
                                        weight_reg_buf1[8] <= weight_reg_din[16 +: 16];
                                        buf_read_flag <= 2;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            2:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 2; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i+2)*16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 2; i < 6; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i-2)*16 +: 16];
                                        end
                                        if(read_en) weight_buf1_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        weight_reg_buf1[6] <= weight_reg_din[0 +: 16];
                                        weight_reg_buf1[7] <= weight_reg_din[16 +: 16];
                                        weight_reg_buf1[8] <= weight_reg_din[32 +: 16];
                                        buf_read_flag <= 2;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            1:begin
                                case(r_processing)
                                    0: begin
                                        weight_reg_buf1[0] <= weight_reg_din[48 +: 16];
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 1; i < 5; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i-1)*16 +: 16];
                                        end
                                        if(read_en) weight_buf1_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        for (i = 5; i < 9; i = i + 1) begin
                                            weight_reg_buf1[i] <= weight_reg_din[(i-5)*16 +: 16];
                                        end
                                        buf_read_flag <= 2;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                        endcase
                      end
                    2:begin
                        case(remain)
                            0:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 4; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[i*16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 4; i < 8; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i-4)*16 +: 16];
                                        end
                                        if(read_en) weight_buf2_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        weight_reg_buf2[8] <= weight_reg_din[0 +: 16];
                                        buf_read_flag <= 0;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            3:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 3; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i+1)*16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 3; i < 7; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i-3)*16 +: 16];
                                        end
                                        if(read_en) weight_buf2_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        weight_reg_buf2[7] <= weight_reg_din[0 +: 16];
                                        weight_reg_buf2[8] <= weight_reg_din[16 +: 16];
                                        buf_read_flag <= 0;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            2:begin
                                case(r_processing)
                                    0: begin
                                        for (i = 0; i < 2; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i+2)*16 +: 16];
                                        end
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 2; i < 6; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i-2)*16 +: 16];
                                        end
                                        if(read_en) weight_buf2_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        weight_reg_buf2[6] <= weight_reg_din[0 +: 16];
                                        weight_reg_buf2[7] <= weight_reg_din[16 +: 16];
                                        weight_reg_buf2[8] <= weight_reg_din[32 +: 16];
                                        buf_read_flag <= 0;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                            1:begin
                                case(r_processing)
                                    0: begin
                                        weight_reg_buf2[0] <= weight_reg_din[48 +: 16];
                                        r_processing <= 1;
                                    end
                                    1: begin
                                        for (i = 1; i < 5; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i-1)*16 +: 16];
                                        end
                                        if(read_en) weight_buf2_full <= 1;
                                        r_processing <= 2;
                                    end
                                    2: begin
                                        for (i = 5; i < 9; i = i + 1) begin
                                            weight_reg_buf2[i] <= weight_reg_din[(i-5)*16 +: 16];
                                        end
                                        buf_read_flag <= 0;
                                        r_processing <= 0;
                                    end
                                endcase
                              end
                        endcase
                      end
                endcase
            end else begin
            end
            
            //end of bram state define
            //write to convolution machine
            if(weight_buf0_full && buf_write_flag == 0 && ifm_weight_hs )begin
                buf_write_flag <= 1 ;
                weight_buf0_full <= 0;
                hs_cnt <= hs_cnt+1;
            end else if(weight_buf1_full && buf_write_flag == 1 && ifm_weight_hs )begin
                buf_write_flag <= 2 ;
                weight_buf1_full <= 0;
                hs_cnt <= hs_cnt+1;
            end else if(weight_buf2_full && buf_write_flag == 2 && ifm_weight_hs )begin
                buf_write_flag <= 0 ;
                weight_buf2_full <= 0;
                hs_cnt <= hs_cnt+1;
            end else begin
                hs_cnt <= hs_cnt;
                //buf_write_flag <= buf_write_flag;
                //weight_buf0_full <= weight_buf0_full;
                //weight_buf1_full <= weight_buf1_full;
                //weight_buf2_full <= weight_buf2_full;
            end
            
            
           
            
            //end of write
        end
    end 
    
    
    
    always@(posedge clk)begin
        if(!rst_n||ap_done)begin
            save_state <= 0;
            con_ifm_channel <= 0;
            read_en <= 0;
            weight0_reg_read_en <= 0;
            weight1_reg_read_en <= 0;
            weight2_reg_read_en <= 0;
            weight3_reg_read_en <= 0;
            weight4_reg_read_en <= 0;
            weight5_reg_read_en <= 0;
            weight6_reg_read_en <= 0;
            weight7_reg_read_en <= 0;
            weight8_reg_read_en <= 0;
            weight9_reg_read_en <= 0;
            weight10_reg_read_en <= 0;
            weight11_reg_read_en <= 0;
            weight12_reg_read_en <= 0;
            weight13_reg_read_en <= 0;
            weight14_reg_read_en <= 0;
            weight15_reg_read_en <= 0;
            remain <= 0;
            now_ok0 <= 0;
            now_ok1 <= 0;
        end else begin
            case(num)
                default : begin 
                                read_en <= 0;
                                remain <= 0;
                                //weight_reg_din<= 0;
                                save_state <= 0;
                                if(weight0_bram_full)begin
                                    con_ifm_channel <= ifm_channel;
                                end else begin 
                                    con_ifm_channel <=0;
                                end
                        end
                0 : begin
                        if (weight0_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next0&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight1_reg_read_en <= 1;
                                remain <= remain0;
                                weight0_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight0_reg_read_en <= 0; 
                                    remain <= remain0; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight0_reg_read_en <= 0; 
                                    remain <= remain1; 
                                end else begin 
                                    weight0_reg_read_en <= 1; 
                                    remain <= remain0; 
                                end
                                weight1_reg_read_en <= weight1_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;//trouble maker
                            //else if(r_processing ==1 & read_en & (!ifm_weight_hs) & ((weight_buf0_full & weight_buf1_full) |(weight_buf1_full & weight_buf2_full) | (weight_buf0_full & weight_buf2_full)))read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight0_bram_full & !ifm_weight_hs)begin
                                weight0_reg_read_en <= 0;
                                weight1_reg_read_en <= 0;
                            end else begin
                                weight0_reg_read_en <= 0;
                                weight1_reg_read_en <= weight1_reg_read_en;
                            end
                            if(!weight0_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain1; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain1; 
                                else remain <= remain0; 
                            end
                        end
                        if (buf_out_next0 && weight0_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight0_bram_full) begin 
                            if(weight1_bram_full) save_state <= 1;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                1 : begin
                        if (weight1_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next1&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight2_reg_read_en <= 1;
                                remain <= remain1;
                                weight1_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight1_reg_read_en <= 0;
                                    remain <= remain1;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight1_reg_read_en <= 0; 
                                    remain <= remain2;
                                end else begin
                                    weight1_reg_read_en <= 1;
                                    remain <= remain1;
                                end
                                weight2_reg_read_en <= weight2_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight1_bram_full & !ifm_weight_hs)begin
                                weight1_reg_read_en <= 0;
                                weight2_reg_read_en <= 0;
                            end else begin
                                weight1_reg_read_en <= 0;
                                weight2_reg_read_en <= weight2_reg_read_en;
                            end
                            if(!weight1_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain2; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain2; 
                                else remain <= remain1; 
                            end
                        end
                        if (buf_out_next1 && weight1_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight1_bram_full) begin 
                            if(weight2_bram_full) save_state <= 2;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                2 : begin
                        if (weight2_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next2&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight3_reg_read_en <= 1;
                                remain <= remain2;
                                weight2_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight2_reg_read_en <= 0; 
                                    remain <= remain2; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight2_reg_read_en <= 0; 
                                    remain <= remain3; 
                                end else begin 
                                    weight2_reg_read_en <= 1; 
                                    remain <= remain2; 
                                end
                                weight3_reg_read_en <= weight3_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight2_bram_full & !ifm_weight_hs)begin
                                weight2_reg_read_en <= 0;
                                weight3_reg_read_en <= 0;
                            end else begin
                                weight2_reg_read_en <= 0;
                                weight3_reg_read_en <= weight3_reg_read_en;
                            end
                            if(!weight2_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain3; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain3; 
                                else remain <= remain2; 
                            end
                        end
                        if (buf_out_next2 && weight2_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight2_bram_full) begin 
                            if(weight3_bram_full) save_state <= 3;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                3 : begin
                        if (weight3_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next3&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight4_reg_read_en <= 1;
                                remain <= remain3;
                                weight3_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight3_reg_read_en <= 0;
                                    remain <= remain3;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight3_reg_read_en <= 0; 
                                    remain <= remain4;
                                end else begin
                                    weight3_reg_read_en <= 1;
                                    remain <= remain3;
                                end
                                weight4_reg_read_en <= weight4_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight3_bram_full & !ifm_weight_hs)begin
                                weight3_reg_read_en <= 0;
                                weight4_reg_read_en <= 0;
                            end else begin
                                weight3_reg_read_en <= 0;
                                weight4_reg_read_en <= weight4_reg_read_en;
                            end
                            if(!weight3_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain4; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain4; 
                                else remain <= remain3; 
                            end
                        end
                        if (buf_out_next3 && weight3_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight3_bram_full) begin 
                            if(weight4_bram_full) save_state <= 4;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                4 : begin
                        if (weight4_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next4&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight5_reg_read_en <= 1;
                                remain <= remain4;
                                weight4_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight4_reg_read_en <= 0; 
                                    remain <= remain4; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight4_reg_read_en <= 0; 
                                    remain <= remain5; 
                                end else begin 
                                    weight4_reg_read_en <= 1; 
                                    remain <= remain4; 
                                end
                                weight5_reg_read_en <= weight5_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight4_bram_full & !ifm_weight_hs)begin
                                weight4_reg_read_en <= 0;
                                weight5_reg_read_en <= 0;
                            end else begin
                                weight4_reg_read_en <= 0;
                                weight5_reg_read_en <= weight5_reg_read_en;
                            end
                            if(!weight4_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain5; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain5; 
                                else remain <= remain4; 
                            end
                        end
                        if (buf_out_next4 && weight4_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight4_bram_full) begin 
                            if(weight5_bram_full) save_state <= 5;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                5 : begin
                        if (weight5_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next5&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight6_reg_read_en <= 1;
                                remain <= remain5;
                                weight5_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight5_reg_read_en <= 0;
                                    remain <= remain5;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight5_reg_read_en <= 0; 
                                    remain <= remain6;
                                end else begin
                                    weight5_reg_read_en <= 1;
                                    remain <= remain5;
                                end
                                weight6_reg_read_en <= weight6_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight5_bram_full & !ifm_weight_hs)begin
                                weight5_reg_read_en <= 0;
                                weight6_reg_read_en <= 0;
                            end else begin
                                weight5_reg_read_en <= 0;
                                weight6_reg_read_en <= weight6_reg_read_en;
                            end
                            if(!weight5_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain6; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain6; 
                                else remain <= remain5; 
                            end
                        end
                        if (buf_out_next5 && weight5_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight5_bram_full) begin 
                            if(weight6_bram_full) save_state <= 6;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                6 : begin
                        if (weight6_bram_full && ((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next6&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight7_reg_read_en <= 1;
                                remain <= remain6;
                                weight6_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight6_reg_read_en <= 0; 
                                    remain <= remain6; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight6_reg_read_en <= 0; 
                                    remain <= remain7; 
                                end else begin 
                                    weight6_reg_read_en <= 1; 
                                    remain <= remain6; 
                                end
                                weight7_reg_read_en <= weight7_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight6_bram_full & !ifm_weight_hs)begin
                                weight6_reg_read_en <= 0;
                                weight7_reg_read_en <= 0;
                            end else begin
                                weight6_reg_read_en <= 0;
                                weight7_reg_read_en <= weight7_reg_read_en;
                            end
                            if(!weight6_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain7; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain7; 
                                else remain <= remain6; 
                            end
                        end
                        if (buf_out_next6 && weight6_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight6_bram_full) begin 
                            if(weight7_bram_full) save_state <= 7;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                7 : begin
                        if (weight7_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next7&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight8_reg_read_en <= 1;
                                remain <= remain7;
                                weight7_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight7_reg_read_en <= 0;
                                    remain <= remain7;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight7_reg_read_en <= 0; 
                                    remain <= remain8;
                                end else begin
                                    weight7_reg_read_en <= 1;
                                    remain <= remain7;
                                end
                                weight8_reg_read_en <= weight8_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight7_bram_full & !ifm_weight_hs)begin
                                weight7_reg_read_en <= 0;
                                weight8_reg_read_en <= 0;
                            end else begin
                                weight7_reg_read_en <= 0;
                                weight8_reg_read_en <= weight8_reg_read_en;
                            end
                            if(!weight7_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain8; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain8; 
                                else remain <= remain7; 
                            end
                        end
                        if (buf_out_next7 && weight7_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight7_bram_full) begin 
                            if(weight8_bram_full) save_state <= 8;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                8 : begin
                        if (weight8_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next8&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight9_reg_read_en <= 1;
                                remain <= remain8;
                                weight8_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight8_reg_read_en <= 0; 
                                    remain <= remain8; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight8_reg_read_en <= 0; 
                                    remain <= remain9; 
                                end else begin 
                                    weight8_reg_read_en <= 1; 
                                    remain <= remain8; 
                                end
                                weight9_reg_read_en <= weight9_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight8_bram_full & !ifm_weight_hs)begin
                                weight8_reg_read_en <= 0;
                                weight9_reg_read_en <= 0;
                            end else begin
                                weight8_reg_read_en <= 0;
                                weight9_reg_read_en <= weight9_reg_read_en;
                            end
                            if(!weight8_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain9; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain9; 
                                else remain <= remain8; 
                            end
                        end
                        if (buf_out_next8 && weight8_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight8_bram_full) begin 
                            if(weight9_bram_full) save_state <= 9;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                9 : begin
                        if (weight9_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next9&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight10_reg_read_en <= 1;
                                remain <= remain9;
                                weight9_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight9_reg_read_en <= 0;
                                    remain <= remain9;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight9_reg_read_en <= 0; 
                                    remain <= remain10;
                                end else begin
                                    weight9_reg_read_en <= 1;
                                    remain <= remain9;
                                end
                                weight10_reg_read_en <= weight10_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight9_bram_full & !ifm_weight_hs)begin
                                weight9_reg_read_en <= 0;
                                weight10_reg_read_en <= 0;
                            end else begin
                                weight9_reg_read_en <= 0;
                                weight10_reg_read_en <= weight10_reg_read_en;
                            end
                            if(!weight9_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain10; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain10; 
                                else remain <= remain9; 
                            end
                        end
                        if (buf_out_next9 && weight9_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight9_bram_full) begin 
                            if(weight10_bram_full) save_state <= 10;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                10 : begin
                        if (weight10_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next10&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight11_reg_read_en <= 1;
                                remain <= remain10;
                                weight10_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight10_reg_read_en <= 0; 
                                    remain <= remain10; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight10_reg_read_en <= 0; 
                                    remain <= remain11; 
                                end else begin 
                                    weight10_reg_read_en <= 1; 
                                    remain <= remain10; 
                                end
                                weight11_reg_read_en <= weight11_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight10_bram_full & !ifm_weight_hs)begin
                                weight10_reg_read_en <= 0;
                                weight11_reg_read_en <= 0;
                            end else begin
                                weight10_reg_read_en <= 0;
                                weight11_reg_read_en <= weight11_reg_read_en;
                            end
                            if(!weight10_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain11; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain11; 
                                else remain <= remain10; 
                            end
                        end
                        if (buf_out_next10 && weight10_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight10_bram_full) begin 
                            if(weight11_bram_full) save_state <= 11;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                11 : begin
                        if (weight11_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next11&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight12_reg_read_en <= 1;
                                remain <= remain11;
                                weight11_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight11_reg_read_en <= 0;
                                    remain <= remain11;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight11_reg_read_en <= 0; 
                                    remain <= remain12;
                                end else begin
                                    weight11_reg_read_en <= 1;
                                    remain <= remain11;
                                end
                                weight12_reg_read_en <= weight12_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight11_bram_full & !ifm_weight_hs)begin
                                weight11_reg_read_en <= 0;
                                weight12_reg_read_en <= 0;
                            end else begin
                                weight11_reg_read_en <= 0;
                                weight12_reg_read_en <= weight12_reg_read_en;
                            end
                            if(!weight11_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain12; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain12; 
                                else remain <= remain11; 
                            end
                        end
                        if (buf_out_next11 && weight11_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight11_bram_full) begin 
                            if(weight12_bram_full) save_state <= 12;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                12 : begin
                        if (weight12_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next12&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight13_reg_read_en <= 1;
                                remain <= remain12;
                                weight12_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight12_reg_read_en <= 0; 
                                    remain <= remain12; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight12_reg_read_en <= 0; 
                                    remain <= remain13; 
                                end else begin 
                                    weight12_reg_read_en <= 1; 
                                    remain <= remain12; 
                                end
                                weight13_reg_read_en <= weight13_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight12_bram_full & !ifm_weight_hs)begin
                                weight12_reg_read_en <= 0;
                                weight13_reg_read_en <= 0;
                            end else begin
                                weight12_reg_read_en <= 0;
                                weight13_reg_read_en <= weight13_reg_read_en;
                            end
                            if(!weight12_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain13; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain13; 
                                else remain <= remain12; 
                            end
                        end
                        if (buf_out_next12 && weight12_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight12_bram_full) begin 
                            if(weight13_bram_full) save_state <= 13;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                13 : begin
                        if (weight13_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next13&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight14_reg_read_en <= 1;
                                remain <= remain13;
                                weight13_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight13_reg_read_en <= 0;
                                    remain <= remain13;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight13_reg_read_en <= 0; 
                                    remain <= remain14;
                                end else begin
                                    weight13_reg_read_en <= 1;
                                    remain <= remain13;
                                end
                                weight14_reg_read_en <= weight14_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight13_bram_full & !ifm_weight_hs)begin
                                weight13_reg_read_en <= 0;
                                weight14_reg_read_en <= 0;
                            end else begin
                                weight13_reg_read_en <= 0;
                                weight14_reg_read_en <= weight14_reg_read_en;
                            end
                            if(!weight13_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain14; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain14; 
                                else remain <= remain13; 
                            end
                        end
                        if (buf_out_next13 && weight13_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight13_bram_full) begin 
                            if(weight14_bram_full) save_state <= 14;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
                14 : begin
                        if (weight14_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next14&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight15_reg_read_en <= 1;
                                remain <= remain14;
                                weight14_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight14_reg_read_en <= 0; 
                                    remain <= remain14; 
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight14_reg_read_en <= 0; 
                                    remain <= remain15; 
                                end else begin 
                                    weight14_reg_read_en <= 1; 
                                    remain <= remain14; 
                                end
                                weight15_reg_read_en <= weight15_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm && save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight14_bram_full & !ifm_weight_hs)begin
                                weight14_reg_read_en <= 0;
                                weight15_reg_read_en <= 0;
                            end else begin
                                weight14_reg_read_en <= 0;
                                weight15_reg_read_en <= weight15_reg_read_en;
                            end
                            if(!weight14_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain15; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain15; 
                                else remain <= remain14; 
                            end
                        end
                        if (buf_out_next14 && weight14_bram_full&& next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight14_bram_full) begin 
                            if(weight15_bram_full) save_state <= 15;//
                            else save_state <= save_state; 
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel = hs_next_con_ifm0; 
                                now_ok0 <= 1;
                                now_ok1 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0)) begin 
                            con_ifm_channel = ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin 
                            if(now_ok_cnt1<hs_next_con_ifm1_hs && now_ok1==1)begin
                                now_ok1 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok1 <= 0;
                                if(next ==1&&save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok0 <= 0;
                        end
                     end
                15 : begin
                        if (weight15_bram_full &&((!weight_buf0_full||!weight_buf1_full||!weight_buf2_full) || ifm_weight_hs))begin
                            if(out_next15&&(next_con_ifm!=0 || c_cnt_finish == c_cnt)&&!limit_80)begin
                                weight0_reg_read_en <= 1;
                                remain <= remain15;
                                weight15_reg_read_en <= 0;
                            end else begin
                                if(((r_next == 1 && r_next_cnt == next_ifm-1 && r_rcnt ==2)||r_next_cnt == next_ifm)&& save_state !=num)begin
                                    weight15_reg_read_en <= 0;
                                    remain <= remain15;
                                end else if((tick==1 &&next_con_ifm!=0) || control)begin 
                                    weight15_reg_read_en <= 0; 
                                    remain <= remain0;
                                end else begin
                                    weight15_reg_read_en <= 1;
                                    remain <= remain15;
                                end
                                weight0_reg_read_en <= weight0_reg_read_en;
                            end
                            if(r_next_cnt == next_ifm&& save_state !=num) read_en <= 0;
                            else read_en <= 1;
                        end else begin
                            if(weight15_bram_full & !ifm_weight_hs)begin
                                weight15_reg_read_en <= 0;
                                weight0_reg_read_en <= 0;
                            end else begin
                                weight15_reg_read_en <= 0;
                                weight0_reg_read_en <= weight0_reg_read_en;
                            end
                            if(!weight15_bram_full)begin 
                                read_en <= 1; 
                                remain <= remain0; 
                            end else begin 
                                read_en <= 0; 
                                if((tick==1 &&next_con_ifm!=0) || control) remain <= remain0; 
                                else remain <= remain15; 
                            end
                        end
                        if (buf_out_next15 && weight15_bram_full && next_con_ifm !=0) begin
                            con_ifm_channel <= next_con_ifm;
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else if(!weight15_bram_full) begin 
                            if(weight0_bram_full) save_state <= 0;
                            else save_state <= save_state;
                            if(r_next_cnt != next_ifm&& next_con_ifm !=0)begin
                                con_ifm_channel <= hs_next_con_ifm1; 
                                now_ok1 <= 1;
                                now_ok0 <= 0;
                            end else begin
                                con_ifm_channel <= ifm_channel; 
                                now_ok1 <= 0;
                                now_ok0 <= 0;
                            end
                        end else if( r_next == 1 && (r_next_cnt == next_ifm || next_con_ifm ==0)) begin 
                            con_ifm_channel <= ifm_channel; 
                            save_state <= save_state;
                            now_ok0 <= 0;
                            now_ok1 <= 0;
                        end else begin
                            if(now_ok_cnt0<hs_next_con_ifm0_hs && now_ok0==1)begin
                                now_ok0 <= 1;
                                con_ifm_channel <= next_con_ifm;
                            end else begin
                                now_ok0 <= 0;
                                if(next ==1 && save_state!=num) con_ifm_channel <= next_con_ifm;
                                else con_ifm_channel <= ifm_channel;
                            end
                            save_state <= save_state;
                            now_ok1 <= 0;
                        end
                    end
            endcase
            // end read state
        end
    end
    
    
    always@(*)begin
        if(ap_done)begin
            weight_valid = 0;
            weight_data_in0 = 0;
            weight_data_in1 = 0;
            weight_data_in2 = 0;
            weight_data_in3 = 0;
            weight_data_in4 = 0;
            weight_data_in5 = 0;
            weight_data_in6 = 0;
            weight_data_in7 = 0;
            weight_data_in8 = 0;
            weight_reg_din = 0;
            read_state = 16;
        end else begin
            //weight_reg_din = 0;
            read_state = num;
            case(num)
              default : begin
                        if(weight0_bram_full) read_state = 0;
                        else read_state = 16;
                        weight_reg_din = 0;
                end
              0:begin
                        if ((buf_out_next0 && weight0_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight0_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 0;
                        if(full_en_hs1) weight_reg_din = weight15_reg_din;
                        else weight_reg_din = weight0_reg_din;
                end
              1:begin
                        if ((buf_out_next1 && weight1_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight1_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 1;
                        if(full_en_hs0) weight_reg_din = weight0_reg_din;
                        else weight_reg_din = weight1_reg_din;
                end
              2:begin
                        if ((buf_out_next2 && weight2_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight2_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 2;
                        if(full_en_hs1) weight_reg_din = weight1_reg_din;
                        else weight_reg_din = weight2_reg_din;
                end
              3:begin
                        if ((buf_out_next3 && weight3_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight3_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 3;
                        if(full_en_hs0) weight_reg_din = weight2_reg_din;
                        else weight_reg_din = weight3_reg_din;
                end
              4:begin
                        if ((buf_out_next4 && weight4_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight4_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 4;
                        if(full_en_hs1) weight_reg_din = weight3_reg_din;
                        else weight_reg_din = weight4_reg_din;
                end
              5:begin
                        if ((buf_out_next5 && weight5_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight5_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 5;
                        if(full_en_hs0) weight_reg_din = weight4_reg_din;
                        else weight_reg_din = weight5_reg_din;
                end
              6:begin
                        if ((buf_out_next6 && weight6_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight6_bram_full) begin
                            read_state = 7;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 6;
                        if(full_en_hs1) weight_reg_din = weight5_reg_din;
                        else weight_reg_din = weight6_reg_din;
                end
              7:begin
                        if ((buf_out_next7 && weight7_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight7_bram_full) begin
                            read_state = 8;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 7;
                        if(full_en_hs0) weight_reg_din = weight6_reg_din;
                        else weight_reg_din = weight7_reg_din;
                end
              8:begin
                        if ((buf_out_next8 && weight8_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight8_bram_full) begin
                            read_state = 9;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 8;
                        if(full_en_hs1) weight_reg_din = weight7_reg_din;
                        else weight_reg_din = weight8_reg_din;
                end
              9:begin
                        if ((buf_out_next9 && weight9_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight9_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 9;
                        if(full_en_hs0) weight_reg_din = weight8_reg_din;
                        else weight_reg_din = weight9_reg_din;
                end
              10:begin
                        if ((buf_out_next10 && weight10_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight10_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 10;
                        if(full_en_hs1) weight_reg_din = weight9_reg_din;
                        else weight_reg_din = weight10_reg_din;
                end
              11:begin
                        if ((buf_out_next11 && weight11_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight11_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 11;
                        if(full_en_hs0) weight_reg_din = weight10_reg_din;
                        else weight_reg_din = weight11_reg_din;
                end
              12:begin
                        if ((buf_out_next12 && weight12_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight12_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 12;
                        if(full_en_hs1) weight_reg_din = weight11_reg_din;
                        else weight_reg_din = weight12_reg_din;
                end
              13:begin
                        if ((buf_out_next13 && weight13_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight13_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end// else read_state = 13;
                        if(full_en_hs0) weight_reg_din = weight12_reg_din;
                        else weight_reg_din = weight13_reg_din;
                end
              14:begin
                        if ((buf_out_next14 && weight14_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight14_bram_full) begin
                            read_state = read_state + 1;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end// else read_state = 14;
                        if(full_en_hs1) weight_reg_din = weight13_reg_din;
                        else weight_reg_din = weight14_reg_din;
                end
              15:begin
                        if ((buf_out_next15 && weight15_bram_full && r_next_cnt != next_ifm&&next_con_ifm !=0)||!weight15_bram_full) begin
                            read_state = 0;
                        end else if( r_next == 1 && (r_next_cnt == next_ifm||next_con_ifm ==0))begin
                            read_state = save_state;
                        end //else read_state = 15;
                        if(full_en_hs0) weight_reg_din = weight14_reg_din;
                        else weight_reg_din = weight15_reg_din;
                end
            endcase
        
            if(buf_weight_buf0_full && buf_write_flag == 0 )begin
                if(no_weight_valid == hs_cnt)begin
                    weight_valid = 0;
                end else begin
                    weight_valid = 1;
                end
                
                weight_data_in0 = weight_reg_buf0[0];
                weight_data_in1 = weight_reg_buf0[1];
                weight_data_in2 = weight_reg_buf0[2];
                weight_data_in3 = weight_reg_buf0[3];
                weight_data_in4 = weight_reg_buf0[4];
                weight_data_in5 = weight_reg_buf0[5];
                weight_data_in6 = weight_reg_buf0[6];
                weight_data_in7 = weight_reg_buf0[7];
                weight_data_in8 = weight_reg_buf0[8];
            end else if(buf_weight_buf1_full && buf_write_flag == 1 )begin
                if(no_weight_valid == hs_cnt)begin
                    weight_valid = 0;
                end else begin
                    weight_valid = 1;
                end
                weight_data_in0 = weight_reg_buf1[0];
                weight_data_in1 = weight_reg_buf1[1];
                weight_data_in2 = weight_reg_buf1[2];
                weight_data_in3 = weight_reg_buf1[3];
                weight_data_in4 = weight_reg_buf1[4];
                weight_data_in5 = weight_reg_buf1[5];
                weight_data_in6 = weight_reg_buf1[6];
                weight_data_in7 = weight_reg_buf1[7];
                weight_data_in8 = weight_reg_buf1[8];
            end else if(buf_weight_buf2_full && buf_write_flag == 2 )begin
                if(no_weight_valid == hs_cnt)begin
                    weight_valid = 0;
                end else begin
                    weight_valid = 1;
                end
                weight_data_in0 = weight_reg_buf2[0];
                weight_data_in1 = weight_reg_buf2[1];
                weight_data_in2 = weight_reg_buf2[2];
                weight_data_in3 = weight_reg_buf2[3];
                weight_data_in4 = weight_reg_buf2[4];
                weight_data_in5 = weight_reg_buf2[5];
                weight_data_in6 = weight_reg_buf2[6];
                weight_data_in7 = weight_reg_buf2[7];
                weight_data_in8 = weight_reg_buf2[8];
            end else begin
                weight_valid = 0;
                weight_data_in0 = 0;
                weight_data_in1 = 0;
                weight_data_in2 = 0;
                weight_data_in3 = 0;
                weight_data_in4 = 0;
                weight_data_in5 = 0;
                weight_data_in6 = 0;
                weight_data_in7 = 0;
                weight_data_in8 = 0;
            end
        end
    end
endmodule
