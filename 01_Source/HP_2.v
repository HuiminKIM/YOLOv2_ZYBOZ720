`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/16 16:14:54
// Design Name: 
// Module Name: HP_2
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


module HP_2(
    input clk,
    input rst_n,
    
    //axi ports
    output axi_rdma2_ARVALID,
    input axi_rdma2_ARREADY,
    output [31:0] axi_rdma2_ARADDR,
    output axi_rdma2_ARID,
    output [7:0] axi_rdma2_ARLEN,
    output [2:0] axi_rdma2_ARSIZE,
    output [1:0] axi_rdma2_ARBURST,
    output [1:0] axi_rdma2_ARLOCK,
    output [3:0] axi_rdma2_ARCACHE,
    output [2:0] axi_rdma2_ARPROT,
    output [3:0] axi_rdma2_ARQOS,
    output [3:0] axi_rdma2_ARREGION,
    output axi_rdma2_ARUSER,
    input axi_rdma2_RVALID,
    output axi_rdma2_RREADY,
    input [63:0] axi_rdma2_RDATA,
    input axi_rdma2_RLAST,
    input axi_rdma2_RID,
    input axi_rdma2_RUSER,
    input [1:0] axi_rdma2_RRESP,
    
    //etc ports
    input is_conv_3,
    input [10:0] ifm_channel,
    input [10:0] ofm_channel,
    input [31:0] base_addr,
    input [8:0] ifm_width,
    input is_conv_1,
    input is_maxpooling,
    input ap_done,
    input ap_start,

    input w_full_mp,
    output mp_valid,
    output [15:0] mp_data0,
    output [15:0] mp_data1,
    output [15:0] mp_data2,
    output [15:0] mp_data3,
                   
    output          conv3_ifm_valid,               
    input           conv3_ifm_weight_hs,
    
    output  [15:0]  ifm_data_0,  ifm_data_1,  ifm_data_2,  ifm_data_3,  ifm_data_4,  ifm_data_5,  ifm_data_6,  ifm_data_7,  ifm_data_8,  ifm_data_9, ifm_data_10,  ifm_data_11, ifm_data_12, ifm_data_13, ifm_data_14,
                    ifm_data_15, ifm_data_16, ifm_data_17, ifm_data_18, ifm_data_19, ifm_data_20, ifm_data_21, ifm_data_22, ifm_data_23, ifm_data_24, ifm_data_25, ifm_data_26, ifm_data_27, ifm_data_28, ifm_data_29,
                    ifm_data_30, ifm_data_31, ifm_data_32, ifm_data_33, ifm_data_34, ifm_data_35, ifm_data_36, ifm_data_37, ifm_data_38, ifm_data_39, ifm_data_40, ifm_data_41, ifm_data_42, ifm_data_43, ifm_data_44,
    
    output         conv1_ifm_valid,               
    input          conv1_ifm_weight_hs,
    output  [15:0] conv1_ifm_data_0,  conv1_ifm_data_1,  conv1_ifm_data_2,  conv1_ifm_data_3,  conv1_ifm_data_4,  conv1_ifm_data_5,  conv1_ifm_data_6,  conv1_ifm_data_7,  conv1_ifm_data_8,  conv1_ifm_data_9, conv1_ifm_data_10,  conv1_ifm_data_11, conv1_ifm_data_12
    //output test
    );
    wire [63:0] rdma2_data;
    wire rdma2_valid;
    wire rdma2_done;   
    
    wire [64*12-1:0] ifm_bram_data;
    wire [11:0] ifm_bram_full;
    
    wire dout_valid0;
    wire dout_valid1;
    wire dout_valid2;
    
    wire dout_valid3;
    wire dout_valid4;
    wire dout_valid5;
    wire dout_valid6;
    wire dout_valid7;
    wire dout_valid8;
    wire dout_valid9;
    wire dout_valid10;
    wire dout_valid11;
    
    wire rdma2_start;
    wire bram_full;

    wire din_up_next_full0;
    wire din_down_next_full0;
    wire din_up_next_full1;
    wire din_down_next_full1;
    wire up0_valid;
    wire upnext0_valid;
    wire down0_valid;
    wire downnext0_valid;
    wire up1_valid;
    wire upnext1_valid;
    wire down1_valid;
    wire downnext1_valid;
    wire [31:0] up0_data;
    wire [31:0] upnext0_data;
    wire [31:0] down0_data;
    wire [31:0] downnext0_data;
    wire [31:0] up1_data;
    wire [31:0] upnext1_data;
    wire [31:0] down1_data;
    wire [31:0] downnext1_data;
    
    wire din_up_full0;
    wire din_down_full0;
    wire din_up_full1;
    wire din_down_full1;
    
    rdma2 RDMA2(
    .clk(clk),
    .rst_n(rst_n),
    .bram_full(bram_full),
    .rdma2_data(rdma2_data),
    .rdma2_valid(rdma2_valid),
    .rdma2_done(rdma2_done),    
    .rdma2_start(rdma2_start),
    //axi ports
    .axi_rdma2_ARVALID(axi_rdma2_ARVALID),
    .axi_rdma2_ARREADY(axi_rdma2_ARREADY),
    .axi_rdma2_ARADDR(axi_rdma2_ARADDR),
    .axi_rdma2_ARID(axi_rdma2_ARID),
    .axi_rdma2_ARLEN(axi_rdma2_ARLEN),
    .axi_rdma2_ARSIZE(axi_rdma2_ARSIZE),
    .axi_rdma2_ARBURST(axi_rdma2_ARBURST),
    .axi_rdma2_ARLOCK(axi_rdma2_ARLOCK),
    .axi_rdma2_ARCACHE(axi_rdma2_ARCACHE),
    .axi_rdma2_ARPROT(axi_rdma2_ARPROT),
    .axi_rdma2_ARQOS(axi_rdma2_ARQOS),
    .axi_rdma2_ARREGION(axi_rdma2_ARREGION),
    .axi_rdma2_ARUSER(axi_rdma2_ARUSER),
    .axi_rdma2_RVALID(axi_rdma2_RVALID),
    .axi_rdma2_RREADY(axi_rdma2_RREADY),
    .axi_rdma2_RDATA(axi_rdma2_RDATA),
    .axi_rdma2_RLAST(axi_rdma2_RLAST),
    .axi_rdma2_RID(axi_rdma2_RID),
    .axi_rdma2_RUSER(axi_rdma2_RUSER),
    .axi_rdma2_RRESP(axi_rdma2_RRESP),
    
    //etc ports
    .is_conv_3(is_conv_3),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .base_addr(base_addr),
    .ifm_width(ifm_width),
    .is_conv_1(is_conv_1),
    .is_maxpooling(is_maxpooling),
    .ap_done(ap_done),
    .ap_start(ap_start),
    //.test(test),
    .w_full_mp(w_full_mp)
    );
    
    HP_2_top_controller RDMA2_Controller(
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
    .rdma2_data(rdma2_data),
    .ifm_bram_full(ifm_bram_full),
    .bram_full(bram_full),
    .ifm_bram_data(ifm_bram_data),
    .dout_valid0(dout_valid0),
    .dout_valid1(dout_valid1),
    .dout_valid2(dout_valid2),
    .dout_valid3(dout_valid3),
    .dout_valid4(dout_valid4),
    .dout_valid5(dout_valid5),
    .dout_valid6(dout_valid6),
    .dout_valid7(dout_valid7),
    .dout_valid8(dout_valid8),
    .dout_valid9(dout_valid9),
    .dout_valid10(dout_valid10),
    .dout_valid11(dout_valid11),
    .din_up_full0(din_up_full0),
    .din_down_full0(din_down_full0),
    .din_up_full1(din_up_full1),
    .din_down_full1(din_down_full1),
    .din_up_next_full0(din_up_next_full0),
    .din_down_next_full0(din_down_next_full0),
    .din_up_next_full1(din_up_next_full1),
    .din_down_next_full1(din_down_next_full1),
    .up0_valid(up0_valid),
    .upnext0_valid(upnext0_valid),
    .down0_valid(down0_valid),
    .downnext0_valid(downnext0_valid),
    .up1_valid(up1_valid),
    .upnext1_valid(upnext1_valid),
    .down1_valid(down1_valid),
    .downnext1_valid(downnext1_valid),
    .up0_data(up0_data),
    .upnext0_data(upnext0_data),
    .down0_data(down0_data),
    .downnext0_data(downnext0_data),
    .up1_data(up1_data),
    .upnext1_data(upnext1_data),
    .down1_data(down1_data),
    .downnext1_data(downnext1_data)
    );

    mp_pre_processing Maxpooling_Pre_Processing_Unit(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_up_full0(din_up_full0),
    .din_down_full0(din_down_full0),
    .din_up_full1(din_up_full1),
    .din_down_full1(din_down_full1),
    .din_up_next_full0(din_up_next_full0),
    .din_down_next_full0(din_down_next_full0),
    .din_up_next_full1(din_up_next_full1),
    .din_down_next_full1(din_down_next_full1),
    .up0_valid(up0_valid),
    .upnext0_valid(upnext0_valid),
    .down0_valid(down0_valid),
    .downnext0_valid(downnext0_valid),
    .up1_valid(up1_valid),
    .upnext1_valid(upnext1_valid),
    .down1_valid(down1_valid),
    .downnext1_valid(downnext1_valid),
    .up0_data(up0_data),
    .upnext0_data(upnext0_data),
    .down0_data(down0_data),
    .downnext0_data(downnext0_data),
    .up1_data(up1_data),
    .upnext1_data(upnext1_data),
    .down1_data(down1_data),
    .downnext1_data(downnext1_data),
    .mp_valid(mp_valid),
    .mp_data0(mp_data0),
    .mp_data1(mp_data1),
    .mp_data2(mp_data2),
    .mp_data3(mp_data3)
    );
    
    
    wire temp_valid;
    
    wire temp_valid_3 = is_conv_3 & temp_valid;
    wire temp_hs_3;
    
    wire temp_valid_1 = is_conv_1 & temp_valid;
    wire temp_hs_1;
    wire temp_hs = is_conv_3 ? temp_hs_3 : temp_hs_1 ;
    
    wire [16*44-1:0]  temp_out;
    wire [15:0]temp_data_10 = temp_out[703:688], temp_data_21 = temp_out[687:672], temp_data_32 = temp_out[671:656], temp_data_43 = temp_out[655:640];
    wire [15:0]temp_data_9 = temp_out[639:624], temp_data_20 = temp_out[623:608], temp_data_31 = temp_out[607:592], temp_data_42 = temp_out[591:576];
    wire [15:0]temp_data_8 = temp_out[575:560], temp_data_19 = temp_out[559:544], temp_data_30 = temp_out[543:528], temp_data_41 = temp_out[527:512];
    wire [15:0]temp_data_7 = temp_out[511:496], temp_data_18 = temp_out[495:480], temp_data_29 = temp_out[479:464], temp_data_40 = temp_out[463:448];
    wire [15:0]temp_data_6 = temp_out[447:432], temp_data_17 = temp_out[431:416], temp_data_28 = temp_out[415:400], temp_data_39 = temp_out[399:384];
    wire [15:0]temp_data_5 = temp_out[383:368], temp_data_16 = temp_out[367:352], temp_data_27 = temp_out[351:336], temp_data_38 = temp_out[335:320];
    wire [15:0]temp_data_4 = temp_out[319:304], temp_data_15 = temp_out[303:288], temp_data_26 = temp_out[287:272], temp_data_37 = temp_out[271:256];
    wire [15:0]temp_data_3 = temp_out[255:240], temp_data_14 = temp_out[239:224], temp_data_25 = temp_out[223:208], temp_data_36 = temp_out[207:192];
    wire [15:0]temp_data_2 = temp_out[191:176], temp_data_13 = temp_out[175:160], temp_data_24  = temp_out[159:144], temp_data_35  = temp_out[143:128];
    wire [15:0]temp_data_1  = temp_out[127:112], temp_data_12  = temp_out[111:96],  temp_data_23  = temp_out[95:80],  temp_data_34  = temp_out[79:64];
    wire [15:0]temp_data_0  = temp_out[63:48],   temp_data_11  = temp_out[47:32],   temp_data_22  = temp_out[31:16],  temp_data_33  = temp_out[15:0];

    
    ifm_reg_controller IFM_Temp(
    .ifm_bram_data(ifm_bram_data),
    .ifm_bram_full(ifm_bram_full),
    .height_ifm_hs(temp_hs),
    .rst_na(rst_n),
    .clk(clk),
    .read_en0(dout_valid0),
    .read_en1(dout_valid1),
    .read_en2(dout_valid2),
    .read_en3(dout_valid3),
    .read_en4(dout_valid4),
    .read_en5(dout_valid5),
    .read_en6(dout_valid6),
    .read_en7(dout_valid7),
    .read_en8(dout_valid8),
    .read_en9(dout_valid9),
    .read_en10(dout_valid10),
    .read_en11(dout_valid11),                 
    .temp_out(temp_out),
    .temp_buf_valid(temp_valid)
    );
    

    
    ifm_controller Conv3_IFM_Pre_Processing_Unit(
    .clk(clk),
    .rst_n(rst_n),
    .is_conv_3(is_conv_3),
    .is_maxpooling(is_maxpooling),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .ifm_width(ifm_width),
    
    .temp_valid(temp_valid_3),
    .temp_hs(temp_hs_3),
    .temp_data_0(temp_data_0), .temp_data_1(temp_data_1), .temp_data_2(temp_data_2), .temp_data_3(temp_data_3), 
    .temp_data_4(temp_data_4), .temp_data_5(temp_data_5), .temp_data_6(temp_data_6), .temp_data_7(temp_data_7), 
    .temp_data_8(temp_data_8), .temp_data_9(temp_data_9), .temp_data_10(temp_data_10), .temp_data_11(temp_data_11), 
    .temp_data_12(temp_data_12), .temp_data_13(temp_data_13), .temp_data_14(temp_data_14), .temp_data_15(temp_data_15),
    .temp_data_16(temp_data_16), .temp_data_17(temp_data_17), .temp_data_18(temp_data_18), .temp_data_19(temp_data_19),
    .temp_data_20(temp_data_20), .temp_data_21(temp_data_21), .temp_data_22(temp_data_22), .temp_data_23(temp_data_23), 
    .temp_data_24(temp_data_24), .temp_data_25(temp_data_25), .temp_data_26(temp_data_26), .temp_data_27(temp_data_27), 
    .temp_data_28(temp_data_28), .temp_data_29(temp_data_29), .temp_data_30(temp_data_30), .temp_data_31(temp_data_31),
    .temp_data_32(temp_data_32), .temp_data_33(temp_data_33), .temp_data_34(temp_data_34), .temp_data_35(temp_data_35),
    .temp_data_36(temp_data_36), .temp_data_37(temp_data_37), .temp_data_38(temp_data_38), .temp_data_39(temp_data_39),
    .temp_data_40(temp_data_40), .temp_data_41(temp_data_41), .temp_data_42(temp_data_42), .temp_data_43(temp_data_43),
    
    .conv3_ifm_valid(conv3_ifm_valid),               
    .conv3_ifm_weight_hs(conv3_ifm_weight_hs),
    .ifm_data_0(ifm_data_0),  .ifm_data_1(ifm_data_1),  .ifm_data_2(ifm_data_2),  .ifm_data_3(ifm_data_3),  .ifm_data_4(ifm_data_4),  .ifm_data_5(ifm_data_5),  .ifm_data_6(ifm_data_6),  .ifm_data_7(ifm_data_7),  .ifm_data_8(ifm_data_8),  .ifm_data_9(ifm_data_9), .ifm_data_10(ifm_data_10),  .ifm_data_11(ifm_data_11), .ifm_data_12(ifm_data_12), .ifm_data_13(ifm_data_13), .ifm_data_14(ifm_data_14),
    .ifm_data_15(ifm_data_15), .ifm_data_16(ifm_data_16), .ifm_data_17(ifm_data_17), .ifm_data_18(ifm_data_18), .ifm_data_19(ifm_data_19), .ifm_data_20(ifm_data_20), .ifm_data_21(ifm_data_21), .ifm_data_22(ifm_data_22), .ifm_data_23(ifm_data_23), .ifm_data_24(ifm_data_24), .ifm_data_25(ifm_data_25), .ifm_data_26(ifm_data_26), .ifm_data_27(ifm_data_27), .ifm_data_28(ifm_data_28), .ifm_data_29(ifm_data_29),
    .ifm_data_30(ifm_data_30), .ifm_data_31(ifm_data_31), .ifm_data_32(ifm_data_32), .ifm_data_33(ifm_data_33), .ifm_data_34(ifm_data_34), .ifm_data_35(ifm_data_35), .ifm_data_36(ifm_data_36), .ifm_data_37(ifm_data_37), .ifm_data_38(ifm_data_38), .ifm_data_39(ifm_data_39), .ifm_data_40(ifm_data_40), .ifm_data_41(ifm_data_41), .ifm_data_42(ifm_data_42), .ifm_data_43(ifm_data_43), .ifm_data_44(ifm_data_44)
    );
    
    one_conv_ifm_controller Conv1_IFM_Pre_Processing_Unit(
    .clk(clk),
    .rst_n(rst_n),
    .is_conv_1(is_conv_1),
    .is_maxpooling(is_maxpooling),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .ifm_width(ifm_width),
    
    .temp_valid(temp_valid_1),
    .temp_hs(temp_hs_1),
    .temp_data_0(temp_data_0), .temp_data_1(temp_data_1), .temp_data_2(temp_data_2), .temp_data_3(temp_data_3), 
    .temp_data_4(temp_data_4), .temp_data_5(temp_data_5), .temp_data_6(temp_data_6), .temp_data_7(temp_data_7), 
    .temp_data_8(temp_data_8), .temp_data_9(temp_data_9), .temp_data_10(temp_data_10), .temp_data_11(temp_data_11), 
    .temp_data_12(temp_data_12), .temp_data_13(temp_data_13), .temp_data_14(temp_data_14), .temp_data_15(temp_data_15),
    
    .conv1_ifm_valid(conv1_ifm_valid),               
    .conv1_ifm_weight_hs(conv1_ifm_weight_hs),
    .conv1_ifm_data_0(conv1_ifm_data_0),  .conv1_ifm_data_1(conv1_ifm_data_1),  .conv1_ifm_data_2(conv1_ifm_data_2),  .conv1_ifm_data_3(conv1_ifm_data_3),  .conv1_ifm_data_4(conv1_ifm_data_4),  .conv1_ifm_data_5(conv1_ifm_data_5),  .conv1_ifm_data_6(conv1_ifm_data_6),  .conv1_ifm_data_7(conv1_ifm_data_7),  .conv1_ifm_data_8(conv1_ifm_data_8),  .conv1_ifm_data_9(conv1_ifm_data_9), .conv1_ifm_data_10(conv1_ifm_data_10),  .conv1_ifm_data_11(conv1_ifm_data_11), .conv1_ifm_data_12(conv1_ifm_data_12)
    );
endmodule
