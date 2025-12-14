`timescale 1ns / 1ps

module address_calculation(
    input clk,
    input rst_n,
    input fifo_full_n,
    input maxpool,
    input one_one_conv,
    input three_three_row_1,
    input three_three_reuse,
    input conv1_recycle,
    input recycle,
    input [10:0] ifm_channel,
    input [31:0] base_addr,
    input [8:0] ifm_width,
    output [31:0] address,
    output addr_valid
    );
    reg buf0_fifo_full_n;
    reg buf1_fifo_full_n;
    reg init_addr_valid;
    
    reg buf_init_addr_valid;
    
    assign addr_valid = buf_init_addr_valid;
    reg [31:0] buf_init_addr;
    reg [31:0] init_addr;
    reg [31:0] real_addr;
    assign address = real_addr;
    
    reg [31:0] save_addr_row;
    reg [10:0] mp_width;
    reg [9:0] addr_width0;
    reg [9:0] addr_width1;
    reg [9:0] buf0_addr_width0;
    reg [9:0] buf1_addr_width0;
    reg [9:0] buf2_addr_width0;

    
    reg [31:0] save_addr_channnel;
    reg [18:0] addr_channel;
    
    reg [31:0] init_temp1;
    reg [31:0] init_temp2;
    
    reg [1:0] width_remain;
    reg [1:0] channel_remain;
    
    reg [4:0] w_cnt;
    reg [3:0] mp_end_w_cnt;
    reg [4:0] end_w_cnt;
    reg [9:0] save_col;
    reg [10:0] c_cnt;
    reg [1:0] c_cnt_13;
    reg [10:0] buf_c_cnt; 
    reg [1:0] h_cnt;
    reg [1:0] h_cnt_13;
    reg [1:0] buf_h_cnt;
    reg [1:0] buf_h_cnt1;
    reg [1:0] buf_h_cnt2;
    
    reg buf_three_three_row_1;
    reg buf_three_three_reuse;
    reg buf_one_one_conv;
    reg buf_maxpool;
    
    //maxpooling
    wire mp_26width = maxpool & (ifm_width == 26);
    wire mp_next_row = (w_cnt == mp_end_w_cnt) && fifo_full_n;
    reg buf_mp_next_row;
    wire mp_next_col = (h_cnt ==1 && fifo_full_n);
    reg buf_mp_next_col;
    //row1    
    wire next_row;
    reg buf_next_row;
    
    wire next_col;
    wire end_width;
    wire next_channel_3;
    reg buf_next_channel_3;
    reg buf_next_col;
    //wire buf_next_row;
    
    wire is_plus_col;
    wire one_one_plus_col;
    reg buf_is_plus_col;
    reg buf_one_one_plus_col;
    
    //reuse
    wire reuse_next_row;
    reg reuse_buf_next_row;
    
    wire reuse_next_col;
    wire reuse_end_width;
    wire reuse_next_channel_3;
    reg reuse_buf_next_channel_3;
    reg reuse_buf_next_col;
    //wire reuse_buf_next_row;
    
    reg buf_recycle;
    reg buf_conv1_recycle;
    
    wire three_three_conv;
    //row1
    assign next_channel_3 = (h_cnt ==1) && fifo_full_n;
    //assign buf_next_channel_3 = (buf_h_cnt ==1) && buf0_fifo_full_n;
    
    assign end_width = (w_cnt == end_w_cnt && fifo_full_n);
    
    assign next_col = (c_cnt == ifm_channel-1 && fifo_full_n && h_cnt==1);
    
    assign next_row = end_width & next_col;
    //end
    
    //reuse or 1x1  (Do not use before declare three_three_reuse or oneXone)
    assign reuse_next_channel_3 =  fifo_full_n;
    
    assign reuse_end_width = (w_cnt == end_w_cnt && fifo_full_n);
    
    assign reuse_next_col = (c_cnt == ifm_channel-1 && fifo_full_n);
    
    assign reuse_next_row = reuse_end_width & reuse_next_col;
    
    //end
    assign three_three_conv = (three_three_row_1 || three_three_reuse);
    assign is_plus_col = three_three_conv && (w_cnt ==4 || w_cnt ==8 || w_cnt ==12 || w_cnt ==16 || w_cnt ==20 || w_cnt ==24  || w_cnt ==28);
    assign one_one_plus_col = one_one_conv && (w_cnt == 3);
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_mp_next_col<=0;
            buf_mp_next_row <=0;
            buf_maxpool<=0;
            buf_recycle <=0;
            reuse_buf_next_channel_3 <= 0;
            buf_three_three_row_1<=0;
            buf_three_three_reuse<=0;
            buf_next_row<=0;
            reuse_buf_next_row<=0;
            buf0_addr_width0<=0;
            buf1_addr_width0<=0;
            buf2_addr_width0<=0;
            buf0_fifo_full_n<=0;
            buf1_fifo_full_n<=0;
            init_addr_valid<=0;
            buf_next_col<=0;
            reuse_buf_next_col<=0;
            buf_is_plus_col<=0;
            buf_next_channel_3 <= 0;
            buf_one_one_conv<=0;
            buf_one_one_plus_col <= 0;
            buf_conv1_recycle <= 0;
        end else begin
            buf_mp_next_col <= mp_next_col;
            buf_mp_next_row <= mp_next_row;
            buf_maxpool <= maxpool;
            buf_recycle <= recycle;
            reuse_buf_next_channel_3 <= reuse_next_channel_3;
            buf_three_three_row_1<=three_three_row_1;
            buf_three_three_reuse<=three_three_reuse;
            buf_next_row<=next_row;
            reuse_buf_next_row<=reuse_next_row;
            buf0_addr_width0<=addr_width0;
            buf1_addr_width0<=buf0_addr_width0;
            buf2_addr_width0<=buf1_addr_width0;
            buf0_fifo_full_n<=fifo_full_n;
            buf1_fifo_full_n<=buf0_fifo_full_n;
            init_addr_valid<=buf1_fifo_full_n;
            buf_next_col<= next_col;
            buf_next_channel_3 <= next_channel_3;
            reuse_buf_next_col<=reuse_next_col;
            buf_is_plus_col <= is_plus_col;
            buf_one_one_plus_col<= one_one_plus_col;
            buf_one_one_conv <= one_one_conv;
            buf_conv1_recycle <= conv1_recycle;
        end
    end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            save_addr_row <=0;
            save_addr_channnel <=0;
            save_col <=0;
        end else begin
            if(buf_three_three_row_1)begin
                if(buf_next_row)begin
                    save_addr_row <= save_addr_row + addr_width0 + addr_width1;
                    save_addr_channnel <=0;
                end else if(buf_next_col)begin
                    save_addr_channnel <=0;
                end else if(buf_next_channel_3)begin
                    save_addr_channnel <= save_addr_channnel + addr_channel;
                end 

                if(buf_next_row)begin
                    save_col <= 0;
                end else if(buf_next_col)begin
                    if(buf_is_plus_col)begin
                        save_col <= save_col+32;
                    end else begin
                        save_col <= save_col+24;
                    end
                end
                
            end else if(buf_three_three_reuse || buf_one_one_conv)begin
                if(reuse_buf_next_row)begin
                    if(buf_recycle || buf_conv1_recycle)begin
                        save_addr_row <= 0;
                    end else begin
                        if(buf_three_three_reuse) save_addr_row <= save_addr_row + addr_width1;
                        else if(buf_one_one_conv)save_addr_row <= save_addr_row + addr_width0;
                        
                    end
                    save_addr_channnel <=0;
                end else if(reuse_buf_next_col)begin
                    save_addr_channnel <=0;
                end else if(reuse_buf_next_channel_3)begin
                    save_addr_channnel <= save_addr_channnel + addr_channel;
                end
                
                if(reuse_buf_next_row)begin
                    save_col <= 0;
                end else if(reuse_buf_next_col)begin
                    if(buf_is_plus_col || buf_one_one_plus_col)begin
                        save_col <= save_col+32;
                    end else begin
                        save_col <= save_col+24;
                    end
                end
                
            end else if(buf_maxpool)begin
                if(mp_26width && buf0_fifo_full_n )begin
                    save_addr_row <= save_addr_row+104;
                end else begin
                    if(buf_mp_next_row)begin
                        save_col<=0;
                        save_addr_row <= save_addr_row +mp_width;
                    end else if(buf_mp_next_col)begin
                        save_col <= save_col+104;
                    end
                end
            end else begin
                save_addr_row <=0;
                save_addr_channnel <=0;
                save_col <=0;
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
             h_cnt<= 0;
             buf_h_cnt<=0;
             buf_h_cnt1 <=0;
             buf_h_cnt2 <=0;
             c_cnt<= 0;
             c_cnt_13 <=3;
             w_cnt<= 0;
             h_cnt_13<=3;
             buf_c_cnt<=0;
        end else begin
            buf_h_cnt<=h_cnt;
            buf_h_cnt1<=buf_h_cnt;
            buf_h_cnt2<=buf_h_cnt1;
            buf_c_cnt<=c_cnt;
            if(three_three_row_1 && fifo_full_n)begin
                if(next_channel_3)begin
                    h_cnt<= 0;
                    if(next_row)begin
                        c_cnt<= 0;
                        w_cnt<= 0;
                        h_cnt_13<=h_cnt_13-1;
                        c_cnt_13 <= h_cnt_13-1;
                    end else if(next_col)begin
                        c_cnt<= 0;
                        w_cnt<= w_cnt+1;
                    end else begin
                        c_cnt<= c_cnt+1;
                        c_cnt_13 <= c_cnt_13-1;
                    end
                end else if(fifo_full_n)begin
                    h_cnt<=h_cnt+1; 
                    h_cnt_13 <=3;
                    if(h_cnt_13 !=3 & c_cnt_13 !=3) c_cnt_13 <= 3;
                end
            end else if((one_one_conv || three_three_reuse) && fifo_full_n) begin
                if(reuse_next_channel_3)begin
                    if(reuse_next_row)begin
                        c_cnt<=0;
                        w_cnt<=0;
                        if(conv1_recycle)begin
                            h_cnt_13<=3;
                            c_cnt_13 <=3;
                        end else begin
                            h_cnt_13 <= h_cnt_13-1;
                            c_cnt_13 <= h_cnt_13-1;
                        end
                    end else if(reuse_next_col)begin
                        c_cnt<=0;
                        w_cnt<=w_cnt+1;
                    end else begin
                        c_cnt <= c_cnt+1;
                        c_cnt_13 <= c_cnt_13-1;
                    end
                end
            end else if(maxpool && fifo_full_n)begin
                if(mp_26width)begin
                    h_cnt<=0;
                end else if(w_cnt == mp_end_w_cnt)begin
                    w_cnt <= 0;
                    h_cnt<=0;
                end else if(h_cnt==1)begin
                    h_cnt<= 0;
                    w_cnt <= w_cnt+1;
                end else begin
                    w_cnt <= w_cnt+1;
                    h_cnt<=h_cnt+1;
                end
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            width_remain<=0;
            channel_remain<=0;
        end else begin
            if(three_three_row_1)begin
                if(recycle)begin
                    width_remain<=0;
                end else if(next_row)begin
                    width_remain<=width_remain+1;
                end
                if(next_row)begin
                    channel_remain<=0;
                end else if(next_channel_3)begin
                    channel_remain<=channel_remain+1;
                end
            end else if(three_three_reuse || one_one_conv)begin
                if(recycle)begin
                    width_remain<=0;
                end else if(reuse_next_row)begin
                    width_remain<=width_remain+1;
                end
                if(reuse_next_row)begin
                    channel_remain<=0;
                end else if(reuse_next_channel_3)begin
                    channel_remain<=channel_remain+1;
                end
            end
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            mp_width <= 0;
            mp_end_w_cnt <= 0; 
            addr_width0 <= 0; 
            addr_width1 <= 0; 
            end_w_cnt <= 0;
            addr_channel <= 0;
        end else begin
            case(ifm_width)
                416:begin 
                    mp_width <= 1664;
                    mp_end_w_cnt <= 15;
                    end_w_cnt <= 31;
                    addr_width0 <= 832; 
                    addr_width1 <= 832;
                    addr_channel <= 346112; 
                    end
                208:begin 
                    mp_width <= 832;
                    mp_end_w_cnt <= 7;
                    end_w_cnt <= 15;
                    addr_width0 <= 416; 
                    addr_width1 <= 416;
                    addr_channel <= 86528; 
                    end
                104:begin 
                    mp_width <= 416;
                    mp_end_w_cnt <= 3;
                    end_w_cnt <= 7;
                    addr_width0 <= 208; 
                    addr_width1 <= 208;
                    addr_channel <= 21632; 
                    end
                52:begin 
                    mp_width <= 208;
                    mp_end_w_cnt <= 1;
                    end_w_cnt <= 3;
                    addr_width0 <= 104; 
                    addr_width1 <= 104;
                    addr_channel <= 5408; 
                    end
                26:begin
                    mp_width <= 104;
                    end_w_cnt <= 1;
                    if(width_remain == 0 || width_remain == 2)begin
                        addr_width0 <= 48; 
                        addr_width1 <= 56;
                    end  else begin
                        addr_width0 <= 56;
                        addr_width1 <= 48;
                    end
                    addr_channel <= 1352; 
                    end
                13:begin 
                    end_w_cnt <= 0;
                    if(three_three_row_1 & !next_row)begin
                        if(c_cnt_13 == 0)begin
                            addr_width0 <= 32; 
                            addr_width1 <= 24;
                        end else begin
                            if(c_cnt_13 == 1)begin
                                addr_width1 <= 32;
                            end else begin
                                addr_width1 <= 24;
                            end
                            addr_width0 <= 24;
                        end
                    end else begin
                        if(h_cnt_13 ==0)begin
                            addr_width0 <= 32; 
                            addr_width1 <= 24;
                        end else begin
                            if(h_cnt_13 ==1)begin
                                addr_width1 <= 32;
                            end else begin
                                addr_width1 <= 24;
                            end
                            addr_width0 <= 24;
                        end
                    end
                    if(three_three_reuse)begin
                        if(c_cnt_13 == 1)begin
                            addr_channel <= 344; 
                        end else begin
                            addr_channel <= 336; 
                        end
                    end else begin
                        if(c_cnt_13 == 0)begin
                            addr_channel <= 344; 
                        end else begin
                            addr_channel <= 336; 
                        end
                    end
                    
                    end
            endcase
            
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_init_addr<=0;
            init_temp1<=0;
            init_temp2<=0;
        end else begin
            if(buf0_fifo_full_n)begin
                init_temp1 <= base_addr + save_addr_row;
                init_temp2 <= save_addr_channnel + save_col;
            end
            if(buf1_fifo_full_n) begin
                buf_init_addr <= init_temp1+init_temp2;
            end
        end
    end

    always@(*)begin
        if(init_addr_valid && buf_h_cnt2 == 0)begin
            init_addr = buf_init_addr;
        end else if(init_addr_valid && buf_h_cnt2 == 1)begin
            init_addr = buf_init_addr+buf2_addr_width0;
        end else begin
            init_addr = 0;
        end
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_init_addr_valid <= 0;
            real_addr<=0;
        end else begin
            buf_init_addr_valid <= init_addr_valid;
            real_addr <= init_addr;
        end
    end
endmodule
