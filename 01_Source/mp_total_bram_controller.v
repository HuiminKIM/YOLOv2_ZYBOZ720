`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/19 11:11:19
// Design Name: 
// Module Name: mp_total_bram_controller
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


module mp_total_bram_controller(
    input clk,
    input rst_n,
    input [8:0]ifm_width,
    input din_valid,
    input din_next_valid,
    input [63:0] din,
    output din_full,
    output din_next_full,
    input dout_valid,
    input dout_valid_next,
    output [31:0] dout,
    output [31:0] dout_next,
    output dout_full,
    output next_bram,
    output next_bram_next
    );
    
    wire [31:0] din_bram = din[31:0];
    wire [31:0] din_bram_next = din[63:32];
    
    wire din_bram_full;
    wire din_bram_next_full;
    
    assign din_full = din_bram_full;
    assign din_next_full = din_bram_next_full;
    
    wire dout_bram_full;
    wire dout_bram_next_full;
    
    assign dout_full = dout_bram_full & dout_bram_next_full;
    
 mp_bram_controller MP_BRAM_Controller(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_valid(din_valid),
    .din(din_bram),
    .din_full(din_bram_full),
    .dout_valid(dout_valid),
    .dout(dout),
    .dout_full(dout_bram_full),
    .next(next_bram)
    );
    
 mp_next_bram_controller MP_BRAM_Controller_Next(
    .clk(clk),
    .rst_n(rst_n),
    .ifm_width(ifm_width),
    .din_valid(din_next_valid),
    .din(din_bram_next),
    .din_full(din_bram_next_full),
    .dout_valid(dout_valid_next),
    .dout(dout_next),
    .dout_full(dout_bram_next_full),
    .next(next_bram_next)
    );
    
endmodule
