`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/13 17:27:20
// Design Name: 
// Module Name: ar_len_fifo
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


module ar_len_fifo#(
    parameter FIFO_SIZE = 4,
    parameter FIFO_LOG = 2
    )(
    input clk,
    input rst_n,
    input [FIFO_SIZE-1:0] rdma_to_arfifo_arlen,
    output [FIFO_SIZE-1:0] arfifo_to_rdma_arlen,
    input is_rlast,
    output ar_fifo_full_n,
    input ar_ready,
    output ar_fifo_empty_n
    );
    
    reg [FIFO_SIZE-1:0] FIFO [0:3];
    wire addr_same;
    wire addr_flag;
    
    reg [FIFO_LOG:0] r_cnt;
    reg [FIFO_LOG:0] w_cnt;
    
    wire empty;
    wire full;
    
    assign addr_same = (r_cnt[FIFO_LOG-1 :0] == w_cnt[FIFO_LOG-1 :0]);
    assign addr_flag = r_cnt[FIFO_LOG] ^ w_cnt[FIFO_LOG];
    
    assign empty = addr_same && (!addr_flag);
    assign full = addr_same && addr_flag;
    
    assign ar_fifo_full_n = !full;
    assign ar_fifo_empty_n = !empty;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            r_cnt <= 0;
            w_cnt <= 0;
        end else begin
            if(ar_fifo_full_n && ar_ready)begin
                r_cnt<= r_cnt+1;
            end
            if(ar_fifo_empty_n && is_rlast)begin
                w_cnt <= w_cnt+1;
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            FIFO[0] <= 0;
            FIFO[1] <= 0;
            FIFO[2] <= 0;
            FIFO[3] <= 0;
        end else begin
            if(ar_fifo_full_n && ar_ready)begin
                FIFO[r_cnt[FIFO_LOG-1 :0]] <= rdma_to_arfifo_arlen;
            end
        end
    end
    
    assign arfifo_to_rdma_arlen = FIFO[w_cnt[FIFO_LOG-1 :0]];
endmodule
