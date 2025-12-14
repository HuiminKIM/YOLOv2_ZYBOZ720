`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/14 11:38:43
// Design Name: 
// Module Name: wdma0
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


module wdma0(
    input clk,
    input rst_n,
    output axi_dma0_AWVALID,
    input axi_dma0_AWREADY,
    output [31:0] axi_dma0_AWADDR,
    output [2:0] axi_dma0_AWSIZE,
    output [1:0] axi_dma0_AWBURST,
    output [3:0] axi_dma0_AWCACHE,
    output [2:0] axi_dma0_AWPROT,
    output axi_dma0_AWID,
    output [7:0] axi_dma0_AWLEN,
    output axi_dma0_AWLOCK,
    output [3:0] axi_dma0_AWQOS,
    output [3:0] axi_dma0_AWREGION,
    output axi_dma0_AWUSER,
    
    output axi_dma0_WVALID,
    input axi_dma0_WREADY,
    output axi_dma0_WLAST,
    output [63:0] axi_dma0_WDATA,
    output [7:0] axi_dma0_WSTRB,
    output axi_dma0_WID,
    output axi_dma0_WUSER,
    
    input axi_dma0_BVALID,
    output axi_dma0_BREADY,
    input [1:0] axi_dma0_BRESP,
    input axi_dma0_BID,
    input axi_dma0_BUSER,
    
    input [31:0] ofm_base_addr,
    input [31:0] ofm_transfer_byte,
    
    input ofm_bram_valid,
    output ofm_bram_ready,
    input [63:0] ofm_bram_data,
    
    input  wdma0_start,
    output ap_idle,
    output ap_done
    );
    assign axi_dma0_AWID = 1'b0;
    assign axi_dma0_AWSIZE = 3'b011;
    assign axi_dma0_AWBURST = 2'b01;
    assign axi_dma0_AWLOCK = 2'b0;
    assign axi_dma0_AWCACHE = 4'b0;
    assign axi_dma0_AWPROT = 3'b0;
    assign axi_dma0_AWQOS = 4'b0;
    assign axi_dma0_AWREGION = 4'b0;
    assign axi_dma0_AWUSER = 1'b0;
    assign axi_dma0_WSTRB= 'hFF;
    assign axi_dma0_WDATA = ofm_bram_data;

    
    localparam idle = 2'b00;
    localparam pre = 2'b01;
    localparam run = 2'b10;
    localparam done = 2'b11;
    localparam boundary_4k = 2'b11;
    
    reg buf_wdma_start_n;
    wire wdma_start_tick = wdma0_start & (!buf_wdma_start_n);

    wire wdma_start_n= !wdma0_start;
    
    //w_state
    reg [1:0] c_state;
    reg [1:0] n_state;
    //aw_state
    reg [1:0] aw_n_state;
    reg [1:0] aw_c_state;
    wire aw_fifo_full_n;
    wire is_boundary_4k;
    
    wire [5:0] wdma_to_awfifo_awlen;
    wire [5:0] awfifo_to_wdma_awlen;
    
    //w_state
    reg w_c_state;
    reg w_n_state;
    wire aw_fifo_empty_n;
    wire aw_fifo_empty= !aw_fifo_empty_n;
    wire wdma0_done;
    
    //b_state
    reg [1:0] b_c_state;
    reg [1:0] b_n_state;
    wire b_hs_done;
    wire b_fifo_full_n;

    always@(posedge clk)begin
        if(!rst_n)begin
            buf_wdma_start_n <= 0;
        end else begin
            buf_wdma_start_n <= wdma_start_n;
        end
    end
    
    reg [31:0] finish_address;
    //total_state
    wire is_last_aw = (axi_dma0_AWADDR + (axi_dma0_AWLEN + 1)*8)  == finish_address;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            c_state <= idle;
        end else begin
            c_state <= n_state;
        end
    end
    
    wire aw_hs = axi_dma0_AWVALID & axi_dma0_AWREADY;
    
    always@(*)begin
        n_state = c_state;
        case(c_state)
            idle:begin
                if(wdma_start_tick) n_state = pre;
            end
            pre: n_state = run;
            run:begin
                if(is_last_aw & aw_hs) n_state = done;
            end
            done:begin
                if(b_hs_done & !wdma0_start) n_state = idle;
            end
        endcase
    end
    
    assign wdma0_done = (c_state ==done & aw_fifo_empty);
    assign ap_done = wdma0_done;
    assign ap_idle = (c_state ==idle);
    
    always@(posedge clk)begin
        if(!rst_n)begin
            finish_address <=0;
        end else begin
            if(c_state == pre)begin
                finish_address <= ofm_transfer_byte + ofm_base_addr;
            end else if(c_state ==idle)begin
                finish_address <= 0;
            end
        end
    end
    
    reg[31:0] init_address;
    reg [7:0] init_awlen;
    reg[31:0] remain_hs_cnt;
    reg [8:0] awlen_mem_cal;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            init_address <= 0;
            init_awlen <= 0;
            remain_hs_cnt<=0;
            awlen_mem_cal<=0;
        end else begin
            case(c_state)
                idle:begin
                    init_address <= 0;
                    init_awlen <= 0;
                    remain_hs_cnt<=0;
                    awlen_mem_cal<=0;
                end
                pre: begin
                    init_address <= ofm_base_addr;
                    init_awlen <= 32;
                    remain_hs_cnt <= (ofm_transfer_byte >> 3) - 32;//i fixed this (04_03)
                    awlen_mem_cal<= 64 -1;
                end
                run: begin
                    if(aw_hs & aw_c_state == run)begin
                        if(remain_hs_cnt >32)begin
                            remain_hs_cnt <= remain_hs_cnt - 32;
                            init_awlen <= 32;
                            awlen_mem_cal <= 32*8 - 1;
                        end else begin
                            init_awlen <= remain_hs_cnt;
                            awlen_mem_cal <= remain_hs_cnt*8 - 1;
                        end
                        if(!is_last_aw) init_address <= init_address + (init_awlen*8);
                    end
                end
            endcase
        end
    end
    //ar_state
    assign axi_dma0_AWVALID = aw_fifo_full_n && (aw_c_state==boundary_4k || aw_c_state==run) ; //b


    always@(posedge clk)begin
        if(!rst_n)begin
            aw_c_state <= idle;
        end else begin
            aw_c_state <= aw_n_state;
        end
    end
    
    always@(*)begin
        aw_n_state = aw_c_state;
        case(aw_c_state)
            idle:begin
                if(c_state == run & aw_fifo_full_n)aw_n_state = pre;
            end
            pre:begin
                if(is_boundary_4k)begin
                    aw_n_state = boundary_4k;
                end else begin
                    aw_n_state = run;
                end
            end
            boundary_4k:begin
                if(aw_hs) aw_n_state = run;
            end
            run:begin
                if(aw_hs) aw_n_state = idle; 
            end
        endcase
    end
    
    
    wire [5:0] boundary_4k_burst;
    wire [5:0] after_boundary_4k_burst;
    reg [5:0] real_aw_len;
    reg [5:0] after_4k_len;
    reg [31:0] real_address;
    assign axi_dma0_AWADDR = real_address;
    assign axi_dma0_AWLEN = real_aw_len - 1;
    
    assign is_boundary_4k = {1'b0,init_address[11:0]} + awlen_mem_cal > 12'hFFF;
    assign boundary_4k_burst = (13'd4096 - init_address[11:0]) >> 3;
    assign after_boundary_4k_burst = init_awlen - boundary_4k_burst;
    
    assign wdma_to_awfifo_awlen = real_aw_len;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            real_aw_len <= 0;
            after_4k_len <= 0;
            real_address <=0;
        end else begin
            case(aw_c_state)
            pre:begin
                real_address <= init_address;
                if(is_boundary_4k)begin
                    real_aw_len <= boundary_4k_burst;
                    after_4k_len <= after_boundary_4k_burst;
                end else begin
                    real_aw_len <= init_awlen;
                end
            end
            boundary_4k:begin
                if(aw_hs)begin
                    real_aw_len <= after_4k_len;
                    real_address <= real_address + (real_aw_len << 3);
                end
            end
            endcase
        end
    end


    //r_state
    wire w_hs= axi_dma0_WREADY & axi_dma0_WVALID;
    assign ofm_bram_ready = w_hs;
    reg [4:0] awlen_cnt;
    wire is_burst_done = (awlen_cnt == awfifo_to_wdma_awlen -1);
    wire is_last_hs = is_burst_done & w_hs;
    assign axi_dma0_WLAST = is_burst_done;
    assign axi_dma0_WVALID = aw_fifo_empty_n & ofm_bram_valid & b_fifo_full_n;
    
    wire b_hs = axi_dma0_BVALID & axi_dma0_BREADY;
       
    ar_len_fifo #(.FIFO_SIZE(6)) WDMA0_AWLEN_FIFO(
        .clk(clk),
        .rst_n(rst_n),
        .rdma_to_arfifo_arlen(wdma_to_awfifo_awlen),
        .arfifo_to_rdma_arlen(awfifo_to_wdma_awlen),
        .is_rlast(is_last_hs), //is_last_hs
        .ar_fifo_full_n(aw_fifo_full_n), //axi_rdma2_ARVALID
        .ar_ready(aw_hs),
        .ar_fifo_empty_n(aw_fifo_empty_n)
    ); 
    
    always@(posedge clk)begin
        if(!rst_n)begin
            awlen_cnt <= 0;
            w_c_state <= idle;
        end else begin
            if(w_hs)begin
                if(is_burst_done & w_hs) awlen_cnt <= 0;
                else awlen_cnt <= awlen_cnt+1;
            end 
            w_c_state <= w_n_state;
        end
    end
    
    always@(*)begin
        w_n_state = w_c_state;
        case(w_c_state)
            idle:begin
                if(aw_fifo_empty_n) w_n_state = run;
            end
            run:begin
                if(is_burst_done & (!aw_fifo_empty_n)) w_n_state = idle;
            end
        endcase
    end
    
    wire [5:0] wlen_to_bfifo_awlen = awfifo_to_wdma_awlen;
    wire [5:0] bfifo_to_wlen_awlen;

    wire b_fifo_empty_n;

    
    b_len_fifo #(.FIFO_SIZE(6)) WDMA0_BRESP_LEN_FIFO(
        .clk(clk),
        .rst_n(rst_n),
        .rdma_to_arfifo_arlen(wlen_to_bfifo_awlen),
        .arfifo_to_rdma_arlen(bfifo_to_wlen_awlen),
        .is_rlast(b_hs),
        .ar_ready(is_last_hs), // is_last_hs
        .ar_fifo_full_n(b_fifo_full_n),
        .ar_fifo_empty_n(b_fifo_empty_n)
    );
    
    always@(posedge clk)begin
        if(!rst_n)begin
            b_c_state <= idle;
        end else begin
            b_c_state <= b_n_state;
        end
    end
    
    always@(*)begin
        b_n_state = b_c_state;
        case(b_c_state)
            idle:begin
                if((c_state == run || c_state == done) & b_fifo_empty_n) b_n_state = run; //pre
            end
            pre:begin
                b_n_state = run;
            end
            run:begin
                if(b_hs) b_n_state = idle;
            end
        endcase
    end
    
    assign axi_dma0_BREADY = (b_c_state == run);
    //assign axi_dma0_BREADY = 1;
    
    reg [31:0] b_finish_hs;
    reg [31:0] b_finish_cnt;
    
    assign b_hs_done = b_finish_hs == b_finish_cnt;
    always@(posedge clk)begin
        if(!rst_n)begin
            b_finish_cnt<=0;
            b_finish_hs<=0;
        end else begin
            if(c_state == pre)begin
                b_finish_hs <= ofm_transfer_byte >> 3;
            end else if(c_state ==idle)begin
                b_finish_hs<=0;
            end
            if(b_hs_done & !wdma0_start)begin
                b_finish_cnt <= 0;
            end else if(b_hs)begin
                b_finish_cnt <= b_finish_cnt + bfifo_to_wlen_awlen;
            end
        end
    end
endmodule
