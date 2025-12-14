`timescale 1ns / 1ps

module address_fsm(
    input clk,
    input rst_n,
    input is_conv_1,
    input is_conv_3,
    input is_maxpooling,
    input ap_start,
    input ap_done,
    input [10:0]ifm_channel,
    input [10:0]ofm_channel,
    input [8:0] ifm_width,
    input is_4k_boundary,
    output maxpool,
    output one_one_conv,
    output three_three_row_1,
    output three_three_reuse,
    output conv1_recycle,
    output recycle,
    input fifo_full_n
    );

localparam idle = 2'b00;
localparam oneXone = 2'b01;
localparam threeXthree = 2'b10;
localparam maxpooling = 2'b11;



reg [1:0]c_state;
reg [1:0]n_state;

wire oneXone_finish;
wire conv_1_finish;

wire threeXthree_finish;
wire conv_3_finish;

wire maxpooling_finish;
wire maxpool_finish;

assign maxpooling_finish = ap_done && maxpool_finish;
assign oneXone_finish= ap_done && conv_1_finish;
assign threeXthree_finish= ap_done && conv_3_finish;

//define main_fsm
always@(posedge clk)begin
    if(!rst_n)begin
        c_state <=idle;
    end else begin
        c_state <= n_state;
    end
end

always@(*)begin
    n_state = c_state;
    case(c_state)
        idle : begin
                if(is_conv_1 && !ap_done && ap_start) n_state = oneXone;
                else if(is_conv_3 && !ap_done && ap_start) n_state = threeXthree;
                else if (is_maxpooling && !ap_done && ap_start)n_state = maxpooling;
            end
        oneXone : begin
                if(oneXone_finish&& ap_done && !ap_start) n_state = idle;
            end
        threeXthree : begin
                if(threeXthree_finish && ap_done && !ap_start)n_state = idle;
            end
        maxpooling : begin
                if(maxpooling_finish&& ap_done && !ap_start)n_state = idle;
            end
    endcase
end

//define max pooling, conv_1, conv_3 fsm
reg [1:0] c_statem;
reg [1:0] n_statem;
reg [1:0] c_state1;
reg [1:0] n_state1;
reg [1:0] c_state3;
reg [1:0] n_state3;
always@(posedge clk)begin
    if(!rst_n)begin
        c_state3 <= idle;
        c_state1 <= idle;
        c_statem <= idle;
    end else begin
        c_state3 <= n_state3;
        c_state1 <= n_state1;
        c_statem <= n_statem;
    end
end

//maxpooling;
reg [16:0] mp_cnt;
reg [16:0] mp_finish_cnt;

//1x1 conv
wire conv_1_last_row_col;

reg [11:0] conv_1_ofm_cnt;
reg [16:0] conv_1_cnt;
reg [16:0] conv_1_finish_cnt;

//3x3 conv
wire row_1_last_col;
wire reuse_last_row_col;

reg[13:0] row_1_finish_cnt;
reg [16:0]last_row_finish_cnt;
reg [11:0] conv_3_cnt;
reg[13:0] row_1_cnt;
reg [16:0]reuse_row_cnt;

//maxpooling
assign maxpool_finish =  (mp_cnt >= mp_finish_cnt-1);
//1x1 convolution

assign conv_1_finish = (ofm_channel != 0) && (conv_1_ofm_cnt >= ofm_channel -1);
assign conv_1_last_row_col = (conv_1_cnt == conv_1_finish_cnt -1);
assign conv1_recycle = conv_1_last_row_col;

//3x3 convolution

assign conv_3_finish = (ofm_channel != 0) && (conv_3_cnt >= ofm_channel -1 );
assign row_1_last_col = (row_1_finish_cnt!=0 )&& (row_1_cnt==row_1_finish_cnt-1);
assign reuse_last_row_col = (reuse_row_cnt == last_row_finish_cnt-1);
assign recycle = reuse_last_row_col;

localparam row_1 = 2'b01;
localparam run = 2'b10;
localparam reuse = 2'b10;
localparam done = 2'b11;

always@(*)begin
    n_statem=c_statem;
    case(c_statem)
        idle : if(c_state == maxpooling) n_statem = run;
        run : if(fifo_full_n && maxpool_finish) n_statem = done;
        done : if(ap_done && !ap_start) n_statem = idle;
    endcase
end

assign maxpool = c_statem ==run;

always@(*)begin
    n_state1=c_state1;
    case(c_state1)
        idle: if(c_state == oneXone) n_state1 = run;
        run: if(fifo_full_n && conv_1_last_row_col && conv_1_finish) n_state1 = done;
        done: if(ap_done && !ap_start) n_state1 = idle;
    endcase
end

assign one_one_conv =  c_state1 == run;

always@(*)begin
    n_state3 = c_state3;
    case(c_state3)
        idle: if(c_state == threeXthree) n_state3 = row_1;
        row_1: if(fifo_full_n && row_1_last_col) n_state3 = reuse;
        reuse: if(fifo_full_n && reuse_last_row_col && conv_3_finish)begin 
                n_state3 = done;
               end else if(fifo_full_n && reuse_last_row_col)begin
                    n_state3 = row_1;
               end
        done : if(ap_done && !ap_start) n_state3 = idle;
    endcase 
end


assign three_three_row_1 = c_state3 == row_1;
assign three_three_reuse = c_state3 == reuse;

//maxpooling
always@(posedge clk)begin
    if(!rst_n)begin
        mp_finish_cnt<=0;
    end else begin
        case(ifm_width)
            416:begin
                mp_finish_cnt <= 106496;
            end
            208:begin
                mp_finish_cnt <= 53248;
            end
            104:begin
                mp_finish_cnt <= 26624;
            end
            52:begin
                mp_finish_cnt <= 13312;
            end
            26:begin
                mp_finish_cnt <= 6656;
            end
        endcase
    end
end
//1x1
always@(posedge clk)begin
    if(!rst_n)begin
        conv_1_finish_cnt<=0;
    end else begin
        case(ifm_width)
            104:begin
                conv_1_finish_cnt<=106496;
            end
            52:begin
                conv_1_finish_cnt<=53248;
            end
            26:begin
                conv_1_finish_cnt<=26624;
            end
            13:begin
                conv_1_finish_cnt<=13312;
            end
        endcase
    end
end
//3x3

always@(posedge clk)begin
    if(!rst_n)begin
        row_1_finish_cnt<=0;
        last_row_finish_cnt<=0;
    end else begin
        case(ifm_width)
            416: begin 
                    row_1_finish_cnt<=192;
                    last_row_finish_cnt<=39744;
                 end
            208: begin 
                    row_1_finish_cnt<=1024;
                    last_row_finish_cnt<=105472;
                 end
            104: begin 
                    row_1_finish_cnt<=1024;
                    last_row_finish_cnt<=52224;
                 end
            52: begin 
                    row_1_finish_cnt<=1024;
                    last_row_finish_cnt<=25600;
                 end
            26: begin 
                    row_1_finish_cnt<=1024;
                    last_row_finish_cnt<=12288;
                 end
            13: begin 
                    case(ifm_channel)
                        512: begin
                            row_1_finish_cnt<=1024; 
                            last_row_finish_cnt<=5632;
                            end
                        1024: begin 
                            row_1_finish_cnt<=2048; 
                            last_row_finish_cnt<=11264;
                            end
                        1280: begin 
                            row_1_finish_cnt<=2560; 
                            last_row_finish_cnt<=14080;
                            end
                    endcase
                 end
        endcase
    end
end
//maxpooling
always@(posedge clk)begin
    if(!rst_n)begin
        mp_cnt <=0;
    end else begin
        if(c_statem == run && fifo_full_n && !is_4k_boundary)begin
            mp_cnt <= mp_cnt+1;
        end else if(c_statem == done && ap_done && !ap_start)begin
            mp_cnt <= 0;
        end
    end
end

//1x1
always@(posedge clk)begin
    if(!rst_n)begin
        conv_1_ofm_cnt<= 0;
        conv_1_cnt<= 0;
    end else begin
        case(c_state1)
            run:begin
                if(fifo_full_n && !is_4k_boundary)begin
                    if(conv_1_cnt == conv_1_finish_cnt-1)begin
                        conv_1_cnt<= 0;
                        conv_1_ofm_cnt<= conv_1_ofm_cnt+1;
                    end else begin
                        conv_1_cnt<= conv_1_cnt+1;
                    end
                end
            end
            done:begin
                if(ap_done && !ap_start)begin
                    conv_1_ofm_cnt<= 0;
                end
            end
        endcase
    end
end

//3x3
always@(posedge clk)begin
    if(!rst_n)begin
        row_1_cnt<=0;
        reuse_row_cnt<=0;
        conv_3_cnt<=0;
    end else begin
        case(c_state3)
            row_1: begin
                        if(fifo_full_n && !is_4k_boundary)begin
                             if(row_1_cnt == row_1_finish_cnt-1)begin
                                 row_1_cnt<=0;
                             end else begin
                                row_1_cnt<=row_1_cnt+1;
                             end
                        end
                    end
            reuse: begin
                         if(fifo_full_n && !is_4k_boundary)begin
                             if(reuse_row_cnt == last_row_finish_cnt-1)begin
                                 reuse_row_cnt<=0;
                                 if(!conv_3_finish)
                                 conv_3_cnt<=conv_3_cnt+1;
                             end else begin
                                reuse_row_cnt<=reuse_row_cnt+1;
                             end
                         end
                    end
            done: begin
                      if(ap_done && !ap_start)begin
                        conv_3_cnt<=0;
                      end
                  end
        endcase
        
    end
end
endmodule
