`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2024 07:27:49 PM
// Design Name: 
// Module Name: HP_0_controller
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


module HP_0_controller(
    input  wire [10:0] ifm_channel,
    input  wire [8:0] total_ifm,
    input  wire       convolution_3,
    input  wire       convolution_1,
    input  wire        ap_done,
    input  wire        is_bias,
    input  wire [31:0] bias_or_weight_transferbyte,
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] din,
    input  wire        write_en,
    output wire        full_n, // out_r_full_n rdma rready
    
    input  wire [31:0] m_axi_ARADDR,
    
    input  wire        bias_valid,
    
    output wire        bias_bram_full,
    input  wire        bias_reg_read_en,
    output wire [63:0] bias_reg_din,
    
    input  wire [10:0] con_ifm_channel,
    
    output wire        conv_1_bram0_full,
    output wire [63:0] conv_1_bram0_data,
    input  wire        conv_1_bram0_valid,
    
    output wire        conv_1_bram1_full,
    output wire [63:0] conv_1_bram1_data,
    input  wire        conv_1_bram1_valid,

    output wire        weight0_bram_full,
    input  wire        weight0_reg_read_en,
    output wire [63:0] weight0_reg_din,
    output wire        out_next0,
    output wire [1:0]  remain0,

    output wire        weight1_bram_full,
    input  wire        weight1_reg_read_en,
    output wire [63:0] weight1_reg_din,
    output wire        out_next1,
    output wire [1:0]  remain1,

    output wire        weight2_bram_full,
    input  wire        weight2_reg_read_en,
    output wire [63:0] weight2_reg_din,
    output wire        out_next2,
    output wire [1:0]  remain2,

    output wire        weight3_bram_full,
    input  wire        weight3_reg_read_en,
    output wire [63:0] weight3_reg_din,
    output wire        out_next3,
    output wire [1:0]  remain3,

    output wire        weight4_bram_full,
    input  wire        weight4_reg_read_en,
    output wire [63:0] weight4_reg_din,
    output wire        out_next4,
    output wire [1:0]  remain4,

    output wire        weight5_bram_full,
    input  wire        weight5_reg_read_en,
    output wire [63:0] weight5_reg_din,
    output wire        out_next5,
    output wire [1:0]  remain5,

    output wire        weight6_bram_full,
    input  wire        weight6_reg_read_en,
    output wire [63:0] weight6_reg_din,
    output wire        out_next6,
    output wire [1:0]  remain6,

    output wire        weight7_bram_full,
    input  wire        weight7_reg_read_en,
    output wire [63:0] weight7_reg_din,
    output wire        out_next7,
    output wire [1:0]  remain7,

    output wire        weight8_bram_full,
    input  wire        weight8_reg_read_en,
    output wire [63:0] weight8_reg_din,
    output wire        out_next8,
    output wire [1:0]  remain8,

    output wire        weight9_bram_full,
    input  wire        weight9_reg_read_en,
    output wire [63:0] weight9_reg_din,
    output wire        out_next9,
    output wire [1:0]  remain9,

    output wire        weight10_bram_full,
    input  wire        weight10_reg_read_en,
    output wire [63:0] weight10_reg_din,
    output wire        out_next10,
    output wire [1:0]  remain10,

    output wire        weight11_bram_full,
    input  wire        weight11_reg_read_en,
    output wire [63:0] weight11_reg_din,
    output wire        out_next11,
    output wire [1:0]  remain11,

    output wire        weight12_bram_full,
    input  wire        weight12_reg_read_en,
    output wire [63:0] weight12_reg_din,
    output wire        out_next12,
    output wire [1:0]  remain12,

    output wire        weight13_bram_full,
    input  wire        weight13_reg_read_en,
    output wire [63:0] weight13_reg_din,
    output wire        out_next13,
    output wire [1:0]  remain13,
    
    output wire        weight14_bram_full,
    input  wire        weight14_reg_read_en,
    output wire [63:0] weight14_reg_din,
    output wire        out_next14,
    output wire [1:0]  remain14,

    output wire        weight15_bram_full,
    input  wire        weight15_reg_read_en,
    output wire [63:0] weight15_reg_din,
    output wire        out_next15,
    output wire [1:0]  remain15
    //output wire [15:0]  ila_bram_full
    );
    localparam idle = 2'b00;
    localparam bias = 2'b01;
    localparam pre = 2'b10;
    localparam weight = 2'b11;
    localparam weight1= 1'b1;
    
    reg one_conv_c_state;
    reg one_conv_n_state;
    
    reg [1:0] c_state;
    reg [1:0] n_state;
    
    wire weight_full_n;
    wire conv1_weight_full_n;
    
    reg [31:0] bias_transferbyte;
    wire [63:0] bias_din;
    wire bias_write_en; //dram -> bram
    wire bias_full_n;
    
    wire [63:0] bram0_din;
    wire bram0_en;
    
    wire [63:0] bram1_din;
    wire bram1_en;
    
    wire [63:0] weight0_din;
    wire weight0_write_en; //dram -> bram
    wire weight0_full_n;
    
    wire [63:0] weight1_din;
    wire weight1_write_en; //dram -> bram
    wire weight1_full_n;
    
    wire [63:0] weight2_din;
    wire weight2_write_en; //dram -> bram
    wire weight2_full_n;
    
    wire [63:0] weight3_din;
    wire weight3_write_en; //dram -> bram
    wire weight3_full_n;
    
    wire [63:0] weight4_din;
    wire weight4_write_en; //dram -> bram
    wire weight4_full_n;
    
    wire [63:0] weight5_din;
    wire weight5_write_en; //dram -> bram
    wire weight5_full_n;
    
    wire [63:0] weight6_din;
    wire weight6_write_en; //dram -> bram
    wire weight6_full_n;
    
    wire [63:0] weight7_din;
    wire weight7_write_en; //dram -> bram
    wire weight7_full_n;
    
    wire [63:0] weight8_din;
    wire weight8_write_en; //dram -> bram
    wire weight8_full_n;
    
    wire [63:0] weight9_din;
    wire weight9_write_en; //dram -> bram
    wire weight9_full_n;
    
    wire [63:0] weight10_din;
    wire weight10_write_en; //dram -> bram
    wire weight10_full_n;
    
    wire [63:0] weight11_din;
    wire weight11_write_en; //dram -> bram
    wire weight11_full_n;
    
    wire [63:0] weight12_din;
    wire weight12_write_en; //dram -> bram
    wire weight12_full_n;
    
    wire [63:0] weight13_din;
    wire weight13_write_en; //dram -> bram
    wire weight13_full_n;
    
    wire [63:0] weight14_din;
    wire weight14_write_en; //dram -> bram
    wire weight14_full_n;
    
    wire [63:0] weight15_din;
    wire weight15_write_en; //dram -> bram
    wire weight15_full_n;
    
    reg [31:0] transfer_calc;
    reg [10:0] weight_transferbyte;
    wire [31:0] current_transferbyte;
    
    reg [3:0] bram_weight_num;
    reg [3:0] bram_reg;
    
    reg pushflag;
    reg buf_pushflag;
    
    reg [31:0] cnt;
    reg [31:0] test;

    
    reg [10:0] weight0_transferbyte;
    reg [10:0] weight1_transferbyte;
    reg [10:0] weight2_transferbyte;
    reg [10:0] weight3_transferbyte;
    reg [10:0] weight4_transferbyte;
    reg [10:0] weight5_transferbyte;
    reg [10:0] weight6_transferbyte;
    reg [10:0] weight7_transferbyte;
    reg [10:0] weight8_transferbyte;
    reg [10:0] weight9_transferbyte;
    reg [10:0] weight10_transferbyte;
    reg [10:0] weight11_transferbyte;
    reg [10:0] weight12_transferbyte;
    reg [10:0] weight13_transferbyte;
    reg [10:0] weight14_transferbyte;
    reg [10:0] weight15_transferbyte;
    
    reg bias_control;
    
    assign full_n = (c_state == bias && !bias_bram_full && bias_control !=  1)?1:(c_state==weight&&bram_reg==bram_weight_num)? weight_full_n:(one_conv_c_state == weight1)? conv1_weight_full_n:0;
    
    assign weight_full_n=(weight0_full_n || weight1_full_n || weight2_full_n || weight3_full_n || weight4_full_n || weight5_full_n || weight6_full_n || weight7_full_n||
                          weight8_full_n || weight9_full_n || weight10_full_n || weight11_full_n || weight12_full_n || weight13_full_n || weight14_full_n || weight15_full_n);
                          
    //assign ila_bram_full = {!weight0_full_n,!weight1_full_n,!weight2_full_n,!weight3_full_n,!weight4_full_n,!weight5_full_n, !weight6_full_n,!weight7_full_n,
                          //!weight8_full_n,!weight9_full_n,!weight10_full_n,!weight11_full_n,!weight12_full_n,!weight13_full_n,!weight14_full_n,!weight15_full_n};
    
    assign conv1_weight_full_n = (!conv_1_bram0_full||!conv_1_bram1_full);
    
    //assign current_transferbyte = (write_en) ? bias_or_weight_transferbyte- test : 0;
    assign current_transferbyte =  bias_or_weight_transferbyte- test;
    
    assign bias_write_en =(c_state == bias && !bias_bram_full && bias_control !=  1)? write_en : 0;
    
    assign bram0_en = (one_conv_c_state == weight1 & !conv_1_bram0_full & !pushflag)? write_en:0;
    assign bram1_en = (one_conv_c_state == weight1 & !conv_1_bram1_full &pushflag)? write_en:0;
    
    assign weight0_write_en=(bram_reg ==0 && c_state ==weight && !weight0_bram_full)?write_en:0;
    assign weight1_write_en=(bram_reg ==1 && c_state ==weight && !weight1_bram_full)?write_en:0;
    assign weight2_write_en=(bram_reg ==2 && c_state ==weight && !weight2_bram_full)?write_en:0;
    assign weight3_write_en=(bram_reg ==3 && c_state ==weight && !weight3_bram_full)?write_en:0;
    assign weight4_write_en=(bram_reg ==4 && c_state ==weight && !weight4_bram_full)?write_en:0;
    assign weight5_write_en=(bram_reg ==5 && c_state ==weight && !weight5_bram_full)?write_en:0;
    assign weight6_write_en=(bram_reg ==6 && c_state ==weight && !weight6_bram_full)?write_en:0;
    assign weight7_write_en=(bram_reg ==7 && c_state ==weight && !weight7_bram_full)?write_en:0;
    assign weight8_write_en=(bram_reg ==8 && c_state ==weight && !weight8_bram_full)?write_en:0;
    assign weight9_write_en=(bram_reg ==9 && c_state ==weight && !weight9_bram_full)?write_en:0;
    assign weight10_write_en=(bram_reg ==10 && c_state ==weight && !weight10_bram_full)?write_en:0;
    assign weight11_write_en=(bram_reg ==11 && c_state ==weight && !weight11_bram_full)?write_en:0;
    assign weight12_write_en=(bram_reg ==12 && c_state ==weight && !weight12_bram_full)?write_en:0;
    assign weight13_write_en=(bram_reg ==13 && c_state ==weight && !weight13_bram_full)?write_en:0;
    assign weight14_write_en=(bram_reg ==14 && c_state ==weight && !weight14_bram_full)?write_en:0;
    assign weight15_write_en=(bram_reg ==15 && c_state ==weight && !weight15_bram_full)?write_en:0;
    
    assign bias_din =(c_state == bias && !bias_bram_full)?din:0;
    
    assign bram0_din = (one_conv_c_state == weight1 & !conv_1_bram0_full)?din:0;
    assign bram1_din = (one_conv_c_state == weight1 & !conv_1_bram1_full)?din:0;
    
    assign weight0_din = (bram_reg ==0 && c_state ==weight && !weight0_bram_full)?din:0;
    assign weight1_din = (bram_reg ==1 && c_state ==weight && !weight1_bram_full)?din:0;
    assign weight2_din = (bram_reg ==2 && c_state ==weight && !weight2_bram_full)?din:0;
    assign weight3_din = (bram_reg ==3 && c_state ==weight && !weight3_bram_full)?din:0;
    assign weight4_din = (bram_reg ==4 && c_state ==weight && !weight4_bram_full)?din:0;
    assign weight5_din = (bram_reg ==5 && c_state ==weight && !weight5_bram_full)?din:0;
    assign weight6_din = (bram_reg ==6 && c_state ==weight && !weight6_bram_full)?din:0;
    assign weight7_din = (bram_reg ==7 && c_state ==weight && !weight7_bram_full)?din:0;
    assign weight8_din = (bram_reg ==8 && c_state ==weight && !weight8_bram_full)?din:0;
    assign weight9_din = (bram_reg ==9 && c_state ==weight && !weight9_bram_full)?din:0;
    assign weight10_din = (bram_reg ==10 && c_state ==weight && !weight10_bram_full)?din:0;
    assign weight11_din = (bram_reg ==11 && c_state ==weight && !weight11_bram_full)?din:0;
    assign weight12_din = (bram_reg ==12 && c_state ==weight && !weight12_bram_full)?din:0;
    assign weight13_din = (bram_reg ==13 && c_state ==weight && !weight13_bram_full)?din:0;
    assign weight14_din = (bram_reg ==14 && c_state ==weight && !weight14_bram_full)?din:0;
    assign weight15_din = (bram_reg ==15 && c_state ==weight && !weight15_bram_full)?din:0;

    
    always@(posedge clk)begin
        if(!rst_n || ap_done)begin
            transfer_calc <= 'd0;
            cnt <= 'd0;
            bram_reg<=0;
            test <=0;
        end else begin
            if(!is_bias)begin
                transfer_calc <= bram_weight_num;
                if(transfer_calc != bram_weight_num)begin
                    cnt <= cnt +'d1;
                    test <= (cnt +'d1)*1440;
                end
                bram_reg <= bram_weight_num;
            end
        end
    end
    

    
    always@(posedge clk)begin
        if(!rst_n)begin
            bias_control <= 0;
        end else begin
            if(ap_done)bias_control <= 0;
            else if(c_state == bias && bias_bram_full) bias_control <= 1;
        end
    end
    

    //assign bram_reg = bram_weight_num;
    always@(*)begin
        n_state=c_state;
        case(c_state)
            idle :if(is_bias)n_state = 1;
            bias :begin 
                    if(bias_bram_full & convolution_3)n_state =2;
                    else if(ap_done)n_state=0;
            end
            pre :if(bias_valid && m_axi_ARADDR != 0) n_state=3;
            weight :if(ap_done)n_state=0;
        endcase
    end
    
    //1x1 weight

    always@(posedge clk)begin
        if(!rst_n)begin
            one_conv_c_state <= 0;
        end else begin
            one_conv_c_state <= one_conv_n_state;
        end
    end
    
    always@(*)begin
        one_conv_n_state = one_conv_c_state;
        case(one_conv_c_state)
            idle:begin
                if(bias_bram_full & convolution_1)one_conv_n_state = weight1;
            end
            weight1:begin
                if(ap_done)one_conv_n_state = idle;
            end
        endcase
    end
    
    
    //end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            weight0_transferbyte <= 0;
            weight1_transferbyte <= 0;
            weight2_transferbyte <= 0;
            weight3_transferbyte <= 0;
            weight4_transferbyte <= 0;
            weight5_transferbyte <= 0;
            weight6_transferbyte <= 0;
            weight7_transferbyte <= 0;
            weight8_transferbyte <= 0;
            weight9_transferbyte <= 0;
            weight10_transferbyte <= 0;
            weight11_transferbyte <= 0;
            weight12_transferbyte <= 0;
            weight13_transferbyte <= 0;
            weight14_transferbyte <= 0;
            weight15_transferbyte <= 0;
            bias_transferbyte <= 0;
            c_state <= 0;
        end else begin
            c_state <= n_state;
            case(n_state)
                idle :begin


                    weight_transferbyte <= 'd0;
                    
                    bias_transferbyte <= bias_transferbyte;
                    
                    weight0_transferbyte <= weight0_transferbyte;
                    weight1_transferbyte <= weight1_transferbyte;
                    weight2_transferbyte <= weight2_transferbyte;
                    weight3_transferbyte <= weight3_transferbyte;
                    weight4_transferbyte <= weight4_transferbyte;
                    weight5_transferbyte <= weight5_transferbyte;
                    weight6_transferbyte <= weight6_transferbyte;
                    weight7_transferbyte <= weight7_transferbyte;
                    weight8_transferbyte <= weight8_transferbyte;
                    weight9_transferbyte <= weight9_transferbyte;
                    weight10_transferbyte <= weight10_transferbyte;
                    weight11_transferbyte <= weight11_transferbyte;
                    weight12_transferbyte <= weight12_transferbyte;
                    weight13_transferbyte <= weight13_transferbyte;
                    weight14_transferbyte <= weight14_transferbyte;
                    weight15_transferbyte <= weight15_transferbyte;
                end
                bias:begin
                    if(!bias_bram_full)bias_transferbyte <= bias_or_weight_transferbyte;
                    
                    weight_transferbyte <= 'd0;
                    weight0_transferbyte <= weight0_transferbyte;
                    weight1_transferbyte <= weight1_transferbyte;
                    weight2_transferbyte <= weight2_transferbyte;
                    weight3_transferbyte <= weight3_transferbyte;
                    weight4_transferbyte <= weight4_transferbyte;
                    weight5_transferbyte <= weight5_transferbyte;
                    weight6_transferbyte <= weight6_transferbyte;
                    weight7_transferbyte <= weight7_transferbyte;
                    weight8_transferbyte <= weight8_transferbyte;
                    weight9_transferbyte <= weight9_transferbyte;
                    weight10_transferbyte <= weight10_transferbyte;
                    weight11_transferbyte <= weight11_transferbyte;
                    weight12_transferbyte <= weight12_transferbyte;
                    weight13_transferbyte <= weight13_transferbyte;
                    weight14_transferbyte <= weight14_transferbyte;
                    weight15_transferbyte <= weight15_transferbyte;
                end
                pre:begin
                    bias_transferbyte <= bias_transferbyte;
                    
                    weight_transferbyte <= 'd0;
                    
                    weight0_transferbyte <= weight0_transferbyte;
                    weight1_transferbyte <= weight1_transferbyte;
                    weight2_transferbyte <= weight2_transferbyte;
                    weight3_transferbyte <= weight3_transferbyte;
                    weight4_transferbyte <= weight4_transferbyte;
                    weight5_transferbyte <= weight5_transferbyte;
                    weight6_transferbyte <= weight6_transferbyte;
                    weight7_transferbyte <= weight7_transferbyte;
                    weight8_transferbyte <= weight8_transferbyte;
                    weight9_transferbyte <= weight9_transferbyte;
                    weight10_transferbyte <= weight10_transferbyte;
                    weight11_transferbyte <= weight11_transferbyte;
                    weight12_transferbyte <= weight12_transferbyte;
                    weight13_transferbyte <= weight13_transferbyte;
                    weight14_transferbyte <= weight14_transferbyte;
                    weight15_transferbyte <= weight15_transferbyte;
                end
                weight:begin
                    bias_transferbyte = bias_transferbyte;
                    
                    if( 1440>= current_transferbyte)begin
                        weight_transferbyte <= current_transferbyte;//208*208*32 >>208*208*64 = 9*64*32*2
                    end else begin
                        weight_transferbyte <= 'd1440;
                    end
                    
                    case(bram_weight_num)
                        0:begin
                            if(weight0_bram_full)begin
                                weight0_transferbyte <= weight0_transferbyte;
                            end else begin
                                weight0_transferbyte <= weight_transferbyte;
                            end
                        end
                        1:begin
                            if(weight1_bram_full)begin
                                weight1_transferbyte <= weight1_transferbyte;
                            end else begin
                                weight1_transferbyte <= weight_transferbyte;
                            end
                        end
                        2:begin
                            if(weight2_bram_full)begin
                                weight2_transferbyte <= weight2_transferbyte;
                            end else begin
                                weight2_transferbyte <= weight_transferbyte;
                            end
                        end
                        3:begin
                            if(weight3_bram_full)begin
                                weight3_transferbyte <= weight3_transferbyte;
                            end else begin
                                weight3_transferbyte <= weight_transferbyte;
                            end
                        end
                        4:begin
                            if(weight4_bram_full)begin
                                weight4_transferbyte <= weight4_transferbyte;
                            end else begin
                                weight4_transferbyte <= weight_transferbyte;
                            end
                        end
                        5:begin
                            if(weight5_bram_full)begin
                                weight5_transferbyte <= weight5_transferbyte;
                            end else begin
                                weight5_transferbyte <= weight_transferbyte;
                            end
                        end
                        6:begin
                            if(weight6_bram_full)begin
                                weight6_transferbyte <= weight6_transferbyte;
                            end else begin
                                weight6_transferbyte <= weight_transferbyte;
                            end
                        end
                        7:begin
                            if(weight7_bram_full)begin
                                weight7_transferbyte <= weight7_transferbyte;
                            end else begin
                                weight7_transferbyte <= weight_transferbyte;
                            end
                        end
                        8:begin
                            if(weight8_bram_full)begin
                                weight8_transferbyte <= weight8_transferbyte;
                            end else begin
                                weight8_transferbyte <= weight_transferbyte;
                            end
                        end
                        9:begin
                            if(weight9_bram_full)begin
                                weight9_transferbyte <= weight9_transferbyte;
                            end else begin
                                weight9_transferbyte <= weight_transferbyte;
                            end
                        end
                        10:begin
                            if(weight10_bram_full)begin
                                weight10_transferbyte <= weight10_transferbyte;
                            end else begin
                                weight10_transferbyte <= weight_transferbyte;
                            end
                        end
                        11:begin
                            if(weight11_bram_full)begin
                                weight11_transferbyte <= weight11_transferbyte;
                            end else begin
                                weight11_transferbyte <= weight_transferbyte;
                            end
                        end
                        12:begin
                            if(weight12_bram_full)begin
                                weight12_transferbyte <= weight12_transferbyte;
                            end else begin
                                weight12_transferbyte <= weight_transferbyte;
                            end
                        end
                        13:begin
                            if(weight13_bram_full)begin
                                weight13_transferbyte <= weight13_transferbyte;
                            end else begin
                                weight13_transferbyte <= weight_transferbyte;
                            end
                        end
                        14:begin
                            if(weight14_bram_full)begin
                                weight14_transferbyte <= weight14_transferbyte;
                            end else begin
                                weight14_transferbyte <= weight_transferbyte;
                            end
                        end
                        15:begin
                            if(weight15_bram_full)begin
                                weight15_transferbyte <= weight15_transferbyte;
                            end else begin
                                weight15_transferbyte <= weight_transferbyte;
                            end
                        end
                    endcase
                end
            endcase
        end
    end
    
    always@(*)begin
            bram_weight_num=bram_reg;
            case(bram_reg)
                'd0:begin
                        if(weight0_transferbyte == 1440 && weight0_bram_full && !weight1_bram_full)begin bram_weight_num = 'd1; end
                    end
                'd1:begin
                        if(weight1_transferbyte == 1440 && weight1_bram_full && !weight2_bram_full)begin bram_weight_num = 'd2; end
                    end
                'd2:begin
                        if(weight2_transferbyte == 1440 && weight2_bram_full && !weight3_bram_full)begin bram_weight_num = 'd3; end
                    end
                'd3:begin
                        if(weight3_transferbyte == 1440 && weight3_bram_full && !weight4_bram_full)begin bram_weight_num = 'd4; end
                    end    
                'd4:begin
                        if(weight4_transferbyte == 1440 && weight4_bram_full && !weight5_bram_full)begin bram_weight_num = 'd5;end
                    end
                'd5:begin
                        if(weight5_transferbyte == 1440 && weight5_bram_full && !weight6_bram_full)begin bram_weight_num = 'd6;end
                    end
                'd6:begin
                        if(weight6_transferbyte == 1440 && weight6_bram_full && !weight7_bram_full)begin bram_weight_num = 'd7; end
                    end
                'd7:begin
                        if(weight7_transferbyte == 1440 && weight7_bram_full && !weight8_bram_full)begin bram_weight_num = 'd8; end
                    end
                'd8:begin
                        if(weight8_transferbyte == 1440 && weight8_bram_full && !weight9_bram_full)begin bram_weight_num = 'd9; end
                    end
                'd9:begin
                        if(weight9_transferbyte == 1440 && weight9_bram_full && !weight10_bram_full)begin bram_weight_num = 'd10;end
                    end
                'd10:begin
                        if(weight10_transferbyte == 1440 && weight10_bram_full && !weight11_bram_full)begin bram_weight_num = 'd11;end
                    end
                'd11:begin
                        if(weight11_transferbyte == 1440 && weight11_bram_full && !weight12_bram_full)begin bram_weight_num = 'd12;end
                    end
                'd12:begin
                        if(weight12_transferbyte == 1440 && weight12_bram_full && !weight13_bram_full)begin bram_weight_num = 'd13; end
                    end
                'd13:begin
                        if(weight13_transferbyte == 1440 && weight13_bram_full && !weight14_bram_full)begin bram_weight_num = 'd14; end
                    end
                'd14:begin
                        if(weight14_transferbyte == 1440 && weight14_bram_full && !weight15_bram_full)begin bram_weight_num = 'd15; end
                    end
                'd15:begin
                        if(weight15_transferbyte == 1440 && weight15_bram_full && !weight0_bram_full)begin bram_weight_num = 'd0; end
                    end
            endcase
       
    end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            buf_pushflag <=0;
        end else begin
            buf_pushflag <=pushflag;
        end
    end
    
    always@(*)begin
        pushflag = buf_pushflag;
        case(buf_pushflag)
            0:if(conv_1_bram0_full & !conv_1_bram1_full) pushflag =1;
            1:if(conv_1_bram1_full & !conv_1_bram0_full) pushflag =0;
        endcase
    end
    
bias_bram_controller Bias_BRAM (
    .clk(clk),
    .rst_n(rst_n),
    .din(bias_din),
    .write_en(bias_write_en),
    .full_n(bias_full_n), // out_r_full_n rdma rready
    .dout(bias_reg_din),
    .read_en(bias_reg_read_en),
    .transfer_byte(bias_transferbyte),
    .full(bias_bram_full)
);
//1x1
conv_1_weight_bram_controller Conv_1_BRAM_0(
    .clk(clk),
    .rst_n(rst_n),
    .bram_en(bram0_en),
    .din(bram0_din),
    .conv_1_bram_valid(conv_1_bram0_valid),
    .dout(conv_1_bram0_data),
    .bram_full(conv_1_bram0_full),
    .ifm_channel(ifm_channel),
    .ifm_width(total_ifm)
    );

conv_1_weight_bram_controller Conv_1_BRAM_1(
    .clk(clk),
    .rst_n(rst_n),
    .bram_en(bram1_en),
    .din(bram1_din),
    .conv_1_bram_valid(conv_1_bram1_valid),
    .dout(conv_1_bram1_data),
    .bram_full(conv_1_bram1_full),
    .ifm_channel(ifm_channel),
    .ifm_width(total_ifm)
    );
//end
weight_bram_controller Weight_BRAM_0(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight0_din),
    .write_en(weight0_write_en),
    .full_n(weight0_full_n), // out_r_full_n rdma rready
    .dout(weight0_reg_din),
    .read_en(weight0_reg_read_en),
    .transfer_byte(weight0_transferbyte),
    .full(weight0_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next0),
    .remain(remain0)
);

weight_bram_controller Weight_BRAM_1(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight1_din),
    .write_en(weight1_write_en),
    .full_n(weight1_full_n), // out_r_full_n rdma rready
    .dout(weight1_reg_din),
    .read_en(weight1_reg_read_en),
    .transfer_byte(weight1_transferbyte),
    .full(weight1_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next1),
    .remain(remain1)
);

weight_bram_controller Weight_BRAM_2(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight2_din),
    .write_en(weight2_write_en),
    .full_n(weight2_full_n), // out_r_full_n rdma rready
    .dout(weight2_reg_din),
    .read_en(weight2_reg_read_en),
    .transfer_byte(weight2_transferbyte),
    .full(weight2_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next2),
    .remain(remain2)
);

weight_bram_controller Weight_BRAM_3(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight3_din),
    .write_en(weight3_write_en),
    .full_n(weight3_full_n), // out_r_full_n rdma rready
    .dout(weight3_reg_din),
    .read_en(weight3_reg_read_en),
    .transfer_byte(weight3_transferbyte),
    .full(weight3_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next3),
    .remain(remain3)
);

weight_bram_controller Weight_BRAM_4(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight4_din),
    .write_en(weight4_write_en),
    .full_n(weight4_full_n), // out_r_full_n rdma rready
    .dout(weight4_reg_din),
    .read_en(weight4_reg_read_en),
    .transfer_byte(weight4_transferbyte),
    .full(weight4_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next4),
    .remain(remain4)
);

weight_bram_controller Weight_BRAM_5(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight5_din),
    .write_en(weight5_write_en),
    .full_n(weight5_full_n), // out_r_full_n rdma rready
    .dout(weight5_reg_din),
    .read_en(weight5_reg_read_en),
    .transfer_byte(weight5_transferbyte),
    .full(weight5_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next5),
    .remain(remain5)
);

weight_bram_controller Weight_BRAM_6(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight6_din),
    .write_en(weight6_write_en),
    .full_n(weight6_full_n), // out_r_full_n rdma rready
    .dout(weight6_reg_din),
    .read_en(weight6_reg_read_en),
    .transfer_byte(weight6_transferbyte),
    .full(weight6_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next6),
    .remain(remain6)
);

weight_bram_controller Weight_BRAM_7(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight7_din),
    .write_en(weight7_write_en),
    .full_n(weight7_full_n), // out_r_full_n rdma rready
    .dout(weight7_reg_din),
    .read_en(weight7_reg_read_en),
    .transfer_byte(weight7_transferbyte),
    .full(weight7_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next7),
    .remain(remain7)
);

weight_bram_controller Weight_BRAM_8(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight8_din),
    .write_en(weight8_write_en),
    .full_n(weight8_full_n), // out_r_full_n rdma rready
    .dout(weight8_reg_din),
    .read_en(weight8_reg_read_en),
    .transfer_byte(weight8_transferbyte),
    .full(weight8_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next8),
    .remain(remain8)
);

weight_bram_controller Weight_BRAM_9(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight9_din),
    .write_en(weight9_write_en),
    .full_n(weight9_full_n), // out_r_full_n rdma rready
    .dout(weight9_reg_din),
    .read_en(weight9_reg_read_en),
    .transfer_byte(weight9_transferbyte),
    .full(weight9_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next9),
    .remain(remain9)
);

weight_bram_controller Weight_BRAM_10(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight10_din),
    .write_en(weight10_write_en),
    .full_n(weight10_full_n), // out_r_full_n rdma rready
    .dout(weight10_reg_din),
    .read_en(weight10_reg_read_en),
    .transfer_byte(weight10_transferbyte),
    .full(weight10_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next10),
    .remain(remain10)
);

weight_bram_controller Weight_BRAM_11(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight11_din),
    .write_en(weight11_write_en),
    .full_n(weight11_full_n), // out_r_full_n rdma rready
    .dout(weight11_reg_din),
    .read_en(weight11_reg_read_en),
    .transfer_byte(weight11_transferbyte),
    .full(weight11_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next11),
    .remain(remain11)
);

weight_bram_controller Weight_BRAM_12(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight12_din),
    .write_en(weight12_write_en),
    .full_n(weight12_full_n), // out_r_full_n rdma rready
    .dout(weight12_reg_din),
    .read_en(weight12_reg_read_en),
    .transfer_byte(weight12_transferbyte),
    .full(weight12_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next12),
    .remain(remain12)
);

weight_bram_controller Weight_BRAM_13(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight13_din),
    .write_en(weight13_write_en),
    .full_n(weight13_full_n), // out_r_full_n rdma rready
    .dout(weight13_reg_din),
    .read_en(weight13_reg_read_en),
    .transfer_byte(weight13_transferbyte),
    .full(weight13_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next13),
    .remain(remain13)
);

weight_bram_controller Weight_BRAM_14(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight14_din),
    .write_en(weight14_write_en),
    .full_n(weight14_full_n), // out_r_full_n rdma rready
    .dout(weight14_reg_din),
    .read_en(weight14_reg_read_en),
    .transfer_byte(weight14_transferbyte),
    .full(weight14_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next14),
    .remain(remain14)
);

weight_bram_controller Weight_BRAM_15(
    .clk(clk),
    .rst_n(rst_n),
    .din(weight15_din),
    .write_en(weight15_write_en),
    .full_n(weight15_full_n), // out_r_full_n rdma rready
    .dout(weight15_reg_din),
    .read_en(weight15_reg_read_en),
    .transfer_byte(weight15_transferbyte),
    .full(weight15_bram_full),
    .total_ifm(total_ifm),
    .con_ifm_channel(con_ifm_channel),
    .out_next(out_next15),
    .remain(remain15)
);

endmodule
