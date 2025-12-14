
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2024 09:06:12 PM
// Design Name: 
// Module Name: weight_bram_controller
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


module weight_bram_controller
#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64,
    parameter para_addr_save = 1,
    parameter bram_num = 0
)
(   
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] din,
    input  wire        write_en,
    output wire        full_n, // out_r_full_n rdma rready
    output reg [63:0]  dout,
    input  wire        read_en,
    input  wire [10:0] transfer_byte,
    output             full,
    input  wire [8:0] total_ifm,
    input  wire [10:0] con_ifm_channel,
    output wire        out_next,
    output reg  [1:0]  remain
    );

localparam DEPTH = (1 << ADDR_WIDTH)-1;
reg [ADDR_WIDTH:0]   w_data_count = 0;  // Only assigned in the always block
reg [ADDR_WIDTH:0]   d_cnt = 0;
reg [ADDR_WIDTH:0]   r_cnt = 0;
reg [31:0]           c_cnt = 0;
reg [1:0]            r_c_cnt;

reg [ADDR_WIDTH-1:0] addr_save;

reg [1:0] start_remain;

reg [10:0] w_transfer_byte = 0;
wire wea;

reg [ADDR_WIDTH-1:0] addra; 
reg [DATA_WIDTH-1:0] dina; 
wire [DATA_WIDTH-1:0] douta;
reg finish;

reg [31:0] c_cnt_finish;

reg [15:0] buf_cnt_finish0;
reg [15:0] buf_cnt_finish1;
reg [31:0] buf_cnt_finish2;
wire done;


assign wea = !finish&&write_en? 'b1: 'b0;

assign full_n = (!finish);

assign full = finish;

assign done = (c_cnt == c_cnt_finish && d_cnt == w_transfer_byte -1 && read_en ); //d_cnt == w_transferbyte - 1 && c_cnt == c_cnt_finish

assign out_next = (finish && read_en && c_cnt_finish !=0 && r_c_cnt ==2 &&(r_cnt == 79 || d_cnt == 179))? 1 : 0;
//write to BRAM
always@(posedge clk)begin
    if(!rst_n)begin
        w_data_count <= 0;
        r_cnt <= 0;
        r_c_cnt <= 0;
        d_cnt <= 0;
        w_transfer_byte <= 0;
        buf_cnt_finish0 <= 0;
        buf_cnt_finish1 <= 0;
        buf_cnt_finish2 <= 0;
        c_cnt_finish <= 0;
        addr_save <= 0;
        remain<=0;
        start_remain<=0;
        c_cnt<=0;
        finish<=0;
    end else if(done)begin
        w_data_count <= 0;
        r_cnt <= 0;
        r_c_cnt <= 0;
        d_cnt <= 0;
        w_transfer_byte <= 0;
        buf_cnt_finish0 <= 0;
        buf_cnt_finish1 <= 0;
        buf_cnt_finish2 <= 0;
        c_cnt_finish <= 0;
        addr_save <= 0;
        remain<=0;
        start_remain<=0;
        c_cnt<=0;
        finish<=0;
    end else begin
        if (write_en && !finish)begin
            w_data_count <= w_data_count + 'b1;
            w_transfer_byte <= w_transfer_byte + 1;
        end
        
        if((transfer_byte != 0) & ((transfer_byte >> 3)== w_transfer_byte +1) &write_en) finish <= 1;
        
        case(total_ifm)
                418: c_cnt_finish <= 13311;
                210: c_cnt_finish <= 3327;
                106: c_cnt_finish <= 831;
                54: c_cnt_finish <= 207;
                28: c_cnt_finish <= 51;
                15: c_cnt_finish <= 12;
                default: c_cnt_finish <= 0;
            endcase
    //define read_en state
    
        if(finish && read_en && c_cnt_finish !=0)begin
            if(r_c_cnt ==2)begin
                if((r_cnt == 79 || d_cnt == 179) && c_cnt !=  c_cnt_finish)begin //r_cnt == 79???
                    r_cnt <= 0;
                    c_cnt <= c_cnt+1;
                end else if(r_cnt != 79 && r_cnt >= con_ifm_channel -1 )begin
                    if(c_cnt == c_cnt_finish ) begin
                        r_cnt <= 0;
                        c_cnt <= 0 ;
                        start_remain <= remain-1;
                        if(remain == 1) begin addr_save <= d_cnt+1; end
                        else begin addr_save <= d_cnt; end
                    end else begin
                        r_cnt <= 0;
                        c_cnt <= c_cnt+1;
                    end
                end else begin
                     r_cnt <= r_cnt + 1;
                end
                r_c_cnt<=0;
            end else begin
                r_c_cnt<=r_c_cnt+1;
            end
        end
        if(finish && read_en && c_cnt_finish !=0)begin
            if(r_c_cnt ==2)begin
                if((r_cnt == 79 || d_cnt == 179) && c_cnt !=  c_cnt_finish)begin
                    remain <= start_remain;
                    d_cnt <= addr_save;
                end else if(r_cnt != 79 && r_cnt >= con_ifm_channel -1 )begin
                    if(c_cnt == c_cnt_finish ) begin
                        remain <= remain-1; 
                        if(remain == 1) d_cnt<= d_cnt+1;
                    end else begin
                        remain <= start_remain;
                        d_cnt <= addr_save;
                    end
                end else begin
                    remain <= remain -1;
                    if(remain == 1) d_cnt <= d_cnt + 1;
                end
            end else if(( r_cnt != 79  || (r_cnt ==79 && r_c_cnt !=2)) && d_cnt!= 179 )begin
                case(remain)
                    0:begin
                      if(r_c_cnt !=2 && d_cnt != 179)d_cnt <= d_cnt + 1;
                      else if(r_cnt != con_ifm_channel -1) remain <= 3;
                      end
                     3:begin
                      if(r_c_cnt !=2 && d_cnt != 179)d_cnt <= d_cnt + 1;
                      else if(r_cnt != con_ifm_channel -1) remain <= 2;
                      end
                     2:begin
                      if(r_c_cnt !=2 && d_cnt != 179)d_cnt <= d_cnt + 1;
                      else if(r_cnt != con_ifm_channel -1) remain <= 1;
                      end
                     1:begin
                      if(r_c_cnt !=2 && d_cnt != 179)d_cnt <= d_cnt + 1;
                      else if(r_cnt != con_ifm_channel -1) begin remain <= 0; d_cnt <= d_cnt + 1; end
                      end
                endcase
            end
        end
    end
end

always@(*)begin
    if(write_en && !finish) begin
        addra = w_data_count;
        dina = din;
        dout = douta;
    end else if(read_en && finish)begin
        addra = d_cnt;
        dout = douta;
        dina = 0;
    end else begin
        addra = 0;
        dina = 0;
        dout = douta;
    end
end

    true_sync_dpbram  #(
    .DWIDTH (64),
    .MEM_SIZE (180)
    )
    BRAM_weight(
    .clk(clk),
    .addr(addra),
    .ce('b1),
    .we(wea),
    .dout(douta),
    .din(dina)
    );

endmodule
