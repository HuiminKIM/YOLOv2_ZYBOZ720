`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/17 12:37:00
// Design Name: 
// Module Name: ofm_wdma_controller
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


module ofm_wdma_controller(
    input clk,
    input rst_n,
    input ofm_valid,
    input [63:0] ofm_data,
    output reg ofm_bram_valid,
    output reg [63:0] ofm_bram_data,
    input [31:0] ofm_transferbyte,
    input ofm_axi_ready,
    input ap_start,
    output w_full
    );
    localparam bram0 = 3'b000;
    localparam bram1 = 3'b001;
    localparam bram2 = 3'b010;
    localparam bram3 = 3'b011;
    localparam bram4 = 3'b100;
    localparam bram5 = 3'b101;
    localparam bram6 = 3'b110;
    localparam idle = 3'b111;
    
    reg [2:0] r_c_state;
    reg [2:0] r_n_state;
    reg [2:0] w_c_state;
    reg [2:0] w_n_state;
    
    wire ofm_valid0;
    wire ofm_valid1;
    wire ofm_valid2;
    wire ofm_valid3;
    wire ofm_valid4;
    wire ofm_valid5;
    wire ofm_valid6;
    
    wire ofm_bram_valid0;
    wire ofm_bram_valid1;
    wire ofm_bram_valid2;
    wire ofm_bram_valid3;
    wire ofm_bram_valid4;
    wire ofm_bram_valid5;
    wire ofm_bram_valid6;
    
    wire ofm_bram0_full;
    wire ofm_bram1_full;
    wire ofm_bram2_full;
    wire ofm_bram3_full;
    wire ofm_bram4_full;
    wire ofm_bram5_full;
    wire ofm_bram6_full;
    
    
    wire ofm_bram0_full_n = !ofm_bram0_full;
    wire ofm_bram1_full_n = !ofm_bram1_full;
    wire ofm_bram2_full_n = !ofm_bram2_full;
    wire ofm_bram3_full_n = !ofm_bram3_full;
    wire ofm_bram4_full_n = !ofm_bram4_full;
    wire ofm_bram5_full_n = !ofm_bram5_full;
    wire ofm_bram6_full_n = !ofm_bram6_full;
    
    reg buf_ofm_bram0_full;
    reg buf_ofm_bram1_full;
    reg buf_ofm_bram2_full;
    reg buf_ofm_bram3_full;
    reg buf_ofm_bram4_full;
    reg buf_ofm_bram5_full;
    reg buf_ofm_bram6_full;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_ofm_bram0_full <= 0;
            buf_ofm_bram1_full <= 0;
            buf_ofm_bram2_full <= 0;
            buf_ofm_bram3_full <= 0;
            buf_ofm_bram4_full <= 0;
            buf_ofm_bram5_full <= 0;
            buf_ofm_bram6_full <= 0;
        end else begin
            buf_ofm_bram0_full <= ofm_bram0_full;
            buf_ofm_bram1_full <= ofm_bram1_full;
            buf_ofm_bram2_full <= ofm_bram2_full;
            buf_ofm_bram3_full <= ofm_bram3_full;
            buf_ofm_bram4_full <= ofm_bram4_full;
            buf_ofm_bram5_full <= ofm_bram5_full;
            buf_ofm_bram6_full <= ofm_bram6_full;
        end 
    end
    
    wire minus_tick =( (buf_ofm_bram0_full & ofm_bram0_full_n) | (buf_ofm_bram1_full & ofm_bram1_full_n) | (buf_ofm_bram2_full & ofm_bram2_full_n) | 
                        (buf_ofm_bram3_full & ofm_bram3_full_n) |(buf_ofm_bram4_full & ofm_bram4_full_n) |(buf_ofm_bram5_full & ofm_bram5_full_n) |(buf_ofm_bram6_full & ofm_bram6_full_n) ); 
    
    wire [63:0] ofm_bram0_data;
    wire [63:0] ofm_bram1_data;
    wire [63:0] ofm_bram2_data;
    wire [63:0] ofm_bram3_data;
    wire [63:0] ofm_bram4_data;
    wire [63:0] ofm_bram5_data;
    wire [63:0] ofm_bram6_data;
    
    reg [3:0]read_cnt0;
    reg [3:0]read_cnt1;
    reg [3:0]read_cnt2;
    reg [3:0]read_cnt3;
    reg [3:0]read_cnt4;
    reg [3:0]read_cnt5;
    reg [3:0]read_cnt6;
    
    reg buf_start;
    wire start_tick = buf_start & ap_start;
    reg start;
    
    reg [31:0]total_read_cnt;
    reg [31:0]current_read_cnt;
    wire done = current_read_cnt>=total_read_cnt;
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_start<=0;
            start<=0;
            total_read_cnt<=0;
            current_read_cnt<=0;
            read_cnt0<=10;
            read_cnt1<=10;
            read_cnt2<=10;
            read_cnt3<=10;
            read_cnt4<=10;
            read_cnt5<=10;
            read_cnt6<=10;
        end else begin
            buf_start <= ap_start;
            if(done) start<=0;
            else if(start_tick) start<=1;
            total_read_cnt<= ofm_transferbyte >>3;
            if(!ap_start & (!ofm_bram0_full & !ofm_bram1_full & !ofm_bram2_full))begin
                read_cnt0<=10;
                read_cnt1<=10;
                read_cnt2<=10;
                read_cnt3<=10;
                read_cnt4<=10;
                read_cnt5<=10;
                read_cnt6<=10;
                current_read_cnt<=0;
            end else if(start)begin
                case(r_c_state)
                    bram0:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt1<=10; // total_read_cnt - (current_read_cnt+10) >10 is equal total_read_cnt - current_read_cnt > 20
                        else read_cnt1<=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram0_full)current_read_cnt<=current_read_cnt+10;
                    end
                    bram1:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt2<=10;
                        else read_cnt2<=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram1_full)current_read_cnt<=current_read_cnt+10;
                    end
                    bram2:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt3<=10;
                        else read_cnt3<=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram2_full)current_read_cnt<=current_read_cnt+10;
                    end
                    bram3:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt4 <=10;
                        else read_cnt4 <=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram3_full)current_read_cnt<=current_read_cnt+10;
                    end
                    bram4:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt5<=10;
                        else read_cnt5<=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram4_full)current_read_cnt<=current_read_cnt+10;
                    end
                    bram5:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt6<=10;
                        else read_cnt6<=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram5_full)current_read_cnt<=current_read_cnt+10;
                    end
                    bram6:begin
                        if(total_read_cnt - current_read_cnt > 20)read_cnt0<=10;
                        else read_cnt0<=total_read_cnt - (current_read_cnt+10);
                        if(ofm_bram6_full)current_read_cnt<=current_read_cnt+10;
                    end
                endcase
            end
        end
    end
    
    //read side
    always@(posedge clk)begin
        if(!rst_n)begin
            r_c_state<=bram0;
        end else begin
            r_c_state<=r_n_state;
        end
    end
    
    always@(*)begin
        r_n_state = r_c_state;
        case(r_c_state)
            bram0:begin
                if(ofm_bram0_full)r_n_state = bram1;
            end
            bram1:begin
                if(ofm_bram1_full)r_n_state = bram2;
            end
            bram2:begin
                if(ofm_bram2_full)r_n_state = bram3;
            end
            bram3:begin
                if(ofm_bram3_full)r_n_state = bram4;
            end
            bram4:begin
                if(ofm_bram4_full)r_n_state = bram5;
            end
            bram5:begin
                if(ofm_bram5_full)r_n_state = bram6;
            end
            bram6:begin
                if(ofm_bram6_full)r_n_state = bram0;
            end
        endcase
    end
    
    
    //assign w_full = 0;
    reg [2:0] remain_cnt;
    
    assign w_full = remain_cnt[2];
    
    always@(posedge clk)begin
        if(!rst_n)begin
            remain_cnt <= 0;
        end else begin
            case(r_c_state)
                bram0:begin
                    if(!minus_tick & ofm_bram0_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram0_full) remain_cnt <= remain_cnt -1;
                end
                bram1:begin
                    if(!minus_tick & ofm_bram1_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram1_full) remain_cnt <= remain_cnt -1;
                end
                bram2:begin
                    if(!minus_tick & ofm_bram2_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram2_full) remain_cnt <= remain_cnt -1;
                end
                bram3:begin
                    if(!minus_tick & ofm_bram3_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram3_full) remain_cnt <= remain_cnt -1;
                end
                bram4:begin
                    if(!minus_tick & ofm_bram4_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram4_full) remain_cnt <= remain_cnt -1;
                end
                bram5:begin
                    if(!minus_tick & ofm_bram5_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram5_full) remain_cnt <= remain_cnt -1;
                end
                bram6:begin
                    if(!minus_tick & ofm_bram6_full)remain_cnt <= remain_cnt+1;
                    else if (minus_tick& !ofm_bram6_full) remain_cnt <= remain_cnt -1;
                end
            endcase
        end
    end
    
    assign ofm_valid0 = ofm_valid & (r_n_state == bram0);
    assign ofm_valid1 = ofm_valid & (r_n_state == bram1);
    assign ofm_valid2 = ofm_valid & (r_n_state == bram2);
    assign ofm_valid3 = ofm_valid & (r_n_state == bram3);
    assign ofm_valid4 = ofm_valid & (r_n_state == bram4);
    assign ofm_valid5 = ofm_valid & (r_n_state == bram5);
    assign ofm_valid6 = ofm_valid & (r_n_state == bram6);
    
    //write side
    always@(posedge clk)begin
        if(!rst_n)begin
            w_c_state <= idle;
        end else begin
            w_c_state <= w_n_state;
        end
    end
    
    always@(*)begin
        w_n_state = w_c_state;
        case(w_c_state)
            idle:begin
                if(ofm_bram0_full)w_n_state = bram0;
            end
            bram0:begin
                if(ofm_bram1_full & !ofm_bram0_full)w_n_state = bram1;
            end
            bram1:begin
                if(ofm_bram2_full & !ofm_bram1_full)w_n_state = bram2;
            end
            bram2:begin
                if(ofm_bram3_full & !ofm_bram2_full)w_n_state = bram3;
            end
            bram3:begin
                if(ofm_bram4_full & !ofm_bram3_full)w_n_state = bram4;
            end
            bram4:begin
                if(ofm_bram5_full & !ofm_bram4_full)w_n_state = bram5;
            end
            bram5:begin
                if(ofm_bram6_full & !ofm_bram5_full)w_n_state = bram6;
            end
            bram6:begin
                if(ofm_bram0_full & !ofm_bram6_full)w_n_state = bram0;
            end
        endcase
    end
    
    wire ofm_axi_ready0 = ofm_axi_ready &(w_c_state == bram0);
    wire ofm_axi_ready1 = ofm_axi_ready &(w_c_state == bram1);
    wire ofm_axi_ready2 = ofm_axi_ready &(w_c_state == bram2);
    wire ofm_axi_ready3 = ofm_axi_ready &(w_c_state == bram3);
    wire ofm_axi_ready4 = ofm_axi_ready &(w_c_state == bram4);
    wire ofm_axi_ready5 = ofm_axi_ready &(w_c_state == bram5);
    wire ofm_axi_ready6 = ofm_axi_ready &(w_c_state == bram6);
    
    always@(*)begin
        case(w_c_state)
            idle:begin
                ofm_bram_valid = 0;
                ofm_bram_data = 0;
            end
            bram0:begin
                ofm_bram_valid = ofm_bram_valid0;
                ofm_bram_data = ofm_bram0_data;
            end
            bram1:begin
                ofm_bram_valid = ofm_bram_valid1;
                ofm_bram_data = ofm_bram1_data;
            end
            bram2:begin
                ofm_bram_valid = ofm_bram_valid2;
                ofm_bram_data = ofm_bram2_data;
            end
            bram3:begin
                ofm_bram_valid = ofm_bram_valid3;
                ofm_bram_data = ofm_bram3_data;
            end
            bram4:begin
                ofm_bram_valid = ofm_bram_valid4;
                ofm_bram_data = ofm_bram4_data;
            end
            bram5:begin
                ofm_bram_valid = ofm_bram_valid5;
                ofm_bram_data = ofm_bram5_data;
            end
            bram6:begin
                ofm_bram_valid = ofm_bram_valid6;
                ofm_bram_data = ofm_bram6_data;
            end
        endcase
    end
    
    ofm_bram_controller OFM_BRAM_0(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid0),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid0),
    .ofm_axi_ready(ofm_axi_ready0),
    .ofm_bram_data(ofm_bram0_data),
    .ofm_bram_full(ofm_bram0_full),
    .read_cnt(read_cnt0)
    );
    
    ofm_bram_controller OFM_BRAM_1(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid1),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid1),
    .ofm_axi_ready(ofm_axi_ready1),
    .ofm_bram_data(ofm_bram1_data),
    .ofm_bram_full(ofm_bram1_full),
    .read_cnt(read_cnt1)
    );
    
    ofm_bram_controller OFM_BRAM_2(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid2),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid2),
    .ofm_axi_ready(ofm_axi_ready2),
    .ofm_bram_data(ofm_bram2_data),
    .ofm_bram_full(ofm_bram2_full),
    .read_cnt(read_cnt2)
    );
    
    ofm_bram_controller OFM_BRAM_3(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid3),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid3),
    .ofm_axi_ready(ofm_axi_ready3),
    .ofm_bram_data(ofm_bram3_data),
    .ofm_bram_full(ofm_bram3_full),
    .read_cnt(read_cnt3)
    );
    
    ofm_bram_controller OFM_BRAM_4(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid4),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid4),
    .ofm_axi_ready(ofm_axi_ready4),
    .ofm_bram_data(ofm_bram4_data),
    .ofm_bram_full(ofm_bram4_full),
    .read_cnt(read_cnt4)
    );
    
    ofm_bram_controller OFM_BRAM_5(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid5),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid5),
    .ofm_axi_ready(ofm_axi_ready5),
    .ofm_bram_data(ofm_bram5_data),
    .ofm_bram_full(ofm_bram5_full),
    .read_cnt(read_cnt5)
    );
    
    ofm_bram_controller OFM_BRAM_6(
    .clk(clk),
    .rst_n(rst_n),
    .ofm_valid(ofm_valid6),
    .ofm_data(ofm_data),
    .ofm_bram_valid(ofm_bram_valid6),
    .ofm_axi_ready(ofm_axi_ready6),
    .ofm_bram_data(ofm_bram6_data),
    .ofm_bram_full(ofm_bram6_full),
    .read_cnt(read_cnt6)
    );
endmodule
