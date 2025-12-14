`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/16 19:24:50
// Design Name: 
// Module Name: HP_2_cal
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


module HP_2_cal(
    input clk,
    input rst_n,
    input rdma2_start,
    input rdma2_done,
    input is_conv_1,
    input is_maxpooling,
    input is_conv_3,
    input [8:0] ifm_width,
    input [10:0] ifm_channel,
    input rdma2_valid,
    output [3:0]r_finish_cnt
    );
    
    localparam idle = 2'b00;
    localparam mp = 2'b01;
    localparam conv1 = 2'b10;
    localparam conv3 = 2'b11;
    
    reg [1:0] c_state;
    reg [1:0] n_state;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            c_state <= 0;
        end else begin
            c_state <= n_state;
        end
    end
    
    always@(*)begin
        n_state = c_state;
        case(c_state)
        idle:begin
            if(rdma2_start & is_conv_1)n_state = conv1;
            else if(rdma2_start & is_maxpooling)n_state = mp;
            else if(rdma2_start & is_conv_3)n_state = conv3;
            else n_state = idle;
        end
        mp:begin
            if(rdma2_done) n_state = idle;
        end
        conv1:begin
            if(rdma2_done) n_state = idle;
        end
        conv3:begin
            if(rdma2_done) n_state = idle;
        end
        endcase
    end
    
    reg [4:0] w_finish_cnt;
    reg [16:0] t_last_cnt;
    always@(posedge clk)begin
        if(!rst_n)begin
            w_finish_cnt <=0;
            t_last_cnt <=0;
        end else begin
            if(c_state == idle)begin
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
    reg [4:0] w_cnt;
    reg [10:0] c_cnt;
    reg [16:0] t_cnt;

    reg h_cnt;
    reg not_reuse;

    wire ar_len_5 = (w_cnt == 2) || (w_cnt == 3) || (w_cnt == 6) || (w_cnt == 7) || (w_cnt == 10)
                     || (w_cnt == 11) || (w_cnt == 14) || (w_cnt == 15) || (w_cnt == 18) || (w_cnt == 19)
                     || (w_cnt == 22) || (w_cnt == 23) || (w_cnt == 26) || (w_cnt == 27);
    
    reg [3:0] r_cnt;
    
    wire last_read = (r_cnt == init_arlen-1);
    
    always@(posedge clk)begin
        if(!rst_n)begin
            not_reuse <= 1;
            init_arlen <= 0;
            w_cnt <= 0;
            c_cnt <= 0;
            t_cnt <= 0;
            h_cnt <= 0;
            r_cnt <= 0;
        end else begin
        
            if(rdma2_valid & last_read) r_cnt <= 0;
            else if(rdma2_valid) r_cnt <= r_cnt + 1;
            
            case(c_state)
                idle:begin
                    if(is_conv_3 || is_conv_1)begin
                        init_arlen <= 4;
                    end else begin
                        init_arlen <= 13;
                    end
                end
                conv3:begin
                    if(rdma2_valid & last_read & is_conv_3)begin
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
                    if(rdma2_valid & is_conv_3 & last_read & (c_cnt == ifm_channel-1)&(!not_reuse || not_reuse & h_cnt))begin
                        if(ar_len_5 & !(w_cnt >= w_finish_cnt-1))begin
                            init_arlen <= 5;
                        end else begin 
                            init_arlen <= 4;
                        end
                    end
                end
            endcase
        end
    end
    
    assign r_finish_cnt = (not_reuse & is_conv_3)? (init_arlen+init_arlen) : init_arlen;
endmodule
