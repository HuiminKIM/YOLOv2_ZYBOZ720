`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/17 10:05:43
// Design Name: 
// Module Name: yolo_con_test
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


module yolo_con_test#(
    parameter AXI_ADDR_WIDTH = 8,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH     = 1,
    parameter ADDR_WIDTH   = 32,
    parameter DATA_WIDTH   = 64,
    parameter AWUSER_WIDTH = 1,
    parameter ARUSER_WIDTH = 1,
    parameter WUSER_WIDTH  = 1,
    parameter RUSER_WIDTH  = 1,
    parameter BUSER_WIDTH  = 1
)
(
    input                            clk,
    input                            rst_n,
    input   [AXI_ADDR_WIDTH-1:0]     s_AWADDR,
    input                            s_AWVALID,
    output                           s_AWREADY,
    input   [AXI_DATA_WIDTH-1:0]     s_WDATA,
    input   [AXI_DATA_WIDTH/8-1:0]   s_WSTRB,
    input                            s_WVALID,
    output                           s_WREADY,
    output  [1:0]                    s_BRESP,
    output                           s_BVALID,
    input                            s_BREADY,
    input   [AXI_ADDR_WIDTH-1:0]     s_ARADDR,
    input                            s_ARVALID,
    output                           s_ARREADY,
    output  [AXI_DATA_WIDTH-1:0]     s_RDATA,
    output  [1:0]                    s_RRESP,
    output                           s_RVALID,
    input                            s_RREADY,
    output                           interrupt,
    
    output [AXI_ID_WIDTH - 1:0] m_axi_ARID,
    output [2:0] m_axi_ARSIZE,
    output [1:0] m_axi_ARBURST,
    output [1:0] m_axi_ARLOCK,
    output [3:0] m_axi_ARCACHE,
    output [2:0] m_axi_ARPROT,
    output [3:0] m_axi_ARQOS,
    output [3:0] m_axi_ARREGION,
    input  [AXI_ID_WIDTH - 1:0] m_axi_RID,
    input  [RUSER_WIDTH - 1:0] m_axi_RUSER,
    output [ARUSER_WIDTH - 1:0] m_axi_ARUSER,
    input  [1:0] m_axi_RRESP,

// AR Channel
    output m_axi_ARVALID,
    input  m_axi_ARREADY,
    output [ADDR_WIDTH - 1:0] m_axi_ARADDR,
    output [7:0] m_axi_ARLEN,

// R Channel
    input  m_axi_RVALID,
    output m_axi_RREADY,
    input  [DATA_WIDTH - 1:0] m_axi_RDATA,
    input  m_axi_RLAST,
    
    output [15:0]  weight_data_in0,
    output [15:0]  weight_data_in1,
    output [15:0]  weight_data_in2,
    output [15:0]  weight_data_in3,
    output [15:0]  weight_data_in4,
    output [15:0]  weight_data_in5,
    output [15:0]  weight_data_in6,
    output [15:0]  weight_data_in7,
    output [15:0]  weight_data_in8,
    
    output          weight_valid,
    input           ifm_valid,
    
    output [15:0]bias_data,
    output bias_valid,
    
    input conv_1_ifm_weight_hs,
    output conv_1_weight_valid,
    output [15:0] conv_1_weight,
    
    input cnn_conv_end,
    
    //test
    output        is_relu,
    output        en_bias,
    output        maxpooling,
    output        convolution_3,
    output        convolution_1,
    
    output [10:0] ifm_channel,
    output [10:0] ofm_channel,
    output [8:0] ifm_width,
    output [8:0] ifm_height,
    output [8:0] ofm_width,
    output [8:0] ofm_height,
    output LT_conv,
    
    output [4:0]  bias_shift,
    output [4:0]  conv_shift,
    output [4:0]  ofm_shift,
    output [31:0] ifm_base_addr,
    output [31:0] ofm_base_addr,
    input  ap_idle,
    input  ap_done,
    output hp2_ap_start,
    output [31:0] ofm_transferbyte,
    input w_full
    //output [15:0] ila_bram_full,
    //output [31:0] ila_no_weight_valid
    );
    
    
    wire                          ap_start;
    wire                          ap_ready;
    wire [31:0]                   ifm;
    wire [31:0]                   ofm;
    assign ifm_base_addr = ifm;
    assign ofm_base_addr = ofm;
    wire [31:0]                   weight;
    wire [31:0]                   bias;
    wire [31:0]                   k_s_pad_ltype;
    wire [31:0]                   iofm_num;
    wire [31:0]                   ifm_w_h;
    wire [31:0]                   ofm_w_h;
    wire [31:0]                   TRTC;
    wire [31:0]                   TMTN;
    wire [31:0]                   OFM_num_bound;
    wire [31:0]                   mLoopsxTM;
    wire [31:0]                   mLoops_a1xTM;
    wire [15:0]                   pad_val;
    wire [31:0]                   TRowTCol;
    wire [31:0]                   IHW;
    wire [31:0]                   OHW;
    wire [31:0]                   KK_INumxKK;
    wire [31:0]                   en_bits;
    wire [31:0]                   WeightQ;
    wire [31:0]                   BetaQ;
    wire [31:0]                   InputQ;
    wire [31:0]                   OutputQ;
    
    wire                          hp_0_ap_start;
    
    
    wire [31:0] bias_transferbyte;
    wire [31:0] weight_transferbyte;
    
    wire [8:0] total_ifm;
    
    
    wire bias_bram_full;
    wire bias_reg_read_en;
    wire [63:0]bias_reg_din;
    
    wire  [31:0] bias_or_weight_transferbyte;
    wire [31:0] bias_or_weight_address;
    
    wire        weight0_bram_full;
    wire        weight0_reg_read_en;
    wire [63:0] weight0_reg_din;
    wire        out_next0;
    wire [1:0]  remain0;

    wire        weight1_bram_full;
    wire        weight1_reg_read_en;
    wire [63:0] weight1_reg_din;
    wire        out_next1;
    wire [1:0]  remain1;

    wire        weight2_bram_full;
    wire        weight2_reg_read_en;
    wire [63:0] weight2_reg_din;
    wire        out_next2;
    wire [1:0]  remain2;

    wire        weight3_bram_full;
    wire        weight3_reg_read_en;
    wire [63:0] weight3_reg_din;
    wire        out_next3;
    wire [1:0]  remain3;

    wire        weight4_bram_full;
    wire        weight4_reg_read_en;
    wire [63:0] weight4_reg_din;
    wire        out_next4;
    wire [1:0]  remain4;

    wire        weight5_bram_full;
    wire        weight5_reg_read_en;
    wire [63:0] weight5_reg_din;
    wire        out_next5;
    wire [1:0]  remain5;

    wire        weight6_bram_full;
    wire        weight6_reg_read_en;
    wire [63:0] weight6_reg_din;
    wire        out_next6;
    wire [1:0]  remain6;

    wire        weight7_bram_full;
    wire        weight7_reg_read_en;
    wire [63:0] weight7_reg_din;
    wire        out_next7;
    wire [1:0]  remain7;

    wire        weight8_bram_full;
    wire        weight8_reg_read_en;
    wire [63:0] weight8_reg_din;
    wire        out_next8;
    wire [1:0]  remain8;

    wire        weight9_bram_full;
    wire        weight9_reg_read_en;
    wire [63:0] weight9_reg_din;
    wire        out_next9;
    wire [1:0]  remain9;

     wire        weight10_bram_full;
     wire        weight10_reg_read_en;
     wire [63:0] weight10_reg_din;
     wire        out_next10;
     wire [1:0]  remain10;

     wire        weight11_bram_full;
     wire        weight11_reg_read_en;
     wire [63:0] weight11_reg_din;
     wire        out_next11;
     wire [1:0]  remain11;

     wire        weight12_bram_full;
     wire        weight12_reg_read_en;
     wire [63:0] weight12_reg_din;
     wire        out_next12;
     wire [1:0]  remain12;

     wire        weight13_bram_full;
     wire        weight13_reg_read_en;
     wire [63:0] weight13_reg_din;
     wire        out_next13;
     wire [1:0]  remain13;
   
     wire        weight14_bram_full;
     wire        weight14_reg_read_en;
     wire [63:0] weight14_reg_din;
     wire        out_next14;
     wire [1:0]  remain14;

     wire        weight15_bram_full;
     wire        weight15_reg_read_en;
     wire [63:0] weight15_reg_din;
     wire        out_next15;
     wire [1:0]  remain15;
    
    wire [63:0] din;
    wire write_en;
    wire full_n;
    
    wire [10:0]con_ifm_channel;
    
    wire is_bias;
    
    wire [14:0] repeat_ifm;
    
    wire        conv_1_bram0_full;
    wire [63:0] conv_1_bram0_data;
    wire        conv_1_bram0_valid;
    
    wire        conv_1_bram1_full;
    wire [63:0] conv_1_bram1_data;
    wire        conv_1_bram1_valid;
    
    FPGA_Acc_CTRL_BUS_s_axi AXI_Lite(
    .ACLK(clk),
    .ARESET(rst_n),
    .ACLK_EN('b1),
    .AWADDR(s_AWADDR),
    .AWVALID(s_AWVALID),
    .AWREADY(s_AWREADY),
    .WDATA(s_WDATA),
    .WSTRB(s_WSTRB),
    .WVALID(s_WVALID),
    .WREADY(s_WREADY),
    .BRESP(s_BRESP),
    .BVALID(s_BVALID),
    .BREADY(s_BREADY),
    .ARADDR(s_ARADDR),
    .ARVALID(s_ARVALID),
    .ARREADY(s_ARREADY),
    .RDATA(s_RDATA),
    .RRESP(s_RRESP),
    .RVALID(s_RVALID),
    .RREADY(s_RREADY),
    .interrupt(interrupt),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_ready(ap_ready),
    .ap_idle(ap_idle),
    .ifm(ifm),
    .ofm(ofm),
    .weight(weight),
    .bias(bias),
    .k_s_pad_ltype(k_s_pad_ltype),
    .iofm_num(iofm_num),
    .ifm_w_h(ifm_w_h),
    .ofm_w_h(ofm_w_h),
    .pad_val(pad_val),
    .IHW(IHW),
    .OHW(OHW),
    .KK_INumxKK(KK_INumxKK),
    .en_bits(en_bits),
    .WeightQ(WeightQ),
    .BetaQ(BetaQ),
    .InputQ(InputQ),
    .OutputQ(OutputQ)
    );


    
    
    main_controller Main_Controller(
    .clk(clk),
    .rst_n(rst_n),
    .k_s_pad_ltype(k_s_pad_ltype),
    .iofm_num(iofm_num),
    .ifm_w_h(ifm_w_h),
    .ofm_w_h(ofm_w_h),
    .en_bits(en_bits),
    .WeightQ(WeightQ),
    .BetaQ(BetaQ),
    .InputQ(InputQ),
    .OutputQ(OutputQ),
    .ap_start(ap_start),
    
    .is_relu(is_relu),
    .en_bias(en_bias),
    .maxpooling(maxpooling),
    .convolution_3(convolution_3),
    .convolution_1(convolution_1),
    
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .ifm_width(ifm_width),
    .ifm_height(ifm_height),
    .ofm_width(ofm_width),
    .ofm_height(ofm_height),
    
    .bias_shift(bias_shift),
    .conv_shift(conv_shift),
    .is_ofm_shift(LT_conv),
    .ofm_shift(ofm_shift),
    
    .bias_transferbyte(bias_transferbyte),
    .weight_transferbyte(weight_transferbyte),
    
    .total_ifm(total_ifm),
    .hp2_ap_start(hp2_ap_start),
    .ofm_transferbyte(ofm_transferbyte)
    );

    axi4_bias_weight_controller FSM (
    .clk(clk),
    .rst_n(rst_n),
    .en_bias(en_bias),
    .convolution_3(convolution_3),
    .convolution_1(convolution_1),
    
    .ap_start(ap_start),
    .ap_done(ap_done),
    
    .weight_address(weight),
    .bias_address(bias),
    
    .bias_transferbyte(bias_transferbyte),
    .weight_transferbyte(weight_transferbyte),
    
    .bias_or_weight_transferbyte(bias_or_weight_transferbyte),
    .bias_or_weight_address(bias_or_weight_address),
    
    .bias_bram_full(bias_bram_full),
    
    .hp_0_ap_start(hp_0_ap_start),
    .is_bias(is_bias)
    );

    rdma0 RDMA0 (
        .clk(clk),
        .rst_n(rst_n),
        .bram_full_n(full_n),
        .rdma0_data(din),
        .rdma0_valid(write_en),
        .rdma0_start(hp_0_ap_start),
        .axi_rdma0_ARVALID(m_axi_ARVALID),
        .axi_rdma0_ARREADY(m_axi_ARREADY),
        .axi_rdma0_ARADDR(m_axi_ARADDR),
        .axi_rdma0_ARID(m_axi_ARID),
        .axi_rdma0_ARLEN(m_axi_ARLEN),
        .axi_rdma0_ARSIZE(m_axi_ARSIZE),
        .axi_rdma0_ARBURST(m_axi_ARBURST),
        .axi_rdma0_ARLOCK(m_axi_ARLOCK),
        .axi_rdma0_ARCACHE(m_axi_ARCACHE),
        .axi_rdma0_ARPROT(m_axi_ARPROT),
        .axi_rdma0_ARQOS(m_axi_ARQOS),
        .axi_rdma0_ARREGION(m_axi_ARREGION),
        .axi_rdma0_ARUSER(m_axi_ARUSER),
        .axi_rdma0_RVALID(m_axi_RVALID),
        .axi_rdma0_RREADY(m_axi_RREADY),
        .axi_rdma0_RDATA(m_axi_RDATA),
        .axi_rdma0_RLAST(m_axi_RLAST),
        .axi_rdma0_RID(m_axi_RID),
        .axi_rdma0_RUSER(m_axi_RUSER),
        .axi_rdma0_RRESP(m_axi_RRESP),
        .transfer_byte(bias_or_weight_transferbyte),
        .base_addr(bias_or_weight_address)
    );
    
    HP_0_controller RDMA0_Controller(
    .ifm_channel(ifm_channel),
    .total_ifm(total_ifm),
    .convolution_3(convolution_3),
    .convolution_1(convolution_1),
    .ap_done(ap_done),
    .is_bias(is_bias),
    .bias_or_weight_transferbyte(bias_or_weight_transferbyte),
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .write_en(write_en),
    .full_n(full_n), // out_r_full_n rdma rready
    
    .m_axi_ARADDR(m_axi_ARADDR),
    
    .bias_valid(bias_valid),
    
    .bias_bram_full(bias_bram_full),
    .bias_reg_read_en(bias_reg_read_en),
    .bias_reg_din(bias_reg_din),
    
    .con_ifm_channel(con_ifm_channel),
    
    .conv_1_bram0_full(conv_1_bram0_full),
    .conv_1_bram0_data(conv_1_bram0_data),
    .conv_1_bram0_valid(conv_1_bram0_valid),
    
    .conv_1_bram1_full(conv_1_bram1_full),
    .conv_1_bram1_data(conv_1_bram1_data),
    .conv_1_bram1_valid(conv_1_bram1_valid),

    .weight0_bram_full(weight0_bram_full),
    .weight0_reg_read_en(weight0_reg_read_en),
    .weight0_reg_din(weight0_reg_din),
    .out_next0(out_next0),
    .remain0(remain0),

    .weight1_bram_full(weight1_bram_full),
    .weight1_reg_read_en(weight1_reg_read_en),
    .weight1_reg_din(weight1_reg_din),
    .out_next1(out_next1),
    .remain1(remain1),

    .weight2_bram_full(weight2_bram_full),
    .weight2_reg_read_en(weight2_reg_read_en),
    .weight2_reg_din(weight2_reg_din),
    .out_next2(out_next2),
    .remain2(remain2),

    .weight3_bram_full(weight3_bram_full),
    .weight3_reg_read_en(weight3_reg_read_en),
    .weight3_reg_din(weight3_reg_din),
    .out_next3(out_next3),
    .remain3(remain3),

    .weight4_bram_full(weight4_bram_full),
    .weight4_reg_read_en(weight4_reg_read_en),
    .weight4_reg_din(weight4_reg_din),
    .out_next4(out_next4),
    .remain4(remain4),

    .weight5_bram_full(weight5_bram_full),
    .weight5_reg_read_en(weight5_reg_read_en),
    .weight5_reg_din(weight5_reg_din),
    .out_next5(out_next5),
    .remain5(remain5),

    .weight6_bram_full(weight6_bram_full),
    .weight6_reg_read_en(weight6_reg_read_en),
    .weight6_reg_din(weight6_reg_din),
    .out_next6(out_next6),
    .remain6(remain6),

    .weight7_bram_full(weight7_bram_full),
    .weight7_reg_read_en(weight7_reg_read_en),
    .weight7_reg_din(weight7_reg_din),
    .out_next7(out_next7),
    .remain7(remain7),

    .weight8_bram_full(weight8_bram_full),
    .weight8_reg_read_en(weight8_reg_read_en),
    .weight8_reg_din(weight8_reg_din),
    .out_next8(out_next8),
    .remain8(remain8),

    .weight9_bram_full(weight9_bram_full),
    .weight9_reg_read_en(weight9_reg_read_en),
    .weight9_reg_din(weight9_reg_din),
    .out_next9(out_next9),
    .remain9(remain9),

    .weight10_bram_full(weight10_bram_full),
    .weight10_reg_read_en(weight10_reg_read_en),
    .weight10_reg_din(weight10_reg_din),
    .out_next10(out_next10),
    .remain10(remain10),

    .weight11_bram_full(weight11_bram_full),
    .weight11_reg_read_en(weight11_reg_read_en),
    .weight11_reg_din(weight11_reg_din),
    .out_next11(out_next11),
    .remain11(remain11),

    .weight12_bram_full(weight12_bram_full),
    .weight12_reg_read_en(weight12_reg_read_en),
    .weight12_reg_din(weight12_reg_din),
    .out_next12(out_next12),
    .remain12(remain12),

    .weight13_bram_full(weight13_bram_full),
    .weight13_reg_read_en(weight13_reg_read_en),
    .weight13_reg_din(weight13_reg_din),
    .out_next13(out_next13),
    .remain13(remain13),
    
    .weight14_bram_full(weight14_bram_full),
    .weight14_reg_read_en(weight14_reg_read_en),
    .weight14_reg_din(weight14_reg_din),
    .out_next14(out_next14),
    .remain14(remain14),

    .weight15_bram_full(weight15_bram_full),
    .weight15_reg_read_en(weight15_reg_read_en),
    .weight15_reg_din(weight15_reg_din),
    .out_next15(out_next15),
    .remain15(remain15)
    //.ila_bram_full(ila_bram_full)
    );
    

     bias_controller Bias_Pre_Processing_Unit(
    .clk(clk),
    .rst_n(rst_n),
    .ap_done(ap_done),
    .total_ifm(total_ifm),
    .bias_bram_full(bias_bram_full),
    .bias_reg_read_en(bias_reg_read_en),
    .bias_reg_din(bias_reg_din),
    
    .bias_data(bias_data),
    .bias_valid(bias_valid),
    
    .cnn_conv_end(cnn_conv_end), // maybe need buffer depend on cnn latency if cnn need 4cycle, you need to add 4 cycle buffer.
    
    .repeat_ifm(repeat_ifm)
    );
    
    weight_controller Conv3_Weight_Pre_Processing_Unit(
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .total_ifm(total_ifm),
    .ap_done(ap_done),
    .clk(clk),
    .rst_n(rst_n),
    
    .repeat_ifm(repeat_ifm),
    
    .con_ifm_channel(con_ifm_channel),

    .weight0_bram_full(weight0_bram_full),
    .weight0_reg_read_en(weight0_reg_read_en),
    .weight0_reg_din(weight0_reg_din),
    .out_next0(out_next0),
    .remain0(remain0),

    .weight1_bram_full(weight1_bram_full),
    .weight1_reg_read_en(weight1_reg_read_en),
    .weight1_reg_din(weight1_reg_din),
    .out_next1(out_next1),
    .remain1(remain1),

    .weight2_bram_full(weight2_bram_full),
    .weight2_reg_read_en(weight2_reg_read_en),
    .weight2_reg_din(weight2_reg_din),
    .out_next2(out_next2),
    .remain2(remain2),

    .weight3_bram_full(weight3_bram_full),
    .weight3_reg_read_en(weight3_reg_read_en),
    .weight3_reg_din(weight3_reg_din),
    .out_next3(out_next3),
    .remain3(remain3),

    .weight4_bram_full(weight4_bram_full),
    .weight4_reg_read_en(weight4_reg_read_en),
    .weight4_reg_din(weight4_reg_din),
    .out_next4(out_next4),
    .remain4(remain4),

    .weight5_bram_full(weight5_bram_full),
    .weight5_reg_read_en(weight5_reg_read_en),
    .weight5_reg_din(weight5_reg_din),
    .out_next5(out_next5),
    .remain5(remain5),

    .weight6_bram_full(weight6_bram_full),
    .weight6_reg_read_en(weight6_reg_read_en),
    .weight6_reg_din(weight6_reg_din),
    .out_next6(out_next6),
    .remain6(remain6),

    .weight7_bram_full(weight7_bram_full),
    .weight7_reg_read_en(weight7_reg_read_en),
    .weight7_reg_din(weight7_reg_din),
    .out_next7(out_next7),
    .remain7(remain7),

    .weight8_bram_full(weight8_bram_full),
    .weight8_reg_read_en(weight8_reg_read_en),
    .weight8_reg_din(weight8_reg_din),
    .out_next8(out_next8),
    .remain8(remain8),

    .weight9_bram_full(weight9_bram_full),
    .weight9_reg_read_en(weight9_reg_read_en),
    .weight9_reg_din(weight9_reg_din),
    .out_next9(out_next9),
    .remain9(remain9),

    .weight10_bram_full(weight10_bram_full),
    .weight10_reg_read_en(weight10_reg_read_en),
    .weight10_reg_din(weight10_reg_din),
    .out_next10(out_next10),
    .remain10(remain10),

    .weight11_bram_full(weight11_bram_full),
    .weight11_reg_read_en(weight11_reg_read_en),
    .weight11_reg_din(weight11_reg_din),
    .out_next11(out_next11),
    .remain11(remain11),

    .weight12_bram_full(weight12_bram_full),
    .weight12_reg_read_en(weight12_reg_read_en),
    .weight12_reg_din(weight12_reg_din),
    .out_next12(out_next12),
    .remain12(remain12),

    .weight13_bram_full(weight13_bram_full),
    .weight13_reg_read_en(weight13_reg_read_en),
    .weight13_reg_din(weight13_reg_din),
    .out_next13(out_next13),
    .remain13(remain13),
    
    .weight14_bram_full(weight14_bram_full),
    .weight14_reg_read_en(weight14_reg_read_en),
    .weight14_reg_din(weight14_reg_din),
    .out_next14(out_next14),
    .remain14(remain14),

    .weight15_bram_full(weight15_bram_full),
    .weight15_reg_read_en(weight15_reg_read_en),
    .weight15_reg_din(weight15_reg_din),
    .out_next15(out_next15),
    .remain15(remain15),
    
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
    .ifm_valid(ifm_valid),
    .w_full(w_full)
    );
    
    conv_1_weight_controller Conv1_Weight_Pre_Processing_Unit(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(total_ifm),
    .conv_1_ifm_weight_hs(conv_1_ifm_weight_hs),
    .conv_1_weight_valid(conv_1_weight_valid),
    .conv_1_weight(conv_1_weight),
    .conv_1_bram0_valid(conv_1_bram0_valid),
    .conv_1_bram1_valid(conv_1_bram1_valid),
    .conv_1_bram0_full(conv_1_bram0_full),
    .conv_1_bram1_full(conv_1_bram1_full),
    .conv_1_bram0_data(conv_1_bram0_data),
    .conv_1_bram1_data(conv_1_bram1_data)
    );
endmodule
