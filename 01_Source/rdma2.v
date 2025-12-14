`timescale 1ns / 1ps

module rdma2(
    input clk,
    input rst_n,
    input bram_full,
    output [63:0] rdma2_data,
    output rdma2_valid,
    output rdma2_done,    
    output rdma2_start,
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
    //output test,
    input w_full_mp
    );
    assign axi_rdma2_ARID = 1'b0;
    assign axi_rdma2_ARSIZE = 3'b011;
    assign axi_rdma2_ARBURST = 2'b01;
    assign axi_rdma2_ARLOCK = 2'b0;
    assign axi_rdma2_ARCACHE = 4'b0;
    assign axi_rdma2_ARPROT = 3'b0;
    assign axi_rdma2_ARQOS = 4'b0;
    assign axi_rdma2_ARREGION = 4'b0;
    assign axi_rdma2_ARUSER = 1'b0;
    assign rdma2_data = axi_rdma2_RDATA;

    
    localparam idle = 2'b00;
    localparam pre = 2'b01;
    localparam run = 2'b10;
    localparam done = 2'b11;
    localparam boundary_4k = 2'b11;
    
    wire fifo_empty_n;
    wire [31:0] fifo_data;
    wire fifo_valid;
    wire fifo_hs = fifo_empty_n & fifo_valid;
    reg buf_fifo_empty_n;
    wire fifo_emtpy_n_tick = fifo_empty_n & (!buf_fifo_empty_n);
    reg fifo_start;
    assign rdma2_start = fifo_start;
    wire fifo_empty= !fifo_empty_n;
    //c_state
    reg [1:0] c_state;
    reg [1:0] n_state;
    //ar_state
    reg [1:0] ar_n_state;
    reg [1:0] ar_c_state;
    wire ar_fifo_full_n;
    wire is_boundary_4k;
    
    wire [3:0] rdma_to_arfifo_arlen;
    wire [3:0] arfifo_to_rdma_arlen;
    
    //r_state
    reg r_c_state;
    reg r_n_state;
    wire ar_fifo_empty_n;
    wire ar_fifo_empty= !ar_fifo_empty_n;
    
    rdma2_address RDMA2_Address(
    .clk(clk),
    .rst_n(rst_n),
    .ap_done(ap_done),
    .ap_start(ap_start),
    .ifm_channel(ifm_channel),
    .ofm_channel(ofm_channel),
    .ifm_width(ifm_width),
    .base_addr(base_addr),
    .is_conv_3(is_conv_3),
    .is_conv_1(is_conv_1),
    .is_maxpooling(is_maxpooling),
    .fifo_data(fifo_data),
    .fifo_valid(fifo_valid),
    .fifo_empty_n(fifo_empty_n)
    );
    
    reg [4:0] w_finish_cnt;
    reg [16:0] t_last_cnt;
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_fifo_empty_n <= 0;
            fifo_start <= 0;
            w_finish_cnt <=0;
            t_last_cnt <=0;
        end else begin
            buf_fifo_empty_n <= fifo_empty_n;
            if(c_state == done)begin
                fifo_start <= 0;
            end else if(fifo_emtpy_n_tick)begin
                fifo_start <= 1;
            end
            if(c_state == pre)begin
                case(ifm_width)
                    416: begin
                        w_finish_cnt <= 31;
                        t_last_cnt <= 39936;
                    end
                    208: begin 
                        w_finish_cnt <= 15;
                        t_last_cnt <= 106496;
                    end
                    104: begin 
                        w_finish_cnt <= 7;
                        t_last_cnt <= 53248;
                    end
                    52: begin 
                        w_finish_cnt <= 3;
                        t_last_cnt <= 26624;
                    end
                    26:begin 
                        w_finish_cnt <= 1;
                        t_last_cnt <= 13312;
                    end
                    13: begin 
                        w_finish_cnt <=0;
                        case(ifm_channel)
                        512: t_last_cnt <= 6656;
                        1024: t_last_cnt <= 13312;
                        1280: t_last_cnt <= 16640;
                        endcase
                    end
                endcase
            end
        end
    end
    
    reg [3:0]init_arlen;
    reg [6:0] arlen_mem_cal;
    reg [4:0] w_cnt;
    reg [10:0] c_cnt;
    reg [16:0] t_cnt;

    reg h_cnt;
    reg not_reuse;
    reg is_52;
    wire ar_len_5 = (w_cnt == 2) || (w_cnt == 3) || (w_cnt == 6) || (w_cnt == 7) || (w_cnt == 10)
                     || (w_cnt == 11) || (w_cnt == 14) || (w_cnt == 15) || (w_cnt == 18) || (w_cnt == 19)
                     || (w_cnt == 22) || (w_cnt == 23) || (w_cnt == 26) || (w_cnt == 27);
    
    always@(posedge clk)begin
        if(!rst_n)begin
            arlen_mem_cal<=0;
            not_reuse <= 1;
            init_arlen <= 0;
            w_cnt <= 0;
            c_cnt <= 0;
            is_52 <= 0;
            t_cnt <= 0;
            h_cnt <= 0;
        end else begin
            is_52 <= (ifm_channel == 52);
            case(c_state)
                pre:begin
                    if(is_conv_3 || is_conv_1)begin
                        init_arlen <= 4;
                        arlen_mem_cal <= 31;
                    end else begin
                        init_arlen <= 13;
                        arlen_mem_cal <= 103;
                    end
                end
                run:begin
                    if(fifo_hs & is_conv_3)begin
                        if((w_cnt == w_finish_cnt)&(c_cnt == ifm_channel-1))begin
                            if(t_last_cnt -1 == t_cnt)begin
                                t_cnt <=0;
                                not_reuse <= 1;
                            end else if (not_reuse & !h_cnt)begin
                                not_reuse <= 1;
                                t_cnt <= t_cnt+1;
                            end else begin
                                not_reuse <= 0;
                                t_cnt <= t_cnt+1;
                            end
                            if((not_reuse & h_cnt) || !not_reuse)begin 
                                h_cnt <= 0;
                                w_cnt <=0;
                                c_cnt <=0;
                            end else begin
                                h_cnt <= h_cnt+1;
                            end
                        end else if(c_cnt == ifm_channel-1)begin
                            if(not_reuse & h_cnt)begin 
                                c_cnt <=0;
                                w_cnt <= w_cnt + 1;
                            end else if(!not_reuse)begin
                                c_cnt <=0;
                                w_cnt <= w_cnt + 1;
                            end
                            t_cnt <= t_cnt+1;
                            if(not_reuse)h_cnt <= h_cnt+1;
                            else h_cnt <= 0;
                        end else begin
                            if(not_reuse)begin
                                if(h_cnt == 1) c_cnt <= c_cnt + 1;
                                t_cnt<= t_cnt+1;
                                h_cnt <= h_cnt+1;
                            end else begin
                                c_cnt <= c_cnt + 1;
                                t_cnt<= t_cnt+1;
                            end
                        end
                    end
                    if(is_conv_3 & fifo_hs & (c_cnt == ifm_channel-1)&(!not_reuse || not_reuse & h_cnt))begin
                        if(ar_len_5 & !(w_cnt >= w_finish_cnt-1))begin
                            init_arlen <= 5;
                            arlen_mem_cal <= 39;
                        end else begin 
                            init_arlen <= 4;
                            arlen_mem_cal <= 31;
                        end
                    end
                end
            endcase
        end
    end
    
    //total_state
    
    always@(posedge clk)begin
        if(!rst_n)begin
            c_state <= idle;
        end else begin
            c_state <= n_state;
        end
    end
    

    always@(*)begin
        n_state = c_state;
        case(c_state)
            idle:begin
                if(fifo_emtpy_n_tick) n_state = pre;
            end
            pre: n_state = run;
            run:begin
                if(fifo_start & fifo_empty) n_state = done;
            end
            done:begin
                if(ap_done & !ap_start) n_state = idle;
            end
        endcase
    end
    assign rdma2_done = (c_state ==done & ar_fifo_empty);
    //ar_state
    assign axi_rdma2_ARVALID = ar_fifo_full_n && (ar_c_state==boundary_4k || ar_c_state==run) ;

    wire ar_hs = axi_rdma2_ARVALID & axi_rdma2_ARREADY;
    always@(posedge clk)begin
        if(!rst_n)begin
            ar_c_state <= idle;
        end else begin
            ar_c_state <= ar_n_state;
        end
    end
    
    always@(*)begin
        ar_n_state = ar_c_state;
        case(ar_c_state)
            idle:begin
                if(c_state == run & ar_fifo_full_n)ar_n_state = pre;
            end
            pre:begin
                if(is_boundary_4k)begin
                    ar_n_state = boundary_4k;
                end else begin
                    ar_n_state = run;
                end
            end
            boundary_4k:begin
                if(ar_hs) ar_n_state = run;
            end
            run:begin
                if(ar_hs) ar_n_state = idle; 
            end
        endcase
    end
    
    
    wire [3:0] boundary_4k_burst;
    wire [3:0] after_boundary_4k_burst;
    reg [3:0] real_ar_len;
    reg [3:0] after_4k_len;
    reg [31:0] real_address;
    assign axi_rdma2_ARADDR = real_address;
    assign axi_rdma2_ARLEN = real_ar_len - 1;
    
    assign fifo_valid = (ar_c_state ==pre);
    assign is_boundary_4k = {1'b0,fifo_data[11:0]} + arlen_mem_cal > 12'hFFF;
    assign boundary_4k_burst = (13'd4096 - fifo_data[11:0]) >> 3;
    assign after_boundary_4k_burst = init_arlen - boundary_4k_burst;
    
    assign rdma_to_arfifo_arlen = real_ar_len;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            real_ar_len <= 0;
            after_4k_len <= 0;
            real_address <=0;
        end else begin
            case(ar_c_state)
            pre:begin
                real_address <= fifo_data;
                if(is_boundary_4k)begin
                    real_ar_len <= boundary_4k_burst;
                    after_4k_len <= after_boundary_4k_burst;
                end else begin
                    real_ar_len <= init_arlen;
                end
            end
            boundary_4k:begin
                if(ar_hs)begin
                    real_ar_len <= after_4k_len;
                    real_address <= real_address + (real_ar_len << 3);
                end
            end
            endcase
        end
    end
    //r_state
    wire r_hs= axi_rdma2_RREADY & axi_rdma2_RVALID;
    wire real_rlast_done = axi_rdma2_RLAST & r_hs;
    
    ar_len_fifo RDMA2_ARLEN_FIFO(
        .clk(clk),
        .rst_n(rst_n),
        .rdma_to_arfifo_arlen(rdma_to_arfifo_arlen),
        .arfifo_to_rdma_arlen(arfifo_to_rdma_arlen),
        .is_rlast(real_rlast_done),
        .ar_fifo_full_n(ar_fifo_full_n), //axi_rdma2_ARVALID
        .ar_ready(ar_hs),
        .ar_fifo_empty_n(ar_fifo_empty_n)
    );
    


    assign rdma2_valid = r_hs;
    reg [3:0] arlen_cnt;
    wire is_burst_done = (arlen_cnt == arfifo_to_rdma_arlen -1) & (axi_rdma2_RLAST);
    assign axi_rdma2_RREADY = ar_fifo_empty_n & !bram_full & !w_full_mp; //
    //assign axi_rdma2_RREADY = !bram_full;
    //assign test = ar_fifo_empty_n;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            arlen_cnt <= 0;
            r_c_state <= idle;
        end else begin
            if(r_hs)begin
                if(is_burst_done) arlen_cnt <= 0;
                else arlen_cnt <= arlen_cnt+1;
            end 
            r_c_state <= r_n_state;
        end
    end
    
    always@(*)begin
        r_n_state = r_c_state;
        case(r_c_state)
            idle:begin
                if(ar_fifo_empty_n) r_n_state = run;
            end
            run:begin
                if(is_burst_done & (!ar_fifo_empty_n)) r_n_state = idle;
            end
        endcase
    end
    
endmodule
