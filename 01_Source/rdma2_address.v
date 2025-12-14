`timescale 1ns / 1ps

module rdma2_address(
    input clk,
    input rst_n,
    input is_conv_3,
    input fifo_valid,
    input [10:0] ifm_channel,
    input [10:0] ofm_channel,
    input [31:0] base_addr,
    input [8:0] ifm_width,
    input is_conv_1,
    input is_maxpooling,
    input ap_done,
    input ap_start,
    input is_4k_boundary,
    output [31:0] fifo_data,
    output fifo_empty_n
    );
    wire [31:0]address;
    wire fifo_full_n;
    wire maxpool;
    wire one_one_conv;
    wire three_three_row_1;
    wire three_three_reuse;
    wire conv1_recycle;
    wire recycle;
    wire addr_valid;
    
    address_fsm Address_FSM(
    .clk(clk),
    .rst_n(rst_n),
    .is_conv_1(is_conv_1),
    .is_conv_3(is_conv_3),
    .is_maxpooling(is_maxpooling),
    .ap_done(ap_done),
    .ap_start(ap_start),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .ifm_width(ifm_width),
    .is_4k_boundary('b0),
    .maxpool(maxpool),
    .one_one_conv(one_one_conv),
    .three_three_row_1(three_three_row_1),
    .three_three_reuse(three_three_reuse),
    .recycle(recycle),
    .conv1_recycle(conv1_recycle),
    .fifo_full_n(fifo_full_n)
    );
    
    address_calculation Address_Calculation(
    .clk(clk),
    .rst_n(rst_n),
    .fifo_full_n(fifo_full_n),
    .maxpool(maxpool),
    .one_one_conv(one_one_conv),
    .three_three_row_1(three_three_row_1),
    .three_three_reuse(three_three_reuse),
    .ifm_channel(ifm_channel),
    .base_addr(base_addr),
    .recycle(recycle),
    .conv1_recycle(conv1_recycle),
    .ifm_width(ifm_width),
    .address(address),
    .addr_valid(addr_valid)
    );
    
    address_FIFO Address_FIFO(
    .clk(clk),
    .rst_n(rst_n),
    .maxpool(maxpool),
    .one_one_conv(one_one_conv),
    .three_three_row_1(three_three_row_1),
    .three_three_reuse(three_three_reuse),
    .fifo_full_n(fifo_full_n),
    .fifo_data(fifo_data),
    .fifo_empty_n(fifo_empty_n),
    .address(address),
    .addr_valid(addr_valid),
    .fifo_valid(fifo_valid)
    );
endmodule
