`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/16 19:33:05
// Design Name: 
// Module Name: HP_2_bram_controller
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


module HP_2_bram_controller(
    input clk,
    input rst_n,
    input din_valid,
    input [3:0] din_cnt,
    input [63:0] din,
    output din_full,
    input dout_valid,
    output [63:0] dout,
    output dout_full,
    output next
    );
    reg [3:0] r_cnt;
    reg [3:0] w_cnt;
    reg [3:0] save_din_cnt;
    wire [3:0] addr = (!din_full)? r_cnt : w_cnt;
    reg buf_din_full;
    wire r_hs = (!din_full) & din_valid;
    wire [3:0] r_finsih_cnt = save_din_cnt;
    
    conv_bram conv_bram(
    .addra(addr),  // Port A address bus, width determined from RAM_DEPTH
    .dina(din),    // Port A RAM input data
    .clka(clk),    // Clock
    .wea(r_hs),    // Port A write enable
    .ena('b1),     // Port A RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_n),  // Port A output reset (does not affect memory contents)
    .regcea('b0),  // Port A output register enable
    .douta(dout)   // Port A RAM output data
    );
    
    reg is_next;

    assign din_full = (r_cnt == r_finsih_cnt) & (r_cnt != w_cnt);
    assign next = (is_next & din_valid);
    assign dout_full = buf_din_full;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            is_next <=0;
            r_cnt <= 0;
            w_cnt <= 0;
            buf_din_full <= 0;
            save_din_cnt<= 4;
        end else begin
            if((r_cnt != 0 & r_cnt == save_din_cnt-2) & din_valid )is_next <= 1;
            else if(din_valid) is_next <=0; // if(din_valid)
            if(din_full & dout_valid) buf_din_full <= din_full;
            else buf_din_full<=0;
            if( dout_valid & din_full & r_cnt-1 == w_cnt )begin
                r_cnt <= 0;
                w_cnt <= 0;
            end else if(din_valid & !din_full)begin
                r_cnt <= r_cnt + 1;
                save_din_cnt <= din_cnt;
            end else if(din_full & dout_valid)begin
                w_cnt <= w_cnt + 1;
            end
        end
    end
    
endmodule
