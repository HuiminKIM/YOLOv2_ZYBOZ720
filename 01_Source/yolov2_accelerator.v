module yolov2_accelerator(
    input clk,
    input rst_n,

    //GP0
    input   [7:0]     axi_lite_AWADDR,
    input             axi_lite_AWVALID,
    output            axi_lite_AWREADY,
    input   [31:0]    axi_lite_WDATA,
    input   [3:0]     axi_lite_WSTRB,
    input             axi_lite_WVALID,
    output            axi_lite_WREADY,
    output  [1:0]     axi_lite_BRESP,
    output            axi_lite_BVALID,
    input             axi_lite_BREADY,
    input   [7:0]     axi_lite_ARADDR,
    input             axi_lite_ARVALID,
    output            axi_lite_ARREADY,
    output  [31:0]    axi_lite_RDATA,
    output  [1:0]     axi_lite_RRESP,
    output            axi_lite_RVALID,
    input             axi_lite_RREADY,
    output            interrupt,
    //HP0
    output            axi_dma0_ARVALID,
    input             axi_dma0_ARREADY,
    output  [31:0]    axi_dma0_ARADDR,
    output            axi_dma0_ARID,
    output  [7:0]     axi_dma0_ARLEN,
    output  [2:0]     axi_dma0_ARSIZE,
    output  [1:0]     axi_dma0_ARBURST,
    output  [1:0]     axi_dma0_ARLOCK,
    output  [3:0]     axi_dma0_ARCACHE,
    output  [2:0]     axi_dma0_ARPROT,
    output  [3:0]     axi_dma0_ARQOS,
    output  [3:0]     axi_dma0_ARREGION,
    output            axi_dma0_ARUSER,
    input             axi_dma0_RVALID,
    output            axi_dma0_RREADY,
    input   [63:0]    axi_dma0_RDATA,
    input             axi_dma0_RLAST,
    input             axi_dma0_RID,
    input             axi_dma0_RUSER,
    input   [1:0]     axi_dma0_RRESP,
    
    output            axi_dma0_AWVALID,
    input             axi_dma0_AWREADY,
    output  [31:0]    axi_dma0_AWADDR,
    output  [2:0]     axi_dma0_AWSIZE, 
    output  [1:0]     axi_dma0_AWBURST,
    output  [3:0]     axi_dma0_AWCACHE,
    output  [2:0]     axi_dma0_AWPROT,
    output            axi_dma0_AWID,
    output  [7:0]     axi_dma0_AWLEN,
    output            axi_dma0_AWLOCK,
    output  [3:0]     axi_dma0_AWQOS,
    output  [3:0]     axi_dma0_AWREGION,
    output            axi_dma0_AWUSER,
    
    output            axi_dma0_WVALID,
    input             axi_dma0_WREADY,
    output            axi_dma0_WLAST,
    output  [63:0]    axi_dma0_WDATA,
    output  [7:0]     axi_dma0_WSTRB,
    output            axi_dma0_WID,
    output            axi_dma0_WUSER,
    
    input             axi_dma0_BVALID,
    output            axi_dma0_BREADY,
    input   [1:0]     axi_dma0_BRESP,
    input             axi_dma0_BID,
    input             axi_dma0_BUSER,
    
    //HP2
    output           axi_dma2_ARVALID,
    input            axi_dma2_ARREADY,
    output  [31:0]   axi_dma2_ARADDR,
    output           axi_dma2_ARID,
    output  [7:0]    axi_dma2_ARLEN,
    output  [2:0]    axi_dma2_ARSIZE,
    output  [1:0]    axi_dma2_ARBURST,
    output  [1:0]    axi_dma2_ARLOCK,
    output  [3:0]    axi_dma2_ARCACHE,
    output  [2:0]    axi_dma2_ARPROT,
    output  [3:0]    axi_dma2_ARQOS,
    output  [3:0]    axi_dma2_ARREGION,
    output           axi_dma2_ARUSER,
    input            axi_dma2_RVALID,
    output           axi_dma2_RREADY,
    input   [63:0]   axi_dma2_RDATA,
    input            axi_dma2_RLAST,
    input            axi_dma2_RID,
    input            axi_dma2_RUSER,
    input   [1:0]    axi_dma2_RRESP,
    //no use hp2 write
    output           axi_dma2_AWVALID,
    input            axi_dma2_AWREADY,
    output  [31:0]   axi_dma2_AWADDR,
    output  [2:0]    axi_dma2_AWSIZE,
    output  [1:0]    axi_dma2_AWBURST,
    output  [3:0]    axi_dma2_AWCACHE,
    output  [2:0]    axi_dma2_AWPROT,
    output           axi_dma2_AWID,
    output  [7:0]    axi_dma2_AWLEN,
    output           axi_dma2_AWLOCK,
    output  [3:0]    axi_dma2_AWQOS,
    output  [3:0]    axi_dma2_AWREGION,
    output           axi_dma2_AWUSER,
    
    output           axi_dma2_WVALID,
    input            axi_dma2_WREADY,
    output           axi_dma2_WLAST,
    output  [63:0]   axi_dma2_WDATA,
    output  [7:0]    axi_dma2_WSTRB,
    output           axi_dma2_WID,
    output           axi_dma2_WUSER,
    
    input            axi_dma2_BVALID,
    output           axi_dma2_BREADY,
    input   [1:0]    axi_dma2_BRESP,
    input            axi_dma2_BID,
    input            axi_dma2_BUSER
    //output test
    //output [15:0] ila_bram_full,
    //output ila_weight_valid,
    //output ila_ifm_valid,
    //output [31:0] ila_no_weight_valid
    );
    
    assign axi_dma2_AWVALID = 0;
    assign axi_dma2_AWADDR = 0;
    assign axi_dma2_AWSIZE = 0;
    assign axi_dma2_AWBURST = 0;
    assign axi_dma2_AWCACHE = 0;
    assign axi_dma2_AWPROT = 0;
    assign axi_dma2_AWID = 0;
    assign axi_dma2_AWLEN = 0;
    assign axi_dma2_AWLOCK = 0;
    assign axi_dma2_AWQOS = 0;
    assign axi_dma2_AWREGION = 0;
    assign axi_dma2_AWUSER = 0;
    assign axi_dma2_WVALID = 0;
    assign axi_dma2_WLAST = 0;
    assign axi_dma2_WDATA = 0;
    assign axi_dma2_WSTRB = 0;
    assign axi_dma2_WID = 0;
    assign axi_dma2_WUSER = 0;
    assign axi_dma2_BREADY = 0;
    
    wire        is_relu; // == isNL
    wire        en_bias;
    wire [10:0] ifm_channel;
    wire [10:0] ofm_channel;
    wire [8:0]  ifm_height;
    wire [8:0]  ofm_width;
    wire [8:0]  ofm_height;
    wire        LT_conv;
    wire [4:0]  bias_shift;
    wire [4:0]  conv_shift;
    wire [4:0]  ofm_shift;
    
    wire [31:0] ifm_base_addr;
    wire [31:0] ofm_base_addr;
    
    wire [15:0]  weight_data_in0;
    wire [15:0]  weight_data_in1;
    wire [15:0]  weight_data_in2;
    wire [15:0]  weight_data_in3;
    wire [15:0]  weight_data_in4;
    wire [15:0]  weight_data_in5;
    wire [15:0]  weight_data_in6;
    wire [15:0]  weight_data_in7;
    wire [15:0]  weight_data_in8;
    
    wire weight_valid;
    
    wire [15:0] bias_data;
    assign conv_bias = bias_data;
    wire bias_valid;
    
    //wire conv_1_ifm_weight_hs;
    wire conv_1_weight_valid;
    wire [15:0] conv_1_weight;
    
    wire is_conv_3;
    wire [8:0] ifm_width;
    wire is_conv_1;
    wire is_maxpooling;
    
    wire hp2_ap_start;
    wire wdma0_start = hp2_ap_start;
    wire ap_done;
    wire ap_idle;
    
    wire [31:0] ofm_transferbyte;
    wire ofm_bram_valid;
    wire ofm_bram_ready;
    wire [63:0] ofm_bram_data;
    
    wire [63:0] ofm_buffer_data;
    wire ofm_buffer_valid;
    
    wire mp_valid;
    wire [15:0] mp_data0;
    wire [15:0] mp_data1;
    wire [15:0] mp_data2;
    wire [15:0] mp_data3;
    
    assign mp_is_valid = mp_valid;
    assign  mp_0 = mp_data0;
    assign  mp_1 = mp_data1;
    assign  mp_2 = mp_data2;
    assign  mp_3 = mp_data3;
                   
    wire          conv3_ifm_valid;
    wire          conv3_ifm_weight_hs;
    
    wire  [15:0]  ifm_data_0,  ifm_data_1,  ifm_data_2,  ifm_data_3,  ifm_data_4,  ifm_data_5,  ifm_data_6,  ifm_data_7,  ifm_data_8,  ifm_data_9, ifm_data_10,  ifm_data_11, ifm_data_12, ifm_data_13, ifm_data_14,
                    ifm_data_15, ifm_data_16, ifm_data_17, ifm_data_18, ifm_data_19, ifm_data_20, ifm_data_21, ifm_data_22, ifm_data_23, ifm_data_24, ifm_data_25, ifm_data_26, ifm_data_27, ifm_data_28, ifm_data_29,
                    ifm_data_30, ifm_data_31, ifm_data_32, ifm_data_33, ifm_data_34, ifm_data_35, ifm_data_36, ifm_data_37, ifm_data_38, ifm_data_39, ifm_data_40, ifm_data_41, ifm_data_42, ifm_data_43, ifm_data_44;
    
    wire         conv1_ifm_valid;               
    wire         conv1_ifm_weight_hs;
    wire  [15:0] conv1_ifm_data_0,  conv1_ifm_data_1,  conv1_ifm_data_2,  conv1_ifm_data_3,  conv1_ifm_data_4,  conv1_ifm_data_5,  conv1_ifm_data_6,  conv1_ifm_data_7,  conv1_ifm_data_8,  conv1_ifm_data_9, conv1_ifm_data_10,  conv1_ifm_data_11, conv1_ifm_data_12;
    wire         conv_end;
    
    //etc you can use following ports.
    wire conv3_valid;

    wire [15:0]  conv3_ifm_0,  conv3_ifm_1,  conv3_ifm_2,  conv3_ifm_3,  conv3_ifm_4,  conv3_ifm_5,  conv3_ifm_6,  conv3_ifm_7,  conv3_ifm_8,  conv3_ifm_9,  conv3_ifm_10,  conv3_ifm_11,  conv3_ifm_12,  conv3_ifm_13,  conv3_ifm_14,
                 conv3_ifm_15, conv3_ifm_16, conv3_ifm_17, conv3_ifm_18, conv3_ifm_19, conv3_ifm_20, conv3_ifm_21, conv3_ifm_22, conv3_ifm_23, conv3_ifm_24, conv3_ifm_25, conv3_ifm_26, conv3_ifm_27, conv3_ifm_28, conv3_ifm_29,
                 conv3_ifm_30, conv3_ifm_31, conv3_ifm_32, conv3_ifm_33, conv3_ifm_34, conv3_ifm_35, conv3_ifm_36, conv3_ifm_37, conv3_ifm_38, conv3_ifm_39, conv3_ifm_40, conv3_ifm_41, conv3_ifm_42, conv3_ifm_43, conv3_ifm_44;
    wire [15:0]  conv3_weight_0, conv3_weight_1, conv3_weight_2,
                 conv3_weight_3, conv3_weight_4, conv3_weight_5, 
                 conv3_weight_6, conv3_weight_7, conv3_weight_8;
    wire [15:0]  conv1_ifm_0,  conv1_ifm_1,  conv1_ifm_2,  conv1_ifm_3,  conv1_ifm_4,  conv1_ifm_5,  conv1_ifm_6,  conv1_ifm_7,  conv1_ifm_8,  conv1_ifm_9, conv1_ifm_10,  conv1_ifm_11, conv1_ifm_12;
    wire         conv1_valid;
    wire [15:0]  conv1_weight;
    
    wire w_full;
    
    wire w_full_mp = w_full & is_maxpooling;
    
    assign conv3_ifm_weight_hs = conv3_ifm_valid & weight_valid & !w_full ; //
    assign conv1_ifm_weight_hs = conv1_ifm_valid & conv_1_weight_valid & !w_full ;//
    //assign ila_weight_valid = weight_valid;
    //assign ila_ifm_valid= conv3_ifm_valid;
    
    yolo_con_test Main_Controller_RDMA0 (
    .clk(clk),
    .rst_n(rst_n),
    .s_AWADDR(axi_lite_AWADDR),
    .s_AWVALID(axi_lite_AWVALID),
    .s_AWREADY(axi_lite_AWREADY),
    .s_WDATA(axi_lite_WDATA),
    .s_WSTRB(axi_lite_WSTRB),
    .s_WVALID(axi_lite_WVALID),
    .s_WREADY(axi_lite_WREADY),
    .s_BRESP(axi_lite_BRESP),
    .s_BVALID(axi_lite_BVALID),
    .s_BREADY(axi_lite_BREADY),
    .s_ARADDR(axi_lite_ARADDR),
    .s_ARVALID(axi_lite_ARVALID),
    .s_ARREADY(axi_lite_ARREADY),
    .s_RDATA(axi_lite_RDATA),
    .s_RRESP(axi_lite_RRESP),
    .s_RVALID(axi_lite_RVALID),
    .s_RREADY(axi_lite_RREADY),
    .interrupt(interrupt),
    
    .m_axi_ARID(axi_dma0_ARID),
    .m_axi_ARSIZE(axi_dma0_ARSIZE),
    .m_axi_ARBURST(axi_dma0_ARBURST),
    .m_axi_ARLOCK(axi_dma0_ARLOCK),
    .m_axi_ARCACHE(axi_dma0_ARCACHE),
    .m_axi_ARPROT(axi_dma0_ARPROT),
    .m_axi_ARQOS(axi_dma0_ARQOS),
    .m_axi_ARREGION(axi_dma0_ARREGION),
    .m_axi_RID(axi_dma0_RID),
    .m_axi_RUSER(axi_dma0_RUSER),
    .m_axi_ARUSER(axi_dma0_ARUSER),
    .m_axi_RRESP(axi_dma0_RRESP),

// AR Channel
    .m_axi_ARVALID(axi_dma0_ARVALID),
    .m_axi_ARREADY(axi_dma0_ARREADY),
    .m_axi_ARADDR(axi_dma0_ARADDR),
    .m_axi_ARLEN(axi_dma0_ARLEN),

// R Channel
    .m_axi_RVALID(axi_dma0_RVALID),
    .m_axi_RREADY(axi_dma0_RREADY),
    .m_axi_RDATA(axi_dma0_RDATA),
    .m_axi_RLAST(axi_dma0_RLAST),
    
    .weight_data_in0(weight_data_in0),
    .weight_data_in1(weight_data_in1),
    .weight_data_in2(weight_data_in2),
    .weight_data_in3(weight_data_in3),
    .weight_data_in4(weight_data_in4),
    .weight_data_in5(weight_data_in5),
    .weight_data_in6(weight_data_in6),
    .weight_data_in7(weight_data_in7),
    .weight_data_in8(weight_data_in8),
    
    .weight_valid(weight_valid),
    .ifm_valid(conv3_ifm_valid),
    
    .bias_data(bias_data),
    .bias_valid(bias_valid),
    
    .conv_1_ifm_weight_hs(conv1_ifm_weight_hs),
    .conv_1_weight_valid(conv_1_weight_valid),
    .conv_1_weight(conv_1_weight),
    
    .cnn_conv_end(conv_end),
    
    .is_relu(is_relu),
    .en_bias(en_bias),
    .maxpooling(is_maxpooling),
    .convolution_3(is_conv_3),
    .convolution_1(is_conv_1),
    
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .ifm_width(ifm_width),
    .ifm_height(ifm_height),
    .ofm_width(ofm_width),
    .ofm_height(ofm_height),
    .LT_conv(LT_conv),
    
    .bias_shift(bias_shift),
    .conv_shift(conv_shift),
    .ofm_shift(ofm_shift),
    .ifm_base_addr(ifm_base_addr),
    .ofm_base_addr(ofm_base_addr),
    .hp2_ap_start(hp2_ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ofm_transferbyte(ofm_transferbyte),
    .w_full(w_full)
    //.ila_bram_full(ila_bram_full),
    //.ila_no_weight_valid(ila_no_weight_valid)
    );
    

    
    HP_2 RDMA2_Controller (
    .clk(clk),
    .rst_n(rst_n),
    
    //axi ports
    .axi_rdma2_ARVALID(axi_dma2_ARVALID),
    .axi_rdma2_ARREADY(axi_dma2_ARREADY),
    .axi_rdma2_ARADDR(axi_dma2_ARADDR),
    .axi_rdma2_ARID(axi_dma2_ARID),
    .axi_rdma2_ARLEN(axi_dma2_ARLEN),
    .axi_rdma2_ARSIZE(axi_dma2_ARSIZE),
    .axi_rdma2_ARBURST(axi_dma2_ARBURST),
    .axi_rdma2_ARLOCK(axi_dma2_ARLOCK),
    .axi_rdma2_ARCACHE(axi_dma2_ARCACHE),
    .axi_rdma2_ARPROT(axi_dma2_ARPROT),
    .axi_rdma2_ARQOS(axi_dma2_ARQOS),
    .axi_rdma2_ARREGION(axi_dma2_ARREGION),
    .axi_rdma2_ARUSER(axi_dma2_ARUSER),
    .axi_rdma2_RVALID(axi_dma2_RVALID),
    .axi_rdma2_RREADY(axi_dma2_RREADY),
    .axi_rdma2_RDATA(axi_dma2_RDATA),
    .axi_rdma2_RLAST(axi_dma2_RLAST),
    .axi_rdma2_RID(axi_dma2_RID),
    .axi_rdma2_RUSER(axi_dma2_RUSER),
    .axi_rdma2_RRESP(axi_dma2_RRESP),
    
    //etc ports
    .is_conv_3(is_conv_3),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .base_addr(ifm_base_addr),
    .ifm_width(ifm_width),
    .is_conv_1(is_conv_1),
    .is_maxpooling(is_maxpooling),
    .ap_done(ap_done),
    .ap_start(hp2_ap_start),
    .w_full_mp(w_full_mp),
    
    .mp_valid(mp_valid),
    .mp_data0(mp_data0),
    .mp_data1(mp_data1),
    .mp_data2(mp_data2),
    .mp_data3(mp_data3),
                   
    .conv3_ifm_valid(conv3_ifm_valid),
    .conv3_ifm_weight_hs(conv3_ifm_weight_hs),               
    
    .ifm_data_0(ifm_data_0),  .ifm_data_1(ifm_data_1),  .ifm_data_2(ifm_data_2),  .ifm_data_3(ifm_data_3),  .ifm_data_4(ifm_data_4),  .ifm_data_5(ifm_data_5),  .ifm_data_6(ifm_data_6),  .ifm_data_7(ifm_data_7),  .ifm_data_8(ifm_data_8),  .ifm_data_9(ifm_data_9), .ifm_data_10(ifm_data_10),  .ifm_data_11(ifm_data_11), .ifm_data_12(ifm_data_12), .ifm_data_13(ifm_data_13), .ifm_data_14(ifm_data_14),
    .ifm_data_15(ifm_data_15), .ifm_data_16(ifm_data_16), .ifm_data_17(ifm_data_17), .ifm_data_18(ifm_data_18), .ifm_data_19(ifm_data_19), .ifm_data_20(ifm_data_20), .ifm_data_21(ifm_data_21), .ifm_data_22(ifm_data_22), .ifm_data_23(ifm_data_23), .ifm_data_24(ifm_data_24), .ifm_data_25(ifm_data_25), .ifm_data_26(ifm_data_26), .ifm_data_27(ifm_data_27), .ifm_data_28(ifm_data_28), .ifm_data_29(ifm_data_29),
    .ifm_data_30(ifm_data_30), .ifm_data_31(ifm_data_31), .ifm_data_32(ifm_data_32), .ifm_data_33(ifm_data_33), .ifm_data_34(ifm_data_34), .ifm_data_35(ifm_data_35), .ifm_data_36(ifm_data_36), .ifm_data_37(ifm_data_37), .ifm_data_38(ifm_data_38), .ifm_data_39(ifm_data_39), .ifm_data_40(ifm_data_40), .ifm_data_41(ifm_data_41), .ifm_data_42(ifm_data_42), .ifm_data_43(ifm_data_43), .ifm_data_44(ifm_data_44),
    
    .conv1_ifm_valid(conv1_ifm_valid),               
    .conv1_ifm_weight_hs(conv1_ifm_weight_hs),
    .conv1_ifm_data_0(conv1_ifm_data_0),  .conv1_ifm_data_1(conv1_ifm_data_1), .conv1_ifm_data_2(conv1_ifm_data_2),  .conv1_ifm_data_3(conv1_ifm_data_3),  .conv1_ifm_data_4(conv1_ifm_data_4),  .conv1_ifm_data_5(conv1_ifm_data_5),  .conv1_ifm_data_6(conv1_ifm_data_6), .conv1_ifm_data_7(conv1_ifm_data_7),  .conv1_ifm_data_8(conv1_ifm_data_8),  .conv1_ifm_data_9(conv1_ifm_data_9), .conv1_ifm_data_10(conv1_ifm_data_10),  .conv1_ifm_data_11(conv1_ifm_data_11), .conv1_ifm_data_12(conv1_ifm_data_12)
    //.test(test)
    );

    Pre_Processing Conv_Pre_Processing_Unit(
    .clk(clk),
    .rst_n(rst_n),
    .conv3_ifm_weight_hs(conv3_ifm_weight_hs),
    .conv3_weight_valid(weight_valid),
    .conv1_ifm_weight_hs(conv1_ifm_weight_hs),
    .ifm_data_0(ifm_data_0),  .ifm_data_1(ifm_data_1),  .ifm_data_2(ifm_data_2),  .ifm_data_3(ifm_data_3),  .ifm_data_4(ifm_data_4),  .ifm_data_5(ifm_data_5),  .ifm_data_6(ifm_data_6),  .ifm_data_7(ifm_data_7),  .ifm_data_8(ifm_data_8),  .ifm_data_9(ifm_data_9), .ifm_data_10(ifm_data_10),  .ifm_data_11(ifm_data_11), .ifm_data_12(ifm_data_12), .ifm_data_13(ifm_data_13), .ifm_data_14(ifm_data_14),
    .ifm_data_15(ifm_data_15), .ifm_data_16(ifm_data_16), .ifm_data_17(ifm_data_17), .ifm_data_18(ifm_data_18), .ifm_data_19(ifm_data_19), .ifm_data_20(ifm_data_20), .ifm_data_21(ifm_data_21), .ifm_data_22(ifm_data_22), .ifm_data_23(ifm_data_23), .ifm_data_24(ifm_data_24), .ifm_data_25(ifm_data_25), .ifm_data_26(ifm_data_26), .ifm_data_27(ifm_data_27), .ifm_data_28(ifm_data_28), .ifm_data_29(ifm_data_29),
    .ifm_data_30(ifm_data_30), .ifm_data_31(ifm_data_31), .ifm_data_32(ifm_data_32), .ifm_data_33(ifm_data_33), .ifm_data_34(ifm_data_34), .ifm_data_35(ifm_data_35), .ifm_data_36(ifm_data_36), .ifm_data_37(ifm_data_37), .ifm_data_38(ifm_data_38), .ifm_data_39(ifm_data_39), .ifm_data_40(ifm_data_40), .ifm_data_41(ifm_data_41), .ifm_data_42(ifm_data_42), .ifm_data_43(ifm_data_43), .ifm_data_44(ifm_data_44),
    .weight_data_in0(weight_data_in0), .weight_data_in1(weight_data_in1), .weight_data_in2(weight_data_in2),
    .weight_data_in3(weight_data_in3), .weight_data_in4(weight_data_in4), .weight_data_in5(weight_data_in5), 
    .weight_data_in6(weight_data_in6), .weight_data_in7(weight_data_in7), .weight_data_in8(weight_data_in8),
    .conv1_ifm_data_0(conv1_ifm_data_0),  .conv1_ifm_data_1(conv1_ifm_data_1),  .conv1_ifm_data_2(conv1_ifm_data_2),  .conv1_ifm_data_3(conv1_ifm_data_3),  .conv1_ifm_data_4(conv1_ifm_data_4),  .conv1_ifm_data_5(conv1_ifm_data_5),  .conv1_ifm_data_6(conv1_ifm_data_6),  .conv1_ifm_data_7(conv1_ifm_data_7),  .conv1_ifm_data_8(conv1_ifm_data_8),  .conv1_ifm_data_9(conv1_ifm_data_9), .conv1_ifm_data_10(conv1_ifm_data_10),  .conv1_ifm_data_11(conv1_ifm_data_11), .conv1_ifm_data_12(conv1_ifm_data_12),
    .conv_1_weight(conv_1_weight),
    
    .conv3_valid(conv3_valid),
    .conv1_valid(conv1_valid),
    .conv3_ifm_0(conv3_ifm_0),  .conv3_ifm_1(conv3_ifm_1),  .conv3_ifm_2(conv3_ifm_2),  .conv3_ifm_3(conv3_ifm_3),  .conv3_ifm_4(conv3_ifm_4),  .conv3_ifm_5(conv3_ifm_5),  .conv3_ifm_6(conv3_ifm_6),  .conv3_ifm_7(conv3_ifm_7),  .conv3_ifm_8(conv3_ifm_8),  .conv3_ifm_9(conv3_ifm_9),  .conv3_ifm_10(conv3_ifm_10),  .conv3_ifm_11(conv3_ifm_11),  .conv3_ifm_12(conv3_ifm_12),  .conv3_ifm_13(conv3_ifm_13),  .conv3_ifm_14(conv3_ifm_14),
    .conv3_ifm_15(conv3_ifm_15), .conv3_ifm_16(conv3_ifm_16), .conv3_ifm_17(conv3_ifm_17), .conv3_ifm_18(conv3_ifm_18), .conv3_ifm_19(conv3_ifm_19), .conv3_ifm_20(conv3_ifm_20), .conv3_ifm_21(conv3_ifm_21), .conv3_ifm_22(conv3_ifm_22), .conv3_ifm_23(conv3_ifm_23), .conv3_ifm_24(conv3_ifm_24), .conv3_ifm_25(conv3_ifm_25), .conv3_ifm_26(conv3_ifm_26), .conv3_ifm_27(conv3_ifm_27), .conv3_ifm_28(conv3_ifm_28), .conv3_ifm_29(conv3_ifm_29),
    .conv3_ifm_30(conv3_ifm_30), .conv3_ifm_31(conv3_ifm_31), .conv3_ifm_32(conv3_ifm_32), .conv3_ifm_33(conv3_ifm_33), .conv3_ifm_34(conv3_ifm_34), .conv3_ifm_35(conv3_ifm_35), .conv3_ifm_36(conv3_ifm_36), .conv3_ifm_37(conv3_ifm_37), .conv3_ifm_38(conv3_ifm_38), .conv3_ifm_39(conv3_ifm_39), .conv3_ifm_40(conv3_ifm_40), .conv3_ifm_41(conv3_ifm_41), .conv3_ifm_42(conv3_ifm_42), .conv3_ifm_43(conv3_ifm_43), .conv3_ifm_44(conv3_ifm_44),
    .conv3_weight_0(conv3_weight_0), .conv3_weight_1(conv3_weight_1), .conv3_weight_2(conv3_weight_2),
    .conv3_weight_3(conv3_weight_3), .conv3_weight_4(conv3_weight_4), .conv3_weight_5(conv3_weight_5), 
    .conv3_weight_6(conv3_weight_6), .conv3_weight_7(conv3_weight_7), .conv3_weight_8(conv3_weight_8),
    .conv1_ifm_0(conv1_ifm_0),  .conv1_ifm_1(conv1_ifm_1),  .conv1_ifm_2(conv1_ifm_2),  .conv1_ifm_3(conv1_ifm_3), .conv1_ifm_4(conv1_ifm_4), .conv1_ifm_5(conv1_ifm_5),  .conv1_ifm_6(conv1_ifm_6),  .conv1_ifm_7(conv1_ifm_7),  .conv1_ifm_8(conv1_ifm_8),  .conv1_ifm_9(conv1_ifm_9), .conv1_ifm_10(conv1_ifm_10),  .conv1_ifm_11(conv1_ifm_11), .conv1_ifm_12(conv1_ifm_12),
    .conv1_weight(conv1_weight)
    );
    
    Conv_top Processing_Units(
        .clk(clk), .rst_n(rst_n), .conv3_valid(conv3_valid), .conv1_valid(conv1_valid), .conv_shift(conv_shift),
        .relu_shift(ofm_shift), .ifm_channel(ifm_channel), .ofm_channel(ofm_channel), .isNL(is_relu), .LT_conv(LT_conv), .mp_valid(mp_valid), .is_mp(is_maxpooling),
    
        .image_data_0(conv3_ifm_0),   .image_data_1(conv3_ifm_1),   .image_data_2(conv3_ifm_2),   .image_data_3(conv3_ifm_3),   .image_data_4(conv3_ifm_4), 
        .image_data_5(conv3_ifm_5),   .image_data_6(conv3_ifm_6),   .image_data_7(conv3_ifm_7),   .image_data_8(conv3_ifm_8),   .image_data_9(conv3_ifm_9), 
        .image_data_10(conv3_ifm_10), .image_data_11(conv3_ifm_11), .image_data_12(conv3_ifm_12), .image_data_13(conv3_ifm_13), .image_data_14(conv3_ifm_14), 
        .image_data_15(conv3_ifm_15), .image_data_16(conv3_ifm_16), .image_data_17(conv3_ifm_17), .image_data_18(conv3_ifm_18), .image_data_19(conv3_ifm_19), 
        .image_data_20(conv3_ifm_20), .image_data_21(conv3_ifm_21), .image_data_22(conv3_ifm_22), .image_data_23(conv3_ifm_23), .image_data_24(conv3_ifm_24), 
        .image_data_25(conv3_ifm_25), .image_data_26(conv3_ifm_26), .image_data_27(conv3_ifm_27), .image_data_28(conv3_ifm_28), .image_data_29(conv3_ifm_29), 
        .image_data_30(conv3_ifm_30), .image_data_31(conv3_ifm_31), .image_data_32(conv3_ifm_32), .image_data_33(conv3_ifm_33), .image_data_34(conv3_ifm_34), 
        .image_data_35(conv3_ifm_35), .image_data_36(conv3_ifm_36), .image_data_37(conv3_ifm_37), .image_data_38(conv3_ifm_38), .image_data_39(conv3_ifm_39), 
        .image_data_40(conv3_ifm_40), .image_data_41(conv3_ifm_41), .image_data_42(conv3_ifm_42), .image_data_43(conv3_ifm_43), .image_data_44(conv3_ifm_44), 
    
        .conv1_image_data_0(conv1_ifm_0),   .conv1_image_data_1(conv1_ifm_1),   .conv1_image_data_2(conv1_ifm_2), .conv1_image_data_3(conv1_ifm_3), .conv1_image_data_4(conv1_ifm_4), 
        .conv1_image_data_5(conv1_ifm_5),   .conv1_image_data_6(conv1_ifm_6),   .conv1_image_data_7(conv1_ifm_7), .conv1_image_data_8(conv1_ifm_8), .conv1_image_data_9(conv1_ifm_9), 
        .conv1_image_data_10(conv1_ifm_10), .conv1_image_data_11(conv1_ifm_11), .conv1_image_data_12(conv1_ifm_12),
    
        .mp_image_data_0(mp_data0), .mp_image_data_1(mp_data1), .mp_image_data_2(mp_data2), .mp_image_data_3(mp_data3), 
    
        .weight_data_0(conv3_weight_0), .weight_data_1(conv3_weight_1), .weight_data_2(conv3_weight_2), .weight_data_3(conv3_weight_3), .weight_data_4(conv3_weight_4), 
        .weight_data_5(conv3_weight_5), .weight_data_6(conv3_weight_6), .weight_data_7(conv3_weight_7), .weight_data_8(conv3_weight_8), 
        .conv1_weight_data(conv1_weight),
        .bias_data(bias_data), .bias_shift(bias_shift),
    
        .ofm_buffer_data(ofm_buffer_data),
        .conv_end(conv_end),
        .ofm_buffer_valid(ofm_buffer_valid)
    );
    
    ofm_wdma_controller WDMA0_Controller(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_buffer_valid),
    .ofm_data(ofm_buffer_data),
    .ofm_bram_valid(ofm_bram_valid),
    .ofm_bram_data(ofm_bram_data),
    .ofm_transferbyte(ofm_transferbyte),
    .ofm_axi_ready(ofm_bram_ready),
    .ap_start(hp2_ap_start),
    .w_full(w_full)
    );
    
     wdma0 WDMA0 (
    .clk(clk),
    .rst_n(rst_n),
    .axi_dma0_AWVALID(axi_dma0_AWVALID),
    .axi_dma0_AWREADY(axi_dma0_AWREADY),
    .axi_dma0_AWADDR(axi_dma0_AWADDR),
    .axi_dma0_AWSIZE(axi_dma0_AWSIZE),
    .axi_dma0_AWBURST(axi_dma0_AWBURST),
    .axi_dma0_AWCACHE(axi_dma0_AWCACHE),
    .axi_dma0_AWPROT(axi_dma0_AWPROT),
    .axi_dma0_AWID(axi_dma0_AWID),
    .axi_dma0_AWLEN(axi_dma0_AWLEN),
    .axi_dma0_AWLOCK(axi_dma0_AWLOCK),
    .axi_dma0_AWQOS(axi_dma0_AWQOS),
    .axi_dma0_AWREGION(axi_dma0_AWREGION),
    .axi_dma0_AWUSER(axi_dma0_AWUSER),
    
    .axi_dma0_WVALID(axi_dma0_WVALID),
    .axi_dma0_WREADY(axi_dma0_WREADY),
    .axi_dma0_WLAST(axi_dma0_WLAST),
    .axi_dma0_WDATA(axi_dma0_WDATA),
    .axi_dma0_WSTRB(axi_dma0_WSTRB),
    .axi_dma0_WID(axi_dma0_WID),
    .axi_dma0_WUSER(axi_dma0_WUSER),
    
    .axi_dma0_BVALID(axi_dma0_BVALID),
    .axi_dma0_BREADY(axi_dma0_BREADY),
    .axi_dma0_BRESP(axi_dma0_BRESP),
    .axi_dma0_BID(axi_dma0_BID),
    .axi_dma0_BUSER(axi_dma0_BUSER),
    
    .ofm_base_addr(ofm_base_addr),
    .ofm_transfer_byte(ofm_transferbyte),
    
    .ofm_bram_valid(ofm_bram_valid),
    .ofm_bram_ready(ofm_bram_ready),
    .ofm_bram_data(ofm_bram_data),
    
    .wdma0_start(wdma0_start),
    .ap_idle(ap_idle),
    .ap_done(ap_done)
    );
    
endmodule