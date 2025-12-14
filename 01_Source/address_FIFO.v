`timescale 1ns / 1ps

module address_FIFO(
    input clk,
    input rst_n,
    input maxpool,
    input one_one_conv,
    input three_three_row_1,
    input three_three_reuse,
    output fifo_full_n,
    output reg [31:0] fifo_data,
    output fifo_empty_n,
    input [31:0] address,
    input addr_valid,
    input fifo_valid
    );
    reg [31:0] FIFO [0:3];
    reg read_flag;
    reg real_read_flag;
    reg write_flag;
    reg [1:0] r_cnt;
    reg [1:0]real_r_cnt;
    reg [1:0] w_cnt;
    
    wire empty = (real_read_flag == write_flag)&& (real_r_cnt == w_cnt);
    wire full = (read_flag != write_flag) &&(r_cnt == w_cnt);
    
    wire fifo_hs = fifo_valid & fifo_empty_n;
    
    assign fifo_full_n = (maxpool || one_one_conv || three_three_row_1 || three_three_reuse) && !full;
    assign fifo_empty_n = !empty;
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            r_cnt <= 0;
            w_cnt <= 0;
            real_r_cnt<= 0;
        end else begin
            if(addr_valid)begin
                real_r_cnt<= real_r_cnt+1;
            end
            if(fifo_full_n)begin
                r_cnt <= r_cnt +1;
            end
            if(fifo_empty_n && fifo_valid)begin
                w_cnt <= w_cnt+1;
            end
        end
    end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            read_flag <=0;
            real_read_flag<=0;
            write_flag <=0;
        end else begin
            if(r_cnt == 3 && fifo_full_n)begin
                read_flag <= read_flag+1;
            end
            if(real_r_cnt == 3 && addr_valid)begin
                real_read_flag <= real_read_flag+1;
            end
            if(w_cnt == 3 && fifo_empty_n && fifo_valid)begin
                write_flag <= write_flag +1;
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
            if(addr_valid)begin
                case(real_r_cnt)
                    0:begin
                        FIFO[0] <= address;
                    end
                    1:begin
                        FIFO[1] <= address;
                    end
                    2:begin
                        FIFO[2] <= address;
                    end
                    3:begin
                        FIFO[3] <= address;
                    end
                endcase
            end
            
        end
    end
    
    always@(*)begin
        if(fifo_empty_n)begin
                case(w_cnt)
                    0:begin
                        fifo_data = FIFO[0];
                    end
                    1:begin
                        fifo_data = FIFO[1];
                    end
                    2:begin
                        fifo_data = FIFO[2];
                    end
                    3:begin
                        fifo_data = FIFO[3];
                    end
                endcase
        end else begin
            fifo_data = 0;
        end
    end
endmodule