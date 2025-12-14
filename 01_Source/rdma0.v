`timescale 1ns / 1ps

 module rdma0(
    input clk,
    input rst_n,
    input bram_full_n,
    output [63:0] rdma0_data,
    output rdma0_valid,
    input rdma0_start,
    //axi ports
    output axi_rdma0_ARVALID,
    input axi_rdma0_ARREADY,
    output [31:0] axi_rdma0_ARADDR,
    output axi_rdma0_ARID,
    output [7:0] axi_rdma0_ARLEN,
    output [2:0] axi_rdma0_ARSIZE,
    output [1:0] axi_rdma0_ARBURST,
    output [1:0] axi_rdma0_ARLOCK,
    output [3:0] axi_rdma0_ARCACHE,
    output [2:0] axi_rdma0_ARPROT,
    output [3:0] axi_rdma0_ARQOS,
    output [3:0] axi_rdma0_ARREGION,
    output axi_rdma0_ARUSER,
    input axi_rdma0_RVALID,
    output axi_rdma0_RREADY,
    input [63:0] axi_rdma0_RDATA,
    input axi_rdma0_RLAST,
    input axi_rdma0_RID,
    input axi_rdma0_RUSER,
    input [1:0] axi_rdma0_RRESP,
    
    //etc ports
    input [31:0] base_addr,
    input [31:0] transfer_byte
    );
    assign axi_rdma0_ARID = 1'b0;
    assign axi_rdma0_ARSIZE = 3'b011;
    assign axi_rdma0_ARBURST = 2'b01;
    assign axi_rdma0_ARLOCK = 2'b0;
    assign axi_rdma0_ARCACHE = 4'b0;
    assign axi_rdma0_ARPROT = 3'b0;
    assign axi_rdma0_ARQOS = 4'b0;
    assign axi_rdma0_ARREGION = 4'b0;
    assign axi_rdma0_ARUSER = 1'b0;
    assign rdma0_data = axi_rdma0_RDATA;

    
    localparam idle = 2'b00;
    localparam pre = 2'b01;
    localparam run = 2'b10;
    localparam done = 2'b11;
    localparam boundary_4k = 2'b11;
    
    reg buf_rdma_start_n;
    wire rdma_start_tick = rdma0_start & (!buf_rdma_start_n);

    wire rdma_start_n= !rdma0_start;
    
    //c_state
    reg [1:0] c_state;
    reg [1:0] n_state;
    //ar_state
    reg [1:0] ar_n_state;
    reg [1:0] ar_c_state;
    wire ar_fifo_full_n;
    wire is_boundary_4k;
    
    wire [5:0] rdma_to_arfifo_arlen;
    wire [5:0] arfifo_to_rdma_arlen;
    
    //r_state
    reg r_c_state;
    reg r_n_state;
    wire ar_fifo_empty_n;
    wire ar_fifo_empty= !ar_fifo_empty_n;
    wire rdma0_done;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_rdma_start_n <= 0;
        end else begin
            buf_rdma_start_n <= rdma_start_n;
        end
    end
    
    reg [31:0] finish_address;
    //total_state
    wire is_last_ar = (axi_rdma0_ARADDR + (axi_rdma0_ARLEN + 1)*8)  == finish_address;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            c_state <= idle;
        end else begin
            c_state <= n_state;
        end
    end
    
    wire ar_hs = axi_rdma0_ARVALID & axi_rdma0_ARREADY;
    
    always@(*)begin
        n_state = c_state;
        case(c_state)
            idle:begin
                if(rdma_start_tick) n_state = pre;
            end
            pre: n_state = run;
            run:begin
                if(is_last_ar & ar_hs) n_state = done;
            end
            done:begin
                if(rdma0_done) n_state = idle;
            end
        endcase
    end
    
    assign rdma0_done = (c_state ==done & ar_fifo_empty &!rdma_start_tick);
    

    
    always@(posedge clk)begin
        if(!rst_n)begin
            finish_address <=0;
        end else begin
            if(c_state == pre)begin
                finish_address <= transfer_byte + base_addr;
            end else if(c_state ==idle)begin
                finish_address <= 0;
            end
        end
    end
    
    reg[31:0] init_address;
    reg [7:0] init_arlen;
    reg[31:0] remain_hs_cnt;
    reg [8:0] arlen_mem_cal;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            init_address <= 0;
            init_arlen <= 0;
            remain_hs_cnt<=0;
            arlen_mem_cal<=0;
        end else begin
            case(c_state)
                idle:begin
                    init_address <= 0;
                    init_arlen <= 0;
                    remain_hs_cnt<=0;
                    arlen_mem_cal<=0;
                end
                pre: begin
                    init_address <= base_addr;
                    init_arlen <= 8;
                    remain_hs_cnt <= (transfer_byte >> 3) - 8;
                    arlen_mem_cal<= 64 -1;
                end
                run: begin
                    if(ar_hs & ar_c_state == run)begin
                        if(remain_hs_cnt >32)begin
                            remain_hs_cnt <= remain_hs_cnt - 32;
                            init_arlen <= 32;
                            arlen_mem_cal <= 32*8 - 1;
                        end else begin
                            init_arlen <= remain_hs_cnt;
                            arlen_mem_cal <= remain_hs_cnt*8 - 1;
                        end
                        if(!is_last_ar) init_address <= init_address + (init_arlen*8);
                    end
                end
            endcase
        end
    end
    //ar_state
    assign axi_rdma0_ARVALID = ar_fifo_full_n && (ar_c_state==boundary_4k || ar_c_state==run) ;


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
    
    
    wire [5:0] boundary_4k_burst;
    wire [5:0] after_boundary_4k_burst;
    reg [5:0] real_ar_len;
    reg [5:0] after_4k_len;
    reg [31:0] real_address;
    assign axi_rdma0_ARADDR = real_address;
    assign axi_rdma0_ARLEN = real_ar_len - 1;
    
    assign is_boundary_4k = {1'b0,init_address[11:0]} + arlen_mem_cal > 12'hFFF;
    assign boundary_4k_burst = (13'd4096 - init_address[11:0]) >> 3;
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
                real_address <= init_address;
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
    wire r_hs= axi_rdma0_RREADY & axi_rdma0_RVALID;
    wire real_rlast_done = axi_rdma0_RLAST & r_hs;
    
    ar_len_fifo #(.FIFO_SIZE(6)) RDMA0_ARLEN_FIFO(
        .clk(clk),
        .rst_n(rst_n),
        .rdma_to_arfifo_arlen(rdma_to_arfifo_arlen),
        .arfifo_to_rdma_arlen(arfifo_to_rdma_arlen),
        .is_rlast(real_rlast_done),
        .ar_fifo_full_n(ar_fifo_full_n), //axi_rdma2_ARVALID
        .ar_ready(ar_hs),
        .ar_fifo_empty_n(ar_fifo_empty_n)
    ); 
    


    assign rdma0_valid = r_hs;
    reg [4:0] arlen_cnt;
    wire is_burst_done = (arlen_cnt == arfifo_to_rdma_arlen -1) & (axi_rdma0_RLAST);
    assign axi_rdma0_RREADY = ar_fifo_empty_n & bram_full_n;
    
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
