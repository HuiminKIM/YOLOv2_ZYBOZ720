`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/16 10:40:18
// Design Name: 
// Module Name: HP_2_top_controller
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


module HP_2_top_controller(
    input clk,
    input rst_n,
    input rdma2_start,
    input rdma2_done,
    input is_conv_1,
    input is_maxpooling,
    input is_conv_3,
    input [8:0] ifm_width,
    input [10:0] ifm_channel,
    input rdma2_valid,
    input [63:0] rdma2_data,
    output [63:0] bram_0_data,
    output [63:0] bram_1_data,
    output [63:0] bram_2_data,
    output [64*12-1:0] ifm_bram_data,
    output bram_full,
    /*output din_full0,
    output din_full1,
    output din_full2,*/
    output [11:0] ifm_bram_full,
    input dout_valid0,
    input dout_valid1,
    input dout_valid2,
    input dout_valid3,
    input dout_valid4,
    input dout_valid5,
    input dout_valid6,
    input dout_valid7,
    input dout_valid8,
    input dout_valid9,
    input dout_valid10,
    input dout_valid11,
    output din_up_full0,
    output din_down_full0,
    output din_up_full1,
    output din_down_full1,
    output din_up_next_full0,
    output din_down_next_full0,
    output din_up_next_full1,
    output din_down_next_full1,
    input up0_valid,
    input upnext0_valid,
    input down0_valid,
    input downnext0_valid,
    input up1_valid,
    input upnext1_valid,
    input down1_valid,
    input downnext1_valid,
    output [31:0] up0_data,
    output [31:0] upnext0_data,
    output [31:0] down0_data,
    output [31:0] downnext0_data,
    output [31:0] up1_data,
    output [31:0] upnext1_data,
    output [31:0] down1_data,
    output [31:0] downnext1_data
    );
    
    wire [3:0]r_finish_cnt;
    HP_2_cal RDMA2_Cal(
    .clk(clk),
    .rst_n(rst_n),
    .rdma2_start(rdma2_start),
    .rdma2_done(rdma2_done),
    .is_conv_1(is_conv_1),
    .is_maxpooling(is_maxpooling),
    .is_conv_3(is_conv_3),
    .ifm_width(ifm_width),
    .ifm_channel(ifm_channel),
    .rdma2_valid(rdma2_valid),
    .r_finish_cnt(r_finish_cnt)
    );

    
    wire din_full0;
    wire din_full1;
    wire din_full2;
    wire din_full3;
    wire din_full4;
    wire din_full5;
    wire din_full6;
    wire din_full7;
    wire din_full8;
    wire din_full9;
    wire din_full10;
    wire din_full11;
    
    wire bram_0_full;
    wire bram_1_full;
    wire bram_2_full;
    wire bram_3_full;
    wire bram_4_full;
    wire bram_5_full;
    wire bram_6_full;
    wire bram_7_full;
    wire bram_8_full;
    wire bram_9_full;
    wire bram_10_full;
    wire bram_11_full;
    
    wire [63:0] bram_3_data;
    wire [63:0] bram_4_data;
    wire [63:0] bram_5_data;
    wire [63:0] bram_6_data;
    wire [63:0] bram_7_data;
    wire [63:0] bram_8_data;
    wire [63:0] bram_9_data;
    wire [63:0] bram_10_data;
    wire [63:0] bram_11_data;
    
    assign ifm_bram_full = {bram_11_full, bram_8_full, bram_5_full, bram_2_full, bram_10_full, bram_7_full, bram_4_full, bram_1_full, bram_9_full, bram_6_full, bram_3_full, bram_0_full};
    assign ifm_bram_data = {bram_11_data, bram_8_data, bram_5_data, bram_2_data, bram_10_data, bram_7_data, bram_4_data, bram_1_data, bram_9_data, bram_6_data, bram_3_data, bram_0_data};
    //({11}, {8}, {5}, {2}, {10}, {7}, {4}, {1}, {9}, {6}, {3}, {0});
    wire din_valid0;
    wire din_valid1;
    wire din_valid2;
    wire din_valid3;
    wire din_valid4;
    wire din_valid5;
    wire din_valid6;
    wire din_valid7;
    wire din_valid8;
    wire din_valid9;
    wire din_valid10;
    wire din_valid11;
    
    reg [3:0] conv_n_state;
    reg [3:0] conv_c_state;
    
    wire mp_bram_full;
    
    //assign bram_full = (din_full0 & din_full1 & din_full2) || mp_bram_full;
    //assign bram_full = (din_full0 & din_full1 & din_full2 & din_full3 & din_full4 & din_full5 & din_full6 & din_full7 & din_full8 & din_full9 & din_full10 & din_full11 ) || mp_bram_full;
    assign bram_full = ((din_full0 & conv_c_state ==0) | (din_full1 & conv_c_state ==1) | (din_full2 & conv_c_state ==2) 
                        | (din_full3 & conv_c_state ==3) | (din_full4 & conv_c_state ==4) | (din_full5 & conv_c_state ==5) 
                        | (din_full6 & conv_c_state ==6) | (din_full7  & conv_c_state ==7) | (din_full8  & conv_c_state ==8)
                        | (din_full9 & conv_c_state ==9) | (din_full10 & conv_c_state ==10) | (din_full11 & conv_c_state ==11) ) || mp_bram_full;
    
    wire next0;
    wire next1;
    wire next2;
    wire next3;
    wire next4;
    wire next5;
    wire next6;
    wire next7;
    wire next8;
    wire next9;
    wire next10;
    wire next11;
    
    HP_2_bram_controller IFM_BRAM_0(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid0),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full0),
    .dout_valid(dout_valid0),
    .dout(bram_0_data),
    .dout_full(bram_0_full),
    .next(next0)
    );
    
    HP_2_bram_controller IFM_BRAM_1(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid1),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full1),
    .dout_valid(dout_valid1),
    .dout(bram_1_data),
    .dout_full(bram_1_full),
    .next(next1)
    );
    
    HP_2_bram_controller IFM_BRAM_2(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid2),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full2),
    .dout_valid(dout_valid2),
    .dout(bram_2_data),
    .dout_full(bram_2_full),
    .next(next2)
    );
    
    HP_2_bram_controller IFM_BRAM_3(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid3),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full3),
    .dout_valid(dout_valid3),
    .dout(bram_3_data),
    .dout_full(bram_3_full),
    .next(next3)
    );
    
    HP_2_bram_controller IFM_BRAM_4(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid4),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full4),
    .dout_valid(dout_valid4),
    .dout(bram_4_data),
    .dout_full(bram_4_full),
    .next(next4)
    );
    
    HP_2_bram_controller IFM_BRAM_5(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid5),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full5),
    .dout_valid(dout_valid5),
    .dout(bram_5_data),
    .dout_full(bram_5_full),
    .next(next5)
    );
    
    HP_2_bram_controller IFM_BRAM_6(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid6),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full6),
    .dout_valid(dout_valid6),
    .dout(bram_6_data),
    .dout_full(bram_6_full),
    .next(next6)
    );
    
    HP_2_bram_controller IFM_BRAM_7(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid7),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full7),
    .dout_valid(dout_valid7),
    .dout(bram_7_data),
    .dout_full(bram_7_full),
    .next(next7)
    );
    
    HP_2_bram_controller IFM_BRAM_8(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid8),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full8),
    .dout_valid(dout_valid8),
    .dout(bram_8_data),
    .dout_full(bram_8_full),
    .next(next8)
    );
    
    HP_2_bram_controller IFM_BRAM_9(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid9),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full9),
    .dout_valid(dout_valid9),
    .dout(bram_9_data),
    .dout_full(bram_9_full),
    .next(next9)
    );
    
    HP_2_bram_controller IFM_BRAM_10(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid10),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full10),
    .dout_valid(dout_valid10),
    .dout(bram_10_data),
    .dout_full(bram_10_full),
    .next(next10)
    );
    
    HP_2_bram_controller IFM_BRAM_11(
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid11),
    .din_cnt(r_finish_cnt),
    .din(rdma2_data),
    .din_full(din_full11),
    .dout_valid(dout_valid11),
    .dout(bram_11_data),
    .dout_full(bram_11_full),
    .next(next11)
    );
    

    
    always@(posedge clk)begin
        if(!rst_n)begin
            conv_c_state <= 0;
        end else begin
            conv_c_state <= conv_n_state;
        end
    end
    
    always@(*)begin
        conv_n_state = conv_c_state;
        case(conv_c_state)
            0: if((is_conv_1||is_conv_3) & next0 ) conv_n_state = 1;
            1: if((is_conv_1||is_conv_3) & next1 ) conv_n_state = 2;
            2: if((is_conv_1||is_conv_3) & next2 ) conv_n_state = 3;
            3: if((is_conv_1||is_conv_3) & next3 ) conv_n_state = 4;
            4: if((is_conv_1||is_conv_3) & next4 ) conv_n_state = 5;
            5: if((is_conv_1||is_conv_3) & next5 ) conv_n_state = 6;
            6: if((is_conv_1||is_conv_3) & next6 ) conv_n_state = 7;
            7: if((is_conv_1||is_conv_3) & next7 ) conv_n_state = 8;
            8: if((is_conv_1||is_conv_3) & next8 ) conv_n_state = 9;
            9: if((is_conv_1||is_conv_3) & next9 ) conv_n_state = 10;
            10: if((is_conv_1||is_conv_3) & next10 ) conv_n_state = 11;
            11: if((is_conv_1||is_conv_3) & next11 ) conv_n_state = 0;
        endcase
    end
    
    assign din_valid0 = (conv_c_state == 0) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid1 = (conv_c_state == 1) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid2 = (conv_c_state == 2) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid3 = (conv_c_state == 3) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid4 = (conv_c_state == 4) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid5 = (conv_c_state == 5) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid6 = (conv_c_state == 6) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid7 = (conv_c_state == 7) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid8 = (conv_c_state == 8) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid9 = (conv_c_state == 9) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid10 = (conv_c_state == 10) & rdma2_valid & (is_conv_1||is_conv_3);
    assign din_valid11 = (conv_c_state == 11) & rdma2_valid & (is_conv_1||is_conv_3);
    
    //maxpooling
    wire din_valid_up0;
    wire din_valid_up_next0;
    wire din_valid_down0;
    wire din_valid_down_next0;
    wire din_valid_up1;
    wire din_valid_up_next1;
    wire din_valid_down1;
    wire din_valid_down_next1;
    
    wire next_up0;
    wire next_up_next0;
    wire next_down0;
    wire next_down_next0;
    wire next_up1;
    wire next_up_next1;
    wire next_down1;
    wire next_down_next1;
    

    
    
    wire [63:0] reversed_data = {rdma2_data[31:0], rdma2_data[63:32]};
    
    wire [63:0] down_din = (ifm_width == 26) ? reversed_data : rdma2_data;
    assign mp_bram_full = din_up_full0 & din_down_full0 & din_up_full1 & din_down_full1;
    
    mp_total_bram_controller MP_BRAM_0_Up(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_valid(din_valid_up0),
    .din_next_valid(din_valid_up_next0),
    .din(rdma2_data),
    .din_full(din_up_full0),
    .din_next_full(din_up_next_full0),
    .dout_valid(up0_valid),
    .dout_valid_next(upnext0_valid),
    .dout(up0_data),
    .dout_next(upnext0_data),  
    .dout_full(up0_full),
    .next_bram(next_up0),
    .next_bram_next(next_up_next0)
    );
     mp_total_bram_controller MP_BRAM_0_Down(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_valid(din_valid_down0),
    .din_next_valid(din_valid_down_next0),
    .din(down_din),
    .din_full(din_down_full0),
    .din_next_full(din_down_next_full0),
    .dout_valid(down0_valid),
    .dout_valid_next(downnext0_valid),
    .dout(down0_data),
    .dout_next(downnext0_data),
    .dout_full(down0_full),
    .next_bram(next_down0),
    .next_bram_next(next_down_next0)
    );
    
     mp_total_bram_controller MP_BRAM_1_Up(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_valid(din_valid_up1),
    .din_next_valid(din_valid_up_next1),
    .din(rdma2_data),
    .din_full(din_up_full1),
    .din_next_full(din_up_next_full1),
    .dout_valid(up1_valid),
    .dout_valid_next(upnext1_valid),
    .dout(up1_data),
    .dout_next(upnext1_data),
    .dout_full(up1_full),
    .next_bram(next_up1),
    .next_bram_next(next_up_next1)
    );
     mp_total_bram_controller MP_BRAM_1_Down(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_valid(din_valid_down1),
    .din_next_valid(din_valid_down_next1),
    .din(down_din),
    .din_full(din_down_full1),
    .din_next_full(din_down_next_full1),
    .dout_valid(down1_valid),
    .dout_valid_next(downnext1_valid),
    .dout(down1_data),
    .dout_next(downnext1_data),
    .dout_full(down1_full),
    .next_bram(next_down1),
    .next_bram_next(next_down_next1)
    );
    
    reg [2:0] mp_c_state;
    reg [2:0] mp_n_state;
    
    localparam up0_upnext0 = 3'b000;
    localparam up0_down0 = 3'b001;
    localparam downnext0_down0 = 3'b010;
    localparam down0_downnext0 = 3'b011;
    localparam up1_upnext1 = 3'b100;
    localparam up1_down1 = 3'b101;
    localparam downnext1_down1 = 3'b110;
    localparam down1_downnext1 = 3'b111;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            mp_c_state<=0;
        end else begin
            mp_c_state <= mp_n_state;
        end
    end
    
    always@(*)begin
        mp_n_state = mp_c_state;
        case(mp_c_state)
            up0_upnext0:begin
                if(next_up0 & next_up_next0) mp_n_state = down0_downnext0;
                else if(next_up_next0) mp_n_state = up0_down0;
            end
            up0_down0:begin
                if(next_up0) mp_n_state = downnext0_down0;
            end
            downnext0_down0:begin
                if(next_down0 & next_down_next0 & !din_up_next_full1) mp_n_state = up1_upnext1;
            end
            down0_downnext0:begin
                if(next_down0 & next_down_next0 & !din_up_full1) mp_n_state = up1_upnext1;
            end
            up1_upnext1:begin
                if(next_up1 & next_up_next1) mp_n_state = down1_downnext1;
                else if(next_up_next1) mp_n_state = up1_down1;
            end
            up1_down1:begin
                if(next_up1) mp_n_state = downnext1_down1;
            end
            downnext1_down1:begin
                if(next_down1 & next_down_next1 & !din_up_next_full0) mp_n_state = up0_upnext0;
            end
            down1_downnext1:begin
                if(next_down1 & next_down_next1 & !din_up_full0) mp_n_state = up0_upnext0;
            end
        endcase
    end
    
    assign din_valid_up0 = (mp_c_state ==up0_upnext0 || mp_c_state == up0_down0) & rdma2_valid & is_maxpooling ;
    assign din_valid_up_next0 = (mp_c_state ==up0_upnext0) & rdma2_valid & is_maxpooling ;
    assign din_valid_down0 = (mp_c_state ==up0_down0 || mp_c_state == downnext0_down0 || mp_c_state == down0_downnext0 ) & rdma2_valid & is_maxpooling ;
    assign din_valid_down_next0 = (mp_c_state == downnext0_down0 || mp_c_state == down0_downnext0 ) & rdma2_valid & is_maxpooling ;
    
    assign din_valid_up1 = (mp_c_state ==up1_upnext1 || mp_c_state == up1_down1) & rdma2_valid & is_maxpooling ;
    assign din_valid_up_next1 = (mp_c_state ==up1_upnext1) & rdma2_valid & is_maxpooling ;
    assign din_valid_down1 = (mp_c_state ==up1_down1 || mp_c_state == downnext1_down1 || mp_c_state == down1_downnext1 ) & rdma2_valid & is_maxpooling ;
    assign din_valid_down_next1 = (mp_c_state == downnext1_down1 || mp_c_state == down1_downnext1 ) & rdma2_valid & is_maxpooling ;
    
endmodule
